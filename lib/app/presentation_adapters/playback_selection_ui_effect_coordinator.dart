import 'package:bujuan/app/presentation_adapters/playback_artwork_presenter.dart';
import 'package:bujuan/app/presentation_adapters/playback_theme_port.dart';
import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';
import 'package:bujuan/features/playback/application/current_track_side_effect_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_lyrics_presenter.dart';
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
        preloadImages();
        await _updateAlbumColor(selection);
        if (latestSelection().selectedItem.id != selectedSong.id) {
          return;
        }
        final nextLyricState = await _lyricsPresenter.loadLyrics(selectedSong);
        if (latestSelection().selectedItem.id != selectedSong.id) {
          return;
        }
        syncLyricState(
          lines: nextLyricState.lines,
          currentIndex: nextLyricState.currentIndex,
          hasTranslatedLyrics: nextLyricState.hasTranslatedLyrics,
        );
      },
    );
  }

  Future<void> _updateAlbumColor(PlaybackSelectionState selection) async {
    try {
      final color =
          await _artworkPresenter.resolveDominantColor(selection.selectedItem);
      if (color != null) {
        _themePort.applyDominantColor(color);
      }
    } catch (_) {
      // 取色失败只影响播放器氛围色，不能中断歌词加载。
    }
  }

  /// 取消挂起的 selection UI 副作用。
  void cancel() {
    _sideEffectCoordinator.cancel('playback-ui-lyric-artwork');
  }
}
