import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/playback_service.dart';

/// 底层切歌结果。
class PlaybackSwitchResult {
  /// 创建底层切歌结果。
  const PlaybackSwitchResult({
    required this.selectionVersion,
    required this.success,
    this.isObsolete = false,
    this.message,
  });

  /// 该结果对应的选择版本。
  final int selectionVersion;

  /// 底层是否成功设置播放源。
  final bool success;

  /// 结果是否已经被更新的选择版本淘汰。
  final bool isObsolete;

  /// 失败或状态提示信息。
  final String? message;
}

/// 负责把 UI selection 串行提交到底层播放器。
///
/// selection 更新本身不经过这里；这里只处理播放源解析、`setSource` 和最后
/// 一次请求生效规则。
class PlaybackSwitchCoordinator {
  /// 创建底层切歌协调器。
  PlaybackSwitchCoordinator({required PlaybackService playbackService})
      : _playbackService = playbackService;

  final PlaybackService _playbackService;
  Future<void> _switchTail = Future<void>.value();
  int _latestVersion = 0;
  int _consecutiveAutoFailures = 0;

  /// 自动推进时允许连续跳过的最大失败次数。
  static const int maxAutoAdvanceFailures = 3;

  /// 提交当前 selection 到底层播放器。
  Future<PlaybackSwitchResult> switchToSelection({
    required PlaybackQueueItem item,
    required int activeIndex,
    required int selectionVersion,
    required PlaybackSwitchTrigger trigger,
    required bool playNow,
  }) async {
    final version = selectionVersion;
    _latestVersion = version;
    if (item.id.isEmpty || activeIndex < 0) {
      return PlaybackSwitchResult(
        selectionVersion: version,
        success: false,
        message: '没有可播放的歌曲',
      );
    }

    final operation = _switchTail.then((_) async {
      if (_isObsolete(version)) {
        return PlaybackSwitchResult(
          selectionVersion: version,
          success: false,
          isObsolete: true,
        );
      }
      final success = await _playbackService.setSourceForQueueItem(
        item: item,
        activeIndex: activeIndex,
        playNow: playNow,
      );
      if (_isObsolete(version)) {
        return PlaybackSwitchResult(
          selectionVersion: version,
          success: false,
          isObsolete: true,
        );
      }
      if (success) {
        _consecutiveAutoFailures = 0;
        return PlaybackSwitchResult(
          selectionVersion: version,
          success: true,
        );
      }
      if (_isAutoAdvance(trigger)) {
        _consecutiveAutoFailures++;
      }
      return PlaybackSwitchResult(
        selectionVersion: version,
        success: false,
        message: _isAutoAdvance(trigger) &&
                _consecutiveAutoFailures >= maxAutoAdvanceFailures
            ? '连续多首歌曲无法播放'
            : '当前歌曲暂时无法播放',
      );
    });
    _switchTail = operation.then<void>((_) {}).catchError((_) {});
    return operation;
  }

  bool _isObsolete(int version) {
    return version != _latestVersion;
  }

  bool _isAutoAdvance(PlaybackSwitchTrigger trigger) {
    return trigger == PlaybackSwitchTrigger.queueCompletion ||
        trigger == PlaybackSwitchTrigger.modeAutoAdvance;
  }
}
