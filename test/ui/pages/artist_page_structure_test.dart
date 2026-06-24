import 'dart:io';

import 'package:bujuan/ui/pages/album/album_page_view.dart';
import 'package:bujuan/ui/pages/artist/artist_page_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('album and artist detail play buttons expose stable states', () {
    expect(
      albumPlayButtonTooltip(title: '  专辑 ', songCount: 3),
      '播放专辑：专辑',
    );
    expect(
      albumPlayButtonTooltip(title: ' ', songCount: 1),
      '播放专辑：当前专辑',
    );
    expect(
      albumPlayButtonTooltip(title: '专辑', songCount: 0),
      '专辑暂无歌曲',
    );
    expect(
      artistPlayButtonTooltip(name: '  歌手 ', songCount: 3),
      '播放歌手热门歌曲：歌手',
    );
    expect(
      artistPlayButtonTooltip(name: ' ', songCount: 1),
      '播放歌手热门歌曲：当前歌手',
    );
    expect(
      artistPlayButtonTooltip(name: '歌手', songCount: 0),
      '歌手暂无歌曲',
    );

    final albumSource = File(
      'lib/ui/pages/album/album_page_view.dart',
    ).readAsStringSync();
    final artistSource = File(
      'lib/ui/pages/artist/artist_page_view.dart',
    ).readAsStringSync();

    expect(albumSource, contains('final canPlayAlbum = albumSongs.isNotEmpty;'));
    expect(albumSource, contains('tooltip: playTooltip'));
    expect(albumSource, contains('disabledColor:'));
    expect(albumSource, contains(': null'));
    expect(artistSource, contains('final canPlayArtist = topSongs.isNotEmpty;'));
    expect(artistSource, contains('tooltip: playTooltip'));
    expect(artistSource, contains('disabledColor:'));
    expect(artistSource, contains(': null'));
  });

  test('artist hot album rail exposes stable tile labels', () {
    expect(artistHotAlbumYearLabel(null), '未知年份');
    expect(artistHotAlbumYearLabel(0), '未知年份');
    expect(
      artistHotAlbumYearLabel(DateTime(2024).millisecondsSinceEpoch),
      '2024',
    );
    expect(
      artistHotAlbumTileSemanticsLabel(
        title: '  专辑 ',
        publishTime: DateTime(2024).millisecondsSinceEpoch,
      ),
      '打开专辑：专辑 - 2024',
    );
    expect(
      artistHotAlbumTileSemanticsLabel(
        title: ' ',
        publishTime: null,
      ),
      '打开专辑：未知专辑 - 未知年份',
    );
  });

  test('artist page keeps hot album rail cache bounded', () {
    final source = File(
      'lib/ui/pages/artist/artist_page_view.dart',
    ).readAsStringSync();

    expect(source, contains('const double artistHotAlbumCacheExtent = 360;'));
    expect(source, contains('artistHotAlbumTileSemanticsLabel('));
    expect(source, contains('artistHotAlbumYearLabel('));
    expect(source, contains('Tooltip('));
    expect(source, contains('Semantics('));
    expect(source, contains('button: true'));
    expect(source, contains('ExcludeSemantics('));
    expect(source, contains('behavior: HitTestBehavior.opaque'));
    expect(source, contains('ListView.builder('));
    expect(source, contains('cacheExtent: artistHotAlbumCacheExtent'));
    expect(
      source,
      contains(
        'SnappingScrollPhysics(itemExtent: albumWidth + AppDimensions.paddingMedium)',
      ),
    );
    expect(source, isNot(contains('shrinkWrap: true')));
  });

  test('album and artist song lists keep stable prototype extents', () {
    final albumSource = File(
      'lib/ui/pages/album/album_page_view.dart',
    ).readAsStringSync();
    final artistSource = File(
      'lib/ui/pages/artist/artist_page_view.dart',
    ).readAsStringSync();

    for (final source in [albumSource, artistSource]) {
      expect(source, contains('SliverPrototypeExtentList('));
      expect(source, contains('prototypeItem: SongItem('));
      expect(source, contains('addAutomaticKeepAlives: false'));
      expect(source, contains('height: AppDimensions.bottomPanelHeaderHeight'));
    }
  });
}
