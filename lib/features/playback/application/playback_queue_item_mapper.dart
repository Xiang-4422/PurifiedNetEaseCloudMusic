import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:bujuan/features/playback/application/playback_queue_metadata_filter.dart';

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
      final localArtworkPath = _localResourcePath(resources.artwork);
      final localLyricsPath = _localResourcePath(resources.lyrics);
      final artworkUrl = _emptyToNull(ImageUrlNormalizer.normalize(track.artworkUrl));
      final albumId = _emptyToNull(track.albumId) ?? _emptyToNull(track.metadata['albumId']?.toString());
      final artistIds = track.artistIds.isNotEmpty ? track.artistIds : (track.metadata['artistIds'] as List? ?? const []).map((item) => '$item').toList();
      return PlaybackQueueItem(
        id: track.id,
        sourceId: track.sourceId,
        sourceType: track.sourceType,
        title: track.title,
        albumTitle: track.albumTitle,
        albumId: albumId,
        artistNames: track.artistNames,
        artistIds: artistIds,
        duration: track.durationMs == null ? null : Duration(milliseconds: track.durationMs!),
        artworkUrl: artworkUrl,
        localArtworkPath: localArtworkPath,
        mediaType: _mediaTypeForTrack(
          track,
          resources,
          fallback: mediaType,
        ),
        playbackUrl: _emptyToNull(_resolvePlaybackUrl(track, resources)),
        lyricKey: track.lyricKey,
        localLyricsPath: localLyricsPath,
        availability: track.availability,
        isLiked: likedSongIds.contains(int.tryParse(track.sourceId)),
        isCached: _isCachedAudioResource(resources.audio),
        metadata: playbackQueueCustomMetadata(track.metadata),
      );
    }).toList();
  }

  static String _resolvePlaybackUrl(
    Track track,
    TrackResourceBundle resources,
  ) {
    final audioPath = _localResourcePath(resources.audio);
    if (audioPath != null) {
      return audioPath;
    }
    return track.remoteUrl ?? '';
  }

  static MediaType _mediaTypeForTrack(
    Track track,
    TrackResourceBundle resources, {
    MediaType? fallback,
  }) {
    final audioPath = _localResourcePath(resources.audio);
    if (audioPath != null) {
      return audioPath.endsWith('.uc!') ? MediaType.neteaseCache : MediaType.local;
    }
    if (track.sourceType == SourceType.local) {
      return MediaType.local;
    }
    if (fallback != null) {
      return fallback;
    }
    return MediaType.playlist;
  }

  static bool _isCachedAudioResource(LocalResourceEntry? audio) {
    switch (audio?.origin) {
      case TrackResourceOrigin.managedDownload:
      case TrackResourceOrigin.playbackCache:
        return true;
      case TrackResourceOrigin.localImport:
      case TrackResourceOrigin.artworkCache:
      case TrackResourceOrigin.none:
      case null:
        return false;
    }
  }

  static String? _emptyToNull(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  static String? _localResourcePath(LocalResourceEntry? resource) {
    return _emptyToNull(LocalFilePathNormalizer.normalize(resource?.path));
  }
}
