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

    test('normalizes subscribed radio scope keys at dao boundary', () async {
      await dataSource.replaceSubscribedRadios(
        ' user ',
        const [
          RadioSummaryData(
            id: ' radio-1 ',
            name: 'First Radio',
            coverUrl: 'cover-1',
            lastProgramName: 'first latest',
          ),
          RadioSummaryData(
            id: ' ',
            name: 'Blank Radio',
            coverUrl: 'blank-cover',
            lastProgramName: 'blank latest',
          ),
        ],
      );
      await dataSource.appendSubscribedRadios(
        'user',
        const [
          RadioSummaryData(
            id: ' radio-2 ',
            name: 'Second Radio',
            coverUrl: 'cover-2',
            lastProgramName: 'second latest',
          ),
        ],
        startOrder: 1,
      );
      await dataSource.replaceSubscribedRadios(
        ' ',
        const [
          RadioSummaryData(
            id: 'radio-blank-user',
            name: 'Blank User Radio',
            coverUrl: 'blank-user-cover',
            lastProgramName: 'blank user latest',
          ),
        ],
      );

      final normalized = await dataSource.loadSubscribedRadios('user');
      final spaced = await dataSource.loadSubscribedRadios(' user ');
      final blank = await dataSource.loadSubscribedRadios(' ');

      expect(normalized.map((item) => item.id), ['radio-1', 'radio-2']);
      expect(spaced.map((item) => item.id), ['radio-1', 'radio-2']);
      expect(blank, isEmpty);
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

    test('normalizes program scope keys at dao boundary', () async {
      await dataSource.replacePrograms(
        ' user ',
        ' radio ',
        asc: true,
        items: const [
          RadioProgramData(
            id: ' program-1 ',
            mainTrackId: ' track-1 ',
            title: 'First Program',
            coverUrl: 'cover-1',
            artistName: 'Artist 1',
            albumTitle: 'Album 1',
            durationMs: 1000,
          ),
          RadioProgramData(
            id: ' ',
            mainTrackId: 'blank-track',
            title: 'Blank Program',
            coverUrl: 'blank-cover',
            artistName: 'Blank Artist',
            albumTitle: 'Blank Album',
            durationMs: 0,
          ),
        ],
      );
      await dataSource.appendPrograms(
        'user',
        'radio',
        asc: true,
        items: const [
          RadioProgramData(
            id: ' program-2 ',
            mainTrackId: ' track-2 ',
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
        ' ',
        'radio',
        asc: true,
        items: const [
          RadioProgramData(
            id: 'blank-user-program',
            mainTrackId: 'blank-user-track',
            title: 'Blank User Program',
            coverUrl: 'blank-user-cover',
            artistName: 'Blank User Artist',
            albumTitle: 'Blank User Album',
            durationMs: 3000,
          ),
        ],
      );

      final normalized = await dataSource.loadPrograms(
        'user',
        'radio',
        asc: true,
      );
      final spaced = await dataSource.loadPrograms(
        ' user ',
        ' radio ',
        asc: true,
      );
      final blank = await dataSource.loadPrograms(
        ' ',
        'radio',
        asc: true,
      );

      expect(normalized.map((item) => item.id), ['program-1', 'program-2']);
      expect(normalized.map((item) => item.mainTrackId), ['track-1', 'track-2']);
      expect(spaced.map((item) => item.id), ['program-1', 'program-2']);
      expect(blank, isEmpty);
    });
  });
}
