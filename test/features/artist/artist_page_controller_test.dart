import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/features/artist/artist_page_controller.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArtistPageController', () {
    test('falls back to null local detail when local cache read fails', () async {
      final controller = ArtistPageController(
        repository: _FakeArtistRepository(
          loadLocalArtistDetailError: StateError('broken artist cache'),
        ),
        likedSongIds: () => const [1],
      );

      await expectLater(controller.loadLocalDetail('artist-1'), completion(isNull));
    });

    test('loads initial detail as local first and marks background refresh', () async {
      final controller = ArtistPageController(
        repository: _FakeArtistRepository(),
        likedSongIds: () => const [1],
      );

      final initialData = await controller.loadInitialDetail('artist-1');

      expect(initialData.localDetail?.artist.sourceId, 'artist-1');
      expect(initialData.hasLocalDetail, isTrue);
      expect(initialData.shouldRefreshInBackground, isTrue);
    });

    test('loads initial detail as empty when local cache read fails', () async {
      final controller = ArtistPageController(
        repository: _FakeArtistRepository(
          loadLocalArtistDetailError: StateError('broken artist cache'),
        ),
        likedSongIds: () => const [1],
      );

      final initialData = await controller.loadInitialDetail('artist-1');

      expect(initialData.localDetail, isNull);
      expect(initialData.hasLocalDetail, isFalse);
      expect(initialData.shouldRefreshInBackground, isFalse);
    });

    test('passes normalized liked song ids to artist repository calls', () async {
      final repository = _FakeArtistRepository();
      final controller = ArtistPageController(
        repository: repository,
        likedSongIds: () => const [2, 1, 2],
      );

      await controller.loadLocalDetail('artist-1');
      await controller.fetchDetail('artist-1');

      expect(repository.localLikedSongIds, [1, 2]);
      expect(repository.remoteLikedSongIds, [1, 2]);
    });
  });
}

class _FakeArtistRepository implements ArtistRepository {
  _FakeArtistRepository({this.loadLocalArtistDetailError});

  final Object? loadLocalArtistDetailError;
  List<int> localLikedSongIds = const [];
  List<int> remoteLikedSongIds = const [];

  @override
  Future<ArtistDetailData?> loadLocalArtistDetail({
    required String artistId,
    required List<int> likedSongIds,
  }) async {
    localLikedSongIds = likedSongIds;
    final error = loadLocalArtistDetailError;
    if (error != null) {
      throw error;
    }
    return ArtistDetailData(
      artist: _artist(artistId),
      topSongs: const [],
      hotAlbums: const [],
    );
  }

  @override
  Future<ArtistDetailData> fetchArtistDetail({
    required String artistId,
    required List<int> likedSongIds,
  }) async {
    remoteLikedSongIds = likedSongIds;
    return ArtistDetailData(
      artist: _artist(artistId),
      topSongs: const [],
      hotAlbums: const [],
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

ArtistEntity _artist(String sourceId) {
  return ArtistEntity(
    id: 'netease:$sourceId',
    sourceType: SourceType.netease,
    sourceId: sourceId,
    name: 'Artist $sourceId',
  );
}
