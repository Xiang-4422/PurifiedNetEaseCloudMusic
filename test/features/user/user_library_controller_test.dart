import 'dart:async';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/data/app_storage/app_key_value_store.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/features/user/user_session_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserLibraryController', () {
    test('ignores stale scoped local data after switching users', () async {
      final repository = _FakeUserRepository();
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );

      sessionController.userInfo.value = const UserSessionData(
        userId: 'old-user',
        nickname: 'Old',
        avatarUrl: '',
      );
      final oldLoad = controller.loadScopedLocalData('old-user');

      sessionController.userInfo.value = const UserSessionData(
        userId: 'new-user',
        nickname: 'New',
        avatarUrl: '',
      );
      final newLoad = controller.loadScopedLocalData('new-user');
      repository.cacheFor('new-user').complete(
        likedIds: [202],
        userPlaylists: const [
          PlaylistSummaryData(id: 'new-playlist', title: 'New Playlist'),
        ],
        likedCollection: const [
          PlaylistSummaryData(id: 'new-liked', title: 'New Liked'),
        ],
      );

      await newLoad;

      expect(controller.likedSongIds, [202]);
      expect(controller.userPlayLists.map((playlist) => playlist.id), ['new-playlist']);
      expect(controller.userLikedSongPlayList.value.id, 'new-liked');
      expect(controller.randomLikedSongId.value, '202');
      expect(controller.randomLikedSongAlbumUrl.value, 'cached-art-202');
      expect(controller.hasLocalData, isTrue);

      repository.cacheFor('old-user').complete(
        likedIds: [101],
        userPlaylists: const [
          PlaylistSummaryData(id: 'old-playlist', title: 'Old Playlist'),
        ],
        likedCollection: const [
          PlaylistSummaryData(id: 'old-liked', title: 'Old Liked'),
        ],
      );
      await oldLoad;

      expect(controller.likedSongIds, [202]);
      expect(controller.userPlayLists.map((playlist) => playlist.id), ['new-playlist']);
      expect(controller.userLikedSongPlayList.value.id, 'new-liked');
      expect(controller.randomLikedSongId.value, '202');
      expect(controller.randomLikedSongAlbumUrl.value, 'cached-art-202');
    });

    test('continues scoped local data load when a cache read fails', () async {
      final repository = _FakeUserRepository();
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );

      final load = controller.loadScopedLocalData('user-1');
      final cache = repository.cacheFor('user-1');
      cache.likedIds.completeError(StateError('broken liked ids cache'));
      cache.playlists[UserPlaylistListKind.userPlaylists]!.complete(
        const [
          PlaylistSummaryData(id: 'cached-playlist', title: 'Cached Playlist'),
        ],
      );
      cache.playlists[UserPlaylistListKind.likedCollection]!.complete(
        const [
          PlaylistSummaryData(id: 'cached-liked', title: 'Cached Liked'),
        ],
      );

      await expectLater(load, completes);

      expect(controller.likedSongIds, isEmpty);
      expect(controller.userPlayLists.map((playlist) => playlist.id), ['cached-playlist']);
      expect(controller.userLikedSongPlayList.value.id, 'cached-liked');
      expect(controller.randomLikedSongId.value, isEmpty);
      expect(controller.randomLikedSongAlbumUrl.value, isEmpty);
      expect(controller.hasLocalData, isTrue);
    });

    test('falls back to remote album url when cached random album read fails', () async {
      final repository = _FakeUserRepository()..loadCachedSongAlbumUrlError = StateError('broken album cache');
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );

      final load = controller.loadScopedLocalData('user-1');
      repository.cacheFor('user-1').complete(
        likedIds: [202],
        userPlaylists: const [],
        likedCollection: const [],
      );

      await expectLater(load, completes);

      expect(controller.likedSongIds, [202]);
      expect(controller.randomLikedSongId.value, '202');
      expect(controller.randomLikedSongAlbumUrl.value, 'remote-art-202');
      expect(controller.hasLocalData, isTrue);
    });

    test('keeps scoped local data when random album url cannot be resolved', () async {
      final repository = _FakeUserRepository()
        ..loadCachedSongAlbumUrlError = StateError('broken album cache')
        ..fetchSongAlbumUrlError = StateError('offline');
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );

      final load = controller.loadScopedLocalData('user-1');
      repository.cacheFor('user-1').complete(
        likedIds: [202],
        userPlaylists: const [
          PlaylistSummaryData(id: 'cached-playlist', title: 'Cached Playlist'),
        ],
        likedCollection: const [],
      );

      await expectLater(load, completes);

      expect(controller.likedSongIds, [202]);
      expect(controller.userPlayLists.map((playlist) => playlist.id), ['cached-playlist']);
      expect(controller.randomLikedSongId.value, '202');
      expect(controller.randomLikedSongAlbumUrl.value, isEmpty);
      expect(controller.hasLocalData, isTrue);
    });

    test('keeps visible liked songs when forced reload fails', () async {
      final repository = _FakeUserRepository()..fetchSongsByIdsError = StateError('offline');
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );
      controller.likedSongIds.addAll([101]);
      controller.likedSongs.add(_song('101', title: 'Cached liked song'));

      await expectLater(
        controller.ensureLikedSongsLoaded(force: true),
        throwsA(isA<StateError>()),
      );

      expect(controller.likedSongs.map((song) => song.title), ['Cached liked song']);
    });

    test('falls back to remote liked songs when cached song read fails', () async {
      final repository = _FakeUserRepository()
        ..loadCachedSongsByIdsError = StateError('broken liked songs cache')
        ..remoteSongsByIds = [_song('101', title: 'Remote liked song')];
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );
      controller.likedSongIds.add(101);

      await controller.ensureLikedSongsLoaded();

      expect(controller.likedSongs.map((song) => song.title), ['Remote liked song']);
    });

    test('limits home frequent playlists without trimming library playlists', () {
      final repository = _FakeUserRepository();
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );
      controller.userPlayLists.addAll(
        List.generate(
          10,
          (index) => PlaylistSummaryData(
            id: 'playlist-$index',
            title: 'Playlist $index',
          ),
        ),
      );

      expect(
        controller.homeFrequentPlaylists.map((playlist) => playlist.id),
        List.generate(8, (index) => 'playlist-$index'),
      );
      expect(controller.userPlayLists, hasLength(10));
    });

    test('syncs visible liked songs when liked id refresh succeeds', () async {
      final repository = _FakeUserRepository()..remoteLikedSongIds = [303, 202];
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );
      controller.likedSongIds.addAll([101, 202, 303]);
      controller.likedSongs.addAll([
        _song('101', title: 'Removed liked song'),
        _song('202', title: 'Second visible song'),
        _song('303', title: 'First visible song'),
      ]);

      await controller.refreshLikedSongIds();

      expect(controller.likedSongIds, [303, 202]);
      expect(controller.likedSongs.map((song) => song.sourceId), ['303', '202']);
      expect(controller.likedSongs.map((song) => song.title), ['First visible song', 'Second visible song']);
      expect(controller.likedSongs.every((song) => song.isLiked), isTrue);
    });

    test('clears visible liked songs when liked id refresh succeeds with no ids', () async {
      final repository = _FakeUserRepository()..remoteLikedSongIds = const [];
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );
      controller.likedSongIds.add(101);
      controller.likedSongs.add(_song('101', title: 'Old liked song'));

      await controller.refreshLikedSongIds();

      expect(controller.likedSongIds, isEmpty);
      expect(controller.likedSongs, isEmpty);
    });

    test('keeps visible library state when snapshot refresh fails', () async {
      final repository = _FakeUserRepository()..fetchUserLibrarySnapshotError = StateError('offline');
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );
      controller.likedSongIds.addAll([101]);
      controller.userLikedSongPlayList.value = const PlaylistSummaryData(
        id: 'cached-liked',
        title: 'Cached Liked',
      );
      controller.userPlayLists.add(
        const PlaylistSummaryData(id: 'cached-playlist', title: 'Cached Playlist'),
      );
      controller.randomLikedSongId.value = '101';
      controller.randomLikedSongAlbumUrl.value = 'cached-art-101';

      await expectLater(controller.refreshUserLibrary(), completes);

      expect(controller.likedSongIds, [101]);
      expect(controller.userLikedSongPlayList.value.id, 'cached-liked');
      expect(controller.userPlayLists.map((playlist) => playlist.id), ['cached-playlist']);
      expect(controller.randomLikedSongId.value, '101');
      expect(controller.randomLikedSongAlbumUrl.value, 'cached-art-101');
      expect(controller.hasLocalData, isTrue);
    });

    test('propagates snapshot refresh failure without visible library data', () async {
      final repository = _FakeUserRepository()..fetchUserLibrarySnapshotError = StateError('offline');
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );

      await expectLater(
        controller.refreshUserLibrary(),
        throwsA(isA<StateError>()),
      );

      expect(controller.likedSongIds, isEmpty);
      expect(controller.userLikedSongPlayList.value.id, isEmpty);
      expect(controller.userPlayLists, isEmpty);
      expect(controller.hasLocalData, isFalse);
    });

    test('clears visible playlists when successful snapshot returns no playlists', () async {
      final repository = _FakeUserRepository()
        ..remoteLikedSongIds = const []
        ..remoteUserPlaylists = const [];
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );
      controller.likedSongIds.add(101);
      controller.userLikedSongPlayList.value = const PlaylistSummaryData(
        id: 'old-liked',
        title: 'Old Liked',
      );
      controller.userPlayLists.add(
        const PlaylistSummaryData(id: 'old-playlist', title: 'Old Playlist'),
      );
      controller.randomLikedSongId.value = '101';
      controller.randomLikedSongAlbumUrl.value = 'cached-art-101';

      await controller.refreshUserLibrary();

      expect(controller.likedSongIds, isEmpty);
      expect(controller.userLikedSongPlayList.value.id, isEmpty);
      expect(controller.userPlayLists, isEmpty);
      expect(controller.randomLikedSongId.value, isEmpty);
      expect(controller.randomLikedSongAlbumUrl.value, isEmpty);
      expect(controller.hasLocalData, isTrue);
    });

    test('clears visible playlists when playlist refresh succeeds with no playlists', () async {
      final repository = _FakeUserRepository()..remoteUserPlaylists = const [];
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );
      controller.userLikedSongPlayList.value = const PlaylistSummaryData(
        id: 'old-liked',
        title: 'Old Liked',
      );
      controller.userPlayLists.add(
        const PlaylistSummaryData(id: 'old-playlist', title: 'Old Playlist'),
      );

      await controller.refreshUserPlaylists();

      expect(controller.userLikedSongPlayList.value.id, isEmpty);
      expect(controller.userPlayLists, isEmpty);
    });

    test('ignores stale liked songs load after switching users', () async {
      final repository = _FakeUserRepository();
      final oldFetch = Completer<List<PlaybackQueueItem>>();
      repository.fetchSongsByIdsWithArgs = ({required ids, required likedSongIds}) {
        return oldFetch.future;
      };
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'old-user',
        nickname: 'Old',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );
      controller.likedSongIds.add(101);

      final oldLoad = controller.ensureLikedSongsLoaded(force: true);
      await Future<void>.delayed(Duration.zero);

      sessionController.userInfo.value = const UserSessionData(
        userId: 'new-user',
        nickname: 'New',
        avatarUrl: '',
      );
      controller.likedSongIds
        ..clear()
        ..add(202);
      controller.likedSongs
        ..clear()
        ..add(_song('202', title: 'New visible song'));

      oldFetch.complete([_song('101', title: 'Old remote song')]);
      await oldLoad;

      expect(controller.likedSongs.map((song) => song.title), ['New visible song']);
    });

    test('reloads liked songs when id list changes with same length', () async {
      final repository = _FakeUserRepository()..remoteSongsByIds = [_song('202', title: 'Fresh liked song')];
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );
      controller.likedSongIds.add(101);
      controller.likedSongs.add(_song('101', title: 'Old liked song'));
      controller.likedSongIds
        ..clear()
        ..add(202);

      await controller.ensureLikedSongsLoaded();

      expect(controller.likedSongs.map((song) => song.title), ['Fresh liked song']);
    });

    test('ignores scoped local data completion after close', () async {
      final repository = _FakeUserRepository();
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );

      final load = controller.loadScopedLocalData('user-1');
      await _flushAsync();

      controller.onClose();
      repository.cacheFor('user-1').complete(
        likedIds: [101],
        userPlaylists: const [
          PlaylistSummaryData(id: 'late-playlist', title: 'Late Playlist'),
        ],
        likedCollection: const [
          PlaylistSummaryData(id: 'late-liked', title: 'Late Liked'),
        ],
      );

      await expectLater(load, completes);
      expect(controller.likedSongIds, isEmpty);
      expect(controller.userPlayLists, isEmpty);
      expect(controller.userLikedSongPlayList.value.id, isEmpty);
      expect(controller.randomLikedSongId.value, isEmpty);
      expect(controller.randomLikedSongAlbumUrl.value, isEmpty);
      expect(controller.hasLocalData, isFalse);
    });

    test('ignores liked songs completion after close', () async {
      final repository = _FakeUserRepository();
      final remoteSongs = Completer<List<PlaybackQueueItem>>();
      repository.fetchSongsByIdsWithArgs = ({required ids, required likedSongIds}) {
        return remoteSongs.future;
      };
      final sessionController = UserSessionController(
        repository: repository,
        sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
        saveLoginFlag: (_) async {},
        canRestoreCachedSession: () => true,
      );
      sessionController.userInfo.value = const UserSessionData(
        userId: 'user-1',
        nickname: 'User',
        avatarUrl: '',
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionAccess: _sessionAccess(sessionController),
      );
      controller.likedSongIds.add(101);
      controller.likedSongs.add(_song('101', title: 'Visible liked song'));

      final load = controller.ensureLikedSongsLoaded(force: true);
      await _flushAsync();

      controller.onClose();
      remoteSongs.complete([_song('101', title: 'Late remote song')]);

      await expectLater(load, completes);
      expect(controller.likedSongs.map((song) => song.title), ['Visible liked song']);
    });
  });
}

