import 'dart:async';

import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/user_scoped_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_cloud_remote_data_source.dart';
import 'package:bujuan/features/cloud/cloud_page_controller.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CloudPageController', () {
    test('ignores blank user id before repository access', () async {
      final repository = _FakeCloudRepository(
        cachedSongs: [_song('cached')],
        fetchCloudSongs: () => Future.value(
          CloudSongPage(
            items: [_song('remote')],
            hasMore: true,
            nextOffset: 1,
          ),
        ),
      );
      final controller = CloudPageController(
        repository: repository,
        userId: '   ',
        likedSongIds: () => const [1],
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      await controller.refresh();
      await controller.loadMore();

      expect(controller.state.value.items, isEmpty);
      expect(controller.state.value.hasMore, isFalse);
      expect(repository.cachedLikedSongRequests, isEmpty);
      expect(repository.fetchLikedSongRequests, isEmpty);
      expect(repository.requestedOffsets, isEmpty);
    });

    test('normalizes account scoped user id before repository access', () async {
      final repository = _FakeCloudRepository(
        fetchCloudSongsWithArgs: ({required userId, required offset, required limit, required likedSongIds}) {
          return Future.value(
            CloudSongPage(
              items: [_song('remote-$offset')],
              hasMore: true,
              nextOffset: offset + 1,
            ),
          );
        },
      );
      final controller = CloudPageController(
        repository: repository,
        userId: ' user-1 ',
        likedSongIds: () => const [],
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      await controller.refresh();
      await controller.loadMore();

      expect(repository.cachedUserIds, ['user-1']);
      expect(repository.fetchUserIds, ['user-1', 'user-1', 'user-1']);
    });

    test('keeps cached songs when background refresh fails', () async {
      final refresh = Completer<CloudSongPage>();
      final error = Exception('offline');
      final repository = _FakeCloudRepository(
        cachedSongs: [_song('cached')],
        fetchCloudSongs: () => refresh.future,
      );
      final controller = _buildController(repository);

      await controller.loadInitial();
      expect(controller.state.value.items.map((item) => item.id), ['cached']);
      expect(controller.state.value.refreshing, isTrue);

      refresh.completeError(error, StackTrace.current);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.value.items.map((item) => item.id), ['cached']);
      expect(controller.state.value.refreshing, isFalse);
      expect(controller.state.value.error, same(error));
      expect(controller.state.value.hasInitialError, isFalse);
    });

    test('uses initial error when no cached songs exist', () async {
      final error = Exception('offline');
      final repository = _FakeCloudRepository(
        fetchCloudSongs: () => Future<CloudSongPage>.error(error),
      );
      final controller = _buildController(repository);

      await controller.loadInitial();

      expect(controller.state.value.items, isEmpty);
      expect(controller.state.value.error, same(error));
      expect(controller.state.value.hasInitialError, isTrue);
    });

    test('falls back to remote page when cached songs load fails', () async {
      final cacheError = Exception('cache failed');
      final repository = _FakeCloudRepository(
        cachedSongsFuture: Future<List<PlaybackQueueItem>>.error(cacheError),
        fetchCloudSongs: () => Future.value(
          CloudSongPage(
            items: [_song('remote')],
            hasMore: false,
            nextOffset: 1,
          ),
        ),
      );
      final controller = _buildController(repository);
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(repository.requestedOffsets, [0]);
      expect(controller.state.value.items.map((item) => item.id), ['remote']);
      expect(controller.state.value.initialLoading, isFalse);
      expect(controller.state.value.error, isNull);
    });

    test('uses normalized latest liked song ids for each cache and remote request', () async {
      var likedSongIds = <int>[2, 1, 2];
      final repository = _FakeCloudRepository(
        fetchCloudSongs: () => Future.value(
          CloudSongPage(
            items: [_song('remote')],
            hasMore: false,
            nextOffset: 1,
          ),
        ),
      );
      final controller = CloudPageController(
        repository: repository,
        userId: 'user-1',
        likedSongIds: () => likedSongIds,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      likedSongIds = <int>[3, 2, 3];
      await controller.refresh();

      expect(repository.cachedLikedSongRequests, [
        [1, 2],
      ]);
      expect(repository.fetchLikedSongRequests, [
        [1, 2],
        [2, 3],
      ]);
    });

    test('ignores stale load more result after refresh completes', () async {
      final loadMore = Completer<CloudSongPage>();
      final refresh = Completer<CloudSongPage>();
      var firstPageLoaded = false;
      final repository = _FakeCloudRepository(
        fetchCloudSongsWithArgs: ({required userId, required offset, required limit, required likedSongIds}) {
          if (offset == 0 && !firstPageLoaded) {
            firstPageLoaded = true;
            return Future.value(
              CloudSongPage(
                items: [_song('old-first')],
                hasMore: true,
                nextOffset: 1,
              ),
            );
          }
          if (offset == 0) {
            return refresh.future;
          }
          return loadMore.future;
        },
      );
      final controller = _buildController(repository);
      addTearDown(controller.dispose);

      await controller.loadInitial();
      expect(controller.state.value.items.map((item) => item.id), ['old-first']);

      final loadMoreFuture = controller.loadMore();
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.value.loadingMore, isTrue);

      final refreshFuture = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      refresh.complete(
        CloudSongPage(
          items: [_song('fresh-first')],
          hasMore: true,
          nextOffset: 1,
        ),
      );
      await refreshFuture;

      expect(controller.state.value.items.map((item) => item.id), ['fresh-first']);

      loadMore.complete(
        CloudSongPage(
          items: [_song('stale-more')],
          hasMore: false,
          nextOffset: 2,
        ),
      );
      await loadMoreFuture;

      expect(controller.state.value.items.map((item) => item.id), ['fresh-first']);
      expect(controller.state.value.loadingMore, isFalse);
      expect(controller.state.value.refreshing, isFalse);
    });

    test('ignores stale cached load after refresh completes', () async {
      final cachedLoad = Completer<List<PlaybackQueueItem>>();
      final refresh = Completer<CloudSongPage>();
      final repository = _FakeCloudRepository(
        cachedSongsFuture: cachedLoad.future,
        fetchCloudSongs: () => refresh.future,
      );
      final controller = _buildController(repository);
      addTearDown(controller.dispose);

      final initialLoad = controller.loadInitial();
      await Future<void>.delayed(Duration.zero);

      final refreshFuture = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      refresh.complete(
        CloudSongPage(
          items: [_song('fresh-first')],
          hasMore: true,
          nextOffset: 1,
        ),
      );
      await refreshFuture;

      expect(controller.state.value.items.map((item) => item.id), ['fresh-first']);

      cachedLoad.complete([_song('stale-cached')]);
      await initialLoad;

      expect(controller.state.value.items.map((item) => item.id), ['fresh-first']);
      expect(controller.state.value.refreshing, isFalse);
    });

    test('ignores cached load completion after dispose', () async {
      final cachedLoad = Completer<List<PlaybackQueueItem>>();
      final repository = _FakeCloudRepository(
        cachedSongsFuture: cachedLoad.future,
        fetchCloudSongs: () => Future.value(
          CloudSongPage(
            items: [_song('remote')],
            hasMore: false,
            nextOffset: 1,
          ),
        ),
      );
      final controller = _buildController(repository);

      final initialLoad = controller.loadInitial();
      await Future<void>.delayed(Duration.zero);
      controller.dispose();

      cachedLoad.complete([_song('cached')]);
      await initialLoad;
    });

    test('ignores refresh completion after dispose', () async {
      final refresh = Completer<CloudSongPage>();
      final repository = _FakeCloudRepository(
        fetchCloudSongs: () => refresh.future,
      );
      final controller = _buildController(repository);

      final refreshFuture = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      controller.dispose();

      refresh.complete(
        CloudSongPage(
          items: [_song('fresh')],
          hasMore: false,
          nextOffset: 1,
        ),
      );
      await refreshFuture;
    });
  });
}

