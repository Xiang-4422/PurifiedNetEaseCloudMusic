import 'dart:io';

import 'package:bujuan/features/playlist/playlist_page_controller.dart';
import 'package:bujuan/ui/pages/playlist/playlist_page_state.dart';
import 'package:bujuan/ui/pages/playlist/playlist_page_view.dart';
import 'package:bujuan/ui/pages/playlist/widgets/playlist_header_sliver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('playlist header action labels stay stable', () {
    expect(
      playlistPlayActionLabel(
        label: ' 顺序播放 ',
        isEnabled: true,
      ),
      '顺序播放',
    );
    expect(
      playlistPlayActionLabel(
        label: '随机播放',
        isEnabled: false,
      ),
      '随机播放（等待歌曲加载）',
    );
    expect(
      playlistPlayActionLabel(
        label: '  ',
        isEnabled: false,
      ),
      '播放歌单（等待歌曲加载）',
    );
    expect(playlistSubscribeControlLabel(isSubscribed: false), '收藏歌单');
    expect(playlistSubscribeControlLabel(isSubscribed: true), '取消收藏歌单');
  });

  test('playlist page delegates header and status presentation to local widgets', () {
    final source = File('lib/ui/pages/playlist/playlist_page_view.dart').readAsStringSync();
    final contentSource = File(
      'lib/ui/pages/playlist/widgets/playlist_content_scroll_view.dart',
    ).readAsStringSync();

    expect(source, contains('PlaylistContentScrollView('));
    expect(source, contains('ErrorView('));
    expect(source, contains('onRetry: () => unawaited('));
    expect(source, isNot(contains('? GestureDetector(')));
    expect(source, isNot(contains('CustomScrollView(')));
    expect(contentSource, contains('RefreshIndicator('));
    expect(contentSource, contains('CustomScrollView('));
    expect(contentSource, contains('PlaylistHeaderSliver('));
    expect(contentSource, contains('PlaylistSongListSliver('));
    expect(contentSource, contains('PlaylistSkeletonSliver('));
    expect(contentSource, contains('PlaylistStatusFooterSliver('));
    expect(source, isNot(contains('SliverAppBar(')));
    expect(source, isNot(contains('SongItem(')));
    expect(source, isNot(contains('class _PlaylistActionButtonSurface')));
  });

  test('playlist page records cached playlist open performance metric', () {
    final source = File('lib/ui/pages/playlist/playlist_page_view.dart').readAsStringSync();

    expect(source, contains('PlaylistPerformanceLogger.elapsedMetric('));
    expect(source, contains('AppPerformanceMetrics.cachedPlaylistOpen'));
    expect(source, contains('cachedPlaylistOpenLocalMetricDetails('));
    expect(source, contains('cachedPlaylistOpenRemoteMetricDetails('));
  });

  test('playlist page keeps cached playlist metric details stable', () {
    expect(
      cachedPlaylistOpenLocalMetricDetails(
        state: PlaylistLocalDetailState.partial,
        songs: 30,
      ),
      'source=local state=partial songs=30',
    );
    expect(
      cachedPlaylistOpenRemoteMetricDetails(
        songs: 12,
        state: PlaylistPageLoadState.showingPartial,
      ),
      'source=remote songs=12 state=showingPartial',
    );
  });

  test('playlist page keeps display state rules in a local state model', () {
    final pageSource = File('lib/ui/pages/playlist/playlist_page_view.dart').readAsStringSync();
    final stateSource = File(
      'lib/ui/pages/playlist/playlist_page_state.dart',
    ).readAsStringSync();

    expect(pageSource, contains('PlaylistPagePresentation('));
    expect(pageSource, isNot(contains('enum _PlaylistPageLoadState')));
    expect(pageSource, isNot(contains('enum _PlaylistFetchKind')));
    expect(stateSource, contains('enum PlaylistPageLoadState'));
    expect(stateSource, contains('enum PlaylistFetchKind'));
    expect(stateSource, contains('class PlaylistPagePresentation'));
    expect(stateSource, contains('canPlayLoadedPlaylist'));
    expect(stateSource, contains('completionMessage'));
  });

  test('playlist page opens playback panel through page shell boundary', () {
    final pageSource = File('lib/ui/pages/playlist/playlist_page_view.dart').readAsStringSync();

    expect(pageSource, contains('final ShellController _shellController = Get.find<ShellController>()'));
    expect(pageSource, contains('void _openPlaybackPanel()'));
    expect(pageSource, contains('_shellController.jumpBottomPanelToPage(0)'));
    expect(pageSource, contains('_shellController.openBottomPanel()'));
    expect(pageSource, contains('_openPlaybackPanel();'));
    expect(pageSource, isNot(contains('ShellController.to')));
  });

  test('playlist header keeps focused playback and subscription actions', () {
    final source = File(
      'lib/ui/pages/playlist/widgets/playlist_header_sliver.dart',
    ).readAsStringSync();

    expect(source, contains("'顺序播放'"));
    expect(source, contains("'随机播放'"));
    expect(source, contains('TablerIcons.repeat'));
    expect(source, contains('TablerIcons.arrows_shuffle'));
    expect(source, contains('TablerIcons.heart_filled'));
    expect(source, contains('TablerIcons.heart'));
    expect(source, contains(r"'歌单·${trackCount ?? loadedTrackCount}首'"));
    expect(source, contains('canPlayLoadedPlaylist'));
    expect(source, contains('playlistPlayActionLabel('));
    expect(source, contains('playlistSubscribeControlLabel('));
    expect(source, contains('tooltip: playlistPlayActionLabel('));
    expect(source, contains('tooltip: playlistSubscribeControlLabel('));
  });

  test('playlist status slivers keep skeleton and footer copy outside page state', () {
    final source = File(
      'lib/ui/pages/playlist/widgets/playlist_status_slivers.dart',
    ).readAsStringSync();

    expect(source, contains('class PlaylistSkeletonSliver'));
    expect(source, contains('class PlaylistStatusFooterSliver'));
    expect(source, contains('childCount: 8'));
    expect(source, contains('message'));
  });

  test('playlist song list keeps row presentation outside page state', () {
    final pageSource = File('lib/ui/pages/playlist/playlist_page_view.dart').readAsStringSync();
    final listSource = File(
      'lib/ui/pages/playlist/widgets/playlist_song_list_sliver.dart',
    ).readAsStringSync();

    expect(pageSource, contains('onTapSong: _playSongAt'));
    expect(pageSource, contains("playListNameHeader: '歌单'"));
    expect(pageSource, isNot(contains('SliverChildBuilderDelegate(')));
    expect(listSource, contains('class PlaylistSongListSliver'));
    expect(listSource, contains('SliverPrototypeExtentList('));
    expect(listSource, contains('prototypeItem: SongItem('));
    expect(listSource, contains('SliverChildBuilderDelegate('));
    expect(listSource, contains('SongItem('));
    expect(listSource, contains("playListHeader: '歌单'"));
    expect(listSource, contains('foregroundColor'));
    expect(listSource, contains('addAutomaticKeepAlives: false'));
  });
}
