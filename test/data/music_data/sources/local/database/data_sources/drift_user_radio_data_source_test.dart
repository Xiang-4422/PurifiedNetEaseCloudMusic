import 'package:bujuan/core/entities/radio_data.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/radio_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_user_radio_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftUserRadioDataSource', () {
    late BujuanDriftDatabase database;
    late DriftUserRadioDataSource dataSource;

    setUp(() {
      database = BujuanDriftDatabase.connect(NativeDatabase.memory());
      dataSource = DriftUserRadioDataSource(
        dao: RadioDao(database: database),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('stores subscribed radios and loads them in order', () async {
      await dataSource.replaceSubscribedRadios(
        'user',
        const [
          RadioSummaryData(
            id: 'radio-1',
            name: 'First Radio',
            coverUrl: 'cover-1',
            lastProgramName: 'first latest',
          ),
        ],
      );
      await dataSource.appendSubscribedRadios(
        'user',
        const [
          RadioSummaryData(
            id: 'radio-2',
            name: 'Second Radio',
            coverUrl: 'cover-2',
            lastProgramName: 'second latest',
          ),
        ],
        startOrder: 1,
      );

      final items = await dataSource.loadSubscribedRadios('user');

      expect(items.map((item) => item.id), ['radio-1', 'radio-2']);
      expect(items.map((item) => item.name), ['First Radio', 'Second Radio']);
    });

    test('stores programs per radio and direction', () async {
      await dataSource.replacePrograms(
        'user',
        'radio',
        asc: true,
        items: const [
          RadioProgramData(
            id: 'program-1',
            mainTrackId: 'track-1',
            title: 'First Program',
            coverUrl: 'cover-1',
            artistName: 'Artist 1',
            albumTitle: 'Album 1',
            durationMs: 1000,
          ),
        ],
      );
      await dataSource.appendPrograms(
        'user',
        'radio',
        asc: true,
        items: const [
          RadioProgramData(
            id: 'program-2',
            mainTrackId: 'track-2',
            title: 'Second Program',
            coverUrl: 'cover-2',
            artistName: 'Artist 2',
            albumTitle: 'Album 2',
            durationMs: 2000,
          ),
        ],
        startOrder: 1,
      );
      await dataSource.replacePrograms(
        'user',
        'radio',
        asc: false,
        items: const [
          RadioProgramData(
            id: 'program-desc',
            mainTrackId: 'track-desc',
            title: 'Descending Program',
            coverUrl: 'cover-desc',
            artistName: 'Artist Desc',
            albumTitle: 'Album Desc',
            durationMs: 3000,
          ),
        ],
      );

      final ascItems = await dataSource.loadPrograms(
        'user',
        'radio',
        asc: true,
      );
      final descItems = await dataSource.loadPrograms(
        'user',
        'radio',
        asc: false,
      );

      expect(ascItems.map((item) => item.id), ['program-1', 'program-2']);
      expect(descItems.map((item) => item.id), ['program-desc']);
    });
  });
}
