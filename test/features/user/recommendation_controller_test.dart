import 'dart:async';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/data/app_storage/app_key_value_store.dart';
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
        sessionController: sessionController,
        libraryController: libraryController,
      );
      addTearDown(controller.onClose);
      controller.recoPlayLists.add(
        const PlaylistSummaryData(id: 'playlist-1', title: 'Playlist 1'),
      );
      controller.todayRecommendSongs.add(_song('today-1'));
      controller.fmSongs.add(_song('fm-1'));

      await controller.updateData();

      expect(controller.dateLoaded.value, isTrue);
      expect(controller.hasLocalData, isTrue);
      expect(controller.recoPlayLists.map((playlist) => playlist.id), ['playlist-1']);
      expect(controller.todayRecommendSongs.map((song) => song.id), ['today-1']);
      expect(controller.fmSongs.map((song) => song.id), ['fm-1']);
    });

    test('ignores stale recommended playlist load more after refresh completes', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController();
      final loadMore = Completer<List<PlaylistSummaryData>>();
      final refresh = Completer<List<PlaylistSummaryData>>();
      final repository = _FakeUserRepository(
        fetchRecommendedPlaylistsWithArgs: ({required userId, required offset, required limit}) {
          if (offset == 0) {
            return refresh.future;
          }
          return loadMore.future;
        },
      );
      final controller = RecommendationController(
        repository: repository,
        sessionController: sessionController,
        libraryController: libraryController,
      );
      addTearDown(controller.onClose);
      controller.recoPlayLists.add(const PlaylistSummaryData(id: 'old-first', title: 'Old first'));

      final loadMoreFuture = controller.updateRecoPlayLists(getMore: true);
      await Future<void>.delayed(Duration.zero);

      final refreshFuture = controller.updateRecoPlayLists();
      await Future<void>.delayed(Duration.zero);
      refresh.complete([
        const PlaylistSummaryData(id: 'fresh-first', title: 'Fresh first'),
      ]);
      await refreshFuture;

      expect(controller.recoPlayLists.map((playlist) => playlist.id), ['fresh-first']);

      loadMore.complete([
        const PlaylistSummaryData(id: 'stale-more', title: 'Stale more'),
      ]);
      await loadMoreFuture;

      expect(controller.recoPlayLists.map((playlist) => playlist.id), ['fresh-first']);
    });

    test('does not start recommended playlist load more while refresh is running', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController();
      final refresh = Completer<List<PlaylistSummaryData>>();
      final requestedOffsets = <int>[];
      final repository = _FakeUserRepository(
        fetchRecommendedPlaylistsWithArgs: ({required userId, required offset, required limit}) {
          requestedOffsets.add(offset);
          return refresh.future;
        },
      );
      final controller = RecommendationController(
        repository: repository,
        sessionController: sessionController,
        libraryController: libraryController,
      );
      addTearDown(controller.onClose);
      controller.recoPlayLists.add(const PlaylistSummaryData(id: 'old-first', title: 'Old first'));

      final refreshFuture = controller.updateRecoPlayLists();
      await Future<void>.delayed(Duration.zero);
      await controller.updateRecoPlayLists(getMore: true);

      expect(requestedOffsets, [0]);

      refresh.complete([
        const PlaylistSummaryData(id: 'fresh-first', title: 'Fresh first'),
      ]);
      await refreshFuture;

      expect(controller.recoPlayLists.map((playlist) => playlist.id), ['fresh-first']);
    });

    test('ignores stale quick start data after newer refresh completes', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController();
      final oldToday = Completer<List<PlaybackQueueItem>>();
      final oldFm = Completer<List<PlaybackQueueItem>>();
      final newToday = Completer<List<PlaybackQueueItem>>();
      final newFm = Completer<List<PlaybackQueueItem>>();
      final todayFetches = [oldToday, newToday];
      final fmFetches = [oldFm, newFm];
      final repository = _FakeUserRepository(
        fetchTodayRecommendSongsWithArgs: ({required userId, required likedSongIds}) {
          return todayFetches.removeAt(0).future;
        },
        fetchFmSongsWithArgs: ({required userId, required likedSongIds}) {
          return fmFetches.removeAt(0).future;
        },
      );
      final controller = RecommendationController(
        repository: repository,
        sessionController: sessionController,
        libraryController: libraryController,
      );
      addTearDown(controller.onClose);

      final oldRefresh = controller.updateData();
      await Future<void>.delayed(Duration.zero);
      final newRefresh = controller.updateData();
      await Future<void>.delayed(Duration.zero);

      newToday.complete([_song('new-today')]);
      newFm.complete([_song('new-fm')]);
      await newRefresh;

      expect(controller.todayRecommendSongs.map((song) => song.id), ['new-today']);
      expect(controller.fmSongs.map((song) => song.id), ['new-fm']);

      oldToday.complete([_song('old-today')]);
      oldFm.complete([_song('old-fm')]);
      await oldRefresh;

      expect(controller.todayRecommendSongs.map((song) => song.id), ['new-today']);
      expect(controller.fmSongs.map((song) => song.id), ['new-fm']);
    });

    test('ignores home refresh completion after close', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController();
      final playlists = Completer<List<PlaylistSummaryData>>();
      final todaySongs = Completer<List<PlaybackQueueItem>>();
      final fmSongs = Completer<List<PlaybackQueueItem>>();
      final repository = _FakeUserRepository(
        fetchRecommendedPlaylistsWithArgs: ({required userId, required offset, required limit}) {
          return playlists.future;
        },
        fetchTodayRecommendSongsWithArgs: ({required userId, required likedSongIds}) {
          return todaySongs.future;
        },
        fetchFmSongsWithArgs: ({required userId, required likedSongIds}) {
          return fmSongs.future;
        },
      );
      final controller = RecommendationController(
        repository: repository,
        sessionController: sessionController,
        libraryController: libraryController,
      );
      controller.recoPlayLists.add(const PlaylistSummaryData(id: 'visible-playlist', title: 'Visible'));
      controller.todayRecommendSongs.add(_song('visible-today'));
      controller.fmSongs.add(_song('visible-fm'));

      final refresh = controller.updateData();
      await _flushAsync();

      controller.onClose();
      playlists.complete([
        const PlaylistSummaryData(id: 'late-playlist', title: 'Late'),
      ]);
      todaySongs.complete([_song('late-today')]);
      fmSongs.complete([_song('late-fm')]);

      await expectLater(refresh, completes);
      expect(controller.recoPlayLists.map((playlist) => playlist.id), ['visible-playlist']);
      expect(controller.todayRecommendSongs.map((song) => song.id), ['visible-today']);
      expect(controller.fmSongs.map((song) => song.id), ['visible-fm']);
    });
  });
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

