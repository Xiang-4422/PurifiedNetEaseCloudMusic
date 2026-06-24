import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('my radio page keeps paged list item extent stable', () {
    final source = File('lib/ui/pages/radio/my_radio_view.dart').readAsStringSync();

    expect(source, contains('const double myRadioListItemExtent = 120;'));
    expect(source, contains('ListView.builder('));
    expect(source, contains('itemExtent: myRadioListItemExtent'));
    expect(source, contains('height: myRadioListItemExtent'));
    expect(source, isNot(contains('shrinkWrap: true')));
  });

  test('radio details page keeps paged program list cache bounded', () {
    final source = File('lib/ui/pages/radio/radio_details_view.dart').readAsStringSync();

    expect(source, contains('const double radioProgramListCacheExtent = 480;'));
    expect(source, contains('ListView.builder('));
    expect(source, contains('cacheExtent: radioProgramListCacheExtent'));
    expect(source, isNot(contains('shrinkWrap: true')));
  });
}
