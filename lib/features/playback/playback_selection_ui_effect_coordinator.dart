import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/playback_artwork_presenter.dart';
import 'package:bujuan/features/playback/lyrics/lyrics_reader_model.dart';
import 'package:bujuan/features/playback/application/current_track_side_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_lyrics_presenter.dart';
import 'package:bujuan/features/playback/playback_performance_logger.dart';
import 'package:bujuan/features/playback/playback_selection_state.dart';
import 'package:flutter/material.dart';

/// 跟随 UI selection 的歌词、取色和封面预取协调器。
///
/// 这些副作用属于展示态，应随用户当前看到的封面切换，而不是等待底层音源确认。
class PlaybackSelectionUiEffectCoordinator {
  /// 创建 selection UI 副作用协调器。
  PlaybackSelectionUiEffectCoordinator({
    required CurrentTrackSideEffectCoordinator sideEffectCoordinator,
    required PlaybackLyricsPresenter lyricsPresenter,
    required PlaybackArtworkPresenter artworkPresenter,
    required void Function(Color color) applyDominantColor,
  })  : _sideEffectCoordinator = sideEffectCoordinator,
        _lyricsPresenter = lyricsPresenter,
        _artworkPresenter = artworkPresenter,
        _applyDominantColor = applyDominantColor;

  final CurrentTrackSideEffectCoordinator _sideEffectCoordinator;
  final PlaybackLyricsPresenter _lyricsPresenter;
  final PlaybackArtworkPresenter _artworkPresenter;
  final void Function(Color color) _applyDominantColor;
  String? _lastSelectionUiSideEffectKey;

  /// 按当前 selection 调度 UI 展示副作用。
  void schedule({
    required PlaybackSelectionState selection,
    required PlaybackSelectionState Function() latestSelection,
    required void Function({
      List<LyricsLineModel>? lines,
      int? currentIndex,
      bool? hasTranslatedLyrics,
    }) syncLyricState,
    required void Function() preloadImages,
  }) {
    final selectedSongId = _normalizedItemId(selection.selectedItem.id);
    if (selectedSongId.isEmpty || selection.selectedIndex < 0) {
      return;
    }
    final selectedSong = _normalizedQueueItem(selection.selectedItem);
    final key = '${selection.selectionVersion}:$selectedSongId';
    if (_lastSelectionUiSideEffectKey == key) {
      return;
    }
    _lastSelectionUiSideEffectKey = key;
    PlaybackPerformanceLogger.log(
      'selectionUi.schedule version=${selection.selectionVersion} id=$selectedSongId index=${selection.selectedIndex} queue=${selection.queue.length}',
    );
    syncLyricState(
      lines: const [],
      currentIndex: -1,
      hasTranslatedLyrics: false,
    );
    _sideEffectCoordinator.schedule(
      channel: 'playback-ui-lyric-artwork',
      delay: const Duration(milliseconds: 180),
      trackId: selectedSongId,
      isStillCurrent: (trackId) => _isSelectedItem(latestSelection(), trackId),
      run: () async {
        final stopwatch = PlaybackPerformanceLogger.start();
        preloadImages();
        await _updateAlbumColor(
          selection,
          latestSelection,
          selectedSong: selectedSong,
          selectedSongId: selectedSongId,
        );
        if (!_isSelectedItem(latestSelection(), selectedSongId)) {
          PlaybackPerformanceLogger.elapsed(
            'selectionUi.cancelAfterColor',
            stopwatch,
            details: 'id=$selectedSongId',
          );
          return;
        }
        final lyricStopwatch = PlaybackPerformanceLogger.start();
        final nextLyricState = await _lyricsPresenter.loadLyrics(selectedSong);
        PlaybackPerformanceLogger.elapsed(
          'selectionUi.loadLyrics',
          lyricStopwatch,
          details: 'id=$selectedSongId lines=${nextLyricState.lines.length}',
          warnAfterMs: 4,
        );
        if (!_isSelectedItem(latestSelection(), selectedSongId)) {
          PlaybackPerformanceLogger.elapsed(
            'selectionUi.cancelAfterLyrics',
            stopwatch,
            details: 'id=$selectedSongId',
          );
          return;
        }
        syncLyricState(
          lines: nextLyricState.lines,
          currentIndex: nextLyricState.currentIndex,
          hasTranslatedLyrics: nextLyricState.hasTranslatedLyrics,
        );
        PlaybackPerformanceLogger.elapsed(
          'selectionUi.run',
          stopwatch,
          details: 'id=$selectedSongId',
          warnAfterMs: 4,
        );
      },
    );
  }

