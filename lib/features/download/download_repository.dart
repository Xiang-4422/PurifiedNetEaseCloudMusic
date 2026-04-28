import 'dart:async';
import 'dart:io';

import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/domain/entities/download_task.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/domain/entities/track_resource_bundle.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/library/local_resource_index_repository.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadRepository {
  static Future<void> _downloadQueue = Future.value();
  static final Map<String, Future<Track?>> _scheduledDownloads = {};
  static final Map<String, Future<Track?>> _scheduledPlaybackCaches = {};
  static final Map<String, CancelToken> _activeCancelTokens = {};
  static final Set<String> _cancelledTrackIds = <String>{};

  DownloadRepository({
    required LibraryRepository libraryRepository,
    required DownloadTaskDataSource taskDataSource,
    required LocalResourceIndexRepository resourceIndexRepository,
    Dio? dio,
  })  : _libraryRepository = libraryRepository,
        _taskDataSource = taskDataSource,
        _resourceIndexRepository = resourceIndexRepository,
        _dio = dio ?? Dio();

  final LibraryRepository _libraryRepository;
  final DownloadTaskDataSource _taskDataSource;
  final LocalResourceIndexRepository _resourceIndexRepository;
  final Dio _dio;

  Future<List<DownloadTask>> recoverInterruptedTasks() async {
    await _cleanupOrphanTemporaryFiles();
    final interruptedTasks = await getTasks(
      statuses: const {
        DownloadTaskStatus.queued,
        DownloadTaskStatus.downloading,
      },
    );
    final queuedTasks = interruptedTasks
        .where((task) => task.status == DownloadTaskStatus.queued)
        .toList();
    final downloadingTasks = interruptedTasks
        .where((task) => task.status == DownloadTaskStatus.downloading)
        .toList();

    for (final task in downloadingTasks) {
      await _deleteTemporaryDownloadIfExists(task.temporaryPath);
      await markFailed(task.trackId, reason: 'download_interrupted');
    }
    for (final task in queuedTasks) {
      unawaited(downloadTrack(task.trackId));
    }
    return getTasks(
      statuses: const {
        DownloadTaskStatus.failed,
      },
    );
  }

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
    final candidateIds = trackIds.toSet().toList();
    if (candidateIds.isEmpty) {
      return;
    }
    final tracksWithResources =
        await _libraryRepository.getTracksWithResources(candidateIds);
    final tracksById = {
      for (final item in tracksWithResources) item.track.id: item,
    };
    for (final trackId in candidateIds) {
      final trackWithResources = tracksById[trackId];
      final currentTask = await _taskDataSource.getTask(trackId);
      if (currentTask != null &&
          {
            DownloadTaskStatus.queued,
            DownloadTaskStatus.downloading,
          }.contains(currentTask.status)) {
        continue;
      }
      if (trackWithResources == null) {
        continue;
      }
      final track = trackWithResources.track;
      final audioResource = trackWithResources.resources.audio;
      if (track.sourceType == SourceType.local ||
          audioResource?.origin == TrackResourceOrigin.managedDownload) {
        continue;
      }
      unawaited(
        downloadTrack(
          trackId,
          preferHighQuality: preferHighQuality,
        ),
      );
    }
  }

  Future<Track?> cacheTrackForPlayback(
    String trackId, {
    bool preferHighQuality = true,
  }) async {
    final existingTask = _scheduledPlaybackCaches[trackId];
    if (existingTask != null) {
      return existingTask;
    }
    final taskFuture = _performCacheTrackForPlayback(
      trackId,
      preferHighQuality: preferHighQuality,
    );
    _scheduledPlaybackCaches[trackId] = taskFuture;
    taskFuture.whenComplete(() {
      _scheduledPlaybackCaches.remove(trackId);
    });
    return taskFuture;
  }

  Future<Track?> _performDownloadTrack(
    String trackId, {
    required bool preferHighQuality,
  }) async {
    if (_cancelledTrackIds.contains(trackId)) {
      await _clearCancelledTask(trackId);
      return null;
    }
    final trackWithResources = await _libraryRepository.getTrackWithResources(
      trackId,
    );
    if (trackWithResources == null) {
      await markFailed(trackId, reason: 'track_not_found');
      return null;
    }

    final track = trackWithResources.track;
    if (track.sourceType == SourceType.local) {
      await clearTask(trackId);
      return track;
    }
    final audioResource = trackWithResources.resources.audio;
    if (audioResource != null && File(audioResource.path).existsSync()) {
      if (audioResource.origin != TrackResourceOrigin.managedDownload &&
          track.sourceType != SourceType.local) {
        await _promoteResourcesToManagedDownload(
          track.id,
          trackWithResources.resources,
        );
      }
      await clearTask(trackId);
      return track;
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
      final audioDirectory =
          await _ensureChildDirectory(rootDirectory, 'audio');
      final artworkDirectory =
          await _ensureChildDirectory(rootDirectory, 'artwork');
      final lyricsDirectory =
          await _ensureChildDirectory(rootDirectory, 'lyrics');
      final cancelToken = CancelToken();
      _activeCancelTokens[trackId] = cancelToken;

      final audioPath = _buildAudioPath(track, playbackUrl, audioDirectory);
      final temporaryPath = '$audioPath.download';
      await markQueued(trackId, temporaryPath: temporaryPath);
      await _downloadBinaryFile(
        playbackUrl,
        audioPath,
        onProgress: (progress) => markDownloading(
          trackId,
          progress: progress,
          temporaryPath: temporaryPath,
        ),
        cancelToken: cancelToken,
      );
      if (_cancelledTrackIds.contains(trackId)) {
        await _deleteTemporaryDownloadIfExists(temporaryPath);
        await _clearCancelledTask(trackId);
        return null;
      }

      final artworkPath = await _downloadArtworkFile(
        track,
        artworkDirectory,
      );
      final lyricsPath = await _writeLyricsFile(trackId, lyricsDirectory);

      await _saveManagedDownloadResources(
        trackId,
        localPath: audioPath,
        artworkPath: artworkPath,
        lyricsPath: lyricsPath,
      );
      await clearTask(trackId);
      return track;
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
    _downloadQueue = _downloadQueue.catchError((_) {}).then((_) async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  Future<void> removeDownloadedTrack(String trackId) async {
    await clearTask(trackId);
    final trackWithResources = await _libraryRepository.getTrackWithResources(
      trackId,
    );
    final audioOrigin = trackWithResources?.resources.audio?.origin;
    await _libraryRepository.removeLocalTrackResources(
      trackId,
      deleteSourceFiles: audioOrigin != TrackResourceOrigin.localImport,
    );
  }

  Future<void> removeLocalTrack(String trackId) {
    return removeDownloadedTrack(trackId);
  }

  Future<void> cancelTask(String trackId) async {
    _cancelledTrackIds.add(trackId);
    _activeCancelTokens[trackId]?.cancel('download_cancelled');
    final currentTask = await _taskDataSource.getTask(trackId);
    await _deleteTemporaryDownloadIfExists(currentTask?.temporaryPath);
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
    await _deleteTemporaryDownloadIfExists(currentTask?.temporaryPath);
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

  Future<void> clearPlaybackCache() {
    return _libraryRepository.removePlaybackCache();
  }

  Future<Track?> markQueued(
    String trackId, {
    String? temporaryPath,
  }) async {
    final currentTask = await _taskDataSource.getTask(trackId);
    await _taskDataSource.saveTask(
      DownloadTask(
        trackId: trackId,
        status: DownloadTaskStatus.queued,
        updatedAt: DateTime.now(),
        progress: 0,
        temporaryPath: temporaryPath ?? currentTask?.temporaryPath,
      ),
    );
    return _libraryRepository.getTrack(trackId);
  }

  Future<Track?> markDownloading(
    String trackId, {
    double? progress,
    String? temporaryPath,
  }) async {
    final currentTask = await _taskDataSource.getTask(trackId);
    await _taskDataSource.saveTask(
      DownloadTask(
        trackId: trackId,
        status: DownloadTaskStatus.downloading,
        updatedAt: DateTime.now(),
        progress: progress ?? 0,
        temporaryPath: temporaryPath ?? currentTask?.temporaryPath,
      ),
    );
    return _libraryRepository.getTrack(trackId);
  }

  Future<Track?> _performCacheTrackForPlayback(
    String trackId, {
    required bool preferHighQuality,
  }) async {
    final trackWithResources = await _libraryRepository.getTrackWithResources(
      trackId,
    );
    final track = trackWithResources?.track;
    if (track == null || track.sourceType == SourceType.local) {
      return track;
    }
    final audioResource = trackWithResources?.resources.audio;
    if (audioResource != null && File(audioResource.path).existsSync()) {
      return track;
    }
    try {
      final playbackUrl = await _libraryRepository.getPlaybackUrlWithQuality(
        trackId,
        qualityLevel: preferHighQuality ? 'lossless' : 'exhigh',
      );
      if (playbackUrl == null || playbackUrl.isEmpty) {
        return track;
      }
      final rootDirectory = await _ensureCacheRootDirectory();
      final audioDirectory =
          await _ensureChildDirectory(rootDirectory, 'audio');
      final artworkDirectory =
          await _ensureChildDirectory(rootDirectory, 'artwork');
      final lyricsDirectory =
          await _ensureChildDirectory(rootDirectory, 'lyrics');
      final audioPath = _buildAudioPath(track, playbackUrl, audioDirectory);
      await _downloadBinaryFile(
        playbackUrl,
        audioPath,
        onProgress: (_) async {},
      );
      final artworkPath = await _downloadArtworkFile(track, artworkDirectory);
      final lyricsPath = await _writeLyricsFile(trackId, lyricsDirectory);
      await _resourceIndexRepository.saveAudioResource(
        trackId,
        path: audioPath,
        origin: TrackResourceOrigin.playbackCache,
      );
      if (artworkPath?.isNotEmpty == true) {
        await _resourceIndexRepository.saveArtworkResource(
          trackId,
          path: artworkPath!,
          origin: TrackResourceOrigin.playbackCache,
        );
      }
      if (lyricsPath?.isNotEmpty == true) {
        await _resourceIndexRepository.saveLyricsResource(
          trackId,
          path: lyricsPath!,
          origin: TrackResourceOrigin.playbackCache,
        );
      }
      return track;
    } catch (_) {
      return track;
    }
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
        temporaryPath: currentTask?.temporaryPath,
        failureReason: reason,
      ),
    );
    return _libraryRepository.getTrack(trackId);
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

  Future<Directory> _ensureCacheRootDirectory() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final rootDirectory = Directory('${supportDirectory.path}/zmusic/cache');
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

    final lyricsPath =
        '${lyricsDirectory.path}/${_safeFileSegment(trackId)}.lrc';
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

  Future<void> _deleteTemporaryDownloadIfExists(String? temporaryPath) {
    if (temporaryPath == null || temporaryPath.isEmpty) {
      return Future.value();
    }
    return _deleteFileIfExists(temporaryPath);
  }

  Future<void> _cleanupOrphanTemporaryFiles() async {
    final rootDirectory = await _ensureDownloadRootDirectory();
    if (!rootDirectory.existsSync()) {
      return;
    }
    await for (final entity in rootDirectory.list(recursive: true)) {
      if (entity is! File) {
        continue;
      }
      if (!entity.path.endsWith('.download')) {
        continue;
      }
      await entity.delete();
    }
  }

  Future<void> _clearCancelledTask(String trackId) async {
    await clearTask(trackId);
    _cancelledTrackIds.remove(trackId);
  }

  Future<void> _saveManagedDownloadResources(
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
  }

  Future<void> _promoteResourcesToManagedDownload(
    String trackId,
    TrackResourceBundle bundle,
  ) async {
    if (bundle.audio?.path.isNotEmpty == true) {
      await _resourceIndexRepository.saveAudioResource(
        trackId,
        path: bundle.audio!.path,
        origin: TrackResourceOrigin.managedDownload,
      );
    }
    if (bundle.artwork?.path.isNotEmpty == true) {
      await _resourceIndexRepository.saveArtworkResource(
        trackId,
        path: bundle.artwork!.path,
        origin: TrackResourceOrigin.managedDownload,
      );
    }
    if (bundle.lyrics?.path.isNotEmpty == true) {
      await _resourceIndexRepository.saveLyricsResource(
        trackId,
        path: bundle.lyrics!.path,
        origin: TrackResourceOrigin.managedDownload,
      );
    }
  }
}
