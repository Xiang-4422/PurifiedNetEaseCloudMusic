import 'package:bujuan/data/music_data/sources/netease/mappers/netease_album_mapper.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_artist_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/netease_music_api.dart';

void main() {
  group('NeteaseAlbumMapper', () {
    test('normalizes album ids before building domain album', () {
      final album = NeteaseAlbumMapper.fromAlbum(_album('  10  '));

      expect(album.id, 'netease:10');
      expect(album.sourceId, '10');
    });

    test('skips blank album ids in batch mapper', () {
      final albums = NeteaseAlbumMapper.fromAlbumList([
        _album('  10  '),
        _album('   '),
        _album('  20  '),
      ]);

      expect(albums.map((album) => album.id), ['netease:10', 'netease:20']);
    });
  });

  group('NeteaseArtistMapper', () {
    test('normalizes artist ids before building domain artist', () {
      final artist = NeteaseArtistMapper.fromArtist(_artist('  30  '));

      expect(artist.id, 'netease:30');
      expect(artist.sourceId, '30');
    });

    test('skips blank artist ids in batch mapper', () {
      final artists = NeteaseArtistMapper.fromArtistList([
        _artist('  30  '),
        _artist('   '),
        _artist('  40  '),
      ]);

      expect(artists.map((artist) => artist.id), ['netease:30', 'netease:40']);
    });
  });
}

Album _album(String id) {
  return Album()
    ..id = id
    ..name = 'Album';
}

Artist _artist(String id) {
  return Artist()
    ..id = id
    ..name = 'Artist';
}
