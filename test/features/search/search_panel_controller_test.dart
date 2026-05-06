import 'dart:async';

import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
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
  });
}

class _FakeSearchRepository implements SearchRepository {
  final Map<String, Completer<SearchResultState>> _pending = <String, Completer<SearchResultState>>{};

  void complete(String keyword, SearchResultState state) {
    _pending[keyword]?.complete(state);
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
    return (await _stateFor(keyword)).songs.data ?? const <PlaybackQueueItem>[];
  }

  @override
  Future<List<PlaylistEntity>> searchPlaylists(
    String keyword, {
    required String currentUserId,
  }) async {
    return (await _stateFor(keyword)).playlists.data ?? const <PlaylistEntity>[];
  }

  @override
  Future<List<AlbumEntity>> searchAlbums(String keyword) async {
    return (await _stateFor(keyword)).albums.data ?? const <AlbumEntity>[];
  }

  @override
  Future<List<ArtistEntity>> searchArtists(String keyword) async {
    return (await _stateFor(keyword)).artists.data ?? const <ArtistEntity>[];
  }

  Future<SearchResultState> _stateFor(String keyword) {
    final completer = _pending.putIfAbsent(
      keyword,
      () => Completer<SearchResultState>(),
    );
    return completer.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
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
