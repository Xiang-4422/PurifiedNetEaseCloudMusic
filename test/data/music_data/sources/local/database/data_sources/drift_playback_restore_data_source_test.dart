import 'package:bujuan/core/entities/playback_restore_state.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_playback_restore_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftPlaybackRestoreDataSource', () {
    late BujuanDriftDatabase database;
    late DriftPlaybackRestoreDataSource dataSource;

    setUp(() {
      database = BujuanDriftDatabase.connect(NativeDatabase.memory());
      dataSource = DriftPlaybackRestoreDataSource(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('normalizes current song id when saving restore state', () async {
      await dataSource.saveRestoreState(
        const PlaybackRestoreState(
          queue: ['cached-1'],
          currentSongId: '  netease:1  ',
        ),
      );

      final state = await dataSource.getRestoreState();

      expect(state?.queue, ['cached-1']);
      expect(state?.currentSongId, 'netease:1');
    });

    test('stores blank current song id as empty restore state field', () async {
      await dataSource.saveRestoreState(
        const PlaybackRestoreState(currentSongId: '   '),
      );

      final state = await dataSource.getRestoreState();

      expect(state?.currentSongId, isEmpty);
    });
  });
}
