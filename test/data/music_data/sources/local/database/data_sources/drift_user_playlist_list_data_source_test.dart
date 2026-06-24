import 'package:bujuan/data/music_data/sources/local/database/dao/playlist_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_user_playlist_list_data_source.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriftUserPlaylistListDataSource', () {
    late BujuanDriftDatabase database;
    late DriftUserPlaylistListDataSource dataSource;

    setUp(() {
      database = BujuanDriftDatabase.connect(NativeDatabase.memory());
      dataSource = DriftUserPlaylistListDataSource(
        dao: PlaylistDao(database: database),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('stores playlist summaries in playlists table and loads refs in order', () async {
      await dataSource.replacePlaylistItems(
        'user',
        UserPlaylistListKind.userPlaylists,
        const [
          PlaylistSummaryData(id: '1', title: 'First', coverUrl: 'cover-1', trackCount: 10),
          PlaylistSummaryData(id: '2', title: 'Second', coverUrl: 'cover-2', trackCount: 20),
        ],
      );

      final items = await dataSource.loadPlaylistItems(
        'user',
        UserPlaylistListKind.userPlaylists,
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

    test('normalizes scoped playlist list keys at dao boundary', () async {
      await dataSource.replacePlaylistItems(
        ' user ',
        UserPlaylistListKind.userPlaylists,
        const [
          PlaylistSummaryData(id: ' 1 ', title: 'Daily Mix'),
          PlaylistSummaryData(id: ' ', title: 'Blank Playlist'),
        ],
      );
      await dataSource.appendPlaylistItems(
        'user',
        UserPlaylistListKind.userPlaylists,
        const [
          PlaylistSummaryData(id: ' netease:2 ', title: 'Evening Focus'),
        ],
        startOrder: 1,
      );
      await dataSource.replacePlaylistItems(
        ' ',
        UserPlaylistListKind.likedCollection,
        const [
          PlaylistSummaryData(id: '3', title: 'Blank User Playlist'),
        ],
      );

      final normalized = await dataSource.loadPlaylistItems(
        'user',
        UserPlaylistListKind.userPlaylists,
      );
      final spaced = await dataSource.loadPlaylistItems(
        ' user ',
        UserPlaylistListKind.userPlaylists,
      );
      final blank = await dataSource.loadPlaylistItems(
        ' ',
        UserPlaylistListKind.likedCollection,
      );
      final searchItems = await dataSource.searchPlaylistItems(' user ', 'Focus');
      final playlistRows = await database.select(database.playlists).get();

      expect(normalized.map((item) => item.id), ['1', '2']);
      expect(spaced.map((item) => item.id), ['1', '2']);
      expect(blank, isEmpty);
      expect(searchItems.map((item) => item.id), ['2']);
      expect(playlistRows.map((row) => row.playlistId).toSet(), {
        'netease:1',
        'netease:2',
      });
    });
  });
}
