import 'dart:async';

import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/search/application/search_application_service.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchPanelController', () {
    test('only applies the latest keyword result', () async {
      final service = _FakeSearchApplicationService();
      final controller = SearchPanelController(service: service);
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

      service.complete('latest', _resultFor('latest'));
      await latestSearch;
      expect(controller.songState.value.data?.single.title, 'latest');

      service.complete('old', _resultFor('old'));
      await firstSearch;
      expect(controller.songState.value.data?.single.title, 'latest');
    });

    test('empty keyword clears state and prevents older result overwrite',
        () async {
      final service = _FakeSearchApplicationService();
      final controller = SearchPanelController(service: service);
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

      service.complete('pending', _resultFor('pending'));
      await firstSearch;
      expect(controller.songState.value.status, LoadStatus.empty);
    });
  });
}

class _FakeSearchApplicationService implements SearchApplicationService {
  final Map<String, Completer<SearchResultState>> _pending =
      <String, Completer<SearchResultState>>{};

  void complete(String keyword, SearchResultState state) {
    _pending[keyword]?.complete(state);
  }

  @override
  Future<LoadState<List<String>>> loadInitialHotKeywords({
    bool force = false,
  }) async {
    return const LoadState.empty();
  }

  @override
  Future<SearchResultState> searchAll(
    String keyword, {
    required List<int> likedSongIds,
    required String currentUserId,
  }) {
    final completer = Completer<SearchResultState>();
    _pending[keyword] = completer;
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
