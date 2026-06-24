import 'package:bujuan/data/music_data/sources/netease/remote/netease_cloud_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/netease_music_api.dart';

void main() {
  group('NeteaseCloudRemoteDataSource', () {
    test('normalizes negative page offsets before SDK requests', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseCloudRemoteDataSource(api: api);

      final page = await dataSource.fetchCloudSongs(offset: -10, limit: 30);

      expect(page.tracks, isEmpty);
      expect(page.itemCount, 0);
      expect(api.cloudRequests, [(offset: 0, limit: 30)]);
    });

    test('rejects non-positive page limits before SDK requests', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseCloudRemoteDataSource(api: api);

      final zeroPage = await dataSource.fetchCloudSongs(offset: 0, limit: 0);
      final negativePage = await dataSource.fetchCloudSongs(
        offset: 0,
        limit: -1,
      );

      expect(zeroPage.tracks, isEmpty);
      expect(zeroPage.itemCount, 0);
      expect(negativePage.tracks, isEmpty);
      expect(negativePage.itemCount, 0);
      expect(api.cloudRequests, isEmpty);
    });
  });
}

class _FakeNeteaseMusicApi implements NeteaseMusicApi {
  final cloudRequests = <({int offset, int limit})>[];

  @override
  Future<CloudSongListWrap> cloudSong({
    int offset = 0,
    int limit = 30,
  }) async {
    cloudRequests.add((offset: offset, limit: limit));
    return CloudSongListWrap()
      ..code = 200
      ..data = const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
