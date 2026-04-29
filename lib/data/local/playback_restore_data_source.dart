import 'package:bujuan/domain/entities/playback_restore_state.dart';

/// 播放恢复状态本地数据源。
abstract class PlaybackRestoreDataSource {
  /// 读取播放恢复状态。
  Future<PlaybackRestoreState?> getRestoreState();

  /// 保存播放恢复状态。
  Future<void> saveRestoreState(PlaybackRestoreState state);
}
