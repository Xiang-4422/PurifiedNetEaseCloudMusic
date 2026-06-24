import 'package:bujuan/features/comment/comment_controller_factory.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/search/search_panel_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/home_shell_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';

/// 首页壳层需要的控制器组合。
class AppHomeControllerBundle {
  /// 创建首页壳层控制器组合。
  const AppHomeControllerBundle({
    required this.commentControllerFactory,
    required this.homeShellController,
    required this.playerController,
    required this.searchController,
    required this.settingsController,
    required this.shellController,
  });

  /// 评论控制器工厂。
  final CommentControllerFactory commentControllerFactory;

  /// 首页分页壳层控制器。
  final HomeShellController homeShellController;

  /// 播放控制器。
  final PlayerController playerController;

  /// 搜索面板控制器。
  final SearchPanelController searchController;

  /// 设置控制器。
  final SettingsController settingsController;

  /// 应用壳层协调器。
  final ShellController shellController;
}
