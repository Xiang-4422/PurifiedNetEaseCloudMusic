import 'dart:io';

import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeShellController layout menus', () {
    test('uses focused normal three-page menu by default', () {
      final controller = HomeShellController();

      expect(controller.homePageCount, 3);
      expect(
        controller.leftMenus.map((menu) => menu.kind),
        [
          HomeShellPageKind.personal,
          HomeShellPageKind.explore,
          HomeShellPageKind.settings,
        ],
      );
      expect(controller.leftMenus.map((menu) => menu.title), [
        '我的音乐',
        '探索',
        '设置',
      ]);
      expect(controller.isExplorePageIndex(1), isTrue);
    });

    test('adds recommended playlists before explore on square screens', () {
      final controller = HomeShellController();

      controller.updateHomeLayoutMode(isSquareLike: true);

      expect(controller.homePageCount, 4);
      expect(
        controller.leftMenus.map((menu) => menu.kind),
        [
          HomeShellPageKind.personal,
          HomeShellPageKind.recommendedPlaylists,
          HomeShellPageKind.explore,
          HomeShellPageKind.settings,
        ],
      );
      expect(controller.leftMenus.map((menu) => menu.title), [
        '我的音乐',
        '推荐',
        '探索',
        '设置',
      ]);
      expect(controller.isExplorePageIndex(1), isFalse);
      expect(controller.isExplorePageIndex(2), isTrue);
    });

    test('resets page index if a layout change removes the current page', () {
      final controller = HomeShellController();
      controller.updateHomeLayoutMode(isSquareLike: true);
      controller.curHomePageIndex.value = 3;

      controller.updateHomeLayoutMode(isSquareLike: false);

      expect(controller.homePageCount, 3);
      expect(controller.curHomePageIndex.value, 0);
    });

    test('calculates stable page switch animation durations', () {
      expect(
        homePageSwitchAnimationDuration(
          currentPage: 0,
          targetIndex: 0,
        ),
        Duration.zero,
      );
      expect(
        homePageSwitchAnimationDuration(
          currentPage: 0.3,
          targetIndex: 1,
        ),
        const Duration(milliseconds: 200),
      );
      expect(
        homePageSwitchAnimationDuration(
          currentPage: 0.7,
          targetIndex: 2,
        ),
        const Duration(milliseconds: 400),
      );
      expect(
        homePageSwitchAnimationDuration(
          currentPage: double.nan,
          targetIndex: 1,
        ),
        Duration.zero,
      );
    });

    test('routes back navigation homepage switch through the shared boundary', () {
      final source = File('lib/features/shell/home_shell_controller.dart').readAsStringSync();
      final handleStart = source.indexOf('bool handleWillPop(');
      final keyboardStart = source.indexOf('void updateKeyboardHeight', handleStart);
      final handleSource = source.substring(handleStart, keyboardStart);

      expect(handleSource, contains('switchHomePage(0)'));
      expect(handleSource, isNot(contains('homePageController.animateToPage(')));
      expect(handleSource, isNot(contains('homePageController.page != 0')));
    });
  });
}
