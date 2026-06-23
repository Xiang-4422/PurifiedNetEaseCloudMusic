import 'dart:async';

import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchPanelController', () {
    test('only applies the latest keyword result', () async {
      final repository = _FakeSearchRepository();
      final controller = _buildController(repository: repository);
      addTearDown(controller.dispose);

      final firstSearch = controller.search('old');
      final latestSearch = controller.search('latest');

      repository.complete('latest', _resultFor('latest'));
      await latestSearch;
      expect(controller.songState.value.data?.single.title, 'latest');

      repository.complete('old', _resultFor('old'));
      await firstSearch;
      expect(controller.songState.value.data?.single.title, 'latest');
    });

    test('empty keyword clears state and prevents older result overwrite', () async {
      final repository = _FakeSearchRepository();
      final controller = _buildController(repository: repository);
      addTearDown(controller.dispose);

      final firstSearch = controller.search('pending');
      await controller.search('');

      repository.complete('pending', _resultFor('pending'));
      await firstSearch;
      expect(controller.songState.value.status, LoadStatus.empty);
    });

    test('reruns same keyword when current user changes and drops scoped results', () async {
      final repository = _FakeSearchRepository();
      var currentUserId = 'user-1';
      final controller = _buildController(
        repository: repository,
        currentUserId: () => currentUserId,
      );
      addTearDown(controller.dispose);

      final firstSearch = controller.search('keyword');
      await _flushAsync();
      repository.complete(
        'keyword',
        SearchResultState(
          songs: LoadState.data([_queueItem('song-user-1')]),
          playlists: LoadState.data([_playlist('playlist-user-1')]),
          albums: const LoadState.empty(),
          artists: const LoadState.empty(),
        ),
      );
      await firstSearch;

      expect(controller.playlistState.value.data?.single.title, 'playlist-user-1');

      currentUserId = 'user-2';
      final secondSearch = controller.search('keyword');
      await _flushAsync();

      expect(repository.requestedPlaylistUserIds, ['user-1', 'user-2']);
      expect(controller.playlistState.value.status, LoadStatus.loading);
      expect(controller.playlistState.value.data, isNull);

      repository.complete(
        'keyword',
        SearchResultState(
          songs: LoadState.data([_queueItem('song-user-2')]),
          playlists: LoadState.data([_playlist('playlist-user-2')]),
          albums: const LoadState.empty(),
          artists: const LoadState.empty(),
        ),
      );
      await secondSearch;

      expect(controller.playlistState.value.data?.single.title, 'playlist-user-2');
    });

    test('trims current user id before comparing search context', () async {
      final repository = _FakeSearchRepository();
      var currentUserId = ' user-1 ';
      final controller = _buildController(
        repository: repository,
        currentUserId: () => currentUserId,
      );
      addTearDown(controller.dispose);

      final firstSearch = controller.search('keyword');
      await _flushAsync();
      expect(repository.requestedPlaylistUserIds, ['user-1']);
      repository.complete('keyword', _resultFor('first'));
      await firstSearch;

      currentUserId = 'user-1';
      await controller.search('keyword');

      expect(repository.requestedPlaylistUserIds, ['user-1']);
      expect(controller.songState.value.data?.single.title, 'first');
    });

    test('reruns same keyword when liked song ids change', () async {
      final repository = _FakeSearchRepository();
      var likedSongIds = <int>[101];
      final controller = _buildController(
        repository: repository,
        likedSongIds: () => likedSongIds,
        currentUserId: () => 'user-1',
      );
      addTearDown(controller.dispose);

      final firstSearch = controller.search('keyword');
      await _flushAsync();
      repository.complete('keyword', _resultFor('first'));
      await firstSearch;

      likedSongIds = <int>[202];
      final secondSearch = controller.search('keyword');
      await _flushAsync();

      expect(repository.requestedLikedSongIds, [
        [101],
        [202],
      ]);
      expect(controller.songState.value.status, LoadStatus.loading);
      expect(controller.songState.value.data?.single.title, 'first');

      repository.complete('keyword', _resultFor('second'));
      await secondSearch;

      expect(controller.songState.value.data?.single.title, 'second');
    });

    test('does not rerun same keyword when liked song ids only reorder', () async {
      final repository = _FakeSearchRepository();
      var likedSongIds = <int>[202, 101];
      final controller = _buildController(
        repository: repository,
        likedSongIds: () => likedSongIds,
        currentUserId: () => 'user-1',
      );
      addTearDown(controller.dispose);

      final firstSearch = controller.search('keyword');
      await _flushAsync();
      repository.complete('keyword', _resultFor('first'));
      await firstSearch;

      likedSongIds = <int>[101, 202];
      await controller.search('keyword');

      expect(repository.requestedLikedSongIds, [
        [202, 101],
      ]);
      expect(controller.songState.value.data?.single.title, 'first');
    });

    test('publishes first completed category before slower categories finish', () async {
      final repository = _FakeSearchRepository();
      final controller = _buildController(repository: repository);
      addTearDown(controller.dispose);

      final search = controller.search('keyword');

      repository.completeSongs('keyword', [_queueItem('song')]);
      await Future<void>.delayed(Duration.zero);

      expect(controller.songState.value.data?.single.title, 'song');
      expect(controller.playlistState.value.status, LoadStatus.loading);
      expect(controller.albumState.value.status, LoadStatus.loading);
      expect(controller.artistState.value.status, LoadStatus.loading);

      repository.completePlaylists('keyword', [_playlist('playlist')]);
      repository.completeAlbums('keyword', [_album('album')]);
      repository.completeArtists('keyword', [_artist('artist')]);
      await search;

      expect(controller.playlistState.value.data?.single.title, 'playlist');
      expect(controller.albumState.value.data?.single.title, 'album');
      expect(controller.artistState.value.data?.single.name, 'artist');
    });

    test('logs first completed category even when search result is empty', () async {
      final debugLogs = <String>[];
      final previousDebugPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) {
          debugLogs.add(message);
        }
      };
      addTearDown(() {
        debugPrint = previousDebugPrint;
      });

      final repository = _FakeSearchRepository();
      final controller = _buildController(repository: repository);
      addTearDown(controller.dispose);

      final search = controller.search('keyword');
      repository.completeSongs('keyword', const []);
      await _flushAsync();

      expect(controller.songState.value.status, LoadStatus.empty);
      final metricLogs = debugLogs.where((log) => log.contains('search.firstResults.total')).toList();
      expect(metricLogs, hasLength(1));
      expect(
        metricLogs.single,
        allOf(
          contains('category=songs'),
          contains('result=empty'),
          contains('count=0'),
        ),
      );

      repository.completePlaylists('keyword', const []);
      repository.completeAlbums('keyword', const []);
      repository.completeArtists('keyword', const []);
      await search;
    });

    test('ignores search results after dispose', () async {
      final repository = _FakeSearchRepository();
      final controller = _buildController(repository: repository);

      final search = controller.search('keyword');
      await _flushAsync();

      controller.dispose();
      repository.complete('keyword', _resultFor('late'));

      await expectLater(search, completes);
    });

    test('cancels pending search and allows same keyword to rerun', () async {
      final repository = _FakeSearchRepository();
      final controller = _buildController(
        repository: repository,
        likedSongIds: () => const [101],
        currentUserId: () => 'user-1',
      );
      addTearDown(controller.dispose);

      final pendingSearch = controller.search('keyword');
      await _flushAsync();

      controller.cancelPendingRequests();
      repository.complete('keyword', _resultFor('late'));
      await pendingSearch;

      expect(controller.songState.value.status, LoadStatus.loading);
      expect(controller.songState.value.data, isNull);

      final rerun = controller.search('keyword');
      await _flushAsync();
      repository.complete('keyword', _resultFor('fresh'));
      await rerun;

      expect(repository.requestedLikedSongIds, [
        [101],
        [101],
      ]);
      expect(controller.songState.value.status, LoadStatus.data);
      expect(controller.songState.value.data?.single.title, 'fresh');
    });

    test('keeps current results while force refreshing same keyword fails', () async {
      final repository = _FakeSearchRepository();
      final controller = _buildController(repository: repository);
      addTearDown(controller.dispose);

      final initialSearch = controller.search('keyword');
      repository.complete(
        'keyword',
        SearchResultState(
          songs: LoadState.data([_queueItem('song')]),
          playlists: LoadState.data([_playlist('playlist')]),
          albums: LoadState.data([_album('album')]),
          artists: LoadState.data([_artist('artist')]),
        ),
      );
      await initialSearch;

      final refresh = controller.search(
        'keyword',
        force: true,
      );
      await _flushAsync();

      expect(controller.songState.value.status, LoadStatus.loading);
      expect(controller.songState.value.data?.single.title, 'song');
      expect(controller.playlistState.value.data?.single.title, 'playlist');

      repository.fail('keyword', StateError('offline'));
      await refresh;

      expect(controller.songState.value.status, LoadStatus.error);
      expect(controller.songState.value.data?.single.title, 'song');
      expect(controller.playlistState.value.status, LoadStatus.error);
      expect(controller.playlistState.value.data?.single.title, 'playlist');
      expect(controller.albumState.value.data?.single.title, 'album');
      expect(controller.artistState.value.data?.single.name, 'artist');
    });

    test('only applies the latest hot keyword refresh', () async {
      final repository = _FakeSearchRepository(
        cachedHotKeywords: null,
        hotKeywordCacheFresh: false,
      );
      final controller = _buildController(repository: repository);
      addTearDown(controller.dispose);

      final firstLoad = controller.loadInitial(force: true);
      await _flushAsync();
      expect(repository.hotKeywordRequestCount, 1);

      final latestLoad = controller.loadInitial(force: true);
      await _flushAsync();
      expect(repository.hotKeywordRequestCount, 2);

      repository.completeHotKeywords(1, const ['latest']);
      await latestLoad;
      expect(controller.hotKeywordState.value.data, const ['latest']);

      repository.completeHotKeywords(0, const ['old']);
      await firstLoad;
      expect(controller.hotKeywordState.value.data, const ['latest']);
    });

    test('publishes cached hot keywords before stale refresh completes', () async {
      final repository = _FakeSearchRepository(
        cachedHotKeywords: const ['cached'],
        hotKeywordCacheFresh: false,
      );
      final controller = _buildController(repository: repository);
      addTearDown(controller.dispose);

      final load = controller.loadInitial();
      await _flushAsync();

      expect(controller.hotKeywordState.value.data, const ['cached']);
      expect(repository.hotKeywordRequestCount, 1);

      repository.completeHotKeywords(0, const ['fresh']);
      await load;

      expect(controller.hotKeywordState.value.data, const ['fresh']);
    });

    test('ignores hot keyword refresh after dispose', () async {
      final repository = _FakeSearchRepository(
        cachedHotKeywords: null,
        hotKeywordCacheFresh: false,
      );
      final controller = _buildController(repository: repository);

      final load = controller.loadInitial(force: true);
      await _flushAsync();
      expect(repository.hotKeywordRequestCount, 1);

      controller.dispose();
      repository.completeHotKeywords(0, const ['late']);

      await expectLater(load, completes);
    });

    test('keeps cached hot keywords when refresh fails', () async {
      final repository = _FakeSearchRepository(
        cachedHotKeywords: const ['cached'],
        hotKeywordCacheFresh: false,
      );
      final controller = _buildController(repository: repository);
      addTearDown(controller.dispose);

      final load = controller.loadInitial();
      await _flushAsync();
      repository.failHotKeywords(0, StateError('offline'));
      await load;

      expect(controller.hotKeywordState.value.data, const ['cached']);

      await controller.loadInitial();
      expect(repository.hotKeywordRequestCount, 1);
    });

    test('falls back to remote hot keywords when cache load fails', () async {
      final repository = _FakeSearchRepository(
        cachedHotKeywordsError: StateError('cache failed'),
      );
      final controller = _buildController(repository: repository);
      addTearDown(controller.dispose);

      final load = controller.loadInitial();
      await _flushAsync();

      expect(controller.hotKeywordState.value.status, LoadStatus.loading);
      expect(repository.hotKeywordRequestCount, 1);

      repository.completeHotKeywords(0, const ['remote']);
      await load;

      expect(controller.hotKeywordState.value.data, const ['remote']);
    });

    test('refreshes hot keywords when cache freshness check fails', () async {
      final repository = _FakeSearchRepository(
        cachedHotKeywords: const ['cached'],
        hotKeywordCacheFreshError: StateError('freshness failed'),
      );
      final controller = _buildController(repository: repository);
      addTearDown(controller.dispose);

      final load = controller.loadInitial();
      await _flushAsync();

      expect(controller.hotKeywordState.value.data, const ['cached']);
      expect(repository.hotKeywordRequestCount, 1);

      repository.completeHotKeywords(0, const ['remote']);
      await load;

      expect(controller.hotKeywordState.value.data, const ['remote']);
    });
  });
}

