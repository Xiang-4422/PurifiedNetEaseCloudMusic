import 'dart:io';

import 'package:bujuan/ui/pages/shell/widgets/search/top_panel_search_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('top panel search action labels stay stable', () {
    expect(topPanelSearchActionLabel(hasKeyword: true), '清空搜索');
    expect(topPanelSearchActionLabel(hasKeyword: false), '关闭搜索');
  });

  test('top panel delegates search chrome and result items to local widgets', () {
    final panelSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_view.dart',
    ).readAsStringSync();
    final homeSource = File(
      'lib/ui/pages/shell/app_home_page_view.dart',
    ).readAsStringSync();
    final chromeSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_chrome_widgets.dart',
    ).readAsStringSync();
    final contentSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_content_widgets.dart',
    ).readAsStringSync();
    final widgetsSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_search_widgets.dart',
    ).readAsStringSync();

    expect(panelSource, contains('TopPanelBackgroundLayer('));
    expect(panelSource, contains('TopPanelContentArea('));
    expect(panelSource, contains('TopPanelBottomControls('));
    expect(panelSource, contains('TopPanelKeyboardSpacer('));
    expect(panelSource, contains('required this.shellController'));
    expect(panelSource, contains('required this.searchController'));
    expect(panelSource, contains('required this.playerController'));
    expect(panelSource, isNot(contains('ShellController.to')));
    expect(panelSource, isNot(contains('Get.find<SearchPanelController>')));
    expect(panelSource, isNot(contains('Get.find<PlayerController>')));
    expect(homeSource, contains('final appHomeControllers = Get.find<AppHomeControllerBundle>()'));
    expect(homeSource, contains('final searchController = appHomeControllers.searchController'));
    expect(homeSource, contains('final playerController = appHomeControllers.playerController'));
    expect(homeSource, isNot(contains('Get.find<SearchPanelController>')));
    expect(homeSource, isNot(contains('Get.find<PlayerController>')));
    expect(homeSource, contains('TopPanelView('));
    expect(homeSource, contains('shellController: controller'));
    expect(homeSource, contains('searchController: searchController'));
    expect(homeSource, contains('playerController: playerController'));
    expect(panelSource, isNot(contains('TopPanelCard(')));
    expect(panelSource, isNot(contains('TabBarView(')));
    expect(panelSource, isNot(contains('BlurryContainer(')));
    expect(panelSource, isNot(contains('MyTabBar(')));
    expect(panelSource, isNot(contains('_buildSearchBar')));
    expect(panelSource, isNot(contains('_buildTopPanelCard')));
    expect(panelSource, isNot(contains('class _PlaylistSearchItem')));
    expect(panelSource, isNot(contains('class _AlbumSearchItem')));
    expect(panelSource, isNot(contains('class _ArtistSearchItem')));

    expect(widgetsSource, contains('class TopPanelSearchBar'));
    expect(widgetsSource, contains("hintText: '输入歌曲、歌手、歌单...'"));
    expect(widgetsSource, contains('topPanelSearchActionLabel(hasKeyword: false)'));
    expect(widgetsSource, contains('topPanelSearchActionLabel(hasKeyword: true)'));
    expect(widgetsSource, contains("return hasKeyword ? '清空搜索' : '关闭搜索';"));
    expect(widgetsSource, contains('SizedBox.square('));
    expect(widgetsSource, isNot(contains('onPressed: () {},')));
    expect(widgetsSource, contains('class PlaylistSearchItem'));
    expect(widgetsSource, contains('class AlbumSearchItem'));
    expect(widgetsSource, contains('class ArtistSearchItem'));

    expect(chromeSource, contains('class TopPanelBackgroundLayer'));
    expect(chromeSource, contains('class TopPanelBottomControls'));
    expect(chromeSource, contains('class TopPanelKeyboardSpacer'));
    expect(chromeSource, contains('BlurryContainer('));
    expect(chromeSource, contains('MyTabBar('));
    expect(chromeSource, contains('TopPanelSearchBar('));
    expect(chromeSource, contains("'单曲'"));
    expect(chromeSource, contains("'歌手'"));

    expect(contentSource, contains('class TopPanelContentArea'));
    expect(contentSource, contains('TabBarView('));
    expect(contentSource, contains('TopPanelCard('));
  });

  test('top panel delegates search result states to local widgets', () {
    final panelSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_view.dart',
    ).readAsStringSync();
    final resultsSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_search_results.dart',
    ).readAsStringSync();

    final contentSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_content_widgets.dart',
    ).readAsStringSync();

    expect(panelSource, isNot(contains('TopPanelHotKeywordList(')));
    expect(panelSource, isNot(contains('TopPanelSongSearchResult(')));
    expect(panelSource, isNot(contains('TopPanelPlaylistSearchResult(')));
    expect(panelSource, isNot(contains('TopPanelAlbumSearchResult(')));
    expect(panelSource, isNot(contains('TopPanelArtistSearchResult(')));
    expect(panelSource, isNot(contains('_buildHotKeywordList')));
    expect(panelSource, isNot(contains('_buildSongSearchResult')));
    expect(panelSource, isNot(contains('_buildPlaylistSearchResult')));
    expect(panelSource, isNot(contains('_buildAlbumSearchResult')));
    expect(panelSource, isNot(contains('_buildArtistSearchResult')));
    expect(panelSource, isNot(contains('ValueListenableBuilder')));
    expect(panelSource, isNot(contains('LoadStateView')));

    expect(contentSource, contains('TopPanelHotKeywordList('));
    expect(contentSource, contains('TopPanelSongSearchResult('));
    expect(contentSource, contains('TopPanelPlaylistSearchResult('));
    expect(contentSource, contains('TopPanelAlbumSearchResult('));
    expect(contentSource, contains('TopPanelArtistSearchResult('));

    expect(resultsSource, contains('class TopPanelHotKeywordList'));
    expect(resultsSource, contains('class TopPanelSongSearchResult'));
    expect(resultsSource, contains('class TopPanelPlaylistSearchResult'));
    expect(resultsSource, contains('class TopPanelAlbumSearchResult'));
    expect(resultsSource, contains('class TopPanelArtistSearchResult'));
    expect(resultsSource, contains('ValueListenableBuilder'));
    expect(resultsSource, contains('LoadStateView'));
    expect(resultsSource, contains('onRetry: () => searchController.loadInitial(force: true)'));
    expect(
      'onRetry: searchController.retryCurrentSearch'.allMatches(resultsSource),
      hasLength(4),
    );
    expect(resultsSource, contains('PlaylistSearchItem('));
    expect(resultsSource, contains('AlbumSearchItem('));
    expect(resultsSource, contains('ArtistSearchItem('));
  });

  test('top panel search lists stay builder based with bounded cache extent', () {
    final resultsSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_search_results.dart',
    ).readAsStringSync();

    expect(resultsSource, contains('const double _topPanelSearchCacheExtent = 320;'));
    expect(resultsSource, contains('itemCount: keywords.length'));
    expect(resultsSource, contains('final keyword = keywords[index];'));
    expect(resultsSource, isNot(contains('children: keywords')));
    expect(resultsSource, isNot(contains('.toList()')));
    expect(
      'cacheExtent: _topPanelSearchCacheExtent'.allMatches(resultsSource),
      hasLength(5),
    );
  });

  test('top panel cancels stale search requests across widget lifecycle', () {
    final panelSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_view.dart',
    ).readAsStringSync();

    expect(panelSource, contains('void _searchCurrentKeyword(String keyword)'));
    expect(panelSource, contains('debounce<String>('));
    expect(panelSource, contains('_searchCurrentKeyword,'));
    expect(panelSource, contains('widget.shellController.searchContent.value.trim().isNotEmpty'));
    expect(panelSource, contains('_searchCurrentKeyword(widget.shellController.searchContent.value)'));
    expect(panelSource, contains('widget.searchController.cancelPendingRequests();'));
    expect(panelSource, isNot(contains('widget.searchController.dispose();')));
  });
}