class _FakeUserRepository implements UserRepository {
  final Map<String, _PendingUserCache> _caches = <String, _PendingUserCache>{};
  Object? fetchUserLibrarySnapshotError;
  List<int> remoteLikedSongIds = const [];
  List<PlaylistSummaryData> remoteUserPlaylists = const [];
  Object? loadCachedSongAlbumUrlError;
  Object? fetchSongAlbumUrlError;
  Object? loadCachedSongsByIdsError;
  Object? fetchSongsByIdsError;
  List<PlaybackQueueItem> remoteSongsByIds = const [];
  Future<List<PlaybackQueueItem>> Function({
    required List<String> ids,
    required List<int> likedSongIds,
  })? fetchSongsByIdsWithArgs;

  _PendingUserCache cacheFor(String userId) {
    return _caches.putIfAbsent(userId, _PendingUserCache.new);
  }

  @override
  Future<List<int>> loadCachedLikedSongIds(String userId) {
    return cacheFor(userId).likedIds.future;
  }

  @override
  Future<List<PlaylistSummaryData>> loadCachedPlaylistList(
    String userId,
    UserPlaylistListKind kind,
  ) {
    return cacheFor(userId).playlists[kind]!.future;
  }

  @override
  Future<String> loadCachedSongAlbumUrl(String songId) async {
    final error = loadCachedSongAlbumUrlError;
    if (error != null) {
      throw error;
    }
    return 'cached-art-$songId';
  }

