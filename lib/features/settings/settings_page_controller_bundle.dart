import 'package:bujuan/features/local_media/local_media_scan_controller.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';

/// 设置页需要的控制器组合。
class SettingsPageControllerBundle {
  /// 创建设置页控制器组合。
  const SettingsPageControllerBundle({
    required this.localMediaScanController,
    required this.playerController,
    required this.settingsController,
  });

  /// 本地音乐扫描控制器。
  final LocalMediaScanController localMediaScanController;

  /// 播放控制器。
  final PlayerController playerController;

  /// 设置控制器。
  final SettingsController settingsController;
}
