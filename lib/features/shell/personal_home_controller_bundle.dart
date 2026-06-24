import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/recent_playback_controller.dart';
import 'package:bujuan/features/user/home_content_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';

/// 首页个人页需要的控制器组合。
class PersonalHomeControllerBundle {
  /// 创建首页个人页控制器组合。
  const PersonalHomeControllerBundle({
    required this.playerController,
    required this.recentPlaybackController,
    required this.homeContentController,
    required this.userLibraryController,
  });

  /// 播放控制器。
  final PlayerController playerController;

  /// 最近播放控制器。
  final RecentPlaybackController recentPlaybackController;

  /// 首页内容控制器。
  final HomeContentController homeContentController;

  /// 用户资料库控制器。
  final UserLibraryController userLibraryController;
}
