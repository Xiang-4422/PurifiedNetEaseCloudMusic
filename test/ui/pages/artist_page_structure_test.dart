import 'dart:io';

import 'package:bujuan/ui/pages/artist/artist_page_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
