import 'dart:async';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/features/explore/explore_page_controller.dart';
import 'package:bujuan/features/explore/explore_playlist_catalogue_data.dart';
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/playlist/playlist_detail_data.dart';
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

    test('ignores stale category playlist responses after tag changes', () async {
      final categoryRequests = <String, Completer<List<PlaylistSummaryData>>>{};
      final controller = _buildController(
        exploreRepository: _FakeExploreRepository(
          fetchCategoryPlaylistsHandler: (category) {
            final completer = Completer<List<PlaylistSummaryData>>();
            categoryRequests[category] = completer;
            return completer.future;
          },
        ),
      );
      addTearDown(controller.onClose);

      controller.curTag.value = '华语';
      final oldLoad = controller.updatePlayLists(force: true);
      controller.curTag.value = '摇滚';
      final currentLoad = controller.updatePlayLists(force: true);

      categoryRequests['摇滚']!.complete(
        const [PlaylistSummaryData(id: 'rock-playlist', title: 'Rock')],
      );
      await currentLoad;
      expect(controller.playLists.map((playlist) => playlist.id), ['rock-playlist']);

      categoryRequests['华语']!.complete(
        const [PlaylistSummaryData(id: 'old-playlist', title: 'Old')],
      );
      await oldLoad;

      expect(controller.curTag.value, '摇滚');
      expect(controller.playLists.map((playlist) => playlist.id), ['rock-playlist']);
    });

    test('falls back to remote category playlists when cached playlists load fails', () async {
      final controller = _buildController(
        exploreRepository: _FakeExploreRepository(
          cachedCategoryPlaylistsError: StateError('cache failed'),
          fetchCategoryPlaylistsHandler: (_) => Future.value(
            const [PlaylistSummaryData(id: 'remote-playlist', title: 'Remote')],
          ),
        ),
      );
      addTearDown(controller.onClose);
      controller.curTag.value = '全部';

      await controller.updatePlayLists();

      expect(controller.playLists.map((playlist) => playlist.id), ['remote-playlist']);
    });

    test('refreshes category playlists when cache freshness check fails', () async {
      final controller = _buildController(
        exploreRepository: _FakeExploreRepository(
          cachedCategoryPlaylists: const [PlaylistSummaryData(id: 'cached-playlist', title: 'Cached')],
          categoryPlaylistsFreshError: StateError('freshness failed'),
          fetchCategoryPlaylistsHandler: (_) => Future.value(
            const [PlaylistSummaryData(id: 'remote-playlist', title: 'Remote')],
          ),
        ),
      );
      addTearDown(controller.onClose);
      controller.curTag.value = '全部';

      await controller.updatePlayLists();

      expect(controller.playLists.map((playlist) => playlist.id), ['remote-playlist']);
    });

    test('ignores stale ranking load more responses after playlist changes', () async {
      final songRequests = <String, Completer<List<PlaybackQueueItem>>>{};
      final controller = _buildController(
        playlistRepository: _FakePlaylistRepository(
          fetchSongsHandler: ({
            required String playlistId,
            required List<int> likedSongIds,
            required int offset,
            required int limit,
          }) {
            final completer = Completer<List<PlaybackQueueItem>>();
            songRequests['$playlistId:$offset'] = completer;
            return completer.future;
          },
        ),
      );
      addTearDown(controller.onClose);
      controller.curTopPlayListId.value = 'ranking-a';
      controller.curTopPlayListSongs.add(_song('a-1'));

      final oldLoadMore = controller.updateRankingPlayListSongs(offset: 1);
      controller.curTopPlayListId.value = 'ranking-b';
      final currentLoad = controller.updateRankingPlayListSongs(force: true);

      songRequests['ranking-b:0']!.complete([_song('b-1')]);
      await currentLoad;
      expect(controller.curTopPlayListSongs.map((song) => song.id), ['b-1']);

      songRequests['ranking-a:1']!.complete([_song('a-2')]);
      await oldLoadMore;

      expect(controller.curTopPlayListId.value, 'ranking-b');
      expect(controller.curTopPlayListSongs.map((song) => song.id), ['b-1']);
    });

    test('falls back to remote ranking songs when cached detail load fails', () async {
      final controller = _buildController(
        playlistRepository: _FakePlaylistRepository(
          cachedDetailError: StateError('cache failed'),
          fetchSongsHandler: ({
            required String playlistId,
            required List<int> likedSongIds,
            required int offset,
            required int limit,
          }) {
            return Future.value([_song('remote-song')]);
          },
        ),
      );
      addTearDown(controller.onClose);
      controller.curTopPlayListId.value = 'ranking-1';

      await controller.updateRankingPlayListSongs();

      expect(controller.curTopPlayListSongs.map((song) => song.id), ['remote-song']);
    });

    test('normalizes current user id before ranking cache and stale checks', () async {
      var currentUserId = ' user-1 ';
      final songLoad = Completer<List<PlaybackQueueItem>>();
      final playlistRepository = _FakePlaylistRepository(
        fetchSongsHandler: ({
          required String playlistId,
          required List<int> likedSongIds,
          required int offset,
          required int limit,
        }) {
          return songLoad.future;
        },
      );
      final controller = _buildController(
        playlistRepository: playlistRepository,
        currentUserId: () => currentUserId,
      );
      addTearDown(controller.onClose);
      controller.curTopPlayListId.value = 'ranking-1';

      final load = controller.updateRankingPlayListSongs();
      await _waitUntil(() => playlistRepository.fetchLikedSongRequests.isNotEmpty);
      currentUserId = 'user-1';
      songLoad.complete([_song('remote-song')]);
      await load;

      expect(playlistRepository.loadLocalDetailUserIds, ['user-1']);
      expect(controller.curTopPlayListSongs.map((song) => song.id), ['remote-song']);
    });

    test('normalizes liked song ids before ranking cache and stale checks', () async {
      var likedSongIds = <int>[202, 101, 202];
      final songLoad = Completer<List<PlaybackQueueItem>>();
      final playlistRepository = _FakePlaylistRepository(
        fetchSongsHandler: ({
          required String playlistId,
          required List<int> likedSongIds,
          required int offset,
          required int limit,
        }) {
          return songLoad.future;
        },
      );
      final controller = _buildController(
        playlistRepository: playlistRepository,
        likedSongIds: () => likedSongIds,
      );
      addTearDown(controller.onClose);
      controller.curTopPlayListId.value = 'ranking-1';

      final load = controller.updateRankingPlayListSongs();
      await _waitUntil(() => playlistRepository.fetchLikedSongRequests.isNotEmpty);
      likedSongIds = <int>[101, 202];
      songLoad.complete([_song('remote-song')]);
      await load;

      expect(playlistRepository.loadLocalDetailLikedSongRequests, [
        [101, 202],
      ]);
      expect(playlistRepository.fetchLikedSongRequests, [
        [101, 202],
      ]);
      expect(controller.curTopPlayListSongs.map((song) => song.id), ['remote-song']);
    });

    test('resolves playlist playback plan with latest liked song ids', () async {
      var likedSongIds = <int>[101, 101];
      final playlistRepository = _FakePlaylistRepository(
        playlistIndex: const PlaylistIndexData(
          id: 'playlist-1',
          name: 'Remote Playlist',
          trackIds: ['netease:101'],
          isSubscribed: false,
          isLikedSongs: false,
        ),
        fetchSongsHandler: ({
          required String playlistId,
          required List<int> likedSongIds,
          required int offset,
          required int limit,
        }) {
          return Future.value([_song('song-${likedSongIds.join('-')}')]);
        },
      );
      final controller = _buildController(
        playlistRepository: playlistRepository,
        likedSongIds: () => likedSongIds,
      );
      addTearDown(controller.onClose);

      final firstPlan = await controller.resolvePlaylistPlayback(
        const PlaylistSummaryData(id: 'playlist-1', title: 'Playlist 1'),
      );
      likedSongIds = <int>[303, 202, 202];
      final secondPlan = await controller.resolvePlaylistPlayback(
        const PlaylistSummaryData(id: 'playlist-1', title: 'Playlist 1'),
      );

      expect(firstPlan.playlistName, 'Remote Playlist');
      expect(firstPlan.songs.single.id, 'song-101');
      expect(secondPlan.songs.single.id, 'song-202-303');
      expect(playlistRepository.indexLikedSongRequests, [
        [101],
        [202, 303],
      ]);
      expect(playlistRepository.fetchLikedSongRequests, [
        [101],
        [202, 303],
      ]);
      expect(playlistRepository.fetchPlaylistIndexNames, [
        'Remote Playlist',
        'Remote Playlist',
      ]);
    });

    test('waits for explore page visibility before bootstrap', () async {
      final visibility = _ManualExplorePageVisibility(isVisible: false);
      final exploreRepository = _FakeExploreRepository();
      final controller = _buildController(
        exploreRepository: exploreRepository,
        pageVisibility: visibility.boundary,
      );
      addTearDown(controller.onClose);

      controller.onReady();
      await Future<void>.delayed(Duration.zero);

      expect(exploreRepository.fetchPlaylistCatalogueCount, 0);

      visibility.show();
      await _waitUntil(() => exploreRepository.fetchPlaylistCatalogueCount == 1);

      expect(controller.loading.value, isFalse);
    });
  });
}

