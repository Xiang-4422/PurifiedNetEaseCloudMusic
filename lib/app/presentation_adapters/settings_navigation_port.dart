import 'package:flutter/widgets.dart';

/// 设置页导航端口，隔离设置 controller 与具体页面 widget。
class SettingsNavigationPort {
  /// 创建设置页导航端口。
  const SettingsNavigationPort({
    required this.openLocalSongs,
    required this.openCoverFlowDemo,
  });

  /// 打开本地歌曲或下载任务页面。
  final void Function(BuildContext context) openLocalSongs;

  /// 打开 CoverFlow 调试演示页面。
  final void Function(BuildContext context) openCoverFlowDemo;
}
