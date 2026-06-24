import 'package:bujuan/data/music_data/sources/netease/mappers/netease_playlist_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/netease_music_api.dart';

void main() {
  group('NeteasePlaylistMapper', () {
    test('normalizes playlist ids before building domain playlist', () {
      final playlist = NeteasePlaylistMapper.fromPlaylist(_playlist('  10  '));

      expect(playlist.id, 'netease:10');
      expect(playlist.sourceId, '10');
    });

    test('normalizes track refs and skips blank track ids', () {
      final playlist = NeteasePlaylistMapper.fromPlaylist(
        _playlist(
          '10',
          trackIds: [
            _trackId('  1  '),
            _trackId('   '),
            _trackId('  2  '),
          ],
        ),
      );

      expect(
        playlist.trackRefs.map((ref) => '${ref.order}:${ref.trackId}'),
        ['0:netease:1', '1:netease:2'],
      );
    });

    test('skips blank playlist ids in batch mapper', () {
      final playlists = NeteasePlaylistMapper.fromPlaylistList([
        _playlist('  10  '),
        _playlist('   '),
        _playlist('  20  '),
      ]);

      expect(playlists.map((playlist) => playlist.id), ['netease:10', 'netease:20']);
    });
  });
}

PlayList _playlist(
  String id, {
  List<PlayTrackId> trackIds = const [],
}) {
  return PlayList()
    ..id = id
    ..name = 'Playlist'
    ..trackIds = trackIds;
}

PlayTrackId _trackId(String id) {
  return PlayTrackId()..id = id;
}
