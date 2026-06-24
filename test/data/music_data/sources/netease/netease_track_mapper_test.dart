import 'package:bujuan/data/music_data/sources/netease/mappers/netease_track_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/netease_music_api.dart';

void main() {
  group('NeteaseTrackMapper', () {
    test('normalizes Song ids before building domain tracks', () {
      final track = NeteaseTrackMapper.fromSong(_song('  1  '));

      expect(track.id, 'netease:1');
      expect(track.sourceId, '1');
      expect(track.lyricKey, 'netease:1');
    });

    test('normalizes Song album and artist ids before building domain tracks', () {
      final track = NeteaseTrackMapper.fromSong(
        _song(
          '1',
          albumId: '  10  ',
          artistIds: const ['  20  ', '   ', '  30  '],
        ),
      );

      expect(track.albumId, '10');
      expect(track.artistIds, ['20', '30']);
    });

    test('normalizes Song2 ids before building domain tracks', () {
      final track = NeteaseTrackMapper.fromSong2(_song2('  2  '));

      expect(track.id, 'netease:2');
      expect(track.sourceId, '2');
      expect(track.lyricKey, 'netease:2');
    });

    test('normalizes Song2 album and artist ids before building domain tracks', () {
      final track = NeteaseTrackMapper.fromSong2(
        _song2(
          '2',
          albumId: '  11  ',
          artistIds: const ['  21  ', '   ', '  31  '],
        ),
      );

      expect(track.albumId, '11');
      expect(track.artistIds, ['21', '31']);
    });

    test('skips blank ids in batch mappers', () {
      final oldTracks = NeteaseTrackMapper.fromSongList([
        _song('  1  '),
        _song('   '),
      ]);
      final newTracks = NeteaseTrackMapper.fromSong2List([
        _song2('  2  '),
        _song2('   '),
      ]);

      expect(oldTracks.map((track) => track.sourceId), ['1']);
      expect(newTracks.map((track) => track.sourceId), ['2']);
    });

    test('normalizes and filters cloud song ids through simple song data', () {
      final tracks = NeteaseTrackMapper.fromCloudSongList([
        _cloudSong(_song2('  3  ')),
        _cloudSong(_song2('   ')),
      ]);

      expect(tracks.map((track) => track.id), ['netease:3']);
      expect(tracks.map((track) => track.sourceId), ['3']);
    });
  });
}

Song _song(
  String id, {
  String? albumId,
  List<String> artistIds = const [],
}) {
  return Song()
    ..id = id
    ..name = 'Song'
    ..album = (Album()
      ..id = albumId ?? '10'
      ..name = 'Album')
    ..artists = artistIds.map(_artist).toList();
}

Song2 _song2(
  String id, {
  String? albumId,
  List<String> artistIds = const [],
}) {
  return Song2()
    ..id = id
    ..name = 'Song'
    ..al = (Album()
      ..id = albumId ?? '10'
      ..name = 'Album')
    ..ar = artistIds.map(_artist).toList();
}

CloudSongItem _cloudSong(Song2 song) {
  return CloudSongItem()
    ..simpleSong = song
    ..songId = song.id
    ..fileName = 'song.mp3'
    ..addTime = 1700000000000;
}

Artist _artist(String id) {
  return Artist()
    ..id = id
    ..name = 'Artist';
}
