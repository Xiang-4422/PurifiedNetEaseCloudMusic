import 'package:bujuan/data/music_data/sources/netease/remote/netease_album_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_artist_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/netease_music_api.dart';

void main() {
  group('NeteaseAlbumRemoteDataSource', () {
    test('normalizes album id before SDK request', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseAlbumRemoteDataSource(api: api);

      await dataSource.fetchAlbumDetail(albumId: ' netease:album-1 ');

      expect(api.albumDetailIds, ['album-1']);
    });

    test('rejects non-netease album id before SDK request', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseAlbumRemoteDataSource(api: api);

      await expectLater(
        dataSource.fetchAlbumDetail(albumId: ' local:album-1 '),
        throwsA(isA<ArgumentError>()),
      );
      expect(api.albumDetailIds, isEmpty);
    });
  });

  group('NeteaseArtistRemoteDataSource', () {
    test('normalizes artist id before all SDK requests', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseArtistRemoteDataSource(api: api);

      await dataSource.fetchArtistDetail(artistId: ' netease:artist-1 ');

      expect(api.artistDetailIds, ['artist-1']);
      expect(api.artistTopSongIds, ['artist-1']);
      expect(api.artistAlbumIds, ['artist-1']);
    });

    test('rejects non-netease artist id before SDK request', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseArtistRemoteDataSource(api: api);

      await expectLater(
        dataSource.fetchArtistDetail(artistId: ' local:artist-1 '),
        throwsA(isA<ArgumentError>()),
      );
      expect(api.artistDetailIds, isEmpty);
      expect(api.artistTopSongIds, isEmpty);
      expect(api.artistAlbumIds, isEmpty);
    });
  });
}

class _FakeNeteaseMusicApi implements NeteaseMusicApi {
  final albumDetailIds = <String>[];
  final artistDetailIds = <String>[];
  final artistTopSongIds = <String>[];
  final artistAlbumIds = <String>[];

  @override
  Future<AlbumDetailWrap> albumDetail(String albumId) async {
    albumDetailIds.add(albumId);
    return AlbumDetailWrap()
      ..code = 200
      ..album = null
      ..songs = const [];
  }

  @override
  Future<ArtistDetailWrap> artistDetail(String artistId) async {
    artistDetailIds.add(artistId);
    return ArtistDetailWrap()
      ..code = 200
      ..data = ArtistDetailData();
  }

  @override
  Future<ArtistSongListWrap> artistTopSongList(String artistId) async {
    artistTopSongIds.add(artistId);
    return ArtistSongListWrap()
      ..code = 200
      ..songs = const [];
  }

  @override
  Future<ArtistAlbumListWrap> artistAlbumList(
    String artistId, {
    int offset = 0,
    int limit = 30,
    bool total = true,
  }) async {
    artistAlbumIds.add(artistId);
    return ArtistAlbumListWrap()
      ..code = 200
      ..hotAlbums = const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
