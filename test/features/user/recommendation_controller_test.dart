import 'dart:async';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/data/app_storage/app_key_value_store.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/features/user/user_session_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecommendationController', () {
    test('keeps local home data visible when library refresh fails', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController(
        refreshError: Exception('offline'),
      );
      final controller = RecommendationController(
        repository: _FakeUserRepository(),
        playlistRepository: _FakePlaylistRepository(),
        sessionAccess: _sessionAccess(sessionController),
        libraryAccess: _libraryAccess(libraryController),
      );
      addTearDown(controller.onClose);
      controller.todayRecommendSongs.add(_song('today-1'));

      await controller.updateData();

      expect(controller.dateLoaded.value, isTrue);
      expect(controller.hasLocalData, isTrue);
      expect(controller.todayRecommendSongs.map((song) => song.id), ['today-1']);
    });

    test('loads only daily local home cache for home bootstrap', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController();
      final repository = _FakeUserRepository(
        cachedDailyRecommendSongs: [_song('cached-today')],
      );
      final controller = RecommendationController(
        repository: repository,
        playlistRepository: _FakePlaylistRepository(),
        sessionAccess: _sessionAccess(sessionController),
        libraryAccess: _libraryAccess(libraryController),
      );
      addTearDown(controller.onClose);

      controller.onInit();
      await controller.ensureCacheLoaded();

      expect(controller.todayRecommendSongs.map((song) => song.id), ['cached-today']);
      expect(controller.hasLocalData, isTrue);
      expect(repository.loadCachedPlaylistListUserIds, isEmpty);
      expect(repository.loadCachedTrackListUserIds, ['user-1']);
      expect(repository.loadCachedTrackListKinds, [UserTrackListKind.dailyRecommend]);
    });

    test('continues home bootstrap when daily cache read fails', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController();
      final repository = _FakeUserRepository(
        loadCachedDailyRecommendSongsError: StateError('broken daily cache'),
      );
      final controller = RecommendationController(
        repository: repository,
        playlistRepository: _FakePlaylistRepository(),
        sessionAccess: _sessionAccess(sessionController),
        libraryAccess: _libraryAccess(libraryController),
      );
      addTearDown(controller.onClose);

      controller.onInit();
      await controller.ensureCacheLoaded();

      expect(controller.todayRecommendSongs, isEmpty);
      expect(controller.hasLocalData, isFalse);
      expect(repository.loadCachedTrackListKinds, [UserTrackListKind.dailyRecommend]);
    });

    test('does not read local home cache for blank user id', () async {
      final sessionController = _buildSessionController('   ');
      final libraryController = _FakeUserLibraryController();
      final repository = _FakeUserRepository();
      final controller = RecommendationController(
        repository: repository,
        playlistRepository: _FakePlaylistRepository(),
        sessionAccess: _sessionAccess(sessionController),
        libraryAccess: _libraryAccess(libraryController),
      );
      addTearDown(controller.onClose);

      controller.onInit();
      await controller.ensureCacheLoaded();

      expect(controller.todayRecommendSongs, isEmpty);
      expect(controller.hasLocalData, isFalse);
      expect(repository.loadCachedPlaylistListUserIds, isEmpty);
      expect(repository.loadCachedTrackListUserIds, isEmpty);
    });

    test('treats startup marker cache failure as stale data', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController();
      final repository = _FakeUserRepository(
        cachedDailyRecommendSongs: [_song('cached-today')],
        isSyncMarkerFreshError: StateError('broken marker cache'),
      );
      final controller = RecommendationController(
        repository: repository,
        playlistRepository: _FakePlaylistRepository(),
        sessionAccess: _sessionAccess(sessionController),
        libraryAccess: _libraryAccess(libraryController),
      );
      addTearDown(controller.onClose);

      controller.onInit();
      await controller.ensureCacheLoaded();

      expect(controller.hasLocalData, isTrue);
      await expectLater(controller.shouldRefreshStartupData(), completion(isTrue));
    });

    test('reloads scoped local data through session access when account changes', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController();
      final controller = RecommendationController(
        repository: _FakeUserRepository(),
        playlistRepository: _FakePlaylistRepository(),
        sessionAccess: _sessionAccess(sessionController),
        libraryAccess: _libraryAccess(libraryController),
      );
      addTearDown(controller.onClose);

      controller.onInit();
      await controller.ensureCacheLoaded();

      sessionController.userInfo.value = const UserSessionData(
        userId: ' user-2 ',
        nickname: 'User user-2',
        avatarUrl: '',
      );

      await _waitUntil(() => libraryController.scopedLocalDataLoads.contains('user-2'));

      expect(libraryController.scopedLocalDataLoads, ['user-2']);
    });

    test('ignores stale quick start data after newer refresh completes', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController();
      final oldToday = Completer<List<PlaybackQueueItem>>();
      final newToday = Completer<List<PlaybackQueueItem>>();
      final todayFetches = [oldToday, newToday];
      final repository = _FakeUserRepository(
        fetchTodayRecommendSongsWithArgs: ({required userId, required likedSongIds}) {
          return todayFetches.removeAt(0).future;
        },
      );
      final controller = RecommendationController(
        repository: repository,
        playlistRepository: _FakePlaylistRepository(),
        sessionAccess: _sessionAccess(sessionController),
        libraryAccess: _libraryAccess(libraryController),
      );
      addTearDown(controller.onClose);

      final oldRefresh = controller.updateData();
      await Future<void>.delayed(Duration.zero);
      final newRefresh = controller.updateData();
      await Future<void>.delayed(Duration.zero);

      newToday.complete([_song('new-today')]);
      await newRefresh;

      expect(controller.todayRecommendSongs.map((song) => song.id), ['new-today']);
      expect(repository.fetchFmSongsUserIds, isEmpty);

      oldToday.complete([_song('old-today')]);
      await oldRefresh;

      expect(controller.todayRecommendSongs.map((song) => song.id), ['new-today']);
    });

    test('clears home data and skips refresh for blank user id', () async {
      final sessionController = _buildSessionController('   ');
      final libraryController = _FakeUserLibraryController();
      final repository = _FakeUserRepository();
      final controller = RecommendationController(
        repository: repository,
        playlistRepository: _FakePlaylistRepository(),
        sessionAccess: _sessionAccess(sessionController),
        libraryAccess: _libraryAccess(libraryController),
      );
      addTearDown(controller.onClose);
      controller.todayRecommendSongs.add(_song('old-today'));

      await controller.updateData();

      expect(controller.dateLoaded.value, isTrue);
      expect(controller.hasLocalData, isFalse);
      expect(controller.todayRecommendSongs, isEmpty);
      expect(libraryController.refreshCalls, 0);
      expect(repository.fetchRecommendedPlaylistsUserIds, isEmpty);
      expect(repository.fetchTodayRecommendSongsUserIds, isEmpty);
      expect(repository.fetchFmSongsUserIds, isEmpty);
      expect(repository.markSyncMarkerUpdatedUserIds, isEmpty);
    });

    test('normalizes session user id before refreshing home data', () async {
      final sessionController = _buildSessionController(' user-1 ');
      final libraryController = _FakeUserLibraryController();
      final repository = _FakeUserRepository();
      final controller = RecommendationController(
        repository: repository,
        playlistRepository: _FakePlaylistRepository(),
        sessionAccess: _sessionAccess(sessionController),
        libraryAccess: _libraryAccess(libraryController),
      );
      addTearDown(controller.onClose);

      await controller.updateData();

      expect(libraryController.refreshCalls, 1);
      expect(repository.fetchRecommendedPlaylistsUserIds, isEmpty);
      expect(repository.fetchTodayRecommendSongsUserIds, ['user-1']);
      expect(repository.fetchFmSongsUserIds, isEmpty);
      expect(repository.markSyncMarkerUpdatedUserIds, ['user-1']);
      expect(controller.dateLoaded.value, isTrue);
      expect(controller.hasLocalData, isTrue);
    });

    test('normalizes liked song ids before home cache and remote requests', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController()..likedSongIds.addAll([202, 101, 202]);
      final repository = _FakeUserRepository();
      final controller = RecommendationController(
        repository: repository,
        playlistRepository: _FakePlaylistRepository(),
        sessionAccess: _sessionAccess(sessionController),
        libraryAccess: _libraryAccess(libraryController),
      );
      addTearDown(controller.onClose);

      controller.onInit();
      await controller.ensureCacheLoaded();

      libraryController.likedSongIds
        ..clear()
        ..addAll([303, 202, 303]);
      await controller.getTodayRecommendSongs();
      await controller.getFmSongs();
      await controller.updateData();

      expect(repository.loadCachedTrackListLikedSongRequests, [
        [101, 202],
      ]);
      expect(repository.fetchTodayRecommendSongsLikedRequests, [
        [202, 303],
        [202, 303],
      ]);
      expect(repository.fetchFmSongsLikedRequests, [
        [202, 303],
      ]);
    });

    test('ignores home refresh completion after close', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController();
      final todaySongs = Completer<List<PlaybackQueueItem>>();
      final repository = _FakeUserRepository(
        fetchTodayRecommendSongsWithArgs: ({required userId, required likedSongIds}) {
          return todaySongs.future;
        },
      );
      final controller = RecommendationController(
        repository: repository,
        playlistRepository: _FakePlaylistRepository(),
        sessionAccess: _sessionAccess(sessionController),
        libraryAccess: _libraryAccess(libraryController),
      );
      controller.todayRecommendSongs.add(_song('visible-today'));

      final refresh = controller.updateData();
      await _flushAsync();

      controller.onClose();
      todaySongs.complete([_song('late-today')]);

      await expectLater(refresh, completes);
      expect(controller.todayRecommendSongs.map((song) => song.id), ['visible-today']);
    });

    test('resolves frequent playlist playback plan with normalized latest liked ids', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController();
      libraryController.likedSongIds.addAll([101, 101]);
      final playlistRepository = _FakePlaylistRepository(
        playlistIndex: const PlaylistIndexData(
          id: 'playlist-1',
          name: 'Frequent Playlist',
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
      final controller = RecommendationController(
        repository: _FakeUserRepository(),
        playlistRepository: playlistRepository,
        sessionAccess: _sessionAccess(sessionController),
        libraryAccess: _libraryAccess(libraryController),
      );
      addTearDown(controller.onClose);

      final firstPlan = await controller.resolveFrequentPlaylistPlayback(
        const PlaylistSummaryData(id: 'playlist-1', title: 'Playlist 1'),
      );
      libraryController.likedSongIds
        ..clear()
        ..addAll([303, 202, 202]);
      final secondPlan = await controller.resolveFrequentPlaylistPlayback(
        const PlaylistSummaryData(id: 'playlist-1', title: 'Playlist 1'),
      );

      expect(firstPlan.playlistName, 'Frequent Playlist');
      expect(firstPlan.songs.single.id, 'song-101');
      expect(secondPlan.songs.single.id, 'song-202-303');
      expect(playlistRepository.indexUserIds, ['user-1', 'user-1']);
      expect(playlistRepository.indexLikedSongRequests, [
        [101],
        [202, 303],
      ]);
      expect(playlistRepository.fetchLikedSongRequests, [
        [101],
        [202, 303],
      ]);
      expect(playlistRepository.fetchPlaylistIndexNames, [
        'Frequent Playlist',
        'Frequent Playlist',
      ]);
    });
  });
}

