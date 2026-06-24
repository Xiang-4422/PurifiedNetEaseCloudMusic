import 'dart:io';

import 'package:bujuan/ui/pages/user/today_page_view.dart';
import 'package:bujuan/ui/pages/user/user_setting_view.dart';
import 'package:bujuan/ui/pages/user/widgets/quick_start_card_rail.dart';
import 'package:bujuan/ui/pages/user/widgets/recent_playback_strip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quick start cards expose stable semantics labels', () {
    expect(
      quickStartCardSemanticsLabel(
        title: ' 每日推荐 ',
        isEnabled: true,
      ),
      '每日推荐',
    );
    expect(
      quickStartCardSemanticsLabel(
        title: '继续播放',
        isEnabled: false,
      ),
      '继续播放（当前不可用）',
    );
    expect(
      quickStartCardSemanticsLabel(
        title: '   ',
        isEnabled: false,
      ),
      '快速入口（当前不可用）',
    );
  });

  test('recent playback cards expose stable semantics labels', () {
    expect(
      recentPlaybackTileSemanticsLabel(
        title: ' Song ',
        artist: ' Artist ',
        isCurrent: false,
      ),
      '播放最近播放：Song - Artist',
    );
    expect(
      recentPlaybackTileSemanticsLabel(
        title: 'Current',
        artist: null,
        isCurrent: true,
      ),
      '当前播放：Current - 未知艺人',
    );
    expect(
      recentPlaybackTileSemanticsLabel(
        title: '  ',
        artist: '  ',
        isCurrent: false,
      ),
      '播放最近播放：未知歌曲 - 未知艺人',
    );
  });

  test('user profile logout uses a stable standard button', () {
    expect(userProfileLogoutControlLabel(), '注销登录');

    final source = File('lib/ui/pages/user/user_setting_view.dart').readAsStringSync();

    expect(source, contains('userProfileLogoutControlLabel('));
    expect(source, contains('FilledButton.icon('));
    expect(source, contains('TablerIcons.logout'));
    expect(source, contains('Tooltip('));
    expect(source, contains('excludeFromSemantics: true'));
    expect(source, contains('_controller.logoutCurrentUser()'));
    expect(source, contains('onRetry: _controller.loadInitial'));
    expect(source, isNot(contains('GestureDetector(')));
  });

  test('today page play all button exposes stable labels', () {
    expect(todayPlayAllControlLabel(hasSongs: true), '播放每日推荐');
    expect(todayPlayAllControlLabel(hasSongs: false), '每日推荐暂无歌曲');
  });

  test('today page song list keeps stable prototype extents', () {
    final source = File(
      'lib/ui/pages/user/today_page_view.dart',
    ).readAsStringSync();

    expect(source, contains('SliverPrototypeExtentList('));
    expect(source, contains('prototypeItem: SongItem('));
    expect(source, contains('addAutomaticKeepAlives: false'));
    expect(source, contains('height: AppDimensions.bottomPanelHeaderHeight'));
  });

  test('personal page keeps continue playback as the first quick start action', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final standardSource = File(
      'lib/ui/pages/user/widgets/standard_personal_home_page.dart',
    ).readAsStringSync();
    final squareHomeSource = File(
      'lib/ui/pages/user/widgets/square_personal_home_page.dart',
    ).readAsStringSync();
    final quickStartSource = File(
      'lib/ui/pages/user/widgets/quick_start_card_rail.dart',
    ).readAsStringSync();
    final quickStartSectionSource = File(
      'lib/ui/pages/user/widgets/quick_start_section.dart',
    ).readAsStringSync();
    final firstRailIndex = standardSource.indexOf('QuickStartSection(');
    final squareRailIndex = squareHomeSource.indexOf('SquareQuickStartPage(');
    final continueIndex = quickStartSource.indexOf('_ContinuePlaybackQuickStartCard(');
    final dailyIndex = quickStartSource.indexOf('_DailyRecommendQuickStartCard(');

    expect(firstRailIndex, isNonNegative);
    expect(squareRailIndex, isNonNegative);
    expect(continueIndex, lessThan(dailyIndex));
    expect(source, contains('standard_personal_home_page.dart'));
    expect(source, contains('square_personal_home_page.dart'));
    expect(source, isNot(contains('quick_start_section.dart')));
    expect(source, isNot(contains('QuickStartCardRail(')));
    expect(source, isNot(contains('squareQuickCardSize(')));
    expect(standardSource, contains('quick_start_section.dart'));
    expect(squareHomeSource, contains('quick_start_section.dart'));
    expect(quickStartSectionSource, contains('class QuickStartSection'));
    expect(quickStartSectionSource, contains('class SquareQuickStartPage'));
    expect(quickStartSectionSource, contains('QuickStartCardRail('));
    expect(quickStartSectionSource, contains('squareQuickCardSize('));
    expect(quickStartSource, contains("title: '继续播放'"));
    expect(quickStartSource, contains("title: '每日推荐'"));
    expect(quickStartSource, contains("title: '漫游模式'"));
    expect(quickStartSource, contains("title: '心动模式'"));
    expect(quickStartSource, contains('quickStartCardSemanticsLabel('));
    expect(quickStartSource, contains('Semantics('));
    expect(quickStartSource, contains('button: true'));
    expect(quickStartSource, contains('Tooltip('));
    expect(quickStartSource, contains('excludeFromSemantics: true'));
    expect(quickStartSource, contains('ExcludeSemantics('));
  });

  test('personal page exposes focused library shortcuts before recommendations', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final standardSource = File(
      'lib/ui/pages/user/widgets/standard_personal_home_page.dart',
    ).readAsStringSync();
    final squareHomeSource = File(
      'lib/ui/pages/user/widgets/square_personal_home_page.dart',
    ).readAsStringSync();
    final sectionSource = File(
      'lib/ui/pages/user/widgets/library_shortcut_section.dart',
    ).readAsStringSync();
    final shortcutSource = File(
      'lib/ui/pages/user/widgets/library_shortcut_bar.dart',
    ).readAsStringSync();
    final libraryIndex = standardSource.indexOf('LibraryShortcutSection(');
    final squareLibraryIndex = squareHomeSource.indexOf('SquareLibraryPage(');
    final recommendedIndex = standardSource.indexOf('RecommendedPlaylistPinnedHeaderSliver(');

    expect(libraryIndex, isNonNegative);
    expect(squareLibraryIndex, isNonNegative);
    expect(recommendedIndex, isNonNegative);
    expect(libraryIndex, lessThan(recommendedIndex));
    expect(source, contains('standard_personal_home_page.dart'));
    expect(source, contains('square_personal_home_page.dart'));
    expect(source, isNot(contains('library_shortcut_section.dart')));
    expect(source, isNot(contains('square_library_page.dart')));
    expect(standardSource, contains('library_shortcut_section.dart'));
    expect(squareHomeSource, contains('square_library_page.dart'));
    expect(source, isNot(contains("Header('资料库'")));
    expect(source, isNot(contains('child: LibraryShortcutBar()')));
    expect(sectionSource, contains("Header(\n      '资料库'"));
    expect(sectionSource, contains('LibraryShortcutBar('));
    expect(sectionSource, contains('likedPlaylist: () => libraryController.userLikedSongPlayList.value'));
    expect(standardSource, contains('recommended_playlist_slivers.dart'));
    expect(shortcutSource, contains("label: '我喜欢'"));
    expect(shortcutSource, contains("label: '我的歌单'"));
    expect(shortcutSource, contains("label: '本地音乐'"));
    expect(shortcutSource, contains("label: '已下载'"));
    expect(shortcutSource, contains("label: '云盘'"));
    expect(shortcutSource, contains('const double _libraryShortcutBarHeight = 72;'));
    expect(shortcutSource, contains('const double _libraryShortcutItemWidth = 84;'));
    expect(shortcutSource, contains('const double _libraryShortcutCacheExtent = 240;'));
    expect(shortcutSource, contains('height: _libraryShortcutBarHeight'));
    expect(shortcutSource, contains('width: _libraryShortcutItemWidth'));
    expect(shortcutSource, contains('cacheExtent: _libraryShortcutCacheExtent'));
    expect(shortcutSource.indexOf("label: '我喜欢'"), lessThan(shortcutSource.indexOf("label: '我的歌单'")));
    expect(shortcutSource.indexOf("label: '我的歌单'"), lessThan(shortcutSource.indexOf("label: '本地音乐'")));
    expect(shortcutSource, contains('final PlaylistSummaryData Function() likedPlaylist'));
    expect(shortcutSource, contains('final WidgetBuilder userPlaylistsPageBuilder'));
    expect(shortcutSource, contains('final playlist = likedPlaylist();'));
    expect(shortcutSource, contains('builder: userPlaylistsPageBuilder'));
    expect(sectionSource, contains('UserPlaylistLibraryPageView('));
    expect(sectionSource, contains('controller: libraryController'));
    expect(shortcutSource, contains('gr.PlayListRouteView('));
    expect(shortcutSource, contains('DownloadTaskPageView.tabLocalImport'));
    expect(shortcutSource, contains('DownloadTaskPageView.tabDownloaded'));
    expect(shortcutSource, contains('context.router.push(const gr.CloudDriveView())'));
    expect(source, isNot(contains('PlayListItem(libraryController.userLikedSongPlayList.value)')));
    expect(source, isNot(contains('PlayListItem(widget.libraryController.userLikedSongPlayList.value)')));
  });

  test('recommended playlists rendering stays in local user widgets', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final standardSource = File(
      'lib/ui/pages/user/widgets/standard_personal_home_page.dart',
    ).readAsStringSync();
    final sliverSource = File(
      'lib/ui/pages/user/widgets/recommended_playlist_slivers.dart',
    ).readAsStringSync();
    final pageSource = File(
      'lib/ui/pages/user/recommended_playlists_page.dart',
    ).readAsStringSync();
    final appBodySource = File('lib/ui/pages/shell/app_body_page_view.dart').readAsStringSync();

    expect(source, contains('StandardPersonalHomePage('));
    expect(source, isNot(contains('RecommendedPlaylistPinnedHeaderSliver(')));
    expect(standardSource, contains('RecommendedPlaylistPinnedHeaderSliver('));
    expect(standardSource, contains('RecommendedPlaylistListSliver(controller: recommendationController)'));
    expect(standardSource, contains('const double standardPersonalHomeScrollCacheExtent = 360;'));
    expect(standardSource, contains('cacheExtent: standardPersonalHomeScrollCacheExtent'));
    expect(standardSource, isNot(contains('cacheExtent: 120')));
    expect(source, isNot(contains('class RecommendedPlaylistsPageView')));
    expect(source, isNot(contains('SliverList.builder(')));
    expect(source, isNot(contains('PlayListItem(recommendationController.recoPlayLists')));
    expect(sliverSource, contains('class RecommendedPlaylistPinnedHeaderSliver'));
    expect(sliverSource, contains('Theme.of(context).colorScheme.surface'));
    expect(sliverSource, contains('controller.recoPlayLists'));
    expect(sliverSource, contains('PlayListItem('));
    expect(pageSource, contains('class RecommendedPlaylistsPageView extends GetView<RecommendationController>'));
    expect(pageSource, contains('const double recommendedPlaylistsPageScrollCacheExtent = 360;'));
    expect(pageSource, contains('cacheExtent: recommendedPlaylistsPageScrollCacheExtent'));
    expect(pageSource, isNot(contains('cacheExtent: 120')));
    expect(pageSource, contains('RecommendedPlaylistHeaderSliver'));
    expect(pageSource, contains('RecommendedPlaylistListSliver(controller: controller)'));
    expect(pageSource, isNot(contains('RecommendationController.to')));
    expect(pageSource, isNot(contains('PlayListItem(')));
    expect(appBodySource, contains('recommended_playlists_page.dart'));
    expect(appBodySource, contains('final homeShellController = HomeShellScope.of(context)'));
    expect(
      appBodySource,
      contains('final personalHomeControllers = Get.find<PersonalHomeControllerBundle>()'),
    );
    expect(appBodySource, contains('DrawerMainScreenView('));
    expect(appBodySource, contains('homeShellController: homeShellController'));
    expect(
      appBodySource,
      contains('recommendationController: personalHomeControllers.recommendationController'),
    );
    expect(
      appBodySource,
      contains('userLibraryController: personalHomeControllers.userLibraryController'),
    );
    expect(
      appBodySource,
      contains('playerController: personalHomeControllers.playerController'),
    );
    expect(
      appBodySource,
      contains('recentPlaybackController: personalHomeControllers.recentPlaybackController'),
    );
    expect(appBodySource, contains('MenuView(homeShellController: homeShellController)'));
  });

  test('user playlist library page lists account playlists without data source access', () {
    final source = File('lib/ui/pages/user/user_playlist_library_page.dart').readAsStringSync();

    expect(source, contains("title: const Text('我的歌单')"));
    expect(source, contains('required this.controller'));
    expect(source, isNot(contains('UserLibraryController.to')));
    expect(source, contains('controller.userPlayLists'));
    expect(source, contains('const double _userPlaylistLibraryCacheExtent = 360;'));
    expect(source, contains('cacheExtent: _userPlaylistLibraryCacheExtent'));
    expect(source, contains('prototypeItem: const Padding('));
    expect(source, contains('child: PlayListItem(_userPlaylistLibraryPrototypePlaylist)'));
    expect(source, contains('const PlaylistSummaryData _userPlaylistLibraryPrototypePlaylist'));
    expect(source, contains('ListView.builder('));
    expect(source, isNot(contains('ListView.separated(')));
    expect(source, contains('child: PlayListItem(playlists[index])'));
    expect(source, contains("Text('暂无歌单')"));
    expect(source, isNot(contains('package:bujuan/data/')));
    expect(source, isNot(contains('_data_source.dart')));
  });

  test('personal page shows recent playback before frequent playlists and library sections', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final standardSource = File(
      'lib/ui/pages/user/widgets/standard_personal_home_page.dart',
    ).readAsStringSync();
    final recentPlaybackSource = File(
      'lib/ui/pages/user/widgets/recent_playback_strip.dart',
    ).readAsStringSync();
    final frequentPlaylistSource = File(
      'lib/ui/pages/user/widgets/frequent_playlist_section.dart',
    ).readAsStringSync();
    final squareLibrarySource = File(
      'lib/ui/pages/user/widgets/square_library_page.dart',
    ).readAsStringSync();
    final recentStripIndex = standardSource.indexOf('RecentPlaybackStrip(');
    final squareRecentStripIndex = squareLibrarySource.indexOf('RecentPlaybackStrip(');
    final recentHeaderIndex = recentPlaybackSource.indexOf("'最近播放'");
    final playlistHeaderIndex = standardSource.indexOf('FrequentPlaylistSection(');
    final squarePlaylistHeaderIndex = squareLibrarySource.indexOf('FrequentPlaylistSection(');
    final libraryHeaderIndex = standardSource.indexOf('LibraryShortcutSection(');

    expect(source, contains('required this.recentPlaybackController'));
    expect(source, contains('required this.recommendationController'));
    expect(source, contains('required this.userLibraryController'));
    expect(source, contains('required this.playerController'));
    expect(source, contains('required this.shellController'));
    expect(source, isNot(contains('RecommendationController.to')));
    expect(source, isNot(contains('UserLibraryController.to')));
    expect(source, isNot(contains('RecentPlaybackController.to')));
    expect(source, isNot(contains('Get.find<PlayerController>')));
    expect(recentStripIndex, isNonNegative);
    expect(squareRecentStripIndex, isNonNegative);
    expect(recentHeaderIndex, isNonNegative);
    expect(playlistHeaderIndex, isNonNegative);
    expect(squarePlaylistHeaderIndex, isNonNegative);
    expect(libraryHeaderIndex, isNonNegative);
    expect(source, contains('SquarePersonalHomePage('));
    expect(recentStripIndex, lessThan(playlistHeaderIndex));
    expect(squareRecentStripIndex, lessThan(squarePlaylistHeaderIndex));
    expect(playlistHeaderIndex, lessThan(libraryHeaderIndex));
    expect(recentPlaybackSource, contains("playListName: '最近播放'"));
    expect(recentPlaybackSource, contains('const double _recentPlaybackStripHeight = 76;'));
    expect(recentPlaybackSource, contains('const double _recentPlaybackTileWidth = 220;'));
    expect(recentPlaybackSource, contains('const double _recentPlaybackCacheExtent = 360;'));
    expect(recentPlaybackSource, contains('height: _recentPlaybackStripHeight'));
    expect(recentPlaybackSource, contains('width: _recentPlaybackTileWidth'));
    expect(recentPlaybackSource, contains('cacheExtent: _recentPlaybackCacheExtent'));
    expect(recentPlaybackSource, contains('recentPlaybackTileSemanticsLabel('));
    expect(recentPlaybackSource, contains('Semantics('));
    expect(recentPlaybackSource, contains('button: true'));
    expect(recentPlaybackSource, contains('selected: isCurrent'));
    expect(recentPlaybackSource, contains('onTap: () => unawaited(onTap())'));
    expect(recentPlaybackSource, contains('Tooltip('));
    expect(recentPlaybackSource, contains('excludeFromSemantics: true'));
    expect(recentPlaybackSource, contains('ExcludeSemantics('));
    expect(source, contains('standard_personal_home_page.dart'));
    expect(source, contains('square_personal_home_page.dart'));
    expect(source, isNot(contains('frequent_playlist_section.dart')));
    expect(source, isNot(contains('square_library_page.dart')));
    expect(standardSource, contains('frequent_playlist_section.dart'));
    expect(source, isNot(contains('homeFrequentPlaylists')));
    expect(source, isNot(contains('PlaylistRepository')));
    expect(frequentPlaylistSource, contains("'常用歌单'"));
    expect(frequentPlaylistSource, contains('homeFrequentPlaylists'));
    expect(frequentPlaylistSource, contains('onPlayPlaylist:'));
    expect(frequentPlaylistSource, contains('_playPlaylistSummary('));
    expect(frequentPlaylistSource, contains('playbackAction,'));
    expect(frequentPlaylistSource, isNot(contains('Get.find<PlayerController>')));
    expect(squareLibrarySource, contains('RecentPlaybackStrip('));
    expect(squareLibrarySource, contains('FrequentPlaylistSection('));
    expect(squareLibrarySource, contains('LibraryShortcutSection('));
    expect(squareLibrarySource, contains('const double squareLibraryPageScrollCacheExtent = 240;'));
    expect(squareLibrarySource, contains('cacheExtent: squareLibraryPageScrollCacheExtent'));
    expect(squareLibrarySource, isNot(contains('cacheExtent: 120')));
    expect(source, isNot(contains('watchCurrentSong')));
  });

  test('personal page artwork entries use playback artwork resolver', () {
    final source = File('lib/ui/pages/user/personal_page.dart').readAsStringSync();
    final standardSource = File(
      'lib/ui/pages/user/widgets/standard_personal_home_page.dart',
    ).readAsStringSync();
    final quickStartSource = File(
      'lib/ui/pages/user/widgets/quick_start_card_rail.dart',
    ).readAsStringSync();
    final quickStartSectionSource = File(
      'lib/ui/pages/user/widgets/quick_start_section.dart',
    ).readAsStringSync();
    final recentPlaybackSource = File(
      'lib/ui/pages/user/widgets/recent_playback_strip.dart',
    ).readAsStringSync();
    final todayPageSource = File('lib/ui/pages/user/today_page_view.dart').readAsStringSync();

    expect(source, contains('standard_personal_home_page.dart'));
    expect(source, isNot(contains('quick_start_card_rail.dart')));
    expect(standardSource, isNot(contains('quick_start_card_rail.dart')));
    expect(quickStartSectionSource, contains('quick_start_card_rail.dart'));
    expect(source, isNot(contains('String _playbackArtworkPath(PlaybackQueueItem item)')));
    expect(quickStartSource, contains('String _playbackArtworkPath(PlaybackQueueItem item)'));
    expect(quickStartSource, contains('ArtworkPathResolver.resolvePlaybackArtwork'));
    expect(recentPlaybackSource, contains('ArtworkPathResolver.resolvePlaybackArtwork'));
    expect(recentPlaybackSource, contains('SimpleExtendedImage('));
    expect(recentPlaybackSource, matches(RegExp(r'SimpleExtendedImage\(\s*artworkPath,')));
    expect(recentPlaybackSource, isNot(contains('artworkPath.isEmpty')));
    expect(todayPageSource, contains('class TodayPageView extends GetView<RecommendationController>'));
    expect(todayPageSource, contains('final songs = controller.todayRecommendSongs'));
    expect(todayPageSource, contains('todayPlayAllControlLabel('));
    expect(todayPageSource, contains('final canPlayDailyRecommendations = songs.isNotEmpty'));
    expect(todayPageSource, contains('tooltip: playAllLabel'));
    expect(todayPageSource, contains('onPressed: canPlayDailyRecommendations'));
    expect(todayPageSource, isNot(contains('RecommendationController.to')));
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
    final standardSource = File(
      'lib/ui/pages/user/widgets/standard_personal_home_page.dart',
    ).readAsStringSync();
    final squareHomeSource = File(
      'lib/ui/pages/user/widgets/square_personal_home_page.dart',
    ).readAsStringSync();
    final quickStartSource = File(
      'lib/ui/pages/user/widgets/quick_start_card_rail.dart',
    ).readAsStringSync();
    final quickStartSectionSource = File(
      'lib/ui/pages/user/widgets/quick_start_section.dart',
    ).readAsStringSync();

    expect(source, contains('StandardPersonalHomePage('));
    expect(source, contains('SquarePersonalHomePage('));
    expect(source, isNot(contains('QuickStartSection(')));
    expect(source, isNot(contains('SquareQuickStartPage(')));
    expect(standardSource, contains('QuickStartSection('));
    expect(squareHomeSource, contains('SquareQuickStartPage('));
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
    final bulkActionSource = File(
      'lib/ui/pages/download/widgets/local_song_bulk_actions.dart',
    ).readAsStringSync();
    final listWidgetSource = File(
      'lib/ui/pages/download/widgets/local_song_list_widgets.dart',
    ).readAsStringSync();
    final tabBarSource = File(
      'lib/ui/pages/download/widgets/local_song_tab_bar.dart',
    ).readAsStringSync();

    expect(source, contains('static const int tabDownloaded = 2;'));
    expect(source, contains('static const int tabLocalImport = 3;'));
    expect(source, contains('final int initialTabIndex;'));
    expect(source, contains('initialIndex: widget.initialTabIndex'));
    expect(source, contains('local_song_bulk_actions.dart'));
    expect(source, contains('local_song_list_widgets.dart'));
    expect(source, contains('local_song_tab_bar.dart'));
    expect(source, contains('LocalSongBulkActions('));
    expect(source, contains('LocalSongTabView('));
    expect(source, contains('LocalSongTabBar('));
    expect(source, isNot(contains('PopupMenuButton<String>')));
    expect(source, isNot(contains('AlertDialog(')));
    expect(source, isNot(contains('删除所有缓存')));
    expect(source, isNot(contains('LoadStateView<List<LocalSongEntry>>')));
    expect(source, isNot(contains('ValueListenableBuilder<LoadState<List<LocalSongEntry>>>')));
    expect(source, isNot(contains('ListTile(')));
    expect(source, isNot(contains('TablerIcons.trash')));
    expect(source, isNot(contains("Tab(text: '全部")));
    expect(bulkActionSource, contains('class LocalSongBulkActions'));
    expect(bulkActionSource, contains('PopupMenuButton<String>'));
    expect(bulkActionSource, contains('AlertDialog('));
    expect(bulkActionSource, contains('onClearPlaybackCache'));
    expect(bulkActionSource, contains('删除所有缓存'));
    expect(listWidgetSource, contains('class LocalSongTabView'));
    expect(listWidgetSource, contains('LoadStateView<List<LocalSongEntry>>'));
    expect(listWidgetSource, contains('onRetry: controller.loadInitial'));
    expect(listWidgetSource, contains('const double _localSongListCacheExtent = 360;'));
    expect(listWidgetSource, contains('cacheExtent: _localSongListCacheExtent'));
    expect(listWidgetSource, contains('prototypeItem: const Padding('));
    expect(listWidgetSource, contains('child: _LocalSongTile('));
    expect(listWidgetSource, contains('const LocalSongEntry _localSongListPrototypeEntry'));
    expect(listWidgetSource, contains('ListView.builder('));
    expect(listWidgetSource, isNot(contains('ListView.separated(')));
    expect(listWidgetSource, contains('ListTile('));
    expect(listWidgetSource, contains('TablerIcons.trash'));
    expect(listWidgetSource, contains('TrackResourceOrigin.playbackCache'));
    expect(tabBarSource, contains('class LocalSongTabBar'));
    expect(tabBarSource, contains('ValueListenableBuilder<LoadState<List<LocalSongEntry>>>'));
    expect(tabBarSource, contains("Tab(text: '全部 "));
    expect(tabBarSource, contains('TrackResourceOrigin.managedDownload'));
    expect(tabBarSource, contains('TrackResourceOrigin.localImport'));
  });
}
