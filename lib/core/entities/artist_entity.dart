import 'source_type.dart';

/// 歌手领域实体。
class ArtistEntity {
  /// 创建歌手实体。
  const ArtistEntity({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.name,
    this.artworkUrl,
    this.description,
  });

  /// 应用内部歌手 id。
  final String id;

  /// 歌手来源类型。
  final SourceType sourceType;

  /// 来源侧歌手 id。
  final String sourceId;

  /// 歌手名称。
  final String name;

  /// 歌手封面地址。
  final String? artworkUrl;

  /// 歌手描述。
  final String? description;

  /// 复制歌手实体并替换指定字段。
  ArtistEntity copyWith({
    String? id,
    SourceType? sourceType,
    String? sourceId,
    String? name,
    String? artworkUrl,
    String? description,
  }) {
    return ArtistEntity(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      description: description ?? this.description,
    );
  }
}
