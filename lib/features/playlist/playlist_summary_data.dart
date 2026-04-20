import 'package:bujuan/domain/entities/playlist_entity.dart';

/// 页面和控制器只需要歌单摘要时，统一使用这层轻量模型，避免继续暴露网易云歌单 bean。
class PlaylistSummaryData {
  const PlaylistSummaryData({
    required this.id,
    required this.title,
    this.coverUrl,
    this.trackCount,
    this.description,
  });

  final String id;
  final String title;
  final String? coverUrl;
  final int? trackCount;
  final String? description;

  factory PlaylistSummaryData.fromJson(Map<String, dynamic> json) {
    return PlaylistSummaryData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      coverUrl: json['coverUrl'] as String?,
      trackCount: json['trackCount'] as int?,
      description: json['description'] as String?,
    );
  }

  factory PlaylistSummaryData.fromEntity(PlaylistEntity playlist) {
    return PlaylistSummaryData(
      id: playlist.sourceId,
      title: playlist.title,
      coverUrl: playlist.coverUrl,
      trackCount: playlist.trackCount,
      description: playlist.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coverUrl': coverUrl,
      'trackCount': trackCount,
      'description': description,
    };
  }

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
