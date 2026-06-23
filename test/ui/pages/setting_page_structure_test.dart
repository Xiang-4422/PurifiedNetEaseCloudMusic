import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('setting page exposes focused player settings sections in order', () {
    final source = File('lib/ui/pages/settings/setting_page.dart').readAsStringSync();
    final sectionsSource = File(
      'lib/ui/pages/settings/widgets/settings_sections.dart',
    ).readAsStringSync();
    final accountIndex = sectionsSource.indexOf("title: '账号',");
    final qualityIndex = sectionsSource.indexOf("title: '音质',");
    final downloadIndex = sectionsSource.indexOf("title: '下载',");
    final cacheIndex = sectionsSource.indexOf("title: '缓存',");
    final appearanceIndex = sectionsSource.indexOf("title: '外观',");
    final debugIndex = sectionsSource.indexOf("title: '调试',");

    expect(accountIndex, isNonNegative);
    expect(qualityIndex, isNonNegative);
    expect(downloadIndex, isNonNegative);
    expect(cacheIndex, isNonNegative);
    expect(appearanceIndex, isNonNegative);
    expect(debugIndex, isNonNegative);
    expect(accountIndex, lessThan(qualityIndex));
    expect(qualityIndex, lessThan(cacheIndex));
    expect(cacheIndex, lessThan(downloadIndex));
    expect(downloadIndex, lessThan(appearanceIndex));
    expect(appearanceIndex, lessThan(debugIndex));
    expect(source, contains('SettingsSectionsList('));
    expect(source, contains('settings_sections.dart'));
    expect(source, isNot(contains("title: '账号',")));
    expect(source, isNot(contains("Header('UI设置')")));
    expect(source, isNot(contains("Header('App设置')")));
  });

  test('setting page keeps account quality cache download appearance and debug entries', () {
    final source = File('lib/ui/pages/settings/setting_page.dart').readAsStringSync();
    final sectionsSource = File(
      'lib/ui/pages/settings/widgets/settings_sections.dart',
    ).readAsStringSync();

    expect(source, contains('SettingsSectionsList('));
    expect(sectionsSource, contains('Routes.userProfile'));
    expect(sectionsSource, contains("title: '账号资料'"));
    expect(sectionsSource, contains("title: '高音质优先'"));
    expect(sectionsSource, contains("title: '本地歌曲与下载'"));
    expect(sectionsSource, contains("title: '扫描本地音乐'"));
    expect(sectionsSource, contains("title: '缓存分析'"));
    expect(sectionsSource, contains("title: '渐变播放背景'"));
    expect(sectionsSource, contains("title: '圆形专辑'"));
    expect(sectionsSource, contains("title: 'Lottie 动画预览'"));
    expect(sectionsSource, contains("title: 'CoverFlow Demo'"));
  });

  test('setting page uses icons for all visible settings entries', () {
    final sectionsSource = File(
      'lib/ui/pages/settings/widgets/settings_sections.dart',
    ).readAsStringSync();
    final toggleCallCount = RegExp(r'SettingToggleTile\(').allMatches(sectionsSource).length;
    final navigationCallCount = RegExp(r'SettingNavigationTile\(').allMatches(sectionsSource).length;
    final iconArgumentCount = RegExp(r'icon: TablerIcons\.').allMatches(sectionsSource).length;

    expect(toggleCallCount, 3);
    expect(navigationCallCount, 6);
    expect(iconArgumentCount, greaterThanOrEqualTo(toggleCallCount + navigationCallCount));
  });

  test('setting page delegates section and tile chrome to local widgets', () {
    final source = File('lib/ui/pages/settings/setting_page.dart').readAsStringSync();
    final sectionsSource = File(
      'lib/ui/pages/settings/widgets/settings_sections.dart',
    ).readAsStringSync();
    final widgetsSource = File(
      'lib/ui/pages/settings/widgets/setting_section_widgets.dart',
    ).readAsStringSync();

    expect(source, contains('SettingsSectionsList('));
    expect(source, isNot(contains('SettingSection(')));
    expect(source, isNot(contains('SettingNavigationTile(')));
    expect(source, isNot(contains('SettingToggleTile(')));
    expect(sectionsSource, contains('SettingSection('));
    expect(sectionsSource, contains('SettingNavigationTile('));
    expect(sectionsSource, contains('SettingToggleTile('));
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
    expect(source, contains('SettingsSectionsList('));
    expect(source, contains('onScanLocalMedia: _scanLocalMedia'));
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
