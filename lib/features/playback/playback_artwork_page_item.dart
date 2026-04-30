import 'package:bujuan/domain/entities/playback_queue_item.dart';

/// 底部封面分页只需要的稳定展示字段。
///
/// 播放队列项会频繁更新喜欢、缓存和 metadata 状态；封面 PageView 只监听这组
/// 字段，可以避免无关队列变化导致整页重建。
class PlaybackArtworkPageItem {
  /// 创建封面分页展示项。
  const PlaybackArtworkPageItem({
    required this.id,
    this.artworkUrl,
    this.localArtworkPath,
  });

  /// 从播放队列项提取封面分页字段。
  factory PlaybackArtworkPageItem.fromQueueItem(PlaybackQueueItem item) {
    return PlaybackArtworkPageItem(
      id: item.id,
      artworkUrl: item.artworkUrl,
      localArtworkPath: item.localArtworkPath,
    );
  }

  /// 歌曲唯一标识，用于保持 PageView 子项 key 稳定。
  final String id;

  /// 远程封面地址。
  final String? artworkUrl;

  /// 本地封面缓存路径。
  final String? localArtworkPath;

  /// 当前展示字段是否与另一个封面项一致。
  bool hasSameArtwork(PlaybackArtworkPageItem other) {
    return id == other.id &&
        artworkUrl == other.artworkUrl &&
        localArtworkPath == other.localArtworkPath;
  }
}
