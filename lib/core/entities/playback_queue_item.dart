import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart' show TrackAvailability;

/// 播放队列项允许携带的调用方自定义元数据。
class PlaybackQueueItemMetadata {
  const PlaybackQueueItemMetadata._(this._values);

  /// 空自定义元数据。
  static const empty = PlaybackQueueItemMetadata._({});

  /// 从动态 Map 创建只读、JSON 兼容的自定义元数据。
  factory PlaybackQueueItemMetadata.custom(Map<dynamic, dynamic> values) {
    if (values.isEmpty) {
      return empty;
    }
    final sanitized = <String, Object?>{};
    for (final entry in values.entries) {
      final key = '${entry.key}'.trim();
      if (key.isEmpty) {
        continue;
      }
      sanitized[key] = _sanitizeValue(entry.value);
    }
    if (sanitized.isEmpty) {
      return empty;
    }
    return PlaybackQueueItemMetadata._(Map.unmodifiable(sanitized));
  }

  final Map<String, Object?> _values;

  /// 只读 JSON 兼容 Map，用于 adapter/cache 边界序列化。
  Map<String, Object?> get values => _values;

  /// 是否没有自定义元数据。
  bool get isEmpty => _values.isEmpty;

  /// 是否包含指定自定义元数据键。
  bool containsKey(String key) => _values.containsKey(key);

  /// 读取指定自定义元数据值。
  Object? operator [](String key) => _values[key];

  static Object? _sanitizeValue(Object? value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is Iterable) {
      return List<Object?>.unmodifiable(value.map(_sanitizeValue));
    }
    if (value is Map) {
      final sanitized = <String, Object?>{};
      for (final entry in value.entries) {
        final key = '${entry.key}'.trim();
        if (key.isNotEmpty) {
          sanitized[key] = _sanitizeValue(entry.value);
        }
      }
      return Map.unmodifiable(sanitized);
    }
    return '$value';
  }
}

/// 播放队列项实体，作为 UI、repository 和播放 service 之间的统一播放模型。
class PlaybackQueueItem {
  static const Object _unset = Object();

  /// 创建播放队列项。
  const PlaybackQueueItem({
    required this.id,
    required this.sourceId,
    this.sourceType = SourceType.netease,
    required this.title,
    required this.albumTitle,
    this.albumId,
    required this.artistNames,
    required this.artistIds,
    required this.duration,
    required this.artworkUrl,
    required this.localArtworkPath,
    required this.mediaType,
    required this.playbackUrl,
    required this.lyricKey,
    this.localLyricsPath,
    this.availability = TrackAvailability.unknown,
    required this.isLiked,
    required this.isCached,
    this.customMetadata = PlaybackQueueItemMetadata.empty,
  });

  /// 创建空播放队列项。
  const PlaybackQueueItem.empty()
      : id = '',
        sourceId = '',
        sourceType = SourceType.unknown,
        title = '暂无',
        albumTitle = null,
        albumId = null,
        artistNames = const [],
        artistIds = const [],
        duration = null,
        artworkUrl = null,
        localArtworkPath = null,
        mediaType = MediaType.playlist,
        playbackUrl = null,
        lyricKey = null,
        localLyricsPath = null,
        availability = TrackAvailability.unknown,
        isLiked = false,
        isCached = false,
        customMetadata = PlaybackQueueItemMetadata.empty;

  /// 应用内部曲目 id。
  final String id;

  /// 来源侧曲目 id。
  final String sourceId;

  /// 曲目来源类型。
  final SourceType sourceType;

  /// 曲目标题。
  final String title;

  /// 专辑标题。
  final String? albumTitle;

  /// 专辑 id。
  final String? albumId;

  /// 歌手名称列表。
  final List<String> artistNames;

  /// 歌手 id 列表。
  final List<String> artistIds;

  /// 曲目时长。
  final Duration? duration;

  /// 远程封面地址。
  final String? artworkUrl;

  /// 本地封面路径。
  final String? localArtworkPath;

  /// 播放媒体类型。
  final MediaType mediaType;

  /// 播放地址。
  final String? playbackUrl;

  /// 歌词键。
  final String? lyricKey;

  /// 本地歌词路径。
  final String? localLyricsPath;

  /// 曲目可播放状态。
  final TrackAvailability availability;

  /// 当前用户是否喜欢。
  final bool isLiked;

  /// 是否已有本地缓存音频。
  final bool isCached;

  /// 调用方自定义元数据。
  final PlaybackQueueItemMetadata customMetadata;

  /// 拼接后的歌手名。
  String? get artist {
    if (artistNames.isEmpty) {
      return null;
    }
    return artistNames.join(' / ');
  }

  /// 复制播放队列项并替换指定字段。
  PlaybackQueueItem copyWith({
    String? id,
    String? sourceId,
    SourceType? sourceType,
    String? title,
    Object? albumTitle = _unset,
    Object? albumId = _unset,
    List<String>? artistNames,
    List<String>? artistIds,
    Object? duration = _unset,
    Object? artworkUrl = _unset,
    Object? localArtworkPath = _unset,
    MediaType? mediaType,
    Object? playbackUrl = _unset,
    Object? lyricKey = _unset,
    Object? localLyricsPath = _unset,
    TrackAvailability? availability,
    bool? isLiked,
    bool? isCached,
    PlaybackQueueItemMetadata? customMetadata,
  }) {
    return PlaybackQueueItem(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      sourceType: sourceType ?? this.sourceType,
      title: title ?? this.title,
      albumTitle: identical(albumTitle, _unset) ? this.albumTitle : albumTitle as String?,
      albumId: identical(albumId, _unset) ? this.albumId : albumId as String?,
      artistNames: artistNames ?? this.artistNames,
      artistIds: artistIds ?? this.artistIds,
      duration: identical(duration, _unset) ? this.duration : duration as Duration?,
      artworkUrl: identical(artworkUrl, _unset) ? this.artworkUrl : artworkUrl as String?,
      localArtworkPath: identical(localArtworkPath, _unset) ? this.localArtworkPath : localArtworkPath as String?,
      mediaType: mediaType ?? this.mediaType,
      playbackUrl: identical(playbackUrl, _unset) ? this.playbackUrl : playbackUrl as String?,
      lyricKey: identical(lyricKey, _unset) ? this.lyricKey : lyricKey as String?,
      localLyricsPath: identical(localLyricsPath, _unset) ? this.localLyricsPath : localLyricsPath as String?,
      availability: availability ?? this.availability,
      isLiked: isLiked ?? this.isLiked,
      isCached: isCached ?? this.isCached,
      customMetadata: customMetadata ?? this.customMetadata,
    );
  }
}
