import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('artist page keeps hot album rail cache bounded', () {
    final source = File(
      'lib/ui/pages/artist/artist_page_view.dart',
    ).readAsStringSync();

    expect(source, contains('const double artistHotAlbumCacheExtent = 360;'));
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
