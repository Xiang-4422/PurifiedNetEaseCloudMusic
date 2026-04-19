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

  bool get hasSnapshotData {
    return playbackMode != PlaybackMode.playlist ||
        repeatMode != AudioServiceRepeatMode.all ||
        queue.isNotEmpty ||
        currentSongId.isNotEmpty ||
        playlistName.isNotEmpty ||
        playlistHeader.isNotEmpty ||
        position > Duration.zero;
  }

  PlaybackRestoreState copyWith({
    PlaybackMode? playbackMode,
    AudioServiceRepeatMode? repeatMode,
    List<String>? queue,
    String? currentSongId,
    String? playlistName,
    String? playlistHeader,
    Duration? position,
  }) {
    return PlaybackRestoreState(
      playbackMode: playbackMode ?? this.playbackMode,
      repeatMode: repeatMode ?? this.repeatMode,
      queue: queue ?? this.queue,
      currentSongId: currentSongId ?? this.currentSongId,
      playlistName: playlistName ?? this.playlistName,
      playlistHeader: playlistHeader ?? this.playlistHeader,
      position: position ?? this.position,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'playbackMode': playbackMode.name,
      'repeatMode': repeatMode.name,
      'queue': queue,
      'currentSongId': currentSongId,
      'playlistName': playlistName,
      'playlistHeader': playlistHeader,
      'positionMs': position.inMilliseconds,
    };
  }

  factory PlaybackRestoreState.fromJson(Map<String, Object?> json) {
    return PlaybackRestoreState(
      playbackMode: PlaybackMode.values.firstWhere(
        (element) => element.name == json['playbackMode'],
        orElse: () => PlaybackMode.playlist,
      ),
      repeatMode: AudioServiceRepeatMode.values.firstWhere(
        (element) => element.name == json['repeatMode'],
        orElse: () => AudioServiceRepeatMode.all,
      ),
      queue: (json['queue'] as List?)?.cast<String>() ?? const <String>[],
      currentSongId: json['currentSongId'] as String? ?? '',
      playlistName: json['playlistName'] as String? ?? '',
      playlistHeader: json['playlistHeader'] as String? ?? '',
      position: Duration(milliseconds: json['positionMs'] as int? ?? 0),
    );
  }
}
