import 'dart:async';

import 'package:bujuan/app/presentation_adapters/playback_artwork_presenter.dart';
import 'package:bujuan/app/presentation_adapters/playback_selection_ui_effect_coordinator.dart';
import 'package:bujuan/app/presentation_adapters/playback_theme_port.dart';
import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';
import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/current_track_side_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_lyrics_presenter.dart';
import 'package:bujuan/features/playback/playback_lyric_state.dart';
import 'package:bujuan/features/playback/playback_selection_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackSelectionUiEffectCoordinator', () {
    test('uses cached color and does not wait for color prewarm', () async {
      final prewarmCompleter = Completer<void>();
      final artworkPresenter = _FakeArtworkPresenter(
        cachedColor: Colors.red,
        prewarmFuture: prewarmCompleter.future,
      );
      final lyricsPresenter = _FakeLyricsPresenter();
      final appliedColors = <Color>[];
      final syncedLyrics = <List<LyricsLineModel>>[];
      final selection = PlaybackSelectionState(
        queue: [_item('1')],
        selectedItem: _item('1'),
        selectedIndex: 0,
        selectionVersion: 1,
      );
      final coordinator = PlaybackSelectionUiEffectCoordinator(
        sideEffectCoordinator: CurrentTrackSideEffectCoordinator(),
        lyricsPresenter: lyricsPresenter,
        artworkPresenter: artworkPresenter,
        themePort: PlaybackThemePort(applyDominantColor: appliedColors.add),
      );

      coordinator.schedule(
        selection: selection,
        latestSelection: () => selection,
        syncLyricState: ({
          List<LyricsLineModel>? lines,
          int? currentIndex,
          bool? hasTranslatedLyrics,
        }) {
          if (lines != null) {
            syncedLyrics.add(lines);
          }
        },
        preloadImages: () {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 240));

      expect(appliedColors, [Colors.red]);
      expect(artworkPresenter.prewarmCallCount, 1);
      expect(lyricsPresenter.loadCallCount, 1);
      expect(syncedLyrics.last.single.mainText, 'line');

      prewarmCompleter.complete();
    });

    test('prewarms color cache without applying uncached color', () async {
      final artworkPresenter = _FakeArtworkPresenter();
      final lyricsPresenter = _FakeLyricsPresenter();
      final appliedColors = <Color>[];
      final selection = PlaybackSelectionState(
        queue: [_item('1'), _item('2')],
        selectedItem: _item('1'),
        selectedIndex: 0,
        selectionVersion: 1,
      );
      final coordinator = PlaybackSelectionUiEffectCoordinator(
        sideEffectCoordinator: CurrentTrackSideEffectCoordinator(),
        lyricsPresenter: lyricsPresenter,
        artworkPresenter: artworkPresenter,
        themePort: PlaybackThemePort(applyDominantColor: appliedColors.add),
      );

      coordinator.schedule(
        selection: selection,
        latestSelection: () => selection,
        syncLyricState: ({
          List<LyricsLineModel>? lines,
          int? currentIndex,
          bool? hasTranslatedLyrics,
        }) {},
        preloadImages: () {},
      );

      await Future<void>.delayed(const Duration(milliseconds: 240));

      expect(appliedColors, isEmpty);
      expect(artworkPresenter.prewarmCallCount, 1);
      expect(lyricsPresenter.loadCallCount, 1);
    });
  });
}

class _FakeArtworkPresenter implements PlaybackArtworkPresenter {
  _FakeArtworkPresenter({
    this.cachedColor,
    Future<void>? prewarmFuture,
  }) : prewarmFuture = prewarmFuture ?? Future<void>.value();

  final Color? cachedColor;
  final Future<void> prewarmFuture;
  int prewarmCallCount = 0;

  @override
  Color? peekCachedDominantColor(PlaybackQueueItem item) => cachedColor;

  @override
  Future<void> prewarmQueueDominantColors({
    required List<PlaybackQueueItem> queue,
    required int currentIndex,
    int radius = 3,
  }) {
    prewarmCallCount++;
    return prewarmFuture;
  }

  @override
  Future<Color?> resolveDominantColor(PlaybackQueueItem item) async {
    return cachedColor;
  }

  @override
  Future<PlaybackQueueItem?> resolveMissingArtwork(
    PlaybackQueueItem currentItem,
  ) async {
    return null;
  }

  @override
  void preloadQueueArtwork({
    required List<PlaybackQueueItem> queue,
    required int currentIndex,
    required BuildContext? context,
  }) {}
}

class _FakeLyricsPresenter implements PlaybackLyricsPresenter {
  int loadCallCount = 0;

  @override
  Future<PlaybackLyricState> loadLyrics(PlaybackQueueItem currentSong) async {
    loadCallCount++;
    return PlaybackLyricState(
      lines: [
        LyricsLineModel()
          ..mainText = 'line'
          ..startTime = 0,
      ],
      currentIndex: -1,
      hasTranslatedLyrics: false,
    );
  }
}

PlaybackQueueItem _item(String id) {
  return PlaybackQueueItem(
    id: id,
    sourceId: id,
    title: 'Track $id',
    albumTitle: null,
    artistNames: const [],
    artistIds: const [],
    duration: null,
    artworkUrl: '/tmp/$id.jpg',
    localArtworkPath: null,
    mediaType: MediaType.playlist,
    playbackUrl: null,
    lyricKey: null,
    isLiked: false,
    isCached: false,
  );
}