RecommendationLibraryAccess _libraryAccess(_FakeUserLibraryController controller) {
  return RecommendationLibraryAccess(
    ensureCacheLoaded: controller.ensureCacheLoaded,
    loadScopedLocalData: controller.loadScopedLocalData,
    refreshUserLibrary: controller.refreshUserLibrary,
    hasPlaylistData: () => controller.hasPlaylistData,
    likedSongIds: () => controller.likedSongIdSnapshot,
    randomLikedSongAlbumUrl: () => controller.randomLikedSongAlbumUrl.value,
  );
}

RecommendationSessionAccess _sessionAccess(UserSessionController controller) {
  return RecommendationSessionAccess(
    ensureCacheLoaded: controller.ensureCacheLoaded,
    currentSession: () => controller.userInfo.value,
    watchSession: (onChanged) {
      final subscription = controller.userInfo.listen(onChanged);
      return subscription.cancel;
    },
  );
}

UserSessionController _buildSessionController(String userId) {
  final controller = UserSessionController(
    repository: _FakeUserRepository(),
    sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
    saveLoginFlag: (_) async {},
    canRestoreCachedSession: () => true,
  );
  controller.userInfo.value = UserSessionData(
    userId: userId,
    nickname: 'User $userId',
    avatarUrl: '',
  );
  return controller;
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

Future<void> _flushAsync() async {
  for (var i = 0; i < 4; i++) {
    await Future<void>.delayed(Duration.zero);
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

class _FakeUserLibraryController extends UserLibraryController {
  _FakeUserLibraryController({this.refreshError})
      : super(
          repository: _FakeUserRepository(),
          sessionAccess: _userLibrarySessionAccess(_buildSessionController('user-1')),
        );

  final Object? refreshError;
  final List<String> scopedLocalDataLoads = <String>[];
  int refreshCalls = 0;

  @override
  Future<void> loadScopedLocalData(String userId) async {
    scopedLocalDataLoads.add(userId);
  }

  @override
  Future<void> refreshUserLibrary() async {
    refreshCalls++;
    final error = refreshError;
    if (error != null) {
      throw error;
    }
  }
}

UserLibrarySessionAccess _userLibrarySessionAccess(UserSessionController controller) {
  return UserLibrarySessionAccess(
    ensureCacheLoaded: controller.ensureCacheLoaded,
    currentSession: () => controller.userInfo.value,
    watchSession: (onChanged) {
      final subscription = controller.userInfo.listen(onChanged);
      return subscription.cancel;
    },
  );
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({
    this.cachedDailyRecommendSongs = const [],
    this.loadCachedDailyRecommendSongsError,
    this.isSyncMarkerFreshError,
    this.fetchTodayRecommendSongsWithArgs,
  });

  final List<PlaybackQueueItem> cachedDailyRecommendSongs;
  final Object? loadCachedDailyRecommendSongsError;
  final Object? isSyncMarkerFreshError;
  final Future<List<PlaybackQueueItem>> Function({
    required String userId,
    required List<int> likedSongIds,
  })? fetchTodayRecommendSongsWithArgs;
  final List<String> loadCachedPlaylistListUserIds = <String>[];
  final List<String> loadCachedTrackListUserIds = <String>[];
  final List<String> isSyncMarkerFreshUserIds = <String>[];
  final List<String> fetchRecommendedPlaylistsUserIds = <String>[];
  final List<String> fetchTodayRecommendSongsUserIds = <String>[];
  final List<String> fetchFmSongsUserIds = <String>[];
  final List<String> markSyncMarkerUpdatedUserIds = <String>[];
  final List<UserTrackListKind> loadCachedTrackListKinds = <UserTrackListKind>[];
  final List<List<int>> loadCachedTrackListLikedSongRequests = <List<int>>[];
  final List<List<int>> fetchTodayRecommendSongsLikedRequests = <List<int>>[];
  final List<List<int>> fetchFmSongsLikedRequests = <List<int>>[];

  @override
  Future<List<PlaylistSummaryData>> loadCachedPlaylistList(
    String userId,
    UserPlaylistListKind kind,
  ) async {
    loadCachedPlaylistListUserIds.add(userId);
    switch (kind) {
      case UserPlaylistListKind.likedCollection:
      case UserPlaylistListKind.userPlaylists:
      case UserPlaylistListKind.recommended:
        return const [];
    }
  }

  @override
  Future<List<PlaybackQueueItem>> loadCachedTrackList({
    required String userId,
    required UserTrackListKind kind,
    required List<int> likedSongIds,
  }) async {
    loadCachedTrackListUserIds.add(userId);
    loadCachedTrackListKinds.add(kind);
    loadCachedTrackListLikedSongRequests.add(List<int>.from(likedSongIds));
    switch (kind) {
      case UserTrackListKind.dailyRecommend:
        final error = loadCachedDailyRecommendSongsError;
        if (error != null) {
          throw error;
        }
        return cachedDailyRecommendSongs;
      case UserTrackListKind.fm:
      case UserTrackListKind.liked:
      case UserTrackListKind.cloud:
        return const [];
    }
  }

  @override
  Future<bool> isSyncMarkerFresh({
    required String userId,
    required String markerKey,
    required Duration ttl,
  }) async {
    isSyncMarkerFreshUserIds.add(userId);
    final error = isSyncMarkerFreshError;
    if (error != null) {
      throw error;
    }
    return true;
  }

  @override
  Future<List<PlaylistSummaryData>> fetchRecommendedPlaylists({
    required String userId,
    required int offset,
    int limit = 10,
  }) {
    fetchRecommendedPlaylistsUserIds.add(userId);
    return Future.value(const []);
  }

  @override
  Future<List<PlaybackQueueItem>> fetchTodayRecommendSongs({
    required String userId,
    required List<int> likedSongIds,
  }) {
    fetchTodayRecommendSongsUserIds.add(userId);
    fetchTodayRecommendSongsLikedRequests.add(List<int>.from(likedSongIds));
    final fetchWithArgs = fetchTodayRecommendSongsWithArgs;
    if (fetchWithArgs != null) {
      return fetchWithArgs(
        userId: userId,
        likedSongIds: likedSongIds,
      );
    }
    return Future.value(const []);
  }

  @override
  Future<List<PlaybackQueueItem>> fetchFmSongs({
    required String userId,
    required List<int> likedSongIds,
  }) {
    fetchFmSongsUserIds.add(userId);
    fetchFmSongsLikedRequests.add(List<int>.from(likedSongIds));
    return Future.value(const []);
  }

  @override
  Future<void> markSyncMarkerUpdated({
    required String userId,
    required String markerKey,
  }) async {
    markSyncMarkerUpdatedUserIds.add(userId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakePlaylistRepository implements PlaylistRepository {
  _FakePlaylistRepository({
    this.playlistIndex = const PlaylistIndexData(
      id: 'playlist',
      name: 'Playlist',
      trackIds: [],
      isSubscribed: false,
      isLikedSongs: false,
    ),
    this.fetchSongsHandler,
  });

  final PlaylistIndexData playlistIndex;
  final Future<List<PlaybackQueueItem>> Function({
    required String playlistId,
    required List<int> likedSongIds,
    required int offset,
    required int limit,
  })? fetchSongsHandler;
  final List<String?> indexUserIds = <String?>[];
  final List<List<int>> indexLikedSongRequests = <List<int>>[];
  final List<List<int>> fetchLikedSongRequests = <List<int>>[];
  final List<String> fetchPlaylistIndexNames = <String>[];

  @override
  Future<PlaylistIndexData> fetchPlaylistIndex(
    String playlistId, {
    String? currentUserId,
    List<int> likedSongIds = const [],
  }) async {
    indexUserIds.add(currentUserId);
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
    return const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _MemoryKeyValueStore implements AppKeyValueStore {
  final Map<String, Object?> values = <String, Object?>{};

  @override
  Object? get(String key, {Object? defaultValue}) {
    return values.containsKey(key) ? values[key] : defaultValue;
  }

  @override
  Future<void> put(String key, Object? value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}
