import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('explore page delegates filter strips and ranking list to local widgets', () {
    final source = File('lib/ui/pages/explore/explore_page.dart').readAsStringSync();

    expect(source, contains('ExploreFilterStrip<String>('));
    expect(source, contains('ExploreRankingSongListSliver('));
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
    expect(source, contains('ListView.builder('));
    expect(source, contains('isSelected(item)'));
    expect(source, contains('onSelected(item)'));
    expect(source, contains('BorderRadius.circular(9999)'));
  });

  test('explore ranking song list owns SongItem rows', () {
    final source = File(
      'lib/ui/pages/explore/widgets/explore_ranking_song_list_sliver.dart',
    ).readAsStringSync();

    expect(source, contains('class ExploreRankingSongListSliver'));
    expect(source, contains('SliverChildBuilderDelegate('));
    expect(source, contains('SongItem('));
    expect(source, contains('showIndex: true'));
    expect(source, contains('addAutomaticKeepAlives: false'));
  });
}