ExplorePageController _buildController({
  _FakeExploreRepository? exploreRepository,
  _FakePlaylistRepository? playlistRepository,
  List<int> Function()? likedSongIds,
  String Function()? currentUserId,
  ExplorePageVisibility? pageVisibility,
}) {
  return ExplorePageController(
    exploreRepository: exploreRepository ?? _FakeExploreRepository(),
    playlistRepository: playlistRepository ?? _FakePlaylistRepository(),
    likedSongIds: likedSongIds ?? () => const [],
    currentUserId: currentUserId ?? () => 'user-1',
    pageVisibility: pageVisibility ??
        ExplorePageVisibility(
          isVisible: () => true,
          watchVisible: (_) => () {},
        ),
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
  _FakeExploreRepository({
    this.cachedCategoryPlaylists,
    this.cachedCategoryPlaylistsError,
    this.categoryPlaylistsFreshError,
    this.fetchPlaylistCatalogueError,
    this.fetchCategoryPlaylistsHandler,
  });

  final List<PlaylistSummaryData>? cachedCategoryPlaylists;
  final Object? cachedCategoryPlaylistsError;
  final Object? categoryPlaylistsFreshError;
  final Object? fetchPlaylistCatalogueError;
  final Future<List<PlaylistSummaryData>> Function(String category)? fetchCategoryPlaylistsHandler;
  int fetchPlaylistCatalogueCount = 0;

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
    fetchPlaylistCatalogueCount++;
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
    final error = cachedCategoryPlaylistsError;
    if (error != null) {
      throw error;
    }
    return cachedCategoryPlaylists;
  }

  @override
  Future<bool> isCategoryPlaylistsFresh(
    String category, {
    required Duration ttl,
  }) async {
    final error = categoryPlaylistsFreshError;
    if (error != null) {
      throw error;
    }
    return false;
  }

  @override
  Future<List<PlaylistSummaryData>> fetchCategoryPlaylists(String category) async {
    final handler = fetchCategoryPlaylistsHandler;
    if (handler != null) {
      return handler(category);
    }
    return const [];
  }
}

