import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('setting page exposes focused player settings sections in order', () {
    final source = File('lib/ui/pages/settings/setting_page.dart').readAsStringSync();
    final accountIndex = source.indexOf("Header('账号')");
    final qualityIndex = source.indexOf("Header('音质')");
    final downloadIndex = source.indexOf("Header('下载')");
    final cacheIndex = source.indexOf("Header('缓存')");
    final appearanceIndex = source.indexOf("Header('外观')");
    final debugIndex = source.indexOf("Header('调试')");
    final accountBuildIndex = source.indexOf('_buildAccountSetting(context)');
    final qualityBuildIndex = source.indexOf('_buildPlaybackSetting(context)');
    final cacheBuildIndex = source.indexOf('_buildCacheSetting(context)');
    final downloadBuildIndex = source.indexOf('_buildDownloadSetting(context)');
    final appearanceBuildIndex = source.indexOf('_buildAppearanceSetting(context)');
    final debugBuildIndex = source.indexOf('_buildDebugSetting(context)');

    expect(accountIndex, isNonNegative);
    expect(qualityIndex, isNonNegative);
    expect(downloadIndex, isNonNegative);
    expect(cacheIndex, isNonNegative);
    expect(appearanceIndex, isNonNegative);
    expect(debugIndex, isNonNegative);
    expect(accountBuildIndex, isNonNegative);
    expect(qualityBuildIndex, isNonNegative);
    expect(cacheBuildIndex, isNonNegative);
    expect(downloadBuildIndex, isNonNegative);
    expect(appearanceBuildIndex, isNonNegative);
    expect(debugBuildIndex, isNonNegative);
    expect(accountBuildIndex, lessThan(qualityBuildIndex));
    expect(qualityBuildIndex, lessThan(cacheBuildIndex));
    expect(cacheBuildIndex, lessThan(downloadBuildIndex));
    expect(downloadBuildIndex, lessThan(appearanceBuildIndex));
    expect(appearanceBuildIndex, lessThan(debugBuildIndex));
    expect(source, isNot(contains("Header('UI设置')")));
    expect(source, isNot(contains("Header('App设置')")));
  });

  test('setting page keeps account quality cache download appearance and debug entries', () {
    final source = File('lib/ui/pages/settings/setting_page.dart').readAsStringSync();

    expect(source, contains('Routes.userProfile'));
    expect(source, contains("title: '账号资料'"));
    expect(source, contains("title: '高音质优先'"));
    expect(source, contains("title: '本地歌曲与下载'"));
    expect(source, contains("title: '扫描本地音乐'"));
    expect(source, contains("title: '缓存分析'"));
    expect(source, contains("title: '渐变播放背景'"));
    expect(source, contains("title: '圆形专辑'"));
    expect(source, contains("title: 'Lottie 动画预览'"));
    expect(source, contains("title: 'CoverFlow Demo'"));
  });

  test('setting page uses icons for all visible settings entries', () {
    final source = File('lib/ui/pages/settings/setting_page.dart').readAsStringSync();
    final toggleCallCount = RegExp(r'_buildToggleTile\(').allMatches(source).length - 1;
    final navigationCallCount = RegExp(r'_buildNavigationTile\(').allMatches(source).length - 1;
    final iconArgumentCount = RegExp(r'icon: TablerIcons\.').allMatches(source).length;

    expect(toggleCallCount, 3);
    expect(navigationCallCount, 6);
    expect(iconArgumentCount, greaterThanOrEqualTo(toggleCallCount + navigationCallCount));
  });
}
