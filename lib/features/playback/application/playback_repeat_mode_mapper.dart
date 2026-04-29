import 'package:audio_service/audio_service.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';

class PlaybackRepeatModeMapper {
  const PlaybackRepeatModeMapper._();

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
