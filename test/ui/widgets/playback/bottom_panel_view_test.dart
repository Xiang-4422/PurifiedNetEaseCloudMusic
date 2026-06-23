import 'dart:io';

import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_mini_player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bottom panel mini player helpers', () {
    test('builds expand control label with title and artist', () {
      expect(
        miniPlayerExpandControlLabel(
          title: 'Song',
          artist: 'Artist',
        ),
        '打开播放器：Song - Artist',
      );
    });

    test('builds expand control label with fallbacks', () {
      expect(
        miniPlayerExpandControlLabel(title: '  ', artist: '  '),
        '打开播放器：当前歌曲',
      );
      expect(
        miniPlayerExpandControlLabel(title: 'Song'),
        '打开播放器：Song',
      );
    });

    test('builds play pause control label', () {
      expect(miniPlayerPlayPauseControlLabel(isPlaying: false), '播放');
      expect(miniPlayerPlayPauseControlLabel(isPlaying: true), '暂停');
    });
  });

  test('bottom panel keeps mini player in a dedicated local widget file', () {
    final panelSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart',
    ).readAsStringSync();
    final miniPlayerSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_mini_player.dart',
    ).readAsStringSync();
    final homeSource = File(
      'lib/ui/pages/shell/app_home_page_view.dart',
    ).readAsStringSync();

    expect(panelSource, isNot(contains('class BottomPanelHeaderView')));
    expect(panelSource, isNot(contains('miniPlayerExpandControlLabel')));
    expect(miniPlayerSource, contains('class BottomPanelHeaderView'));
    expect(miniPlayerSource, contains('required this.playerController'));
    expect(miniPlayerSource, contains('required this.settingsController'));
    expect(miniPlayerSource, contains('miniPlayerExpandControlLabel'));
    expect(miniPlayerSource, contains('miniPlayerPlayPauseControlLabel'));
    expect(miniPlayerSource, isNot(contains('PlayerController.to')));
    expect(miniPlayerSource, isNot(contains('SettingsController.to')));
    expect(homeSource, contains('BottomPanelHeaderView('));
    expect(homeSource, contains('playerController: playerController'));
    expect(homeSource, contains('settingsController: settingsController'));
  });

  test('bottom panel delegates expanded pages to local widgets', () {
    final panelSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart',
    ).readAsStringSync();
    final nowPlayingSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_now_playing_page.dart',
    ).readAsStringSync();
    final metadataSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_now_playing_metadata.dart',
    ).readAsStringSync();
    final indicatorSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_page_indicator.dart',
    ).readAsStringSync();
    final lyricSource = File(
      'lib/ui/pages/shell/widgets/playback/lyric_view.dart',
    ).readAsStringSync();
    final controlsSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_playback_controls.dart',
    ).readAsStringSync();

    expect(panelSource, contains('BottomPanelQueueView('));
    expect(panelSource, contains('BottomPanelHeader('));
    expect(panelSource, contains('playerController: playerController'));
    expect(panelSource, contains('settingsController: settingsController'));
    expect(panelSource, contains('BottomPanelCommentPage('));
    expect(panelSource, contains('BottomPanelNowPlayingPage('));
    expect(panelSource, contains('BottomPanelPageIndicator('));
    expect(panelSource, isNot(contains('_buildCurPlayingPage')));
    expect(panelSource, isNot(contains('_artistEntries')));
    expect(panelSource, isNot(contains('MyTabBar(')));
    expect(panelSource, isNot(contains('LyricView(')));

    expect(nowPlayingSource, contains('class BottomPanelNowPlayingPage'));
    expect(nowPlayingSource, contains('BottomPanelNowPlayingMetadata('));
    expect(nowPlayingSource, contains('BottomPanelPlaybackControls('));
    expect(nowPlayingSource, contains('LyricView('));
    expect(nowPlayingSource, contains('required this.playerController'));
    expect(nowPlayingSource, contains('required this.settingsController'));

    expect(metadataSource, contains('class BottomPanelNowPlayingMetadata'));
    expect(metadataSource, contains('required this.playerController'));
    expect(metadataSource, contains('required this.settingsController'));
    expect(metadataSource, contains('BottomPanelProgressBar('));
    expect(metadataSource, contains('AlbumRouteView'));
    expect(metadataSource, contains('ArtistRouteView'));
    expect(metadataSource, contains('_artistEntries'));
    expect(metadataSource, isNot(contains('PlayerController.to')));
    expect(metadataSource, isNot(contains('SettingsController.to')));

    expect(indicatorSource, contains('class BottomPanelPageIndicator'));
    expect(indicatorSource, contains('required this.playerController'));
    expect(indicatorSource, contains('required this.settingsController'));
    expect(indicatorSource, contains("'播放列表'"));
    expect(indicatorSource, contains("'正在播放'"));
    expect(indicatorSource, contains("'歌曲评论'"));
    expect(indicatorSource, contains('bottomPanelCommentTabController'));
    expect(indicatorSource, isNot(contains('PlayerController.to')));
    expect(indicatorSource, isNot(contains('SettingsController.to')));

    expect(nowPlayingSource, isNot(contains('PlayerController.to')));

    expect(lyricSource, contains('required this.playerController'));
    expect(lyricSource, contains('required this.settingsController'));
    expect(lyricSource, isNot(contains('PlayerController.to')));
    expect(lyricSource, isNot(contains('SettingsController.to')));

    final controlsStart = controlsSource.indexOf('class BottomPanelPlaybackControls');
    final controlButtonStart = controlsSource.indexOf('class _PlaybackControlButton');
    final backgroundStart = controlsSource.indexOf('class _ButtonBackground');
    final progressStart = controlsSource.indexOf('class BottomPanelProgressBar');
    final playbackControlsSource = controlsSource.substring(controlsStart, controlButtonStart);
    final controlButtonBackgroundSource = controlsSource.substring(backgroundStart);
    final progressSource = controlsSource.substring(progressStart, controlsStart);
    expect(progressSource, contains('required this.playerController'));
    expect(progressSource, contains('required this.settingsController'));
    expect(progressSource, isNot(contains('PlayerController.to')));
    expect(progressSource, isNot(contains('SettingsController.to')));
    expect(playbackControlsSource, contains('required this.playerController'));
    expect(playbackControlsSource, contains('required this.settingsController'));
    expect(playbackControlsSource, isNot(contains('PlayerController.to')));
    expect(playbackControlsSource, isNot(contains('SettingsController.to')));
    expect(controlButtonBackgroundSource, contains('required this.settingsController'));
    expect(controlButtonBackgroundSource, isNot(contains('SettingsController.to')));
  });

  test('bottom panel delegates background and fade mask to local widgets', () {
    final panelSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart',
    ).readAsStringSync();
    final backgroundSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_background_layers.dart',
    ).readAsStringSync();

    expect(panelSource, contains('BottomPanelBackgroundLayer('));
    expect(panelSource, contains('BottomPanelContentFadeMask('));
    expect(panelSource, contains('settingsController: settingsController'));
    expect(panelSource, isNot(contains('BlurryContainer(')));
    expect(panelSource, isNot(contains('LinearGradient(')));
    expect(panelSource, isNot(contains('bottomPanelAnimationController.value')));

    expect(backgroundSource, contains('class BottomPanelBackgroundLayer'));
    expect(backgroundSource, contains('class BottomPanelContentFadeMask'));
    expect(backgroundSource, contains('required this.settingsController'));
    expect(backgroundSource, contains('BlurryContainer('));
    expect(backgroundSource, contains('LinearGradient('));
    expect(backgroundSource, contains('bottomPanelAnimationController.value'));
    expect(backgroundSource, isNot(contains('SettingsController.to')));
  });

  test('bottom panel delegates artwork layer details to local widgets', () {
    final panelSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart',
    ).readAsStringSync();
    final artworkLayerSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_artwork_layer.dart',
    ).readAsStringSync();
    final artworkWidgetsSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_artwork_widgets.dart',
    ).readAsStringSync();

    expect(panelSource, contains('BottomPanelArtworkTransitionLayer('));
    expect(panelSource, contains('BottomPanelArtworkPageLayer('));

    expect(artworkLayerSource, contains('BottomPanelCurrentArtworkImage('));
    expect(artworkLayerSource, contains('BottomPanelArtworkPageViewport('));
    expect(artworkLayerSource, isNot(contains('SimpleExtendedImage(')));
    expect(artworkLayerSource, isNot(contains('PageView.builder(')));
    expect(artworkLayerSource, isNot(contains('PerformanceLogger.elapsed')));
    expect(artworkLayerSource, isNot(contains('ArtworkPathResolver.resolveDisplayPath')));

    expect(artworkWidgetsSource, contains('class BottomPanelCurrentArtworkImage'));
    expect(artworkWidgetsSource, contains('class BottomPanelArtworkPageViewport'));
    expect(artworkWidgetsSource, contains('class BottomPanelArtworkPageCard'));
    expect(artworkWidgetsSource, contains('SimpleExtendedImage('));
    expect(artworkWidgetsSource, contains('PageView.builder('));
    expect(artworkWidgetsSource, contains('PerformanceLogger.elapsed'));
    expect(artworkWidgetsSource, contains('ArtworkPathResolver.resolveDisplayPath'));
  });

  test('bottom panel header uses playback artwork resolver', () {
    final headerSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_header.dart',
    ).readAsStringSync();

    expect(headerSource, contains('ArtworkPathResolver.resolvePlaybackArtwork'));
    expect(headerSource, contains('localArtworkPath: currentSong.localArtworkPath'));
    expect(headerSource, contains('required this.playerController'));
    expect(headerSource, contains('required this.settingsController'));
    expect(headerSource, isNot(contains('PlayerController.to')));
    expect(headerSource, isNot(contains('SettingsController.to')));
  });
}
