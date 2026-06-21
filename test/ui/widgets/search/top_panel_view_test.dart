import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('top panel delegates search chrome and result items to local widgets', () {
    final panelSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_view.dart',
    ).readAsStringSync();
    final chromeSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_chrome_widgets.dart',
    ).readAsStringSync();
    final widgetsSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_search_widgets.dart',
    ).readAsStringSync();

    expect(panelSource, contains('TopPanelBackgroundLayer('));
    expect(panelSource, contains('TopPanelBottomControls('));
    expect(panelSource, contains('TopPanelKeyboardSpacer('));
    expect(panelSource, contains('TopPanelCard('));
    expect(panelSource, isNot(contains('BlurryContainer(')));
    expect(panelSource, isNot(contains('MyTabBar(')));
    expect(panelSource, isNot(contains('_buildSearchBar')));
    expect(panelSource, isNot(contains('_buildTopPanelCard')));
    expect(panelSource, isNot(contains('class _PlaylistSearchItem')));
    expect(panelSource, isNot(contains('class _AlbumSearchItem')));
    expect(panelSource, isNot(contains('class _ArtistSearchItem')));

    expect(widgetsSource, contains('class TopPanelSearchBar'));
    expect(widgetsSource, contains("hintText: '输入歌曲、歌手、歌单...'"));
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
  });

  test('top panel delegates search result states to local widgets', () {
    final panelSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_view.dart',
    ).readAsStringSync();
    final resultsSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_search_results.dart',
    ).readAsStringSync();

    expect(panelSource, contains('TopPanelHotKeywordList('));
    expect(panelSource, contains('TopPanelSongSearchResult('));
    expect(panelSource, contains('TopPanelPlaylistSearchResult('));
    expect(panelSource, contains('TopPanelAlbumSearchResult('));
    expect(panelSource, contains('TopPanelArtistSearchResult('));
    expect(panelSource, isNot(contains('_buildHotKeywordList')));
    expect(panelSource, isNot(contains('_buildSongSearchResult')));
    expect(panelSource, isNot(contains('_buildPlaylistSearchResult')));
    expect(panelSource, isNot(contains('_buildAlbumSearchResult')));
    expect(panelSource, isNot(contains('_buildArtistSearchResult')));
    expect(panelSource, isNot(contains('ValueListenableBuilder')));
    expect(panelSource, isNot(contains('LoadStateView')));

    expect(resultsSource, contains('class TopPanelHotKeywordList'));
    expect(resultsSource, contains('class TopPanelSongSearchResult'));
    expect(resultsSource, contains('class TopPanelPlaylistSearchResult'));
    expect(resultsSource, contains('class TopPanelAlbumSearchResult'));
    expect(resultsSource, contains('class TopPanelArtistSearchResult'));
    expect(resultsSource, contains('ValueListenableBuilder'));
    expect(resultsSource, contains('LoadStateView'));
    expect(resultsSource, contains('PlaylistSearchItem('));
    expect(resultsSource, contains('AlbumSearchItem('));
    expect(resultsSource, contains('ArtistSearchItem('));
  });
}
