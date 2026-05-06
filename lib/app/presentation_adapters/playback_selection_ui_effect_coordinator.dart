import 'dart:async';

import 'package:bujuan/app/presentation_adapters/playback_artwork_presenter.dart';
import 'package:bujuan/app/presentation_adapters/playback_theme_port.dart';
import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';
import 'package:bujuan/features/playback/application/current_track_side_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_lyrics_presenter.dart';
import 'package:bujuan/core/diagnostics/playback_performance_logger.dart';
import 'package:bujuan/features/playback/playback_selection_state.dart';

/// 跟随 UI selection 的歌词、取色和封面预取协调器。
///
/// 这些副作用属于展示态，应随用户当前看到的封面切换，而不是等待底层音源确认。
class PlaybackSelectionUiEffectCoordinator {
  /// 创建 selection UI 副作用协调器。
  PlaybackSelectionUiEffectCoordinator({
    required CurrentTrackSideEffectCoordinator sideEffectCoordinator,
    required PlaybackLyricsPresenter lyricsPresenter,
    required PlaybackArtworkPresenter artworkPresenter,
    required PlaybackThemePort themePort,
  })  : _sideEffectCoordinator = sideEffectCoordinator,
        _lyricsPresenter = lyricsPresenter,
        _artworkPresenter = artworkPresenter,
        _themePort = themePort;

  final CurrentTrackSideEffectCoordinator _sideEffectCoordinator;
  final PlaybackLyricsPresenter _lyricsPresenter;
  final PlaybackArtworkPresenter _artworkPresenter;
  final PlaybackThemePort _themePort;
  String? _lastSelectionUiSideEffectKey;
  Timer? _colorPrewarmTimer;

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
    if (!selection.hasSelection) {
      return;
    }
    final selectedSong = selection.selectedItem;
    final key = '${selection.selectionVersion}:${selectedSong.id}';
    if (_lastSelectionUiSideEffectKey == key) {
      return;
    }
    _lastSelectionUiSideEffectKey = key;
    PlaybackPerformanceLogger.log(
      'selectionUi.schedule version=${selection.selectionVersion} id=${selectedSong.id} index=${selection.selectedIndex} queue=${selection.queue.length}',
    );
    syncLyricState(
      lines: const [],
      currentIndex: -1,
      hasTranslatedLyrics: false,
    );
    _sideEffectCoordinator.schedule(
      channel: 'playback-ui-lyric-artwork',
      delay: const Duration(milliseconds: 180),
      trackId: selectedSong.id,
      isStillCurrent: (trackId) => latestSelection().selectedItem.id == trackId,
      run: () async {
        final stopwatch = PlaybackPerformanceLogger.start();
        preloadImages();
        await _updateAlbumColor(selection, latestSelection);
        if (latestSelection().selectedItem.id != selectedSong.id) {
          PlaybackPerformanceLogger.elapsed(
            'selectionUi.cancelAfterColor',
            stopwatch,
            details: 'id=${selectedSong.id}',
          );
          return;
        }
        final lyricStopwatch = PlaybackPerformanceLogger.start();
        final nextLyricState = await _lyricsPresenter.loadLyrics(selectedSong);
        PlaybackPerformanceLogger.elapsed(
          'selectionUi.loadLyrics',
          lyricStopwatch,
          details: 'id=${selectedSong.id} lines=${nextLyricState.lines.length}',
          warnAfterMs: 4,
        );
        if (latestSelection().selectedItem.id != selectedSong.id) {
          PlaybackPerformanceLogger.elapsed(
            'selectionUi.cancelAfterLyrics',
            stopwatch,
            details: 'id=${selectedSong.id}',
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
          details: 'id=${selectedSong.id}',
          warnAfterMs: 4,
        );
      },
    );
  }

  Future<void> _updateAlbumColor(
    PlaybackSelectionState selection,
    PlaybackSelectionState Function() latestSelection,
  ) async {
    try {
      final stopwatch = PlaybackPerformanceLogger.start();
      final color = _artworkPresenter.peekCachedDominantColor(selection.selectedItem);
      if (color != null) {
        _themePort.applyDominantColor(color);
        PlaybackPerformanceLogger.log(
          'selectionUi.applyAlbumColor.cacheHit id=${selection.selectedItem.id}',
        );
      }
      _scheduleColorPrewarm(
        selection,
        latestSelection,
        resolveCurrentColor: color == null,
      );
      PlaybackPerformanceLogger.elapsed(
        'selectionUi.updateAlbumColor',
        stopwatch,
        details: 'id=${selection.selectedItem.id} cacheHit=${color != null} queue=${selection.queue.length}',
        warnAfterMs: 1,
      );
    } catch (_) {
      // 取色失败只影响播放器氛围色，不能中断歌词加载。
    }
  }

  void _scheduleColorPrewarm(
    PlaybackSelectionState selection,
    PlaybackSelectionState Function() latestSelection, {
    required bool resolveCurrentColor,
  }) {
    _colorPrewarmTimer?.cancel();
    final queue = selection.queue;
    final currentIndex = selection.selectedIndex;
    final selectedItem = selection.selectedItem;
    _colorPrewarmTimer = Timer(const Duration(milliseconds: 350), () {
      unawaited(() async {
        if (resolveCurrentColor) {
          final resolvedColor = await _artworkPresenter.resolveDominantColor(selectedItem);
          if (resolvedColor != null && latestSelection().selectedItem.id == selectedItem.id) {
            _themePort.applyDominantColor(resolvedColor);
            PlaybackPerformanceLogger.log(
              'selectionUi.applyAlbumColor.resolved id=${selectedItem.id}',
            );
          }
        }
        await _artworkPresenter.prewarmQueueDominantColors(
          queue: queue,
          currentIndex: currentIndex,
          includeCurrent: false,
          remoteResolveRadius: 1,
        );
      }());
    });
  }

  /// 取消挂起的 selection UI 副作用。
  void cancel() {
    _colorPrewarmTimer?.cancel();
    _colorPrewarmTimer = null;
    _sideEffectCoordinator.cancel('playback-ui-lyric-artwork');
  }
}
