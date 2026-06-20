import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/features/explore/explore_page_controller.dart';
import 'package:bujuan/features/explore/explore_playlist_catalogue_data.dart';
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExplorePageController', () {
    test('keeps ranking songs when first page refresh fails', () async {
      final controller = _buildController(
        playlistRepository: _FakePlaylistRepository(
          fetchSongsError: Exception('offline'),
        ),
      );
      addTearDown(controller.onClose);
      controller.curTopPlayListId.value = 'ranking-1';
      controller.curTopPlayListSongs.add(_song('cached-song'));

      await controller.updateRankingPlayListSongs(force: true);

      expect(controller.curTopPlayListSongs.map((song) => song.id), ['cached-song']);
    });

    test('ends loading and keeps visible data when refresh fails', () async {
      final controller = _buildController(
        exploreRepository: _FakeExploreRepository(
          fetchPlaylistCatalogueError: Exception('offline'),
        ),
      );
      addTearDown(controller.onClose);
      controller.loading.value = true;
      controller.playLists.add(
        const PlaylistSummaryData(id: 'playlist-1', title: 'Playlist 1'),
      );

      await controller.updateData(force: true);

      expect(controller.loading.value, isFalse);
      expect(controller.playLists.map((playlist) => playlist.id), ['playlist-1']);
    });
  });
}

ExplorePageController _buildController({
  _FakeExploreRepository? exploreRepository,
  _FakePlaylistRepository? playlistRepository,
}) {
  return ExplorePageController(
    exploreRepository: exploreRepository ?? _FakeExploreRepository(),
    playlistRepository: playlistRepository ?? _FakePlaylistRepository(),
    likedSongIds: () => const [],
    currentUserId: () => 'user-1',
  );
}

PlaybackQueueItem _song(String id) {
  return PlaybackQueueItem(
    id: id,
    sourceId: id,
    title: 'Song $id',
    albumTitle: 'Album',
    artistNames: const ['Artist'],
    artistIds: const ['artist-1'],
    duration: const Duration(minutes: 3),
    artworkUrl: null,
    localArtworkPath: null,
    mediaType: MediaType.playlist,
    playbackUrl: null,
    lyricKey: null,
    isLiked: false,
    isCached: false,
  );
}

class _FakeExploreRepository implements ExploreRepository {
  _FakeExploreRepository({this.fetchPlaylistCatalogueError});

  final Object? fetchPlaylistCatalogueError;

  @override
  Future<ExplorePlaylistCatalogueData?> loadCachedPlaylistCatalogue() async {
    return null;
  }

  @override
  Future<bool> isPlaylistCatalogueFresh({required Duration ttl}) async {
    return false;
  }

  @override
  Future<ExplorePlaylistCatalogueData> fetchPlaylistCatalogue() async {
    final error = fetchPlaylistCatalogueError;
    if (error != null) {
      throw error;
    }
    return const ExplorePlaylistCatalogueData(
      categoryNames: ['默认'],
      tagsByCategory: {
        '默认': ['全部'],
      },
    );
  }

  @override
  Future<List<PlaylistSummaryData>?> loadCachedCategoryPlaylists(
    String category,
  ) async {
    return null;
  }

  @override
  Future<bool> isCategoryPlaylistsFresh(
    String category, {
    required Duration ttl,
  }) async {
    return false;
  }

  @override
  Future<List<PlaylistSummaryData>> fetchCategoryPlaylists(String category) async {
    return const [];
  }
}

class _FakePlaylistRepository implements PlaylistRepository {
  _FakePlaylistRepository({this.fetchSongsError});

  final Object? fetchSongsError;

  @override
  Future<List<PlaybackQueueItem>> fetchPlaylistSongs({
    required String playlistId,
    required List<int> likedSongIds,
    int offset = 0,
    int limit = -1,
    PlaylistIndexData? playlistIndex,
    bool persist = true,
  }) async {
    final error = fetchSongsError;
    if (error != null) {
      throw error;
    }
    return const [];
  }

  @override
  Future<bool> isCacheFresh(
    String playlistId, {
    required Duration ttl,
  }) async {
    return false;
  }

  @override
  Future<PlaylistDetailData?> loadLocalPlaylistDetail({
    required String playlistId,
    required List<int> likedSongIds,
    required String? currentUserId,
  }) async {
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
