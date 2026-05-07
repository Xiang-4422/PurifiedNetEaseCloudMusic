import 'local_resource_entry.dart';
import 'track.dart';
import 'track_resource_bundle.dart';

/// 本地歌曲聚合实体。
class LocalSongEntry {
  /// 创建本地歌曲聚合实体。
  const LocalSongEntry({
    required this.track,
    required this.resources,
    required this.origin,
    required this.totalSizeBytes,
  });

  /// 曲目实体。
  final Track track;

  /// 曲目关联的本地资源包。
  final TrackResourceBundle resources;

  /// 本地歌曲来源。
  final TrackResourceOrigin origin;

  /// 关联资源总大小，单位字节。
  final int totalSizeBytes;

  /// 音频资源。
  LocalResourceEntry? get audioResource => resources.audio;

  /// 封面资源。
  LocalResourceEntry? get artworkResource => resources.artwork;

  /// 歌词资源。
  LocalResourceEntry? get lyricsResource => resources.lyrics;
}
