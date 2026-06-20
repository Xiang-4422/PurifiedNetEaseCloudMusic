import 'dart:io';

import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/local_media/local_media_scan_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalMediaScanRepository', () {
    late Directory directory;
    late _FakeLocalMediaRepository localMediaRepository;
    late LocalMediaScanRepository scanRepository;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('local-media-scan-');
      localMediaRepository = _FakeLocalMediaRepository();
      scanRepository = LocalMediaScanRepository(
        localMediaRepository: localMediaRepository,
      );
    });

    tearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    test('scanFiles normalizes file uri paths and finds sidecar resources', () async {
      final audioFile = await _writeFile(directory, 'Song With Space.mp3');
      final artworkFile = await _writeFile(directory, 'Song With Space.jpg');
      final lyricsFile = await _writeFile(directory, 'Song With Space.lrc');

      final imports = await scanRepository.scanFiles([
        audioFile.uri.replace(queryParameters: {'token': 'local'}).toString(),
      ]);

      expect(imports, hasLength(1));
      expect(imports.single.filePath, audioFile.path);
      expect(imports.single.title, 'Song With Space');
      expect(imports.single.localArtworkPath, artworkFile.path);
      expect(imports.single.localLyricsPath, lyricsFile.path);
    });

    test('scanFiles accepts localhost file uri authority', () async {
      final audioFile = await _writeFile(directory, 'Localhost Song.mp3');

      final imports = await scanRepository.scanFiles([
        audioFile.uri.replace(host: 'localhost', queryParameters: {'token': 'local'}).toString(),
      ]);

      expect(imports, hasLength(1));
      expect(imports.single.filePath, audioFile.path);
    });

    test('importFiles passes normalized paths to local media repository', () async {
      final audioFile = await _writeFile(directory, 'Imported Song.flac');

      final count = await scanRepository.importFiles([
        audioFile.uri.replace(queryParameters: {'token': 'local'}).toString(),
      ]);

      expect(count, 1);
      expect(localMediaRepository.importedTracks, hasLength(1));
      expect(localMediaRepository.importedTracks.single.filePath, audioFile.path);
    });
  });
}

Future<File> _writeFile(Directory directory, String name) async {
  final file = File('${directory.path}/$name');
  await file.writeAsString('media');
  return file;
}

class _FakeLocalMediaRepository implements LocalMediaRepository {
  final List<LocalTrackImport> importedTracks = <LocalTrackImport>[];

  @override
  String buildTrackTitleFromPath(String filePath) {
    final fileName = filePath.replaceAll('\\', '/').split('/').last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex <= 0 ? fileName : fileName.substring(0, dotIndex);
  }

  @override
  Future<Track> importLocalTrack({
    required String filePath,
    required String title,
    List<String> artistNames = const [],
    String? albumTitle,
    int? durationMs,
    String? artworkUrl,
    String? localArtworkPath,
    String? localLyricsPath,
    Map<String, Object?> metadata = const {},
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Track>> importLocalTracks(List<LocalTrackImport> tracks) async {
    importedTracks.addAll(tracks);
    return const <Track>[];
  }
}
