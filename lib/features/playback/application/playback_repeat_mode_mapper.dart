import 'package:audio_service/audio_service.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';

/// 播放重复模式与 audio_service 重复模式的边界转换器。
class PlaybackRepeatModeMapper {
  /// 禁止实例化重复模式转换器。
  const PlaybackRepeatModeMapper._();

  /// 转换为 audio_service 使用的重复模式。
  static AudioServiceRepeatMode toAudioService(PlaybackRepeatMode mode) {
    switch (mode) {
      case PlaybackRepeatMode.none:
        return AudioServiceRepeatMode.none;
      case PlaybackRepeatMode.one:
        return AudioServiceRepeatMode.one;
      case PlaybackRepeatMode.all:
        return AudioServiceRepeatMode.all;
      case PlaybackRepeatMode.group:
        return AudioServiceRepeatMode.group;
    }
  }

  /// 从 audio_service 重复模式转换为 domain 重复模式。
  static PlaybackRepeatMode fromAudioService(AudioServiceRepeatMode mode) {
    switch (mode) {
      case AudioServiceRepeatMode.none:
        return PlaybackRepeatMode.none;
      case AudioServiceRepeatMode.one:
        return PlaybackRepeatMode.one;
      case AudioServiceRepeatMode.all:
        return PlaybackRepeatMode.all;
      case AudioServiceRepeatMode.group:
        return PlaybackRepeatMode.group;
    }
  }
}
