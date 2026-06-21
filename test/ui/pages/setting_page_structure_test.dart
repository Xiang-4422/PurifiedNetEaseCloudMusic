import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('setting page exposes focused player settings sections in order', () {
    final source = File('lib/ui/pages/settings/setting_page.dart').readAsStringSync();
    final accountIndex = source.indexOf("title: '账号',");
    final qualityIndex = source.indexOf("title: '音质',");
    final downloadIndex = source.indexOf("title: '下载',");
    final cacheIndex = source.indexOf("title: '缓存',");
    final appearanceIndex = source.indexOf("title: '外观',");
    final debugIndex = source.indexOf("title: '调试',");
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
    final toggleCallCount = RegExp(r'SettingToggleTile\(').allMatches(source).length;
    final navigationCallCount = RegExp(r'SettingNavigationTile\(').allMatches(source).length;
    final iconArgumentCount = RegExp(r'icon: TablerIcons\.').allMatches(source).length;

    expect(toggleCallCount, 3);
    expect(navigationCallCount, 6);
    expect(iconArgumentCount, greaterThanOrEqualTo(toggleCallCount + navigationCallCount));
  });

  test('setting page delegates section and tile chrome to local widgets', () {
    final source = File('lib/ui/pages/settings/setting_page.dart').readAsStringSync();
    final widgetsSource = File(
      'lib/ui/pages/settings/widgets/setting_section_widgets.dart',
    ).readAsStringSync();

    expect(source, contains('SettingSection('));
    expect(source, contains('SettingNavigationTile('));
    expect(source, contains('SettingToggleTile('));
    expect(source, isNot(contains('_buildNavigationTile')));
    expect(source, isNot(contains('_buildToggleTile')));
    expect(source, isNot(contains("Header('账号')")));

    expect(widgetsSource, contains('class SettingSection'));
    expect(widgetsSource, contains('class SettingNavigationTile'));
    expect(widgetsSource, contains('class SettingToggleTile'));
    expect(widgetsSource, contains('AdaptiveLayoutMetrics.of(context)'));
    expect(widgetsSource, contains('TablerIcons.chevron_right'));
  });

  test('setting page delegates local media scan side effects to controller', () {
    final source = File('lib/ui/pages/settings/setting_page.dart').readAsStringSync();
    final controllerSource = File(
      'lib/features/local_media/local_media_scan_controller.dart',
    ).readAsStringSync();
    final bootstrapSource = File(
      'lib/app/bootstrap/feature_bootstrap.dart',
    ).readAsStringSync();

    expect(source, contains('Get.find<LocalMediaScanController>()'));
    expect(source, contains('prepareDefaultDirectoryImport()'));
    expect(source, isNot(contains('LocalMediaScanRepository(')));
    expect(source, isNot(contains("import 'dart:io'")));
    expect(source, isNot(contains('getDownloadsDirectory()')));
    expect(source, isNot(contains('Permission.')));
    expect(source, isNot(contains('openAppSettings()')));

    expect(controllerSource, contains('class LocalMediaDefaultScanPreparation'));
    expect(controllerSource, contains('getDownloadsDirectory()'));
    expect(controllerSource, contains('openAppSettings()'));

    expect(bootstrapSource, contains('Get.put<LocalMediaScanRepository>'));
    expect(bootstrapSource, contains('Get.put<LocalMediaScanController>'));
  });
}
