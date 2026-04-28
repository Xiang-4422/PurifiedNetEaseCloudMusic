import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_resource_bundle.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';

/// `MediaItem` 只服务播放适配层，所以统一放在 playback 下，避免各个 feature 再维护一份音频服务专用映射。
class MediaItemMapper {
  const MediaItemMapper._();

  static List<MediaItem> fromTrackList(
    List<Track> tracks, {
    required List<int> likedSongIds,
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
    );
  }

  static List<MediaItem> fromTrackWithResourcesList(
    List<TrackWithResources> tracks, {
    required List<int> likedSongIds,
  }) {
    return tracks.where((item) => item.track.id.isNotEmpty).map((item) {
      final track = item.track;
      final resources = item.resources;
      final localArtworkPath = resources.artwork?.path ?? '';
      final localLyricsPath = resources.lyrics?.path ?? '';
      final localAudioPath = resources.audio?.path ?? '';
      final imageUrl = localArtworkPath.isNotEmpty
          ? localArtworkPath
          : OtherUtils.normalizeImageUrl(track.artworkUrl);
      final artUri = localArtworkPath.isNotEmpty
          ? Uri.file(File(localArtworkPath).path)
          : null;
      return MediaItem(
        id: track.id,
        duration: Duration(milliseconds: track.durationMs ?? 0),
        artUri: artUri,
        extras: {
          'type': _mediaTypeForTrack(track, resources).name,
          'image': imageUrl,
          'url': _resolvePlaybackUrl(track, resources),
          'liked': likedSongIds.contains(int.tryParse(track.sourceId)),
          'artist': track.artistNames.join(' / '),
          'artistNames': track.artistNames,
          'artistIds': List<String>.from(
            (track.metadata['artistIds'] as List?)?.map((e) => '$e') ??
                const [],
          ),
          'albumTitle': track.albumTitle ?? '',
          'albumId': track.metadata['albumId']?.toString() ?? '',
          'sourceType': track.sourceType.name,
          'sourceId': track.sourceId,
          'localArtworkPath': localArtworkPath,
          'localLyricsPath': localLyricsPath,
          'availability': track.availability.name,
          'cache': localAudioPath.isNotEmpty,
        },
        title: track.title,
        album: track.albumTitle,
        artist: track.artistNames.join(' / '),
      );
    }).toList();
  }

  static String _resolvePlaybackUrl(
      Track track, TrackResourceBundle resources) {
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
}
