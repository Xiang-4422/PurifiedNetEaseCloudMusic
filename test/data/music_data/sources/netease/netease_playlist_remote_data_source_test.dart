import 'package:bujuan/data/music_data/sources/netease/remote/netease_playlist_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/netease_music_api.dart';

void main() {
  group('NeteasePlaylistRemoteDataSource', () {
    test('normalizes playlist id before fetching index', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteasePlaylistRemoteDataSource(api: api);

      await dataSource.fetchPlaylistIndex(' netease:playlist-1 ');

      expect(api.playlistDetailIds, ['playlist-1']);
    });

    test('normalizes song ids before fetching paged playlist songs', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteasePlaylistRemoteDataSource(api: api);

      await dataSource.fetchPlaylistSongs(
        songIds: const [
          ' netease:1 ',
          ' local:skip ',
          ' 2 ',
          ' ',
        ],
        offset: 0,
        limit: 10,
      );

      expect(api.songDetailBatches, [
        ['1', '2'],
      ]);
    });

    test('normalizes playlist id before toggling subscription', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteasePlaylistRemoteDataSource(api: api);

      await dataSource.toggleSubscription(
        ' netease:playlist-1 ',
        subscribe: false,
      );

      expect(api.subscribeRequests, [
        (playlistId: 'playlist-1', subscribe: false),
      ]);
    });

    test('normalizes playlist and song ids before manipulating tracks', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteasePlaylistRemoteDataSource(api: api);

      await dataSource.manipulateTracks(
        ' netease:playlist-1 ',
        ' netease:1 ',
        add: true,
      );

      expect(api.manipulateRequests, [
        (playlistId: 'playlist-1', songId: '1', add: true),
      ]);
    });

    test('rejects invalid playlist or song ids before SDK requests', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteasePlaylistRemoteDataSource(api: api);

      await expectLater(
        dataSource.fetchPlaylistIndex(' local:playlist-1 '),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        dataSource.toggleSubscription(' ', subscribe: true),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        dataSource.manipulateTracks(
          ' netease:playlist-1 ',
          ' local:1 ',
          add: true,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(api.playlistDetailIds, isEmpty);
      expect(api.subscribeRequests, isEmpty);
      expect(api.manipulateRequests, isEmpty);
    });
  });
}

class _FakeNeteaseMusicApi implements NeteaseMusicApi {
  final playlistDetailIds = <String>[];
  final songDetailBatches = <List<String>>[];
  final subscribeRequests = <({String playlistId, bool subscribe})>[];
  final manipulateRequests = <({String playlistId, String songId, bool add})>[];

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
  Future<SongDetailWrap> songDetail(List<String> songIds) async {
    songDetailBatches.add(songIds);
    return SongDetailWrap()
      ..code = 200
      ..songs = const [];
  }

  @override
  Future<SinglePlayListWrap> subscribePlayList(
    String pid, {
    bool subscribe = true,
  }) async {
    subscribeRequests.add((playlistId: pid, subscribe: subscribe));
    return SinglePlayListWrap()
      ..code = 200
      ..message = 'ok';
  }

  @override
  Future<SinglePlayListWrap> playlistManipulateTracks(
    String pid,
    String trackId,
    bool add,
  ) async {
    manipulateRequests.add((playlistId: pid, songId: trackId, add: add));
    return SinglePlayListWrap()
      ..code = 200
      ..message = 'ok';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
