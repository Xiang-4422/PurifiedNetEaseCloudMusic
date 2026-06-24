import 'dart:io';

import 'package:bujuan/ui/pages/explore/widgets/explore_filter_strip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('explore filter chips expose stable semantics labels', () {
    expect(
      exploreFilterChipSemanticsLabel(
        label: '  华语 ',
        selected: false,
        semanticAction: '选择歌单标签',
      ),
      '选择歌单标签：华语',
    );
    expect(
      exploreFilterChipSemanticsLabel(
        label: '排行榜',
        selected: true,
        semanticAction: '选择榜单',
      ),
      '选择榜单：排行榜，已选中',
    );
    expect(
      exploreFilterChipSemanticsLabel(
        label: ' ',
        selected: true,
        semanticAction: ' ',
      ),
      '选择筛选项：未命名筛选项，已选中',
    );
  });

  test('explore page delegates filter strips and ranking list to local widgets', () {
    final source = File('lib/ui/pages/explore/explore_page.dart').readAsStringSync();

    expect(source, contains('ExploreFilterStrip<String>('));
    expect(source, contains('ExploreRankingSongListSliver('));
    expect(source, contains('final allTagSelected = controller.curTag.value == "全部";'));
    expect(source, contains('exploreFilterChipSemanticsLabel('));
    expect(source, contains("semanticAction: '选择歌单分类'"));
    expect(source, contains("semanticAction: '选择歌单标签'"));
    expect(source, contains("semanticAction: '选择榜单分类'"));
    expect(source, contains("semanticAction: '选择榜单'"));
    expect(source, contains('Tooltip('));
    expect(source, contains('Semantics('));
    expect(source, contains('selected: allTagSelected'));
    expect(source, contains('ExcludeSemantics('));
    expect(source, contains('final playerController = Get.find<PlayerController>()'));
    expect(source, contains('PlayerController playerController'));
    expect(source, contains('_playPlaylistSummary('));
    expect(source, contains('playerController,'));
    expect(source, isNot(contains('final playbackAction = Get.find<PlayerController>()')));
    expect(source, isNot(contains('SongItem(')));
    expect(source, isNot(contains('SliverChildBuilderDelegate(')));
    expect(source, isNot(contains('AutoSizeSliverPersistentHeader')));
    expect(source, isNot(contains('showChoosePlayList')));
  });

  test('explore filter strip owns horizontal chip presentation', () {
    final source = File(
      'lib/ui/pages/explore/widgets/explore_filter_strip.dart',
    ).readAsStringSync();

    expect(source, contains('class ExploreFilterStrip<T>'));
    expect(source, contains('const double exploreFilterStripCacheExtent = 360;'));
    expect(source, contains('ListView.builder('));
    expect(source, contains('cacheExtent: exploreFilterStripCacheExtent'));
    expect(source, contains('isSelected(item)'));
    expect(source, contains('onSelected(item)'));
    expect(source, contains('semanticAction'));
    expect(source, contains('exploreFilterChipSemanticsLabel('));
    expect(source, contains('Tooltip('));
    expect(source, contains('Semantics('));
    expect(source, contains('selected: selected'));
    expect(source, contains('ExcludeSemantics('));
    expect(source, contains('behavior: HitTestBehavior.opaque'));
    expect(source, contains('BorderRadius.circular(9999)'));
  });

  test('explore ranking song list owns SongItem rows', () {
    final source = File(
      'lib/ui/pages/explore/widgets/explore_ranking_song_list_sliver.dart',
    ).readAsStringSync();

    expect(source, contains('class ExploreRankingSongListSliver'));
    expect(source, contains('SliverPrototypeExtentList('));
    expect(source, contains('prototypeItem: SongItem('));
    expect(source, contains('SliverChildBuilderDelegate('));
    expect(source, contains('SongItem('));
    expect(source, contains('showIndex: true'));
    expect(source, contains('addAutomaticKeepAlives: false'));
    expect(source, isNot(contains('return SliverList(')));
  });
}
