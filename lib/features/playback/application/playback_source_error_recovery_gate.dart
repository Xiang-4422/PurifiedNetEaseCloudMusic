import 'package:bujuan/features/playback/playback_selection_state.dart';

/// 控制底层 source error 恢复调度，避免同一首歌同一 selection 重复强刷 URL。
class PlaybackSourceErrorRecoveryGate {
  bool _recoveryInFlight = false;
  String? _lastRecoveryKey;

  /// 当前播放源已经恢复到可用状态，允许后续 error 再次触发恢复。
  void markSourceReady() {
    _lastRecoveryKey = null;
  }

  /// 判断当前错误状态是否应该发起一次 source error 恢复。
  bool shouldStartRecovery({
    required String currentItemId,
    required PlaybackSelectionState selection,
  }) {
    if (_recoveryInFlight || currentItemId.isEmpty) {
      return false;
    }
    if (!selection.hasSelection || selection.selectedItem.id != currentItemId) {
      return false;
    }
    if (selection.sourceStatus == PlaybackSelectionSourceStatus.loading) {
      return false;
    }
    final recoveryKey = '${selection.selectionVersion}:$currentItemId';
    if (_lastRecoveryKey == recoveryKey) {
      return false;
    }
    _lastRecoveryKey = recoveryKey;
    _recoveryInFlight = true;
    return true;
  }

  /// 当前恢复任务结束。
  void completeRecovery() {
    _recoveryInFlight = false;
  }
}
