import 'package:bujuan/data/music_data/sources/netease/netease_music_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/netease_music_api.dart';

void main() {
  group('NeteaseMusicSource', () {
    test('normalizes track id before fetching track detail', () async {
      final api = _FakeNeteaseMusicApi();
      final source = NeteaseMusicSource(api: api);

      final track = await source.getTrack(' netease:1 ');

      expect(track, isNull);
      expect(api.songDetailBatches, [
        ['1'],
      ]);
    });

    test('normalizes playback url and lyric track ids', () async {
      final api = _FakeNeteaseMusicApi();
      final source = NeteaseMusicSource(api: api);

      final playbackUrl = await source.getPlaybackUrl(
        ' netease:1 ',
        qualityLevel: 'lossless',
      );
      final lyrics = await source.getLyrics(' netease:2 ');

      expect(playbackUrl, 'https://audio.test/1-lossless.mp3');
      expect(lyrics?.main, 'main-2');
      expect(lyrics?.translated, 'translated-2');
      expect(api.downloadRequests.single.songIds, ['1']);
      expect(api.downloadRequests.single.level, 'lossless');
      expect(api.lyricIds, ['2']);
    });

    test('normalizes playlist id before fetching playlist detail', () async {
      final api = _FakeNeteaseMusicApi();
      final source = NeteaseMusicSource(api: api);

      final playlist = await source.getPlaylist(' netease:playlist-1 ');

      expect(playlist, isNull);
      expect(api.playlistDetailIds, ['playlist-1']);
    });

    test('rejects invalid ids before SDK requests', () async {
      final api = _FakeNeteaseMusicApi();
      final source = NeteaseMusicSource(api: api);

      expect(await source.getTrack(' local:1 '), isNull);
      expect(await source.getPlaybackUrl(' local:1 '), isNull);
      expect(await source.getLyrics(' local:1 '), isNull);
      expect(await source.getPlaylist(' local:playlist-1 '), isNull);

      expect(api.songDetailBatches, isEmpty);
      expect(api.downloadRequests, isEmpty);
      expect(api.lyricIds, isEmpty);
      expect(api.playlistDetailIds, isEmpty);
    });
  });
}

class _FakeNeteaseMusicApi implements NeteaseMusicApi {
  final songDetailBatches = <List<String>>[];
  final downloadRequests = <({List<String> songIds, String level})>[];
  final lyricIds = <String>[];
  final playlistDetailIds = <String>[];

  @override
  Future<SongDetailWrap> songDetail(List<String> songIds) async {
    songDetailBatches.add(songIds);
    return SongDetailWrap()
      ..code = 200
      ..songs = const [];
  }

  @override
  Future<SongUrlListWrap> songDownloadUrl(
    List<String> songIds, {
    String level = 'exhigh',
  }) async {
    downloadRequests.add((songIds: songIds, level: level));
    return SongUrlListWrap()
      ..code = 200
      ..data = [
        SongUrl()
          ..id = songIds.first
          ..url = 'https://audio.test/${songIds.first}-$level.mp3',
      ];
  }

  @override
  Future<SongLyricWrap> songLyric(String songId) async {
    lyricIds.add(songId);
    return SongLyricWrap()
      ..code = 200
      ..lrc = (Lyrics2()..lyric = 'main-$songId')
      ..tlyric = (Lyrics2()..lyric = 'translated-$songId');
  }

  @override
  Future<SinglePlayListWrap> playListDetail(
    String categoryId, {
    int subCount = 5,
  }) async {
    playlistDetailIds.add(categoryId);
    return SinglePlayListWrap()
      ..code = 200
      ..playlist = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
