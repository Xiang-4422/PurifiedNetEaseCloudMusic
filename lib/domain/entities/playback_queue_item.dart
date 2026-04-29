import 'package:bujuan/domain/entities/playback_media_type.dart';

class PlaybackQueueItem {
  static const Object _unset = Object();

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

  final String id;
  final String sourceId;
  final String title;
  final String? albumTitle;
  final List<String> artistNames;
  final List<String> artistIds;
  final Duration? duration;
  final String? artworkUrl;
  final String? localArtworkPath;
  final MediaType mediaType;
  final String? playbackUrl;
  final String? lyricKey;
  final bool isLiked;
  final bool isCached;
  final Map<String, dynamic> metadata;

  String? get album => albumTitle;

  String? get artist {
    if (artistNames.isEmpty) {
      return null;
    }
    return artistNames.join(' / ');
  }

  Uri? get artUri {
    final source =
        localArtworkPath?.isNotEmpty == true ? localArtworkPath : artworkUrl;
    if (source == null || source.isEmpty) {
      return null;
    }
    return Uri.tryParse(source);
  }

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
