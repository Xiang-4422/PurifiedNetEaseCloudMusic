import 'dart:io';

import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/local_media/local_media_scan_controller.dart';
import 'package:bujuan/features/local_media/local_media_scan_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalMediaScanController', () {
    late _FakeLocalMediaRepository localMediaRepository;
    late LocalMediaScanRepository scanRepository;

    setUp(() {
      localMediaRepository = _FakeLocalMediaRepository();
      scanRepository = LocalMediaScanRepository(
        localMediaRepository: localMediaRepository,
      );
    });

    test('prepareDefaultDirectoryImport stops before resolving directories when permission is denied', () async {
      var resolvedDirectories = false;
      final controller = LocalMediaScanController(
        scanRepository: scanRepository,
        requestPermission: () async => false,
        resolveDefaultDirectories: () async {
          resolvedDirectories = true;
          return const <String>['/music'];
        },
      );

      final preparation = await controller.prepareDefaultDirectoryImport();

      expect(
        preparation.status,
        LocalMediaDefaultScanPreparationStatus.permissionDenied,
      );
      expect(preparation.directoryPaths, isEmpty);
      expect(resolvedDirectories, isFalse);
    });

    test('prepareDefaultDirectoryImport reports empty default directories', () async {
      final controller = LocalMediaScanController(
        scanRepository: scanRepository,
        requestPermission: () async => true,
        resolveDefaultDirectories: () async => const <String>[],
      );

      final preparation = await controller.prepareDefaultDirectoryImport();

      expect(
        preparation.status,
        LocalMediaDefaultScanPreparationStatus.noDirectories,
      );
      expect(preparation.isReady, isFalse);
    });

    test('prepareDefaultDirectoryImport returns resolved directories when ready', () async {
      final controller = LocalMediaScanController(
        scanRepository: scanRepository,
        requestPermission: () async => true,
        resolveDefaultDirectories: () async => const <String>[
          '/music',
          '/downloads',
        ],
      );

      final preparation = await controller.prepareDefaultDirectoryImport();

      expect(
        preparation.status,
        LocalMediaDefaultScanPreparationStatus.ready,
      );
      expect(preparation.isReady, isTrue);
      expect(preparation.directoryPaths, const <String>['/music', '/downloads']);
    });

    test('importDirectories delegates discovered tracks to scan repository', () async {
      final directory = await Directory.systemTemp.createTemp(
        'local-media-scan-controller-',
      );
      try {
        final audioFile = File('${directory.path}/Ready Song.mp3');
        await audioFile.writeAsString('media');
        final controller = LocalMediaScanController(
          scanRepository: scanRepository,
          requestPermission: () async => true,
          resolveDefaultDirectories: () async => <String>[directory.path],
        );

        final preparation = await controller.prepareDefaultDirectoryImport();
        final importedCount = await controller.importDirectories(
          preparation.directoryPaths,
        );

        expect(importedCount, 1);
        expect(localMediaRepository.importedTracks, hasLength(1));
        expect(localMediaRepository.importedTracks.single.filePath, audioFile.path);
      } finally {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      }
    });
  });
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
