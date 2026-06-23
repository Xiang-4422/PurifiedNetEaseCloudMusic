import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/features/album/album_page_controller.dart';
import 'package:bujuan/features/album/album_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlbumPageController', () {
    test('falls back to null local detail when local cache read fails', () async {
      final controller = AlbumPageController(
        repository: _FakeAlbumRepository(
          loadLocalAlbumDetailError: StateError('broken album cache'),
        ),
        likedSongIds: () => const [1],
      );

      await expectLater(controller.loadLocalDetail('album-1'), completion(isNull));
    });

    test('passes liked song ids to album repository calls', () async {
      final repository = _FakeAlbumRepository();
      final controller = AlbumPageController(
        repository: repository,
        likedSongIds: () => const [1, 2],
      );

      await controller.loadLocalDetail('album-1');
      await controller.fetchDetail('album-1');

      expect(repository.localLikedSongIds, [1, 2]);
      expect(repository.remoteLikedSongIds, [1, 2]);
    });
  });
}

class _FakeAlbumRepository implements AlbumRepository {
  _FakeAlbumRepository({this.loadLocalAlbumDetailError});

  final Object? loadLocalAlbumDetailError;
  List<int> localLikedSongIds = const [];
  List<int> remoteLikedSongIds = const [];

  @override
  Future<AlbumDetailData?> loadLocalAlbumDetail({
    required String albumId,
    required List<int> likedSongIds,
  }) async {
    localLikedSongIds = likedSongIds;
    final error = loadLocalAlbumDetailError;
    if (error != null) {
      throw error;
    }
    return AlbumDetailData(
      album: _album(albumId),
      albumSongs: const [],
    );
  }

  @override
  Future<AlbumDetailData> fetchAlbumDetail({
    required String albumId,
    required List<int> likedSongIds,
  }) async {
    remoteLikedSongIds = likedSongIds;
    return AlbumDetailData(
      album: _album(albumId),
      albumSongs: const [],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

AlbumEntity _album(String sourceId) {
  return AlbumEntity(
    id: 'netease:$sourceId',
    sourceType: SourceType.netease,
    sourceId: sourceId,
    title: 'Album $sourceId',
  );
}
