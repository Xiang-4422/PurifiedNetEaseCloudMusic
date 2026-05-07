import 'source_type.dart';

/// 专辑领域实体。
class AlbumEntity {
  /// 创建专辑实体。
  const AlbumEntity({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    this.artworkUrl,
    this.artistNames = const [],
    this.description,
    this.trackCount,
    this.publishTime,
  });

  /// 应用内部专辑 id。
  final String id;

  /// 专辑来源类型。
  final SourceType sourceType;

  /// 来源侧专辑 id。
  final String sourceId;

  /// 专辑标题。
  final String title;

  /// 专辑封面地址。
  final String? artworkUrl;

  /// 专辑歌手名称列表。
  final List<String> artistNames;

  /// 专辑描述。
  final String? description;

  /// 专辑曲目数量。
  final int? trackCount;

  /// 专辑发布时间戳。
  final int? publishTime;

  /// 复制专辑实体并替换指定字段。
  AlbumEntity copyWith({
    String? id,
    SourceType? sourceType,
    String? sourceId,
    String? title,
    String? artworkUrl,
    List<String>? artistNames,
    String? description,
    int? trackCount,
    int? publishTime,
  }) {
    return AlbumEntity(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      artistNames: artistNames ?? this.artistNames,
      description: description ?? this.description,
      trackCount: trackCount ?? this.trackCount,
      publishTime: publishTime ?? this.publishTime,
    );
  }
}
