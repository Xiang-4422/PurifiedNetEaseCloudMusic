import 'package:bujuan/features/download/local_song_list_controller_factory.dart';
import 'package:bujuan/features/settings/cache_analysis_controller.dart';
import 'package:bujuan/features/user/user_profile_controller_factory.dart';

/// 设置、缓存、本地资源和账号工具页需要的控制器工厂组合。
class UtilityPageControllerBundle {
  /// 创建工具页控制器工厂组合。
  const UtilityPageControllerBundle({
    required this.cacheAnalysisControllerFactory,
    required this.localSongListControllerFactory,
    required this.userProfileControllerFactory,
  });

  /// 缓存分析控制器工厂。
  final CacheAnalysisControllerFactory cacheAnalysisControllerFactory;

  /// 本地歌曲列表控制器工厂。
  final LocalSongListControllerFactory localSongListControllerFactory;

  /// 用户资料控制器工厂。
  final UserProfileControllerFactory userProfileControllerFactory;
}
