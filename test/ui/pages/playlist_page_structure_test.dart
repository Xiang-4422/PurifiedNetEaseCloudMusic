import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('playlist page delegates header and status presentation to local widgets', () {
    final source = File('lib/ui/pages/playlist/playlist_page_view.dart').readAsStringSync();

    expect(source, contains('PlaylistHeaderSliver('));
    expect(source, contains('PlaylistSkeletonSliver('));
    expect(source, contains('PlaylistStatusFooterSliver('));
    expect(source, isNot(contains('SliverAppBar(')));
    expect(source, isNot(contains('class _PlaylistActionButtonSurface')));
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
}
