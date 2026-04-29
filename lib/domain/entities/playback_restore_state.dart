import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';

/// 播放恢复状态描述“应用下次启动时最少需要恢复什么”。
///
/// 这里先收口已经稳定存在于轻存储中的恢复信息，避免队列、模式、进度继续靠散落 key
/// 分别读取。
class PlaybackRestoreState {
  /// 恢复的播放模式。
  final PlaybackMode playbackMode;

  /// 恢复的重复模式。
  final PlaybackRepeatMode repeatMode;

  /// 恢复的播放队列缓存。
  final List<String> queue;

  /// 恢复的当前歌曲 id。
  final String currentSongId;

  /// 恢复的播放列表名称。
  final String playlistName;

  /// 恢复的播放列表头部文案。
  final String playlistHeader;

  /// 恢复的播放位置。
  final Duration position;

  /// 创建播放恢复状态。
  const PlaybackRestoreState({
    this.playbackMode = PlaybackMode.playlist,
    this.repeatMode = PlaybackRepeatMode.all,
    this.queue = const <String>[],
    this.currentSongId = '',
    this.playlistName = '',
    this.playlistHeader = '',
    this.position = Duration.zero,
  });

  /// 是否包含需要恢复的快照数据。
  bool get hasSnapshotData {
    return playbackMode != PlaybackMode.playlist ||
        repeatMode != PlaybackRepeatMode.all ||
        queue.isNotEmpty ||
        currentSongId.isNotEmpty ||
        playlistName.isNotEmpty ||
        playlistHeader.isNotEmpty ||
        position > Duration.zero;
  }

  /// 复制播放恢复状态并替换指定字段。
  PlaybackRestoreState copyWith({
    PlaybackMode? playbackMode,
    PlaybackRepeatMode? repeatMode,
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

  /// 转为可持久化 JSON。
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

  /// 从持久化 JSON 创建播放恢复状态。
  factory PlaybackRestoreState.fromJson(Map<String, Object?> json) {
    return PlaybackRestoreState(
      playbackMode: PlaybackMode.values.firstWhere(
        (element) => element.name == json['playbackMode'],
        orElse: () => PlaybackMode.playlist,
      ),
      repeatMode: PlaybackRepeatMode.values.firstWhere(
        (element) => element.name == json['repeatMode'],
        orElse: () => PlaybackRepeatMode.all,
      ),
      queue: (json['queue'] as List?)?.cast<String>() ?? const <String>[],
      currentSongId: json['currentSongId'] as String? ?? '',
      playlistName: json['playlistName'] as String? ?? '',
      playlistHeader: json['playlistHeader'] as String? ?? '',
      position: Duration(milliseconds: json['positionMs'] as int? ?? 0),
    );
  }
}
