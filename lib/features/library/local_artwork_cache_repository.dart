import 'dart:io';

import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/local_resource_index_repository.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class LocalArtworkCacheRepository {
  LocalArtworkCacheRepository({
    Dio? dio,
    LocalResourceIndexRepository? resourceIndexRepository,
  })  : _dio = dio ?? Dio(),
        _resourceIndexRepository =
            resourceIndexRepository ?? LocalResourceIndexRepository();

  final Dio _dio;
  final LocalResourceIndexRepository _resourceIndexRepository;
  final Set<String> _pendingTrackIds = <String>{};

  Future<List<Track>> cacheTrackArtwork(List<Track> tracks) async {
    if (tracks.isEmpty) {
      return const [];
    }

    final results = <Track>[];
    for (final chunk in _chunk(tracks, 4)) {
      results.addAll(
        await Future.wait(
          chunk.map(cacheSingleTrackArtwork),
        ),
      );
    }
    return results;
  }

  Future<Track> cacheSingleTrackArtwork(Track track) async {
    final existingArtworkPath = track.localArtworkPath ?? '';
    if (existingArtworkPath.isNotEmpty &&
        File(existingArtworkPath).existsSync()) {
      return track;
    }

    final indexedResource =
        await _resourceIndexRepository.getArtworkResource(track.id);
    final indexedPath = indexedResource?.path ?? '';
    if (indexedPath.isNotEmpty && File(indexedPath).existsSync()) {
      return track.copyWith(localArtworkPath: indexedPath);
    }

    final artworkUrl = track.artworkUrl ?? '';
    if (artworkUrl.isEmpty ||
        !artworkUrl.startsWith('http://') &&
            !artworkUrl.startsWith('https://')) {
      return track;
    }

    if (!_pendingTrackIds.add(track.id)) {
      return track;
    }

    try {
      final artworkDirectory = await _ensureArtworkCacheDirectory();
      final artworkPath =
          _buildArtworkPath(track, artworkUrl, artworkDirectory);
      if (!File(artworkPath).existsSync()) {
        await _downloadArtwork(artworkUrl, artworkPath);
      }
      await _resourceIndexRepository.saveArtworkResource(
        track.id,
        path: artworkPath,
        origin: TrackResourceOrigin.artworkCache,
      );
      return track.copyWith(localArtworkPath: artworkPath);
    } catch (_) {
      return track;
    } finally {
      _pendingTrackIds.remove(track.id);
    }
  }

  Future<Directory> _ensureArtworkCacheDirectory() async {
    final supportDirectory = await getApplicationSupportDirectory();
    final artworkDirectory =
        Directory('${supportDirectory.path}/zmusic/artwork-cache');
    if (!artworkDirectory.existsSync()) {
      await artworkDirectory.create(recursive: true);
    }
    return artworkDirectory;
  }

  String _buildArtworkPath(
    Track track,
    String artworkUrl,
    Directory artworkDirectory,
  ) {
    final extension = _resolveExtension(artworkUrl, fallback: '.jpg');
    return '${artworkDirectory.path}/${_safeFileSegment(track.id)}$extension';
  }

  Future<void> _downloadArtwork(String artworkUrl, String outputPath) async {
    final temporaryPath = '$outputPath.download';
    final temporaryFile = File(temporaryPath);
    if (temporaryFile.existsSync()) {
      await temporaryFile.delete();
    }

    await _dio.download(
      artworkUrl,
      temporaryPath,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        headers: _imageHttpHeaders,
      ),
    );

    final outputFile = File(outputPath);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    await temporaryFile.rename(outputPath);
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

  String _safeFileSegment(String value) {
    return value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  Iterable<List<Track>> _chunk(List<Track> tracks, int size) sync* {
    for (var index = 0; index < tracks.length; index += size) {
      final end = index + size > tracks.length ? tracks.length : index + size;
      yield tracks.sublist(index, end);
    }
  }

  static const Map<String, String> _imageHttpHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
  };
}
