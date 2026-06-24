import 'package:bujuan/data/music_data/sources/netease/remote/netease_user_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/netease_music_api.dart';

void main() {
  group('NeteaseUserRemoteDataSource', () {
    test('normalizes heartbeat song ids before SDK request', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseUserRemoteDataSource(api: api);

      await dataSource.fetchHeartBeatSongs(
        startSongId: ' netease:1 ',
        randomLikedSongId: ' netease:2 ',
        fromPlayAll: true,
      );

      expect(api.heartbeatRequests, [
        (songId: '1', playlistId: '2', fromPlayAll: true, count: 20),
      ]);
    });

    test('normalizes song ids before fetching songs by ids', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseUserRemoteDataSource(api: api);

      await dataSource.fetchSongsByIds(
        ids: const [
          ' netease:1 ',
          ' local:skip ',
          ' 2 ',
          ' ',
        ],
      );

      expect(api.songDetailBatches, [
        ['1', '2'],
      ]);
    });

    test('normalizes song id before fetching album artwork', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseUserRemoteDataSource(api: api);

      await dataSource.fetchSongAlbumUrl(' netease:1 ');

      expect(api.songDetailBatches, [
        ['1'],
      ]);
    });

    test('normalizes song id before toggling like state', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseUserRemoteDataSource(api: api);

      final result = await dataSource.toggleLikeSong(' netease:1 ', false);

      expect(result.success, isTrue);
      expect(api.likeSongRequests, [
        (songId: '1', like: false),
      ]);
    });

    test('rejects invalid song ids before SDK requests', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseUserRemoteDataSource(api: api);

      expect(
        await dataSource.fetchHeartBeatSongs(
          startSongId: ' local:1 ',
          randomLikedSongId: ' netease:2 ',
          fromPlayAll: true,
        ),
        isEmpty,
      );
      expect(
        await dataSource.fetchSongsByIds(ids: const [' local:1 ', ' ']),
        isEmpty,
      );
      expect(await dataSource.fetchSongAlbumUrl(' local:1 '), isEmpty);

      final likeResult = await dataSource.toggleLikeSong(' local:1 ', true);

      expect(likeResult.success, isFalse);
      expect(api.heartbeatRequests, isEmpty);
      expect(api.songDetailBatches, isEmpty);
      expect(api.likeSongRequests, isEmpty);
    });
  });
}

class _FakeNeteaseMusicApi implements NeteaseMusicApi {
  final heartbeatRequests = <({
    String songId,
    String playlistId,
    bool fromPlayAll,
    int count,
  })>[];
  final songDetailBatches = <List<String>>[];
  final likeSongRequests = <({String songId, bool like})>[];

  @override
  Future<PlaymodeIntelligenceListWrap> playmodeIntelligenceList(
    String songId,
    String playlistId,
    bool fromPlayAll, {
    String? startMusicId,
    int count = 1,
  }) async {
    heartbeatRequests.add(
      (
        songId: songId,
        playlistId: playlistId,
        fromPlayAll: fromPlayAll,
        count: count,
      ),
    );
    return PlaymodeIntelligenceListWrap()
      ..code = 200
      ..data = const [];
  }

  @override
  Future<SongDetailWrap> songDetail(List<String> songIds) async {
    songDetailBatches.add(songIds);
    return SongDetailWrap()
      ..code = 200
      ..songs = const [];
  }

  @override
  Future<SinglePlayListWrap> likeSong(
    String songId,
    bool like, {
    int time = 3,
    String alg = 'itembased',
  }) async {
    likeSongRequests.add((songId: songId, like: like));
    return SinglePlayListWrap()
      ..code = 200
      ..message = 'ok';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
