import 'package:bujuan/domain/entities/playback_media_type.dart';

/// 播放队列项实体，作为 UI、repository 和播放 service 之间的统一播放模型。
class PlaybackQueueItem {
  static const Object _unset = Object();

  /// 创建播放队列项。
  const PlaybackQueueItem({
    required this.id,
    required this.sourceId,
    required this.title,
    required this.albumTitle,
    required this.artistNames,
    required this.artistIds,
    required this.duration,
    required this.artworkUrl,
    required this.localArtworkPath,
    required this.mediaType,
    required this.playbackUrl,
    required this.lyricKey,
    required this.isLiked,
    required this.isCached,
    this.metadata = const {},
  });

  /// 创建空播放队列项。
  const PlaybackQueueItem.empty()
      : id = '',
        sourceId = '',
        title = '暂无',
        albumTitle = null,
        artistNames = const [],
        artistIds = const [],
        duration = null,
        artworkUrl = null,
        localArtworkPath = null,
        mediaType = MediaType.playlist,
        playbackUrl = null,
        lyricKey = null,
        isLiked = false,
        isCached = false,
        metadata = const {};

  /// 应用内部曲目 id。
  final String id;

  /// 来源侧曲目 id。
  final String sourceId;

  /// 曲目标题。
  final String title;

  /// 专辑标题。
  final String? albumTitle;

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

  /// 当前用户是否喜欢。
  final bool isLiked;

  /// 是否已有本地缓存音频。
  final bool isCached;

  /// 扩展元数据。
  final Map<String, dynamic> metadata;

  /// 兼容播放适配层使用的专辑名。
  String? get album => albumTitle;

  /// 拼接后的歌手名。
  String? get artist {
    if (artistNames.isEmpty) {
      return null;
    }
    return artistNames.join(' / ');
  }

  /// 播放适配层使用的封面 URI。
  Uri? get artUri {
    final source =
        localArtworkPath?.isNotEmpty == true ? localArtworkPath : artworkUrl;
    if (source == null || source.isEmpty) {
      return null;
    }
    return Uri.tryParse(source);
  }

  /// 播放适配层使用的扩展字段。
  Map<String, dynamic>? get extras {
    return {
      ...metadata,
      'type': mediaType.name,
      'image': artworkUrl ?? localArtworkPath ?? '',
      'url': playbackUrl ?? '',
      'liked': isLiked,
      'artist': artist ?? '',
      'artistNames': artistNames,
      'artistIds': artistIds,
      'albumTitle': albumTitle ?? '',
      'sourceId': sourceId,
      'localArtworkPath': localArtworkPath ?? '',
      'lyricKey': lyricKey ?? '',
      'cache': isCached,
    };
  }

  /// 复制播放队列项并替换指定字段。
  PlaybackQueueItem copyWith({
    String? id,
    String? sourceId,
    String? title,
    Object? albumTitle = _unset,
    List<String>? artistNames,
    List<String>? artistIds,
    Object? duration = _unset,
    Object? artworkUrl = _unset,
    Object? localArtworkPath = _unset,
    MediaType? mediaType,
    Object? playbackUrl = _unset,
    Object? lyricKey = _unset,
    bool? isLiked,
    bool? isCached,
    Map<String, dynamic>? metadata,
  }) {
    return PlaybackQueueItem(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      albumTitle: identical(albumTitle, _unset)
          ? this.albumTitle
          : albumTitle as String?,
      artistNames: artistNames ?? this.artistNames,
      artistIds: artistIds ?? this.artistIds,
      duration:
          identical(duration, _unset) ? this.duration : duration as Duration?,
      artworkUrl: identical(artworkUrl, _unset)
          ? this.artworkUrl
          : artworkUrl as String?,
      localArtworkPath: identical(localArtworkPath, _unset)
          ? this.localArtworkPath
          : localArtworkPath as String?,
      mediaType: mediaType ?? this.mediaType,
      playbackUrl: identical(playbackUrl, _unset)
          ? this.playbackUrl
          : playbackUrl as String?,
      lyricKey:
          identical(lyricKey, _unset) ? this.lyricKey : lyricKey as String?,
      isLiked: isLiked ?? this.isLiked,
      isCached: isCached ?? this.isCached,
      metadata: metadata ?? this.metadata,
    );
  }

  /// 从 JSON 创建播放队列项。
  factory PlaybackQueueItem.fromJson(Map<String, dynamic> json) {
    return PlaybackQueueItem(
      id: json['id'] as String? ?? '',
      sourceId: json['sourceId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      albumTitle: json['albumTitle'] as String?,
      artistNames:
          (json['artistNames'] as List? ?? const []).map((e) => '$e').toList(),
      artistIds:
          (json['artistIds'] as List? ?? const []).map((e) => '$e').toList(),
      duration: json['duration'] is int
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      artworkUrl: json['artworkUrl'] as String?,
      localArtworkPath: json['localArtworkPath'] as String?,
      mediaType: MediaType.values.firstWhere(
        (item) => item.name == json['mediaType'],
        orElse: () => MediaType.playlist,
      ),
      playbackUrl: json['playbackUrl'] as String?,
      lyricKey: json['lyricKey'] as String?,
      isLiked: json['isLiked'] as bool? ?? false,
      isCached: json['isCached'] as bool? ?? false,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }

  /// 转为可持久化 JSON。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceId': sourceId,
      'title': title,
      'albumTitle': albumTitle,
      'artistNames': artistNames,
      'artistIds': artistIds,
      'duration': duration?.inMilliseconds,
      'artworkUrl': artworkUrl,
      'localArtworkPath': localArtworkPath,
      'mediaType': mediaType.name,
      'playbackUrl': playbackUrl,
      'lyricKey': lyricKey,
      'isLiked': isLiked,
      'isCached': isCached,
      'metadata': metadata,
    };
  }
}
