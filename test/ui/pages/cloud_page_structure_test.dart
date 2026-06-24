import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cloud page keeps paged song list cache bounded', () {
    final source = File('lib/ui/pages/cloud/cloud_drive_view.dart').readAsStringSync();

    expect(source, contains('const double cloudDriveListCacheExtent = 480;'));
    expect(source, contains('ListView.builder('));
    expect(source, contains('cacheExtent: cloudDriveListCacheExtent'));
    expect(source, isNot(contains('shrinkWrap: true')));
  });
}
