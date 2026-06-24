import 'package:bujuan/core/entities/liked_song_ids.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:bujuan/core/entities/music_resource_id.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/core/util/track_resource_availability.dart';
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
          .where((track) => _normalizedQueueItemId(track.id).isNotEmpty)
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
    final likedSongIdSet = normalizeLikedSongIds(likedSongIds).toSet();
    return tracks.where((item) => _normalizedQueueItemId(item.track.id).isNotEmpty).map((item) {
      final track = item.track;
      final trackId = _normalizedQueueItemId(track.id);
      final resources = item.resources;
      final localArtworkPath = TrackResourceAvailability.localPath(resources.artwork);
      final localLyricsPath = TrackResourceAvailability.localPath(resources.lyrics);
      final artworkUrl = _emptyToNull(ImageUrlNormalizer.normalize(track.artworkUrl));
      return PlaybackQueueItem(
        id: trackId,
        sourceId: track.sourceId,
        sourceType: track.sourceType,
        title: track.title,
        albumTitle: track.albumTitle,
        albumId: track.resolvedAlbumId,
        artistNames: track.artistNames,
        artistIds: track.resolvedArtistIds,
        duration: track.durationMs == null ? null : Duration(milliseconds: track.durationMs!),
        artworkUrl: artworkUrl,
        localArtworkPath: localArtworkPath,
        mediaType: TrackResourceAvailability.queueMediaType(
          track,
          resources,
          fallback: mediaType,
        ),
        playbackUrl: TrackResourceAvailability.queuePlaybackUrl(track, resources),
        lyricKey: track.lyricKey,
        localLyricsPath: localLyricsPath,
        availability: track.availability,
        isLiked: _isLikedTrack(
          trackId: trackId,
          sourceId: track.sourceId,
          likedSongIds: likedSongIdSet,
        ),
        isCached: TrackResourceAvailability.isCachedAudioResource(resources.audio),
        customMetadata: PlaybackQueueItemMetadata.custom(
          playbackQueueCustomMetadata(track.metadata),
        ),
      );
    }).toList();
  }

  static String? _emptyToNull(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  static bool _isLikedTrack({
    required String trackId,
    required String sourceId,
    required Set<int> likedSongIds,
  }) {
    final normalizedSourceId = MusicResourceId.toNeteaseSourceId(
      sourceId.trim().isNotEmpty ? sourceId : trackId,
    );
    final numericSongId = int.tryParse(normalizedSourceId);
    return numericSongId != null && likedSongIds.contains(numericSongId);
  }

  static String _normalizedQueueItemId(String id) {
    return id.trim();
  }
}