CloudPageController _buildController(_FakeCloudRepository repository) {
  return CloudPageController(
    repository: repository,
    userId: 'user-1',
    likedSongIds: () => const [],
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

class _FakeCloudRepository extends CloudRepository {
  _FakeCloudRepository({
    this.cachedSongs = const [],
    this.cachedSongsFuture,
    Future<CloudSongPage> Function()? fetchCloudSongs,
    Future<CloudSongPage> Function({
      required String userId,
      required int offset,
      required int limit,
      required List<int> likedSongIds,
    })? fetchCloudSongsWithArgs,
  })  : _fetchCloudSongs = fetchCloudSongs,
        _fetchCloudSongsWithArgs = fetchCloudSongsWithArgs,
        super(
          musicDataRepository: _UnusedMusicDataRepository(),
          userTrackListDataSource: _UnusedUserTrackListDataSource(),
          remoteDataSource: _UnusedNeteaseCloudRemoteDataSource(),
        );

  final List<PlaybackQueueItem> cachedSongs;
  final Future<List<PlaybackQueueItem>>? cachedSongsFuture;
  final Future<CloudSongPage> Function()? _fetchCloudSongs;
  final Future<CloudSongPage> Function({
    required String userId,
    required int offset,
    required int limit,
    required List<int> likedSongIds,
  })? _fetchCloudSongsWithArgs;
  final List<int> requestedOffsets = <int>[];
  final List<List<int>> cachedLikedSongRequests = <List<int>>[];
  final List<List<int>> fetchLikedSongRequests = <List<int>>[];
  final List<String> cachedUserIds = <String>[];
  final List<String> fetchUserIds = <String>[];

  @override
  Future<List<PlaybackQueueItem>> loadCachedSongs({
    required String userId,
    required List<int> likedSongIds,
  }) async {
    cachedUserIds.add(userId);
    cachedLikedSongRequests.add(List<int>.from(likedSongIds));
    final future = cachedSongsFuture;
    if (future != null) {
      return future;
    }
    return cachedSongs;
  }

  @override
  Future<CloudSongPage> fetchCloudSongs({
    required String userId,
    required int offset,
    required int limit,
    required List<int> likedSongIds,
  }) {
    fetchUserIds.add(userId);
    requestedOffsets.add(offset);
    fetchLikedSongRequests.add(List<int>.from(likedSongIds));
    final fetchWithArgs = _fetchCloudSongsWithArgs;
    if (fetchWithArgs != null) {
      return fetchWithArgs(
        userId: userId,
        offset: offset,
        limit: limit,
        likedSongIds: likedSongIds,
      );
    }
    return _fetchCloudSongs!.call();
  }
}

class _UnusedMusicDataRepository implements MusicDataRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _UnusedUserTrackListDataSource implements UserTrackListDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _UnusedNeteaseCloudRemoteDataSource implements NeteaseCloudRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
