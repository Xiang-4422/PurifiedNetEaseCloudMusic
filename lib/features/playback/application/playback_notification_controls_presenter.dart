import 'package:audio_service/audio_service.dart';

/// 根据当前播放态生成通知栏 controls，避免 handler 内散落按钮拼装细节。
class PlaybackNotificationControlsPresenter {
  const PlaybackNotificationControlsPresenter();

  List<MediaControl> buildControls({
    required bool isPlaying,
    required bool isLiked,
  }) {
    return [
      MediaControl(
        label: 'rewind',
        action: MediaAction.rewind,
        androidIcon: isLiked
            ? 'drawable/audio_service_like'
            : 'drawable/audio_service_unlike',
      ),
      MediaControl.skipToPrevious,
      isPlaying ? MediaControl.pause : MediaControl.play,
      MediaControl.skipToNext,
      MediaControl.stop,
    ];
  }
}
