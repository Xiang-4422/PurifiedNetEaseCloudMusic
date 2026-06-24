import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_playback_history_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftPlaybackHistoryDataSource', () {
    late BujuanDriftDatabase database;
    late DriftPlaybackHistoryDataSource dataSource;

    setUp(() {
      database = BujuanDriftDatabase.connect(NativeDatabase.memory());
      dataSource = DriftPlaybackHistoryDataSource(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('loads recently played track ids in latest-first order', () async {
      await dataSource.recordPlayedTrack(
        'netease:1',
        playedAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );
      await dataSource.recordPlayedTrack(
        'netease:2',
        playedAt: DateTime.fromMillisecondsSinceEpoch(3000),
      );
      await dataSource.recordPlayedTrack(
        'netease:3',
        playedAt: DateTime.fromMillisecondsSinceEpoch(2000),
      );

      final trackIds = await dataSource.loadRecentTrackIds(limit: 2);

      expect(trackIds, ['netease:2', 'netease:3']);
    });

    test('updates existing track instead of duplicating history rows', () async {
      await dataSource.recordPlayedTrack(
        'netease:1',
        playedAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );
      await dataSource.recordPlayedTrack(
        'netease:2',
        playedAt: DateTime.fromMillisecondsSinceEpoch(2000),
      );
      await dataSource.recordPlayedTrack(
        'netease:1',
        playedAt: DateTime.fromMillisecondsSinceEpoch(3000),
      );

      final trackIds = await dataSource.loadRecentTrackIds(limit: 10);

      expect(trackIds, ['netease:1', 'netease:2']);
    });

    test('normalizes track ids before writing history rows', () async {
      await dataSource.recordPlayedTrack(
        '  1  ',
        playedAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );
      await dataSource.recordPlayedTrack(
        'netease:1',
        playedAt: DateTime.fromMillisecondsSinceEpoch(3000),
      );
      await dataSource.recordPlayedTrack(
        ' local:2 ',
        playedAt: DateTime.fromMillisecondsSinceEpoch(2000),
      );
      await dataSource.recordPlayedTrack(
        '   ',
        playedAt: DateTime.fromMillisecondsSinceEpoch(4000),
      );

      final trackIds = await dataSource.loadRecentTrackIds(limit: 10);
      final rows = await database.select(database.playbackHistoryEntries).get();

      expect(trackIds, ['netease:1', 'local:2']);
      expect(rows.map((row) => row.trackId).toSet(), {
        'netease:1',
        'local:2',
      });
    });

    test('prunes older history entries', () async {
      await dataSource.recordPlayedTrack(
        'netease:1',
        playedAt: DateTime.fromMillisecondsSinceEpoch(1000),
      );
      await dataSource.recordPlayedTrack(
        'netease:2',
        playedAt: DateTime.fromMillisecondsSinceEpoch(2000),
      );
      await dataSource.recordPlayedTrack(
        'netease:3',
        playedAt: DateTime.fromMillisecondsSinceEpoch(3000),
      );

      await dataSource.prune(maxEntries: 2);

      final trackIds = await dataSource.loadRecentTrackIds(limit: 10);
      expect(trackIds, ['netease:3', 'netease:2']);
    });
  });
}