SearchPanelController _buildController({
  required SearchRepository repository,
  List<int> Function()? likedSongIds,
  String Function()? currentUserId,
}) {
  return SearchPanelController(
    repository: repository,
    likedSongIds: likedSongIds ?? () => const <int>[],
    currentUserId: currentUserId ?? () => '',
  );
}

class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository({
    this.cachedHotKeywords = const <String>[],
    this.hotKeywordCacheFresh = true,
    this.cachedHotKeywordsError,
    this.hotKeywordCacheFreshError,
  });

  final Map<String, List<_PendingSearchResult>> _pending = <String, List<_PendingSearchResult>>{};
  final Map<String, _PendingSearchResult> _activePending = <String, _PendingSearchResult>{};
  final List<Completer<List<String>>> _hotKeywordRequests = <Completer<List<String>>>[];
  final List<String>? cachedHotKeywords;
  final bool hotKeywordCacheFresh;
  final Object? cachedHotKeywordsError;
  final Object? hotKeywordCacheFreshError;
  final List<List<int>> requestedLikedSongIds = <List<int>>[];
  final List<String> requestedPlaylistUserIds = <String>[];

  int get hotKeywordRequestCount => _hotKeywordRequests.length;

  void complete(String keyword, SearchResultState state) {
    _pendingResultToComplete(keyword).complete(state);
  }

  void completeHotKeywords(int index, List<String> keywords) {
    final request = _hotKeywordRequests[index];
    if (!request.isCompleted) {
      request.complete(keywords);
    }
  }

  void failHotKeywords(int index, Object error) {
    final request = _hotKeywordRequests[index];
    if (!request.isCompleted) {
      request.completeError(error, StackTrace.current);
    }
  }

  void completeSongs(String keyword, List<PlaybackQueueItem> songs) {
    _pendingResultToComplete(keyword).completeSongs(songs);
  }

  void completePlaylists(String keyword, List<PlaylistEntity> playlists) {
    _pendingResultToComplete(keyword).completePlaylists(playlists);
  }

  void completeAlbums(String keyword, List<AlbumEntity> albums) {
    _pendingResultToComplete(keyword).completeAlbums(albums);
  }

  void completeArtists(String keyword, List<ArtistEntity> artists) {
    _pendingResultToComplete(keyword).completeArtists(artists);
  }

  void fail(String keyword, Object error) {
    _pendingResultToComplete(keyword).fail(error);
  }

  @override
  Future<List<String>?> loadCachedHotKeywords() {
    final error = cachedHotKeywordsError;
    if (error != null) {
      return Future<List<String>?>.error(error);
    }
    return Future<List<String>?>.value(cachedHotKeywords);
  }

  @override
  Future<bool> isHotKeywordCacheFresh({required Duration ttl}) {
    final error = hotKeywordCacheFreshError;
    if (error != null) {
      return Future<bool>.error(error);
    }
    return Future<bool>.value(hotKeywordCacheFresh);
  }

  @override
  Future<List<String>> fetchHotKeywords() {
    final request = Completer<List<String>>();
    _hotKeywordRequests.add(request);
    return request.future;
  }

  @override
  Future<List<PlaybackQueueItem>> searchTrackQueueItems(
    String keyword, {
    required List<int> likedSongIds,
  }) async {
    requestedLikedSongIds.add(List<int>.from(likedSongIds));
    return _startPendingResult(keyword).songs.future;
  }

  @override
  Future<List<PlaylistEntity>> searchPlaylists(
    String keyword, {
    required String currentUserId,
  }) async {
    requestedPlaylistUserIds.add(currentUserId);
    return _activePendingResult(keyword).playlists.future;
  }

  @override
  Future<List<AlbumEntity>> searchAlbums(String keyword) async {
    return _activePendingResult(keyword).albums.future;
  }

  @override
  Future<List<ArtistEntity>> searchArtists(String keyword) async {
    return _activePendingResult(keyword).artists.future;
  }

  _PendingSearchResult _startPendingResult(String keyword) {
    final request = _PendingSearchResult();
    _pending.putIfAbsent(keyword, () => <_PendingSearchResult>[]).add(request);
    _activePending[keyword] = request;
    return request;
  }

  _PendingSearchResult _activePendingResult(String keyword) {
    return _activePending[keyword] ?? _startPendingResult(keyword);
  }

  _PendingSearchResult _pendingResultToComplete(String keyword) {
    final requests = _pending[keyword];
    if (requests == null || requests.isEmpty) {
      return _startPendingResult(keyword);
    }
    return requests.firstWhere(
      (request) => !request.isCompleted,
      orElse: () => _startPendingResult(keyword),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _PendingSearchResult {
  final Completer<List<PlaybackQueueItem>> songs = Completer<List<PlaybackQueueItem>>();
  final Completer<List<PlaylistEntity>> playlists = Completer<List<PlaylistEntity>>();
  final Completer<List<AlbumEntity>> albums = Completer<List<AlbumEntity>>();
  final Completer<List<ArtistEntity>> artists = Completer<List<ArtistEntity>>();

  bool get isCompleted => songs.isCompleted && playlists.isCompleted && albums.isCompleted && artists.isCompleted;

  void complete(SearchResultState state) {
    completeSongs(state.songs.data ?? const <PlaybackQueueItem>[]);
    completePlaylists(state.playlists.data ?? const <PlaylistEntity>[]);
    completeAlbums(state.albums.data ?? const <AlbumEntity>[]);
    completeArtists(state.artists.data ?? const <ArtistEntity>[]);
  }

  void fail(Object error) {
    failSongs(error);
    failPlaylists(error);
    failAlbums(error);
    failArtists(error);
  }

  void completeSongs(List<PlaybackQueueItem> value) {
    if (!songs.isCompleted) {
      songs.complete(value);
    }
  }

  void failSongs(Object error) {
    if (!songs.isCompleted) {
      songs.completeError(error, StackTrace.current);
    }
  }

  void completePlaylists(List<PlaylistEntity> value) {
    if (!playlists.isCompleted) {
      playlists.complete(value);
    }
  }

  void failPlaylists(Object error) {
    if (!playlists.isCompleted) {
      playlists.completeError(error, StackTrace.current);
    }
  }

  void completeAlbums(List<AlbumEntity> value) {
    if (!albums.isCompleted) {
      albums.complete(value);
    }
  }

  void failAlbums(Object error) {
    if (!albums.isCompleted) {
      albums.completeError(error, StackTrace.current);
    }
  }

  void completeArtists(List<ArtistEntity> value) {
    if (!artists.isCompleted) {
      artists.complete(value);
    }
  }

  void failArtists(Object error) {
    if (!artists.isCompleted) {
      artists.completeError(error, StackTrace.current);
    }
  }
}

SearchResultState _resultFor(String title) {
  return SearchResultState(
    songs: LoadState.data([_queueItem(title)]),
    playlists: const LoadState.empty(),
    albums: const LoadState.empty(),
    artists: const LoadState.empty(),
  );
}

PlaybackQueueItem _queueItem(String title) {
  return PlaybackQueueItem(
    id: 'netease:$title',
    sourceId: title,
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
    isLiked: false,
    isCached: false,
  );
}

PlaylistEntity _playlist(String title) {
  return PlaylistEntity(
    id: 'netease:$title',
    sourceType: SourceType.netease,
    sourceId: title,
    title: title,
  );
}

AlbumEntity _album(String title) {
  return AlbumEntity(
    id: 'netease:$title',
    sourceType: SourceType.netease,
    sourceId: title,
    title: title,
  );
}

ArtistEntity _artist(String name) {
  return ArtistEntity(
    id: 'netease:$name',
    sourceType: SourceType.netease,
    sourceId: name,
    name: name,
  );
}

Future<void> _flushAsync() async {
  for (var i = 0; i < 4; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
