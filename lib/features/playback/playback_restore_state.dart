import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';

/// 播放恢复状态描述“应用下次启动时最少需要恢复什么”。
///
/// 这里先收口已经稳定存在于轻存储中的恢复信息，避免队列、模式、进度继续靠散落 key
/// 分别读取。后续接正式本地库时，可以直接围绕这个对象迁移，而不是重新梳理每个 key。
class PlaybackRestoreState {
  final PlaybackMode playbackMode;
  final AudioServiceRepeatMode repeatMode;
  final List<String> queue;
  final String currentSongId;
  final String playlistName;
  final String playlistHeader;
  final Duration position;

  const PlaybackRestoreState({
    this.playbackMode = PlaybackMode.playlist,
    this.repeatMode = AudioServiceRepeatMode.all,
    this.queue = const <String>[],
    this.currentSongId = '',
    this.playlistName = '',
    this.playlistHeader = '',
    this.position = Duration.zero,
  });
}