Future<void> _waitUntil(bool Function() condition) async {
  final deadline = DateTime.now().add(const Duration(seconds: 1));
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('condition was not met before timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _ManualExplorePageVisibility {
  _ManualExplorePageVisibility({required bool isVisible}) : _isVisible = isVisible;

  bool _isVisible;
  void Function()? _onVisible;

  ExplorePageVisibility get boundary => ExplorePageVisibility(
        isVisible: () => _isVisible,
        watchVisible: (onVisible) {
          _onVisible = onVisible;
          return () {
            if (identical(_onVisible, onVisible)) {
              _onVisible = null;
            }
          };
        },
      );

  void show() {
    _isVisible = true;
    _onVisible?.call();
  }
}

class _FakePlaylistRepository implements PlaylistRepository {
  _FakePlaylistRepository({
    this.cachedDetailError,
    this.fetchSongsError,
    this.fetchSongsHandler,
    this.playlistIndex = const PlaylistIndexData(
      id: 'playlist',
      name: 'Playlist',
      trackIds: [],
      isSubscribed: false,
      isLikedSongs: false,
    ),
  });

  final Object? cachedDetailError;
  final Object? fetchSongsError;
  final PlaylistIndexData playlistIndex;
  final Future<List<PlaybackQueueItem>> Function({
    required String playlistId,
    required List<int> likedSongIds,
    required int offset,
    required int limit,
  })? fetchSongsHandler;
  final List<List<int>> indexLikedSongRequests = <List<int>>[];
  final List<List<int>> fetchLikedSongRequests = <List<int>>[];
  final List<List<int>> loadLocalDetailLikedSongRequests = <List<int>>[];
  final List<String> fetchPlaylistIndexNames = <String>[];
  final List<String?> loadLocalDetailUserIds = <String?>[];

  @override
  Future<PlaylistIndexData> fetchPlaylistIndex(
    String playlistId, {
    List<int> likedSongIds = const [],
    String? currentUserId,
  }) async {
    indexLikedSongRequests.add(List<int>.from(likedSongIds));
    return playlistIndex;
  }

  @override
  Future<List<PlaybackQueueItem>> fetchPlaylistSongs({
    required String playlistId,
    required List<int> likedSongIds,
    int offset = 0,
    int limit = -1,
    PlaylistIndexData? playlistIndex,
    bool persist = true,
  }) async {
    fetchLikedSongRequests.add(List<int>.from(likedSongIds));
    fetchPlaylistIndexNames.add(playlistIndex?.name ?? '');
    final handler = fetchSongsHandler;
    if (handler != null) {
      return handler(
        playlistId: playlistId,
        likedSongIds: likedSongIds,
        offset: offset,
        limit: limit,
      );
    }
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
    loadLocalDetailLikedSongRequests.add(List<int>.from(likedSongIds));
    loadLocalDetailUserIds.add(currentUserId);
    final error = cachedDetailError;
    if (error != null) {
      throw error;
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
