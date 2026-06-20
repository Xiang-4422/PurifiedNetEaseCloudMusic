import 'dart:async';

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
      );
      final controller = UserLibraryController(
        repository: repository,
        sessionController: sessionController,
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
  });
}

class _FakeUserRepository implements UserRepository {
  final Map<String, _PendingUserCache> _caches = <String, _PendingUserCache>{};

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
    return 'cached-art-$songId';
  }

  @override
  Future<String> fetchSongAlbumUrl(String songId) async {
    return 'remote-art-$songId';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
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
