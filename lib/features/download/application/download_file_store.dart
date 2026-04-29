import 'dart:io';

import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadDirectories {
  const DownloadDirectories({
    required this.audio,
    required this.artwork,
    required this.lyrics,
  });

  final Directory audio;
  final Directory artwork;
  final Directory lyrics;
}

/// 下载文件存储策略，负责目录、临时文件、目标路径和二进制写入。
class DownloadFileStore {
  DownloadFileStore({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<DownloadDirectories> ensureDownloadDirectories() async {
    final rootDirectory = await _ensureRootDirectory('downloads');
    return DownloadDirectories(
      audio: await _ensureChildDirectory(rootDirectory, 'audio'),
      artwork: await _ensureChildDirectory(rootDirectory, 'artwork'),
      lyrics: await _ensureChildDirectory(rootDirectory, 'lyrics'),
    );
  }

  Future<DownloadDirectories> ensureCacheDirectories() async {
    final rootDirectory = await _ensureRootDirectory('cache');
    return DownloadDirectories(
      audio: await _ensureChildDirectory(rootDirectory, 'audio'),
      artwork: await _ensureChildDirectory(rootDirectory, 'artwork'),
      lyrics: await _ensureChildDirectory(rootDirectory, 'lyrics'),
    );
  }

  String buildAudioPath(
    Track track,
    String playbackUrl,
    Directory audioDirectory,
  ) {
    final extension = _resolveExtension(playbackUrl, fallback: '.mp3');
    return '${audioDirectory.path}/${_safeTrackFileName(track)}$extension';
  }

  Future<void> downloadBinaryFile(
    String url,
    String outputPath, {
    required Future<void> Function(double progress) onProgress,
    CancelToken? cancelToken,
  }) async {
    final temporaryPath = '$outputPath.download';
    await deleteFileIfExists(temporaryPath);

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

  Future<String?> downloadArtworkFile(
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
      await downloadBinaryFile(
        artworkUrl,
        artworkPath,
        onProgress: (_) async {},
      );
      return artworkPath;
    } catch (_) {
      return null;
    }
  }

  Future<String?> writeLyricsFile(
    String trackId,
    Directory lyricsDirectory,
    TrackLyrics? lyrics,
  ) async {
    if (lyrics == null || lyrics.main.isEmpty) {
      return null;
    }

    final lyricsPath =
        '${lyricsDirectory.path}/${_safeFileSegment(trackId)}.lrc';
    final lyricFile = File(lyricsPath);
    await lyricFile.writeAsString(_mergeLyricsContent(lyrics));
    return lyricFile.path;
  }

  Future<void> deleteTemporaryDownloadIfExists(String? temporaryPath) {
    if (temporaryPath == null || temporaryPath.isEmpty) {
      return Future.value();
    }
    return deleteFileIfExists(temporaryPath);
  }

  Future<void> deleteFileIfExists(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<void> cleanupOrphanTemporaryFiles() async {
    final rootDirectory = await _ensureRootDirectory('downloads');
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

  Future<Directory> _ensureRootDirectory(String childName) async {
    final supportDirectory = await getApplicationSupportDirectory();
    final rootDirectory =
        Directory('${supportDirectory.path}/zmusic/$childName');
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
}
