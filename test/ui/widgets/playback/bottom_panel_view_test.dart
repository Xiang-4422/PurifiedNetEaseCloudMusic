import 'dart:io';

import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_artwork_widgets.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_header.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_mini_player.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_now_playing_metadata.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_now_playing_page.dart';
import 'package:flutter/material.dart';
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

    test('calculates collapsed and expanded transition layout', () {
      final collapsed = miniPlayerTransitionLayout(
        panelOpenDegree: 0,
        availableWidth: 360,
        topPadding: 24,
        albumMinSize: 60,
        paddingSmall: 10,
        paddingLarge: 30,
        appBarHeight: 80,
      );

      expect(collapsed.panelOpenDegree, 0);
      expect(collapsed.albumWidth, 60);
      expect(collapsed.albumPadding, 10);
      expect(collapsed.albumTopMargin, 0);
      expect(collapsed.albumBorderRadius, 60);
      expect(collapsed.textHorizontalMargin, 80);
      expect(collapsed.textTopMargin, 0);
      expect(collapsed.smallAlbumLeft, 10);

      final expanded = miniPlayerTransitionLayout(
        panelOpenDegree: 1,
        availableWidth: 360,
        topPadding: 24,
        albumMinSize: 60,
        paddingSmall: 10,
        paddingLarge: 30,
        appBarHeight: 80,
      );

      expect(expanded.panelOpenDegree, 1);
      expect(expanded.albumWidth, 300);
      expect(expanded.albumPadding, 30);
      expect(expanded.albumTopMargin, 104);
      expect(expanded.albumBorderRadius, 15);
      expect(expanded.textHorizontalMargin, 30);
      expect(expanded.textTopMargin, 24);
      expect(expanded.smallAlbumLeft, 270);
    });

    test('clamps transition layout for overshoot and narrow widths', () {
      final overshoot = miniPlayerTransitionLayout(
        panelOpenDegree: 1.4,
        availableWidth: 90,
        topPadding: 12,
        albumMinSize: 60,
        paddingSmall: 10,
        paddingLarge: 30,
        appBarHeight: 80,
      );

      expect(overshoot.panelOpenDegree, 1);
      expect(overshoot.albumWidth, 60);
      expect(overshoot.smallAlbumLeft, 10);

      final invalid = miniPlayerTransitionLayout(
        panelOpenDegree: double.nan,
        availableWidth: double.nan,
        topPadding: 12,
        albumMinSize: 60,
        paddingSmall: 10,
        paddingLarge: 30,
        appBarHeight: 80,
      );

      expect(invalid.panelOpenDegree, 0);
      expect(invalid.albumWidth, 60);
      expect(invalid.textHorizontalMargin, 80);
    });
  });

  group('bottom panel metadata helpers', () {
    test('builds album chip control labels', () {
      expect(
        bottomPanelAlbumChipControlLabel(
          albumTitle: ' Album ',
          canOpenAlbum: true,
        ),
        '打开专辑：Album',
      );
      expect(
        bottomPanelAlbumChipControlLabel(
          albumTitle: '  ',
          canOpenAlbum: false,
        ),
        '专辑：未知专辑',
      );
    });

    test('builds artist chip control labels', () {
      expect(
        bottomPanelArtistChipControlLabel(
          artistName: ' Artist ',
          canOpenArtist: true,
        ),
        '打开歌手：Artist',
      );
      expect(
        bottomPanelArtistChipControlLabel(
          artistName: '  ',
          canOpenArtist: false,
        ),
        '歌手：未知歌手',
      );
    });

    test('builds stable label width without intrinsic layout', () {
      final width = bottomPanelMetadataLabelWidth(
        '歌手：',
        const TextStyle(fontSize: 14),
        horizontalReserve: 28,
      );

      expect(width, greaterThan(28));
    });

    test('clamps metadata value width for narrow panels', () {
      expect(
        bottomPanelMetadataValueMaxWidth(
          remainWidth: 40,
          labelWidth: 64,
        ),
        0,
      );
      expect(
        bottomPanelMetadataValueMaxWidth(
          remainWidth: 120,
          labelWidth: 64,
        ),
        56,
      );
    });
  });

  group('bottom panel artwork helpers', () {
    test('builds header artwork control label', () {
      expect(
        bottomPanelHeaderArtworkControlLabel(
          title: ' Song ',
          fullScreenLyricOpen: false,
        ),
        '放大封面：Song',
      );
      expect(
        bottomPanelHeaderArtworkControlLabel(
          title: ' ',
          fullScreenLyricOpen: true,
        ),
        '退出全屏歌词：当前歌曲',
      );
    });

    test('builds page card collapse label', () {
      expect(bottomPanelArtworkPageCardControlLabel(), '收起封面');
    });
  });

  group('bottom panel now playing helpers', () {
    test('builds lyric area control labels', () {
      expect(
        bottomPanelLyricAreaControlLabel(
          title: ' Song ',
          fullScreenLyricOpen: false,
        ),
        '放大封面：Song',
      );
      expect(
        bottomPanelLyricAreaControlLabel(
          title: '  ',
          fullScreenLyricOpen: true,
        ),
        '退出全屏歌词：当前歌曲',
      );
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
    expect(miniPlayerSource, contains('openBottomPanelFromMiniPlayer'));
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
    final homeSource = File(
      'lib/ui/pages/shell/app_home_page_view.dart',
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
    expect(panelSource, contains('required this.commentControllerFactory'));
    expect(panelSource, contains('commentControllerFactory: commentControllerFactory'));
    expect(panelSource, isNot(contains('Get.find<CommentControllerFactory>')));
    expect(panelSource, isNot(contains('PlayerController.to')));
    expect(panelSource, isNot(contains('SettingsController.to')));
    expect(homeSource, contains('final appHomeControllers = Get.find<AppHomeControllerBundle>()'));
    expect(homeSource, contains('final commentControllerFactory = appHomeControllers.commentControllerFactory'));
    expect(homeSource, isNot(contains('Get.find<CommentControllerFactory>')));
    expect(homeSource, contains('panel: BottomPanelView('));
    expect(homeSource, contains('commentControllerFactory: commentControllerFactory'));
    expect(homeSource, contains('playerController: playerController'));
    expect(homeSource, contains('settingsController: settingsController'));
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
    expect(nowPlayingSource, contains('bottomPanelLyricAreaControlLabel('));
    expect(nowPlayingSource, contains('Tooltip('));
    expect(nowPlayingSource, contains('Semantics('));
    expect(nowPlayingSource, contains('required this.playerController'));
    expect(nowPlayingSource, contains('required this.settingsController'));

    expect(metadataSource, contains('class BottomPanelNowPlayingMetadata'));
    expect(metadataSource, contains('required this.playerController'));
    expect(metadataSource, contains('required this.settingsController'));
    expect(metadataSource, contains('BottomPanelProgressBar('));
    expect(metadataSource, contains('bottomPanelAlbumChipControlLabel('));
    expect(metadataSource, contains('bottomPanelArtistChipControlLabel('));
    expect(metadataSource, contains('Semantics('));
    expect(metadataSource, contains('Tooltip('));
    expect(metadataSource, contains('AlbumRouteView'));
    expect(metadataSource, contains('ArtistRouteView'));
    expect(metadataSource, contains('_artistEntries'));
    expect(metadataSource, contains('bottomPanelMetadataLabelWidth('));
    expect(metadataSource, contains('bottomPanelMetadataValueMaxWidth('));
    expect(metadataSource, isNot(contains('IntrinsicWidth(')));
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
    expect(panelSource, contains('playerController: playerController'));

    expect(artworkLayerSource, contains('BottomPanelCurrentArtworkImage('));
    expect(artworkLayerSource, contains('BottomPanelArtworkPageViewport('));
    expect(artworkLayerSource, contains('required this.playerController'));
    expect(artworkLayerSource, isNot(contains('SimpleExtendedImage(')));
    expect(artworkLayerSource, isNot(contains('PageView.builder(')));
    expect(artworkLayerSource, isNot(contains('PerformanceLogger.elapsed')));
    expect(artworkLayerSource, isNot(contains('ArtworkPathResolver.resolveDisplayPath')));

    expect(artworkWidgetsSource, contains('class BottomPanelCurrentArtworkImage'));
    expect(artworkWidgetsSource, contains('class BottomPanelArtworkPageViewport'));
    expect(artworkWidgetsSource, contains('class BottomPanelArtworkPageCard'));
    expect(artworkWidgetsSource, contains('required this.playerController'));
    expect(artworkWidgetsSource, contains('bottomPanelArtworkPageCardControlLabel('));
    expect(artworkWidgetsSource, contains('Tooltip('));
    expect(artworkWidgetsSource, contains('Semantics('));
    expect(artworkWidgetsSource, contains('ExcludeSemantics('));
    expect(artworkWidgetsSource, contains('behavior: HitTestBehavior.opaque'));
    expect(artworkWidgetsSource, contains('SimpleExtendedImage('));
    expect(artworkWidgetsSource, contains('PageView.builder('));
    expect(artworkWidgetsSource, contains('PerformanceLogger.elapsed'));
    expect(artworkWidgetsSource, contains('ArtworkPathResolver.resolveDisplayPath'));
    expect(artworkWidgetsSource, isNot(contains('PlayerController.to')));
  });

  test('bottom panel header uses playback artwork resolver', () {
    final headerSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_header.dart',
    ).readAsStringSync();

    expect(headerSource, contains('ArtworkPathResolver.resolvePlaybackArtwork'));
    expect(headerSource, contains('localArtworkPath: currentSong.localArtworkPath'));
    expect(headerSource, contains('bottomPanelHeaderArtworkControlLabel('));
    expect(headerSource, contains('Tooltip('));
    expect(headerSource, contains('Semantics('));
    expect(headerSource, contains('ExcludeSemantics('));
    expect(headerSource, contains('behavior: HitTestBehavior.opaque'));
    expect(headerSource, contains('required this.playerController'));
    expect(headerSource, contains('required this.settingsController'));
    expect(headerSource, isNot(contains('PlayerController.to')));
    expect(headerSource, isNot(contains('SettingsController.to')));
  });
}
