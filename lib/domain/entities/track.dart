import 'source_type.dart';

/// 曲目可播放状态。
enum TrackAvailability {
  /// 未知状态。
  unknown,

  /// 可在线播放。
  playable,

  /// 不可播放。
  unavailable,

  /// 仅本地可用。
  localOnly,
}

/// 曲目资源来源。
enum TrackResourceOrigin {
  /// 无来源。
  none,

  /// 封面缓存。
  artworkCache,

  /// 正式下载资源。
  managedDownload,

  /// 播放缓存资源。
  playbackCache,

  /// 本地导入资源。
  localImport,
}

/// 曲目领域实体。
class Track {
  static const Object _unset = Object();

  /// 创建曲目实体。
  const Track({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.title,
    this.artistNames = const [],
    this.albumTitle,
    this.durationMs,
    this.artworkUrl,
    this.remoteUrl,
    this.lyricKey,
    this.availability = TrackAvailability.unknown,
    this.metadata = const {},
  });

  /// 应用内部曲目 id。
  final String id;

  /// 曲目来源类型。
  final SourceType sourceType;

  /// 来源侧曲目 id。
  final String sourceId;

  /// 曲目标题。
  final String title;

  /// 歌手名称列表。
  final List<String> artistNames;

  /// 专辑标题。
  final String? albumTitle;

  /// 曲目时长，单位毫秒。
  final int? durationMs;

  /// 封面地址。
  final String? artworkUrl;

  /// 远程播放地址。
  final String? remoteUrl;

  /// 歌词键。
  final String? lyricKey;

  /// 曲目可播放状态。
  final TrackAvailability availability;

  /// 扩展元数据。
  final Map<String, Object?> metadata;

  /// 复制曲目实体并替换指定字段。
  Track copyWith({
    String? id,
    SourceType? sourceType,
    String? sourceId,
    String? title,
    List<String>? artistNames,
    Object? albumTitle = _unset,
    int? durationMs,
    Object? artworkUrl = _unset,
    Object? remoteUrl = _unset,
    Object? lyricKey = _unset,
    TrackAvailability? availability,
    Map<String, Object?>? metadata,
  }) {
    return Track(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      artistNames: artistNames ?? this.artistNames,
      albumTitle: identical(albumTitle, _unset)
          ? this.albumTitle
          : albumTitle as String?,
      durationMs: durationMs ?? this.durationMs,
      artworkUrl: identical(artworkUrl, _unset)
          ? this.artworkUrl
          : artworkUrl as String?,
      remoteUrl:
          identical(remoteUrl, _unset) ? this.remoteUrl : remoteUrl as String?,
      lyricKey:
          identical(lyricKey, _unset) ? this.lyricKey : lyricKey as String?,
      availability: availability ?? this.availability,
      metadata: metadata ?? this.metadata,
    );
  }
}
