import 'dart:async';
import 'dart:io';

import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/domain/entities/download_task.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/library/local_resource_index_repository.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

class DownloadRepository {
  static Future<void> _downloadQueue = Future.value();
  static final Map<String, Future<Track?>> _scheduledDownloads = {};
  static final Map<String, CancelToken> _activeCancelTokens = {};
  static final Set<String> _cancelledTrackIds = <String>{};

  DownloadRepository({
    LibraryRepository? libraryRepository,
    DownloadTaskDataSource? taskDataSource,
    LocalResourceIndexRepository? resourceIndexRepository,
    Dio? dio,
  })  : _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository()),
        _taskDataSource = taskDataSource ??
            (GetIt.instance.isRegistered<DownloadTaskDataSource>()
                ? GetIt.instance<DownloadTaskDataSource>()
                : (throw StateError(
                    'DownloadTaskDataSource is not registered',
                  ))),
        _resourceIndexRepository =
            resourceIndexRepository ?? LocalResourceIndexRepository(),
        _dio = dio ?? Dio();

  final LibraryRepository _libraryRepository;
  final DownloadTaskDataSource _taskDataSource;
  final LocalResourceIndexRepository _resourceIndexRepository;
  final Dio _dio;

  /// 下载任务不会做断点续传；应用异常退出后仍保留 `queued/downloading`
  /// 只会制造假状态，所以启动时要先把这些任务收敛成可见失败态。
  Future<List<DownloadTask>> recoverInterruptedTasks() async {
    final interruptedTasks = await getTasks(
      statuses: const {
        DownloadTaskStatus.queued,
        DownloadTaskStatus.downloading,
      },
    );
    for (final task in interruptedTasks) {
      await _deleteTemporaryDownloadIfExists(task.localPath);
      await markFailed(task.trackId, reason: 'download_interrupted');
    }
    return getTasks(
      statuses: const {
        DownloadTaskStatus.failed,
      },
    );
  }

  /// 下载流程必须以最终文件落地为准，而不是只改状态；
  /// 否则离线播放链路会继续停留在“看起来已下载，实际上没有本地资源”的假状态。
  Future<Track?> downloadTrack(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    _cancelledTrackIds.remove(trackId);
    final existingTask = _scheduledDownloads[trackId];
    if (existingTask != null) {
      return existingTask;
    }
    await markQueued(trackId);

    final taskFuture = _enqueueDownload(
      () => _performDownloadTrack(
        trackId,
        preferHighQuality: preferHighQuality,
      ),
    );
    _scheduledDownloads[trackId] = taskFuture;
    taskFuture.whenComplete(() {
      _scheduledDownloads.remove(trackId);
    });
    return taskFuture;
  }

  Future<void> queueTracks(
    Iterable<String> trackIds, {
    bool preferHighQuality = true,
  }) async {
    for (final trackId in trackIds.toSet()) {
      unawaited(
        downloadTrack(
          trackId,
          preferHighQuality: preferHighQuality,
        ),
      );
    }
  }

  Future<Track?> _performDownloadTrack(
    String trackId, {
    required bool preferHighQuality,
  }) async {
    if (_cancelledTrackIds.contains(trackId)) {
      await _clearCancelledTask(trackId);
      return null;
    }
    final track = await _libraryRepository.getTrack(trackId);
    if (track == null) {
      await markFailed(trackId, reason: 'track_not_found');
      return null;
    }

    if (track.localPath?.isNotEmpty == true &&
        File(track.localPath!).existsSync()) {
      return markDownloaded(
        trackId,
        localPath: track.localPath!,
        artworkPath: track.localArtworkPath,
        lyricsPath: track.localLyricsPath,
      );
    }

    if (_cancelledTrackIds.contains(trackId)) {
      await _clearCancelledTask(trackId);
      return null;
    }

    try {
      final playbackUrl = await _libraryRepository.getPlaybackUrlWithQuality(
        trackId,
        qualityLevel: preferHighQuality ? 'lossless' : 'exhigh',
      );
      if (playbackUrl == null || playbackUrl.isEmpty) {
        return markFailed(trackId, reason: 'playback_url_unavailable');
      }

      final rootDirectory = await _ensureDownloadRootDirectory();
      final audioDirectory = await _ensureChildDirectory(rootDirectory, 'audio');
      final artworkDirectory =
          await _ensureChildDirectory(rootDirectory, 'artwork');
      final lyricsDirectory =
          await _ensureChildDirectory(rootDirectory, 'lyrics');
      final cancelToken = CancelToken();
      _activeCancelTokens[trackId] = cancelToken;

      final audioPath = _buildAudioPath(track, playbackUrl, audioDirectory);
      await _downloadBinaryFile(
        playbackUrl,
        audioPath,
        onProgress: (progress) => markDownloading(trackId, progress: progress),
        cancelToken: cancelToken,
      );
      if (_cancelledTrackIds.contains(trackId)) {
        await _deleteTemporaryDownloadIfExists(audioPath);
        await _clearCancelledTask(trackId);
        return null;
      }

      final artworkPath = await _downloadArtworkFile(
        track,
        artworkDirectory,
      );
      final lyricsPath = await _writeLyricsFile(trackId, lyricsDirectory);

      return markDownloaded(
        trackId,
        localPath: audioPath,
        artworkPath: artworkPath,
        lyricsPath: lyricsPath,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        await _clearCancelledTask(trackId);
        return null;
      }
      return markFailed(trackId, reason: error.toString());
    } catch (error) {
      return markFailed(trackId, reason: error.toString());
    } finally {
      _activeCancelTokens.remove(trackId);
    }
  }

  Future<T> _enqueueDownload<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _downloadQueue = _downloadQueue
        .catchError((_) {})
        .then((_) async {
          try {
            completer.complete(await operation());
          } catch (error, stackTrace) {
            completer.completeError(error, stackTrace);
          }
        });
    return completer.future;
  }

  Future<Track?> removeDownloadedTrack(String trackId) async {
    final track = await _libraryRepository.getTrack(trackId);
    if (track == null) {
      await clearTask(trackId);
      return null;
    }

    await _deleteFileIfExists(track.localPath);
    await _deleteFileIfExists(track.localArtworkPath);
    await _deleteFileIfExists(track.localLyricsPath);
    await _resourceIndexRepository.removeTrackResources(trackId);
    await clearTask(trackId);

    return _libraryRepository.updateTrackLocalState(
      trackId,
      localPath: '',
      localArtworkPath: '',
      localLyricsPath: '',
      downloadState: DownloadState.none,
      resourceOrigin: TrackResourceOrigin.none,
      downloadProgress: 0,
      downloadFailureReason: '',
      availability: TrackAvailability.unknown,
    );
  }

  Future<void> cancelTask(String trackId) async {
    _cancelledTrackIds.add(trackId);
    _activeCancelTokens[trackId]?.cancel('download_cancelled');
    final currentTask = await _taskDataSource.getTask(trackId);
    await _deleteTemporaryDownloadIfExists(currentTask?.localPath);
    await _clearCancelledTask(trackId);
  }

  Future<DownloadTask?> getTask(String trackId) {
    return _taskDataSource.getTask(trackId);
  }

  Future<Track?> retryTask(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    final currentTask = await _taskDataSource.getTask(trackId);
    await _deleteTemporaryDownloadIfExists(currentTask?.localPath);
    return downloadTrack(
      trackId,
      preferHighQuality: preferHighQuality,
    );
  }

  Future<List<DownloadTask>> getTasks({
    Set<DownloadTaskStatus>? statuses,
  }) {
    return _taskDataSource.getTasks(statuses: statuses);
  }

  Stream<List<DownloadTask>> watchTasks({
    Set<DownloadTaskStatus>? statuses,
  }) {
    return _taskDataSource.watchTasks(statuses: statuses);
  }

  Future<List<DownloadTask>> getActiveTasks() {
    return getTasks(
      statuses: const {
        DownloadTaskStatus.queued,
        DownloadTaskStatus.downloading,
      },
    );
  }

  Future<void> clearTask(String trackId) {
    return _taskDataSource.removeTask(trackId);
  }

  Future<Track?> markQueued(String trackId) async {
    await _taskDataSource.saveTask(
      DownloadTask(
        trackId: trackId,
        status: DownloadTaskStatus.queued,
        updatedAt: DateTime.now(),
        progress: 0,
      ),
    );
    return _libraryRepository.updateTrackLocalState(
      trackId,
      downloadState: DownloadState.queued,
      resourceOrigin: TrackResourceOrigin.managedDownload,
      downloadProgress: 0,
      downloadFailureReason: '',
    );
  }

  Future<Track?> markDownloading(
    String trackId, {
    double? progress,
  }) async {
    await _taskDataSource.saveTask(
      DownloadTask(
        trackId: trackId,
        status: DownloadTaskStatus.downloading,
        updatedAt: DateTime.now(),
        progress: progress ?? 0,
      ),
    );
    return _libraryRepository.updateTrackLocalState(
      trackId,
      downloadState: DownloadState.downloading,
      resourceOrigin: TrackResourceOrigin.managedDownload,
      downloadProgress: progress ?? 0,
      downloadFailureReason: '',
    );
  }

  Future<Track?> markDownloaded(
    String trackId, {
    required String localPath,
    String? artworkPath,
    String? lyricsPath,
  }) async {
    await _resourceIndexRepository.saveAudioResource(
      trackId,
      path: localPath,
      origin: TrackResourceOrigin.managedDownload,
    );
    if (artworkPath?.isNotEmpty == true) {
      await _resourceIndexRepository.saveArtworkResource(
        trackId,
        path: artworkPath!,
        origin: TrackResourceOrigin.managedDownload,
      );
    }
    if (lyricsPath?.isNotEmpty == true) {
      await _resourceIndexRepository.saveLyricsResource(
        trackId,
        path: lyricsPath!,
        origin: TrackResourceOrigin.managedDownload,
      );
    }
    await _taskDataSource.saveTask(
      DownloadTask(
        trackId: trackId,
        status: DownloadTaskStatus.completed,
        updatedAt: DateTime.now(),
        progress: 1,
        localPath: localPath,
        artworkPath: artworkPath,
        lyricsPath: lyricsPath,
      ),
    );
    return _libraryRepository.updateTrackLocalState(
      trackId,
      localPath: localPath,
      localArtworkPath: artworkPath,
      localLyricsPath: lyricsPath,
      downloadState: DownloadState.downloaded,
      resourceOrigin: TrackResourceOrigin.managedDownload,
      downloadProgress: 1,
      downloadFailureReason: '',
      availability: TrackAvailability.playable,
    );
  }

  Future<Track?> markFailed(
    String trackId, {
    String? reason,
  }) async {
    final currentTask = await _taskDataSource.getTask(trackId);
    await _taskDataSource.saveTask(
      DownloadTask(
        trackId: trackId,
        status: DownloadTaskStatus.failed,
        updatedAt: DateTime.now(),
        progress: currentTask?.progress,
        localPath: currentTask?.localPath,
        artworkPath: currentTask?.artworkPath,
        lyricsPath: currentTask?.lyricsPath,
        failureReason: reason,
      ),
    );
    return _libraryRepository.updateTrackLocalState(
      trackId,
      downloadState: DownloadState.failed,
      resourceOrigin: TrackResourceOrigin.managedDownload,
      downloadFailureReason: reason ?? '',
    );
  }

  Future<Directory> _ensureDownloadRootDirectory() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final rootDirectory =
        Directory('${supportDirectory.path}/zmusic/downloads');
    if (!rootDirectory.existsSync()) {
      await rootDirectory.create(recursive: true);
    }
    return rootDirectory;
  }

  Future<Directory> _ensureChildDirectory(
    Directory rootDirectory,
    String childName,
  ) async {
    final childDirectory = Directory('${rootDirectory.path}/$childName');
    if (!childDirectory.existsSync()) {
      await childDirectory.create(recursive: true);
    }
    return childDirectory;
  }

  String _buildAudioPath(
    Track track,
    String playbackUrl,
    Directory audioDirectory,
  ) {
    final extension = _resolveExtension(playbackUrl, fallback: '.mp3');
    return '${audioDirectory.path}/${_safeTrackFileName(track)}$extension';
  }

  Future<void> _downloadBinaryFile(
    String url,
    String outputPath, {
    required Future<void> Function(double progress) onProgress,
    CancelToken? cancelToken,
  }) async {
    final temporaryPath = '$outputPath.download';
    await _deleteFileIfExists(temporaryPath);

    var lastProgressPercent = -1;
    await _dio.download(
      url,
      temporaryPath,
      onReceiveProgress: (received, total) async {
        if (total <= 0) {
          return;
        }
        final progress = (received / total).clamp(0, 1).toDouble();
        final progressPercent = (progress * 100).floor();
        if (progressPercent == lastProgressPercent) {
          return;
        }
        lastProgressPercent = progressPercent;
        await onProgress(progress);
      },
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
      ),
      cancelToken: cancelToken,
    );

    final targetFile = File(outputPath);
    if (targetFile.existsSync()) {
      await targetFile.delete();
    }
    await File(temporaryPath).rename(outputPath);
  }

  Future<String?> _downloadArtworkFile(
    Track track,
    Directory artworkDirectory,
  ) async {
    final artworkUrl = track.artworkUrl;
    if (artworkUrl == null || artworkUrl.isEmpty) {
      return null;
    }

    final extension = _resolveExtension(artworkUrl, fallback: '.jpg');
    final artworkPath =
        '${artworkDirectory.path}/${_safeTrackFileName(track)}$extension';
    try {
      await _downloadBinaryFile(
        artworkUrl,
        artworkPath,
        onProgress: (_) async {},
      );
      return artworkPath;
    } catch (_) {
      // 封面失败不应反向打断音频下载，否则离线播放会因为附属资源失败而不可用。
      return null;
    }
  }

  Future<String?> _writeLyricsFile(
    String trackId,
    Directory lyricsDirectory,
  ) async {
    final lyrics = await _libraryRepository.getLyrics(trackId);
    if (lyrics == null || lyrics.main.isEmpty) {
      return null;
    }

    final lyricsPath = '${lyricsDirectory.path}/${_safeFileSegment(trackId)}.lrc';
    final lyricFile = File(lyricsPath);
    await lyricFile.writeAsString(_mergeLyricsContent(lyrics));
    return lyricFile.path;
  }

  String _mergeLyricsContent(TrackLyrics lyrics) {
    final main = lyrics.main;
    final translated = lyrics.translated;
    if (translated.isEmpty) {
      return main;
    }
    return '$main\n$translated';
  }

  String _resolveExtension(String url, {required String fallback}) {
    final uri = Uri.tryParse(url);
    final path = uri?.path ?? '';
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return fallback;
    }
    final extension = path.substring(dotIndex);
    if (extension.length > 10) {
      return fallback;
    }
    return extension;
  }

  String _safeTrackFileName(Track track) {
    final title = track.title.trim().isEmpty ? track.sourceId : track.title;
    return '${_safeFileSegment(track.id)}-${_safeFileSegment(title)}';
  }

  String _safeFileSegment(String value) {
    return value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  Future<void> _deleteFileIfExists(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<void> _deleteTemporaryDownloadIfExists(String? path) {
    if (path == null || path.isEmpty) {
      return Future.value();
    }
    return _deleteFileIfExists('$path.download');
  }

  Future<void> _clearCancelledTask(String trackId) async {
    await clearTask(trackId);
    await _libraryRepository.updateTrackLocalState(
      trackId,
      downloadState: DownloadState.none,
      resourceOrigin: TrackResourceOrigin.none,
      downloadProgress: 0,
      downloadFailureReason: '',
      availability: TrackAvailability.unknown,
    );
    _cancelledTrackIds.remove(trackId);
  }
}
