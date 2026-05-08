import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/user_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_user_scoped_data_source.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftUserScopedDataSource playlist items', () {
    late BujuanDriftDatabase database;
    late DriftUserScopedDataSource dataSource;

    setUp(() {
      database = BujuanDriftDatabase.connect(NativeDatabase.memory());
      dataSource = DriftUserScopedDataSource(
        database: database,
        userDao: UserDao(database: database),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('stores playlist summaries in playlists table and loads refs in order', () async {
      await dataSource.replacePlaylistItems(
        'user',
        UserPlaylistListKind.recommended,
        const [
          PlaylistSummaryData(id: '1', title: 'First', coverUrl: 'cover-1', trackCount: 10),
          PlaylistSummaryData(id: '2', title: 'Second', coverUrl: 'cover-2', trackCount: 20),
        ],
      );

      final items = await dataSource.loadPlaylistItems(
        'user',
        UserPlaylistListKind.recommended,
      );
      final playlistRows = await database.select(database.playlists).get();

      expect(items.map((item) => item.id), ['1', '2']);
      expect(items.map((item) => item.title), ['First', 'Second']);
      expect(playlistRows.map((row) => row.playlistId).toSet(), {'netease:1', 'netease:2'});
    });

    test('appends playlist items and searches through playlists table', () async {
      await dataSource.replacePlaylistItems(
        'user',
        UserPlaylistListKind.userPlaylists,
        const [
          PlaylistSummaryData(id: '1', title: 'Daily Mix'),
        ],
      );
      await dataSource.appendPlaylistItems(
        'user',
        UserPlaylistListKind.userPlaylists,
        const [
          PlaylistSummaryData(id: '2', title: 'Evening Focus'),
        ],
        startOrder: 1,
      );

      final allItems = await dataSource.loadPlaylistItems(
        'user',
        UserPlaylistListKind.userPlaylists,
      );
      final searchItems = await dataSource.searchPlaylistItems('user', 'Focus');

      expect(allItems.map((item) => item.id), ['1', '2']);
      expect(searchItems.map((item) => item.id), ['2']);
    });
  });
}
