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
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchPanelController', () {
    test('only applies the latest keyword result', () async {
      final repository = _FakeSearchRepository();
      final controller = SearchPanelController(repository: repository);
      addTearDown(controller.dispose);

      final firstSearch = controller.search(
        'old',
        likedSongIds: const [],
        currentUserId: '',
      );
      final latestSearch = controller.search(
        'latest',
        likedSongIds: const [],
        currentUserId: '',
      );

      repository.complete('latest', _resultFor('latest'));
      await latestSearch;
      expect(controller.songState.value.data?.single.title, 'latest');

      repository.complete('old', _resultFor('old'));
      await firstSearch;
      expect(controller.songState.value.data?.single.title, 'latest');
    });

    test('empty keyword clears state and prevents older result overwrite', () async {
      final repository = _FakeSearchRepository();
      final controller = SearchPanelController(repository: repository);
      addTearDown(controller.dispose);

      final firstSearch = controller.search(
        'pending',
        likedSongIds: const [],
        currentUserId: '',
      );
      await controller.search(
        '',
        likedSongIds: const [],
        currentUserId: '',
      );

      repository.complete('pending', _resultFor('pending'));
      await firstSearch;
      expect(controller.songState.value.status, LoadStatus.empty);
    });

    test('publishes first completed category before slower categories finish', () async {
      final repository = _FakeSearchRepository();
      final controller = SearchPanelController(repository: repository);
      addTearDown(controller.dispose);

      final search = controller.search(
        'keyword',
        likedSongIds: const [],
        currentUserId: '42',
      );

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
  });
}

class _FakeSearchRepository implements SearchRepository {
  final Map<String, _PendingSearchResult> _pending = <String, _PendingSearchResult>{};

  void complete(String keyword, SearchResultState state) {
    _pendingResult(keyword).complete(state);
  }

  void completeSongs(String keyword, List<PlaybackQueueItem> songs) {
    _pendingResult(keyword).completeSongs(songs);
  }

  void completePlaylists(String keyword, List<PlaylistEntity> playlists) {
    _pendingResult(keyword).completePlaylists(playlists);
  }

  void completeAlbums(String keyword, List<AlbumEntity> albums) {
    _pendingResult(keyword).completeAlbums(albums);
  }

  void completeArtists(String keyword, List<ArtistEntity> artists) {
    _pendingResult(keyword).completeArtists(artists);
  }

  @override
  Future<List<String>?> loadCachedHotKeywords() async => const [];

  @override
  Future<bool> isHotKeywordCacheFresh({required Duration ttl}) async => true;

  @override
  Future<List<String>> fetchHotKeywords() async => const [];

  @override
  Future<List<PlaybackQueueItem>> searchTrackQueueItems(
    String keyword, {
    required List<int> likedSongIds,
  }) async {
    return _pendingResult(keyword).songs.future;
  }

  @override
  Future<List<PlaylistEntity>> searchPlaylists(
    String keyword, {
    required String currentUserId,
  }) async {
    return _pendingResult(keyword).playlists.future;
  }

  @override
  Future<List<AlbumEntity>> searchAlbums(String keyword) async {
    return _pendingResult(keyword).albums.future;
  }

  @override
  Future<List<ArtistEntity>> searchArtists(String keyword) async {
    return _pendingResult(keyword).artists.future;
  }

  _PendingSearchResult _pendingResult(String keyword) {
    return _pending.putIfAbsent(
      keyword,
      _PendingSearchResult.new,
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

  void complete(SearchResultState state) {
    completeSongs(state.songs.data ?? const <PlaybackQueueItem>[]);
    completePlaylists(state.playlists.data ?? const <PlaylistEntity>[]);
    completeAlbums(state.albums.data ?? const <AlbumEntity>[]);
    completeArtists(state.artists.data ?? const <ArtistEntity>[]);
  }

  void completeSongs(List<PlaybackQueueItem> value) {
    if (!songs.isCompleted) {
      songs.complete(value);
    }
  }

  void completePlaylists(List<PlaylistEntity> value) {
    if (!playlists.isCompleted) {
      playlists.complete(value);
    }
  }

  void completeAlbums(List<AlbumEntity> value) {
    if (!albums.isCompleted) {
      albums.complete(value);
    }
  }

  void completeArtists(List<ArtistEntity> value) {
    if (!artists.isCompleted) {
      artists.complete(value);
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
