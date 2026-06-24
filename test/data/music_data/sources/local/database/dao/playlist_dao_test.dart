import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/playlist_track_ref.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/playlist_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart' as drift_db;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaylistDao', () {
    late drift_db.BujuanDriftDatabase database;
    late PlaylistDao dao;

    setUp(() {
      database = drift_db.BujuanDriftDatabase.connect(NativeDatabase.memory());
      dao = PlaylistDao(database: database);
    });

    tearDown(() async {
      await database.close();
    });

    test('normalizes playlist ids and track refs before persistence', () async {
      await dao.savePlaylists([
        _playlist(
          id: ' 123 ',
          trackRefs: const [
            PlaylistTrackRef(trackId: ' 1 ', order: 2),
            PlaylistTrackRef(trackId: 'netease:1', order: 3),
            PlaylistTrackRef(trackId: ' ', order: 4),
            PlaylistTrackRef(trackId: ' local:2 ', order: 5),
          ],
        ),
        _playlist(id: '   '),
      ]);

      final playlist = await dao.getPlaylist(' 123 ');
      final searchResult = await dao.searchPlaylists(' Playlist ');
      final refsByPlaylistId = await dao.loadTrackRefsByPlaylistIds(const [
        ' ',
        ' 123 ',
        'netease:123',
      ]);
      final playlistRows = await database.select(database.playlists).get();
      final refRows = await database.select(database.playlistTrackRefs).get();

      expect(playlistRows.map((row) => row.playlistId), ['netease:123']);
      expect(playlistRows.single.sourceType, SourceType.netease.name);
      expect(playlistRows.single.sourceId, '123');
      expect(playlist?.id, 'netease:123');
      expect(playlist?.sourceId, '123');
      expect(
        playlist?.trackRefs.map((ref) => ref.trackId),
        ['netease:1', 'local:2'],
      );
      expect(searchResult.map((item) => item.id), ['netease:123']);
      expect(refsByPlaylistId.keys, ['netease:123']);
      expect(
        refsByPlaylistId['netease:123']?.map((ref) => ref.trackId),
        ['netease:1', 'local:2'],
      );
      expect(refRows.map((row) => row.playlistId).toSet(), {'netease:123'});
      expect(refRows.map((row) => row.trackId).toSet(), {
        'netease:1',
        'local:2',
      });

      await dao.clearPlaylistTrackRefs(' 123 ');
      final clearedRefs = await dao.loadTrackRefsByPlaylistIds(const ['netease:123']);
      expect(clearedRefs['netease:123'], isNull);
    });

    test('ignores blank playlist ids before touching playlist tables', () async {
      await dao.savePlaylists([
        _playlist(id: '   '),
      ]);
      await dao.clearPlaylistTrackRefs('   ');

      expect(await dao.getPlaylist('   '), isNull);
      expect(await dao.loadTrackRefsByPlaylistIds(const ['   ', '\t']), isEmpty);
      expect(await database.select(database.playlists).get(), isEmpty);
      expect(await database.select(database.playlistTrackRefs).get(), isEmpty);
    });
  });
}

PlaylistEntity _playlist({
  required String id,
  List<PlaylistTrackRef> trackRefs = const [],
}) {
  return PlaylistEntity(
    id: id,
    sourceType: SourceType.netease,
    sourceId: id.trim(),
    title: 'Playlist',
    trackRefs: trackRefs,
  );
}