  Future<void> _updateAlbumColor(
    PlaybackSelectionState selection,
    PlaybackSelectionState Function() latestSelection, {
    required PlaybackQueueItem selectedSong,
    required String selectedSongId,
  }) async {
    try {
      final stopwatch = PlaybackPerformanceLogger.start();
      final color = _artworkPresenter.peekCachedDominantColor(selectedSong);
      if (color != null) {
        _applyDominantColor(color);
        PlaybackPerformanceLogger.log(
          'selectionUi.applyAlbumColor.cacheHit id=$selectedSongId',
        );
      }
      _scheduleColorPrewarm(
        selection,
        latestSelection,
        selectedItem: selectedSong,
        selectedItemId: selectedSongId,
        resolveCurrentColor: color == null,
      );
      PlaybackPerformanceLogger.elapsed(
        'selectionUi.updateAlbumColor',
        stopwatch,
        details: 'id=$selectedSongId cacheHit=${color != null} queue=${selection.queue.length}',
        warnAfterMs: 1,
      );
    } catch (_) {
      // 取色失败只影响播放器氛围色，不能中断歌词加载。
    }
  }

  void _scheduleColorPrewarm(
    PlaybackSelectionState selection,
    PlaybackSelectionState Function() latestSelection, {
    required PlaybackQueueItem selectedItem,
    required String selectedItemId,
    required bool resolveCurrentColor,
  }) {
    final queue = selection.queue;
    final currentIndex = selection.selectedIndex;
    _sideEffectCoordinator.schedule(
      channel: 'playback-ui-color-prewarm',
      delay: const Duration(milliseconds: 350),
      trackId: selectedItemId,
      isStillCurrent: (trackId) => _isSelectedItem(latestSelection(), trackId),
      run: () async {
        if (resolveCurrentColor) {
          final resolvedColor = await _artworkPresenter.resolveDominantColor(selectedItem);
          if (resolvedColor != null && _isSelectedItem(latestSelection(), selectedItemId)) {
            _applyDominantColor(resolvedColor);
            PlaybackPerformanceLogger.log(
              'selectionUi.applyAlbumColor.resolved id=$selectedItemId',
            );
          }
        }
        await _artworkPresenter.prewarmQueueDominantColors(
          queue: queue,
          currentIndex: currentIndex,
          includeCurrent: false,
          remoteResolveRadius: 1,
        );
      },
    );
  }

  bool _isSelectedItem(PlaybackSelectionState selection, String itemId) {
    final normalizedItemId = _normalizedItemId(itemId);
    return normalizedItemId.isNotEmpty && _normalizedItemId(selection.selectedItem.id) == normalizedItemId;
  }

  PlaybackQueueItem _normalizedQueueItem(PlaybackQueueItem item) {
    final normalizedItemId = _normalizedItemId(item.id);
    if (normalizedItemId == item.id) {
      return item;
    }
    return item.copyWith(id: normalizedItemId);
  }

  String _normalizedItemId(String itemId) {
    return itemId.trim();
  }

  /// 取消挂起的 selection UI 副作用。
  void cancel() {
    _sideEffectCoordinator.cancel('playback-ui-lyric-artwork');
    _sideEffectCoordinator.cancel('playback-ui-color-prewarm');
  }
}
