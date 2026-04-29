import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_resource_bundle.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';

/// 播放队列项 mapper，负责从曲目领域实体构建播放队列模型。
class PlaybackQueueItemMapper {
  /// 禁止实例化播放队列 mapper。
  const PlaybackQueueItemMapper._();

  /// 从曲目列表构建播放队列项列表。
  static List<PlaybackQueueItem> fromTrackList(
    List<Track> tracks, {
    required List<int> likedSongIds,
    MediaType? mediaType,
  }) {
    return fromTrackWithResourcesList(
      tracks
          .where((track) => track.id.isNotEmpty)
          .map(
            (track) => TrackWithResources(
              track: track,
              resources: const TrackResourceBundle(),
            ),
          )
          .toList(),
      likedSongIds: likedSongIds,
      mediaType: mediaType,
    );
  }

  /// 从携带本地资源的曲目列表构建播放队列项列表。
  static List<PlaybackQueueItem> fromTrackWithResourcesList(
    List<TrackWithResources> tracks, {
    required List<int> likedSongIds,
    MediaType? mediaType,
  }) {
    return tracks.where((item) => item.track.id.isNotEmpty).map((item) {
      final track = item.track;
      final resources = item.resources;
      final localArtworkPath = _emptyToNull(resources.artwork?.path);
      final localLyricsPath = _emptyToNull(resources.lyrics?.path);
      final localAudioPath = _emptyToNull(resources.audio?.path);
      final artworkUrl = localArtworkPath ??
          _emptyToNull(ImageUrlNormalizer.normalize(track.artworkUrl));
      final artistIds = (track.metadata['artistIds'] as List? ?? const [])
          .map((item) => '$item')
          .toList();
      final metadata = <String, dynamic>{
        ...track.metadata,
        'albumId': track.metadata['albumId']?.toString() ?? '',
        'sourceType': track.sourceType.name,
        'localLyricsPath': localLyricsPath ?? '',
        'availability': track.availability.name,
      };
      return PlaybackQueueItem(
        id: track.id,
        sourceId: track.sourceId,
        title: track.title,
        albumTitle: track.albumTitle,
        artistNames: track.artistNames,
        artistIds: artistIds,
        duration: track.durationMs == null
            ? null
            : Duration(milliseconds: track.durationMs!),
        artworkUrl: artworkUrl,
        localArtworkPath: localArtworkPath,
        mediaType: mediaType ?? _mediaTypeForTrack(track, resources),
        playbackUrl: _emptyToNull(_resolvePlaybackUrl(track, resources)),
        lyricKey: track.lyricKey,
        isLiked: likedSongIds.contains(int.tryParse(track.sourceId)),
        isCached: localAudioPath != null,
        metadata: metadata,
      );
    }).toList();
  }

  static String _resolvePlaybackUrl(
    Track track,
    TrackResourceBundle resources,
  ) {
    if (resources.audio?.path.isNotEmpty == true) {
      return resources.audio!.path;
    }
    if (track.sourceType == SourceType.local) {
      return track.sourceId;
    }
    return track.remoteUrl ?? '';
  }

  static MediaType _mediaTypeForTrack(
    Track track,
    TrackResourceBundle resources,
  ) {
    if (track.sourceType == SourceType.local) {
      return MediaType.local;
    }
    if (resources.audio?.path.isNotEmpty == true) {
      return MediaType.neteaseCache;
    }
    return MediaType.playlist;
  }

  static String? _emptyToNull(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }
}
