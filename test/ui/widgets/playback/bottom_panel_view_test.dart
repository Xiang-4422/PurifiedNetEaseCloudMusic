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

    expect(panelSource, isNot(contains('class BottomPanelHeaderView')));
    expect(panelSource, isNot(contains('miniPlayerExpandControlLabel')));
    expect(miniPlayerSource, contains('class BottomPanelHeaderView'));
    expect(miniPlayerSource, contains('miniPlayerExpandControlLabel'));
    expect(miniPlayerSource, contains('miniPlayerPlayPauseControlLabel'));
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

    expect(panelSource, contains('BottomPanelNowPlayingPage()'));
    expect(panelSource, contains('BottomPanelPageIndicator()'));
    expect(panelSource, isNot(contains('_buildCurPlayingPage')));
    expect(panelSource, isNot(contains('_artistEntries')));
    expect(panelSource, isNot(contains('MyTabBar(')));
    expect(panelSource, isNot(contains('LyricView(')));

    expect(nowPlayingSource, contains('class BottomPanelNowPlayingPage'));
    expect(nowPlayingSource, contains('BottomPanelNowPlayingMetadata()'));
    expect(nowPlayingSource, contains('BottomPanelPlaybackControls()'));
    expect(nowPlayingSource, contains('LyricView('));

    expect(metadataSource, contains('class BottomPanelNowPlayingMetadata'));
    expect(metadataSource, contains('BottomPanelProgressBar()'));
    expect(metadataSource, contains('AlbumRouteView'));
    expect(metadataSource, contains('ArtistRouteView'));
    expect(metadataSource, contains('_artistEntries'));

    expect(indicatorSource, contains('class BottomPanelPageIndicator'));
    expect(indicatorSource, contains("'播放列表'"));
    expect(indicatorSource, contains("'正在播放'"));
    expect(indicatorSource, contains("'歌曲评论'"));
    expect(indicatorSource, contains('bottomPanelCommentTabController'));
  });

  test('bottom panel delegates background and fade mask to local widgets', () {
    final panelSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart',
    ).readAsStringSync();
    final backgroundSource = File(
      'lib/ui/pages/shell/widgets/playback/bottom_panel_background_layers.dart',
    ).readAsStringSync();

    expect(panelSource, contains('BottomPanelBackgroundLayer('));
    expect(panelSource, contains('BottomPanelContentFadeMask()'));
    expect(panelSource, isNot(contains('BlurryContainer(')));
    expect(panelSource, isNot(contains('LinearGradient(')));
    expect(panelSource, isNot(contains('bottomPanelAnimationController.value')));

    expect(backgroundSource, contains('class BottomPanelBackgroundLayer'));
    expect(backgroundSource, contains('class BottomPanelContentFadeMask'));
    expect(backgroundSource, contains('BlurryContainer('));
    expect(backgroundSource, contains('LinearGradient('));
    expect(backgroundSource, contains('bottomPanelAnimationController.value'));
  });
}
