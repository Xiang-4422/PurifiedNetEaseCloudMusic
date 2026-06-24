import 'dart:io';

import 'package:bujuan/ui/pages/radio/my_radio_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('my radio page exposes stable item semantics labels', () {
    expect(
      myRadioTileSemanticsLabel(
        name: '  电台 ',
        lastProgramName: ' 最新节目 ',
      ),
      '打开播客：电台 - 最新节目',
    );
    expect(
      myRadioTileSemanticsLabel(
        name: ' ',
        lastProgramName: ' ',
      ),
      '打开播客：未知播客 - 暂无节目',
    );
  });

  test('my radio page keeps paged list item extent stable', () {
    final source = File('lib/ui/pages/radio/my_radio_view.dart').readAsStringSync();

    expect(source, contains('const double myRadioListItemExtent = 120;'));
    expect(source, contains('myRadioTileSemanticsLabel('));
    expect(source, contains('Tooltip('));
    expect(source, contains('Semantics('));
    expect(source, contains('button: true'));
    expect(source, contains('ExcludeSemantics('));
    expect(source, contains('ListView.builder('));
    expect(source, contains('itemExtent: myRadioListItemExtent'));
    expect(source, contains('height: myRadioListItemExtent'));
    expect(source, contains('ErrorView('));
    expect(source, contains('onRetry: () => unawaited(_controller.loadInitial())'));
    expect(source, isNot(contains('return const ErrorView();')));
    expect(source, isNot(contains('shrinkWrap: true')));
  });

  test('radio details page keeps paged program list cache bounded', () {
    final source = File('lib/ui/pages/radio/radio_details_view.dart').readAsStringSync();

    expect(source, contains('const double radioProgramListCacheExtent = 480;'));
    expect(source, contains('ListView.builder('));
    expect(source, contains('cacheExtent: radioProgramListCacheExtent'));
    expect(source, contains('ErrorView('));
    expect(source, contains('onRetry: () => unawaited(_controller.loadInitial())'));
    expect(source, isNot(contains('return const ErrorView();')));
    expect(source, isNot(contains('shrinkWrap: true')));
  });
}