class _FakeUserLibraryController extends UserLibraryController {
  _FakeUserLibraryController({this.refreshError})
      : super(
          repository: _FakeUserRepository(),
          sessionController: _buildSessionController('user-1'),
        );

  final Object? refreshError;

  @override
  Future<void> refreshUserLibrary() async {
    final error = refreshError;
    if (error != null) {
      throw error;
    }
  }
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({
    this.fetchRecommendedPlaylistsWithArgs,
    this.fetchTodayRecommendSongsWithArgs,
    this.fetchFmSongsWithArgs,
  });

  final Future<List<PlaylistSummaryData>> Function({
    required String userId,
    required int offset,
    required int limit,
  })? fetchRecommendedPlaylistsWithArgs;
  final Future<List<PlaybackQueueItem>> Function({
    required String userId,
    required List<int> likedSongIds,
  })? fetchTodayRecommendSongsWithArgs;
  final Future<List<PlaybackQueueItem>> Function({
    required String userId,
    required List<int> likedSongIds,
  })? fetchFmSongsWithArgs;

  @override
  Future<List<PlaylistSummaryData>> fetchRecommendedPlaylists({
    required String userId,
    required int offset,
    int limit = 10,
  }) {
    final fetchWithArgs = fetchRecommendedPlaylistsWithArgs;
    if (fetchWithArgs != null) {
      return fetchWithArgs(
        userId: userId,
        offset: offset,
        limit: limit,
      );
    }
    return Future.value(const []);
  }

  @override
  Future<List<PlaybackQueueItem>> fetchTodayRecommendSongs({
    required String userId,
    required List<int> likedSongIds,
  }) {
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
    final fetchWithArgs = fetchFmSongsWithArgs;
    if (fetchWithArgs != null) {
      return fetchWithArgs(
        userId: userId,
        likedSongIds: likedSongIds,
      );
    }
    return Future.value(const []);
  }

  @override
  Future<void> markSyncMarkerUpdated({
    required String userId,
    required String markerKey,
  }) async {}

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
