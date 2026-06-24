import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/resource_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart' as drift_db;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResourceDao', () {
    late drift_db.BujuanDriftDatabase database;
    late ResourceDao dao;

    setUp(() {
      database = drift_db.BujuanDriftDatabase.connect(NativeDatabase.memory());
      dao = ResourceDao(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('normalizes track ids before saving, reading, touching, and removing resources', () async {
      await dao.saveResource(
        _resource(
          trackId: ' track-1 ',
          kind: LocalResourceKind.audio,
          path: '/tmp/audio.flac',
        ),
      );
      await dao.saveResource(
        _resource(
          trackId: ' track-1 ',
          kind: LocalResourceKind.artwork,
          path: '/tmp/artwork.jpg',
        ),
      );

      final audio = await dao.getResource(' track-1 ', LocalResourceKind.audio);
      final trackResources = await dao.getTrackResources(' track-1 ');
      final resourcesById = await dao.getTrackResourcesByIds(const [
        ' ',
        ' track-1 ',
        'track-1',
      ]);
      await dao.touchResource(
        ' track-1 ',
        LocalResourceKind.audio,
        accessedAt: DateTime(2026, 1, 2),
      );
      final touchedAudio = await dao.getResource('track-1', LocalResourceKind.audio);
      final rows = await database.select(database.localResourceEntries).get();

      expect(audio?.trackId, 'track-1');
      expect(audio?.path, '/tmp/audio.flac');
      expect(trackResources.map((item) => item.kind), [
        LocalResourceKind.artwork,
        LocalResourceKind.audio,
      ]);
      expect(resourcesById.keys, ['track-1']);
      expect(resourcesById['track-1']?.map((item) => item.trackId).toSet(), {'track-1'});
      expect(touchedAudio?.lastAccessedAt, DateTime(2026, 1, 2));
      expect(rows.map((row) => row.trackId).toSet(), {'track-1'});

      await dao.removeResource(' track-1 ', LocalResourceKind.audio);
      expect(await dao.getResource('track-1', LocalResourceKind.audio), isNull);
      expect(await dao.getTrackResources('track-1'), hasLength(1));

      await dao.removeTrackResources(' track-1 ');
      expect(await dao.getTrackResources('track-1'), isEmpty);
    });

    test('ignores blank track ids before touching local resource table', () async {
      await dao.saveResource(
        _resource(
          trackId: '   ',
          kind: LocalResourceKind.audio,
          path: '/tmp/audio.flac',
        ),
      );
      await dao.touchResource(
        '   ',
        LocalResourceKind.audio,
        accessedAt: DateTime(2026, 1, 2),
      );
      await dao.removeResource('   ', LocalResourceKind.audio);
      await dao.removeTrackResources('   ');

      expect(await dao.getResource('   ', LocalResourceKind.audio), isNull);
      expect(await dao.getTrackResources('   '), isEmpty);
      expect(await dao.getTrackResourcesByIds(const ['   ', '\t']), isEmpty);
      expect(await database.select(database.localResourceEntries).get(), isEmpty);
    });
  });
}

LocalResourceEntry _resource({
  required String trackId,
  required LocalResourceKind kind,
  required String path,
}) {
  return LocalResourceEntry(
    trackId: trackId,
    kind: kind,
    path: path,
    origin: TrackResourceOrigin.managedDownload,
    sizeBytes: 128,
    createdAt: DateTime(2026),
    lastAccessedAt: DateTime(2026),
  );
}
