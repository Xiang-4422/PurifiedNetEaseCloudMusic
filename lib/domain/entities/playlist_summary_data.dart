import 'package:bujuan/domain/entities/playlist_entity.dart';

/// 页面和控制器只需要歌单摘要时，统一使用这层轻量模型，避免继续暴露远程歌单模型。
class PlaylistSummaryData {
  /// 创建歌单摘要数据。
  const PlaylistSummaryData({
    required this.id,
    required this.title,
    this.coverUrl,
    this.trackCount,
    this.description,
  });

  /// 歌单 id。
  final String id;

  /// 歌单标题。
  final String title;

  /// 歌单封面地址。
  final String? coverUrl;

  /// 曲目数量。
  final int? trackCount;

  /// 歌单描述。
  final String? description;

  /// 从 JSON 创建歌单摘要。
  factory PlaylistSummaryData.fromJson(Map<String, dynamic> json) {
    return PlaylistSummaryData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      coverUrl: json['coverUrl'] as String?,
      trackCount: json['trackCount'] as int?,
      description: json['description'] as String?,
    );
  }

  /// 从歌单实体创建歌单摘要。
  factory PlaylistSummaryData.fromEntity(PlaylistEntity playlist) {
    return PlaylistSummaryData(
      id: playlist.sourceId,
      title: playlist.title,
      coverUrl: playlist.coverUrl,
      trackCount: playlist.trackCount,
      description: playlist.description,
    );
  }

  /// 转为可持久化 JSON。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coverUrl': coverUrl,
      'trackCount': trackCount,
      'description': description,
    };
  }

  /// 复制歌单摘要并替换指定字段。
  PlaylistSummaryData copyWith({
    String? id,
    String? title,
    String? coverUrl,
    int? trackCount,
    String? description,
  }) {
    return PlaylistSummaryData(
      id: id ?? this.id,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      trackCount: trackCount ?? this.trackCount,
      description: description ?? this.description,
    );
  }
}
