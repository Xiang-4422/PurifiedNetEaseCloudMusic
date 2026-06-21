import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('top panel delegates search chrome and result items to local widgets', () {
    final panelSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_view.dart',
    ).readAsStringSync();
    final widgetsSource = File(
      'lib/ui/pages/shell/widgets/search/top_panel_search_widgets.dart',
    ).readAsStringSync();

    expect(panelSource, contains('TopPanelSearchBar('));
    expect(panelSource, contains('TopPanelCard('));
    expect(panelSource, contains('PlaylistSearchItem('));
    expect(panelSource, contains('AlbumSearchItem('));
    expect(panelSource, contains('ArtistSearchItem('));
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
  });
}
