import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('personal page keeps continue playback as the first quick start action', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final quickStartSource = File(
      'lib/ui/pages/user/widgets/quick_start_card_rail.dart',
    ).readAsStringSync();
    final quickStartSectionSource = File(
      'lib/ui/pages/user/widgets/quick_start_section.dart',
    ).readAsStringSync();
    final firstRailIndex = source.indexOf('QuickStartSection(');
    final squareRailIndex = source.indexOf('SquareQuickStartPage(');
    final continueIndex = quickStartSource.indexOf('_ContinuePlaybackQuickStartCard(');
    final dailyIndex = quickStartSource.indexOf('_DailyRecommendQuickStartCard(');

    expect(firstRailIndex, isNonNegative);
    expect(squareRailIndex, isNonNegative);
    expect(continueIndex, lessThan(dailyIndex));
    expect(source, contains('quick_start_section.dart'));
    expect(source, isNot(contains('QuickStartCardRail(')));
    expect(source, isNot(contains('squareQuickCardSize(')));
    expect(quickStartSectionSource, contains('class QuickStartSection'));
    expect(quickStartSectionSource, contains('class SquareQuickStartPage'));
    expect(quickStartSectionSource, contains('QuickStartCardRail('));
    expect(quickStartSectionSource, contains('squareQuickCardSize('));
    expect(quickStartSource, contains("title: '继续播放'"));
    expect(quickStartSource, contains("title: '每日推荐'"));
    expect(quickStartSource, contains("title: '漫游模式'"));
    expect(quickStartSource, contains("title: '心动模式'"));
  });

  test('personal page exposes focused library shortcuts before recommendations', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final shortcutSource = File(
      'lib/ui/pages/user/widgets/library_shortcut_bar.dart',
    ).readAsStringSync();
    final libraryIndex = source.indexOf("'资料库'");
    final squareLibraryIndex = source.indexOf("'资料库'", libraryIndex + 1);
    final recommendedIndex = source.indexOf('RecommendedPlaylistPinnedHeaderSliver(');

    expect(libraryIndex, isNonNegative);
    expect(squareLibraryIndex, isNonNegative);
    expect(recommendedIndex, isNonNegative);
    expect(libraryIndex, lessThan(recommendedIndex));
    expect(source, contains('child: LibraryShortcutBar()'));
    expect(source, contains('recommended_playlist_slivers.dart'));
    expect(shortcutSource, contains("label: '我喜欢'"));
    expect(shortcutSource, contains("label: '我的歌单'"));
    expect(shortcutSource, contains("label: '本地音乐'"));
    expect(shortcutSource, contains("label: '已下载'"));
    expect(shortcutSource, contains("label: '云盘'"));
    expect(shortcutSource.indexOf("label: '我喜欢'"), lessThan(shortcutSource.indexOf("label: '我的歌单'")));
    expect(shortcutSource.indexOf("label: '我的歌单'"), lessThan(shortcutSource.indexOf("label: '本地音乐'")));
    expect(shortcutSource, contains('UserLibraryController.to.userLikedSongPlayList.value'));
    expect(shortcutSource, contains('UserPlaylistLibraryPageView'));
    expect(shortcutSource, contains('gr.PlayListRouteView('));
    expect(shortcutSource, contains('DownloadTaskPageView.tabLocalImport'));
    expect(shortcutSource, contains('DownloadTaskPageView.tabDownloaded'));
    expect(shortcutSource, contains('context.router.push(const gr.CloudDriveView())'));
    expect(source, isNot(contains('PlayListItem(libraryController.userLikedSongPlayList.value)')));
    expect(source, isNot(contains('PlayListItem(widget.libraryController.userLikedSongPlayList.value)')));
  });

  test('recommended playlists rendering stays in local user widgets', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final sliverSource = File(
      'lib/ui/pages/user/widgets/recommended_playlist_slivers.dart',
    ).readAsStringSync();
    final pageSource = File(
      'lib/ui/pages/user/recommended_playlists_page.dart',
    ).readAsStringSync();
    final appBodySource = File('lib/ui/pages/shell/app_body_page_view.dart').readAsStringSync();

    expect(source, contains('RecommendedPlaylistPinnedHeaderSliver('));
    expect(source, contains('RecommendedPlaylistListSliver(controller: recommendationController)'));
    expect(source, isNot(contains('class RecommendedPlaylistsPageView')));
    expect(source, isNot(contains('SliverList.builder(')));
    expect(source, isNot(contains('PlayListItem(recommendationController.recoPlayLists')));
    expect(sliverSource, contains('class RecommendedPlaylistPinnedHeaderSliver'));
    expect(sliverSource, contains('Theme.of(context).colorScheme.surface'));
    expect(sliverSource, contains('controller.recoPlayLists'));
    expect(sliverSource, contains('PlayListItem('));
    expect(pageSource, contains('class RecommendedPlaylistsPageView'));
    expect(pageSource, contains('RecommendedPlaylistHeaderSliver'));
    expect(pageSource, contains('RecommendedPlaylistListSliver(controller: recommendationController)'));
    expect(pageSource, isNot(contains('PlayListItem(')));
    expect(appBodySource, contains('recommended_playlists_page.dart'));
  });

  test('user playlist library page lists account playlists without data source access', () {
    final source = File('lib/ui/pages/user/user_playlist_library_page.dart').readAsStringSync();

    expect(source, contains("title: const Text('我的歌单')"));
    expect(source, contains('UserLibraryController.to'));
    expect(source, contains('controller.userPlayLists'));
    expect(source, contains('PlayListItem(playlists[index])'));
    expect(source, contains("Text('暂无歌单')"));
    expect(source, isNot(contains('package:bujuan/data/')));
    expect(source, isNot(contains('_data_source.dart')));
  });

  test('personal page shows recent playback before frequent playlists and library sections', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final recentPlaybackSource = File(
      'lib/ui/pages/user/widgets/recent_playback_strip.dart',
    ).readAsStringSync();
    final frequentPlaylistSource = File(
      'lib/ui/pages/user/widgets/frequent_playlist_section.dart',
    ).readAsStringSync();
    final recentControllerIndex = source.indexOf('final recentPlaybackController = RecentPlaybackController.to;');
    final recentStripIndex = source.indexOf('child: RecentPlaybackStrip(');
    final squareRecentStripIndex = source.indexOf('child: RecentPlaybackStrip(', recentStripIndex + 1);
    final recentHeaderIndex = recentPlaybackSource.indexOf("'最近播放'");
    final playlistHeaderIndex = source.indexOf('FrequentPlaylistSection(');
    final squarePlaylistHeaderIndex = source.indexOf('FrequentPlaylistSection(', playlistHeaderIndex + 1);
    final libraryHeaderIndex = source.indexOf("'资料库'");

    expect(recentControllerIndex, isNonNegative);
    expect(recentStripIndex, isNonNegative);
    expect(squareRecentStripIndex, isNonNegative);
    expect(recentHeaderIndex, isNonNegative);
    expect(playlistHeaderIndex, isNonNegative);
    expect(squarePlaylistHeaderIndex, isNonNegative);
    expect(libraryHeaderIndex, isNonNegative);
    expect(recentStripIndex, lessThan(playlistHeaderIndex));
    expect(squareRecentStripIndex, lessThan(squarePlaylistHeaderIndex));
    expect(playlistHeaderIndex, lessThan(libraryHeaderIndex));
    expect(recentPlaybackSource, contains("playListName: '最近播放'"));
    expect(source, contains('frequent_playlist_section.dart'));
    expect(source, isNot(contains('homeFrequentPlaylists')));
    expect(source, isNot(contains('PlaylistRepository')));
    expect(frequentPlaylistSource, contains("'常用歌单'"));
    expect(frequentPlaylistSource, contains('homeFrequentPlaylists'));
    expect(frequentPlaylistSource, contains('onPlayPlaylist: _playPlaylistSummary'));
    expect(source, isNot(contains('watchCurrentSong')));
  });

  test('personal page artwork entries use playback artwork resolver', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final quickStartSource = File(
      'lib/ui/pages/user/widgets/quick_start_card_rail.dart',
    ).readAsStringSync();
    final recentPlaybackSource = File(
      'lib/ui/pages/user/widgets/recent_playback_strip.dart',
    ).readAsStringSync();
    final todayPageSource = File('lib/ui/pages/user/today_page_view.dart').readAsStringSync();

    expect(source, contains('quick_start_card_rail.dart'));
    expect(source, isNot(contains('String _playbackArtworkPath(PlaybackQueueItem item)')));
    expect(quickStartSource, contains('String _playbackArtworkPath(PlaybackQueueItem item)'));
    expect(quickStartSource, contains('ArtworkPathResolver.resolvePlaybackArtwork'));
    expect(recentPlaybackSource, contains('ArtworkPathResolver.resolvePlaybackArtwork'));
    expect(todayPageSource, contains('ArtworkPathResolver.resolvePlaybackArtwork'));

    expect(source, isNot(contains('currentSong.artworkUrl ??')));
    expect(quickStartSource, isNot(contains('currentSong.artworkUrl ??')));
    expect(source, isNot(contains('todayRecommendSongs[0].artworkUrl')));
    expect(source, isNot(contains('fmSongs[0].artworkUrl')));
    expect(recentPlaybackSource, isNot(contains('song.artworkUrl ?? song.localArtworkPath')));
    expect(todayPageSource, isNot(contains("songs.first.artworkUrl ?? ''")));
  });

  test('personal page keeps quick start card details in local widget file', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final quickStartSource = File(
      'lib/ui/pages/user/widgets/quick_start_card_rail.dart',
    ).readAsStringSync();
    final quickStartSectionSource = File(
      'lib/ui/pages/user/widgets/quick_start_section.dart',
    ).readAsStringSync();

    expect(source, contains('QuickStartSection('));
    expect(source, contains('SquareQuickStartPage('));
    expect(source, isNot(contains('QuickStartCardRail(')));
    expect(source, isNot(contains('class QuickStartCard')));
    expect(source, isNot(contains('LongPressOverlayTransition(')));
    expect(source, isNot(contains('AppAssets.lottieMusicPlaying')));
    expect(quickStartSectionSource, contains('QuickStartCardRail('));
    expect(quickStartSource, contains('class QuickStartCardRail'));
    expect(quickStartSource, contains('class QuickStartCard'));
    expect(quickStartSource, contains('LongPressOverlayTransition('));
    expect(quickStartSource, contains('Lottie.asset('));
    expect(quickStartSource, contains('AppAssets.lottieMusicPlaying'));
  });

  test('download task page can open a focused local library tab', () {
    final source = File('lib/ui/pages/download/download_task_page_view.dart').readAsStringSync();

    expect(source, contains('static const int tabDownloaded = 2;'));
    expect(source, contains('static const int tabLocalImport = 3;'));
    expect(source, contains('final int initialTabIndex;'));
    expect(source, contains('initialIndex: widget.initialTabIndex'));
  });
}
