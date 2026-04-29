import 'playlist_track_ref.dart';
import 'source_type.dart';

/// 歌单领域实体。
class PlaylistEntity {
  /// 创建歌单实体。
  const PlaylistEntity({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    this.description,
    this.coverUrl,
    this.trackCount,
    this.trackRefs = const [],
  });

  /// 应用内部歌单 id。
  final String id;

  /// 歌单来源类型。
  final SourceType sourceType;

  /// 来源侧歌单 id。
  final String sourceId;

  /// 歌单标题。
  final String title;

  /// 歌单描述。
  final String? description;

  /// 歌单封面地址。
  final String? coverUrl;

  /// 曲目数量。
  final int? trackCount;

  /// 歌单曲目引用列表。
  final List<PlaylistTrackRef> trackRefs;

  /// 复制歌单实体并替换指定字段。
  PlaylistEntity copyWith({
    String? id,
    SourceType? sourceType,
    String? sourceId,
    String? title,
    String? description,
    String? coverUrl,
    int? trackCount,
    List<PlaylistTrackRef>? trackRefs,
  }) {
    return PlaylistEntity(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      trackCount: trackCount ?? this.trackCount,
      trackRefs: trackRefs ?? this.trackRefs,
    );
  }
}
