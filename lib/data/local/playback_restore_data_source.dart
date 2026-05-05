import 'package:bujuan/domain/entities/playback_restore_state.dart';

/// 播放恢复状态本地数据源。
abstract class PlaybackRestoreDataSource {
  /// 读取播放恢复状态。
  Future<PlaybackRestoreState?> getRestoreState();

  /// 保存播放恢复状态。
  Future<void> saveRestoreState(PlaybackRestoreState state);

  /// 只保存当前播放进度，避免高频进度更新重写完整队列快照。
  Future<void> saveRestorePosition(Duration position);
}