  @override
  Future<String> fetchSongAlbumUrl(String songId) async {
    final error = fetchSongAlbumUrlError;
    if (error != null) {
      throw error;
    }
    return 'remote-art-$songId';
  }

  @override
  Future<({List<int> likedSongIds, List<PlaylistSummaryData> playlists})> fetchUserLibrarySnapshot(
    String userId,
  ) async {
    final error = fetchUserLibrarySnapshotError;
    if (error != null) {
      throw error;
    }
    return (
      likedSongIds: remoteLikedSongIds,
      playlists: remoteUserPlaylists,
    );
  }

  @override
  Future<List<int>> fetchLikedSongIds(String userId) async {
    return remoteLikedSongIds;
  }

  @override
  Future<List<PlaylistSummaryData>> fetchUserPlaylists(String userId) async {
    return remoteUserPlaylists;
  }

  @override
  Future<List<PlaybackQueueItem>> loadCachedSongsByIds({
    required List<String> ids,
    required List<int> likedSongIds,
  }) async {
    final error = loadCachedSongsByIdsError;
    if (error != null) {
      throw error;
    }
    return const [];
  }

  @override
  Future<List<PlaybackQueueItem>> fetchSongsByIds({
    required List<String> ids,
    required List<int> likedSongIds,
  }) async {
    final fetchWithArgs = fetchSongsByIdsWithArgs;
    if (fetchWithArgs != null) {
      return fetchWithArgs(
        ids: ids,
        likedSongIds: likedSongIds,
      );
    }
    final error = fetchSongsByIdsError;
    if (error != null) {
      throw error;
    }
    return remoteSongsByIds;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

PlaybackQueueItem _song(String id, {required String title}) {
  return PlaybackQueueItem(
    id: 'netease:$id',
    sourceId: id,
    title: title,
    albumTitle: null,
    artistNames: const [],
    artistIds: const [],
    duration: null,
    artworkUrl: null,
    localArtworkPath: null,
    mediaType: MediaType.playlist,
    playbackUrl: null,
    lyricKey: null,
    isLiked: true,
    isCached: false,
  );
}

Future<void> _flushAsync() async {
  for (var i = 0; i < 4; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

UserLibrarySessionAccess _sessionAccess(UserSessionController controller) {
  return UserLibrarySessionAccess(
    ensureCacheLoaded: controller.ensureCacheLoaded,
    currentSession: () => controller.userInfo.value,
    watchSession: (onChanged) {
      final subscription = controller.userInfo.listen(onChanged);
      return subscription.cancel;
    },
  );
}

class _PendingUserCache {
  final Completer<List<int>> likedIds = Completer<List<int>>();
  final Map<UserPlaylistListKind, Completer<List<PlaylistSummaryData>>> playlists = {
    for (final kind in UserPlaylistListKind.values) kind: Completer<List<PlaylistSummaryData>>(),
  };

  void complete({
    required List<int> likedIds,
    required List<PlaylistSummaryData> userPlaylists,
    required List<PlaylistSummaryData> likedCollection,
  }) {
    this.likedIds.complete(likedIds);
    playlists[UserPlaylistListKind.userPlaylists]!.complete(userPlaylists);
    playlists[UserPlaylistListKind.likedCollection]!.complete(likedCollection);
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
