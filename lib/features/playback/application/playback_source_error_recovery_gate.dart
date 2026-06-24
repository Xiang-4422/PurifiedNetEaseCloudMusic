import 'package:bujuan/features/playback/playback_selection_state.dart';

/// 控制底层 source error 恢复调度，避免同一首歌同一 selection 重复强刷 URL。
class PlaybackSourceErrorRecoveryGate {
  String? _recoveryInFlightKey;
  String? _lastRecoveryKey;

  /// 当前播放源已经恢复到可用状态，允许后续 error 再次触发恢复。
  void markSourceReady() {
    _recoveryInFlightKey = null;
    _lastRecoveryKey = null;
  }

  /// 判断当前错误状态是否应该发起一次 source error 恢复。
  bool shouldStartRecovery({
    required String currentItemId,
    required PlaybackSelectionState selection,
  }) {
    final recoveryKey = startRecovery(
      currentItemId: currentItemId,
      selection: selection,
    );
    return recoveryKey != null;
  }

  /// 尝试开始一次 source error 恢复，成功时返回本次恢复 key。
  String? startRecovery({
    required String currentItemId,
    required PlaybackSelectionState selection,
  }) {
    final normalizedCurrentItemId = _normalizedItemId(currentItemId);
    if (normalizedCurrentItemId.isEmpty) {
      return null;
    }
    final normalizedSelectedItemId = _normalizedItemId(selection.selectedItem.id);
    if (normalizedSelectedItemId.isEmpty || selection.selectedIndex < 0 || normalizedSelectedItemId != normalizedCurrentItemId) {
      return null;
    }
    if (selection.sourceStatus == PlaybackSelectionSourceStatus.loading) {
      return null;
    }
    final recoveryKey = '${selection.selectionVersion}:$normalizedCurrentItemId';
    if (_lastRecoveryKey == recoveryKey || _recoveryInFlightKey == recoveryKey) {
      return null;
    }
    _lastRecoveryKey = recoveryKey;
    _recoveryInFlightKey = recoveryKey;
    return recoveryKey;
  }

  /// 当前恢复任务结束。
  void completeRecovery([String? recoveryKey]) {
    if (recoveryKey == null || _recoveryInFlightKey == recoveryKey) {
      _recoveryInFlightKey = null;
    }
  }

  String _normalizedItemId(String itemId) {
    return itemId.trim();
  }
}
