import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';

/// `MediaItem` 只服务播放适配层，所以统一放在 playback 下，避免各个 feature 再维护一份音频服务专用映射。
class MediaItemMapper {
  const MediaItemMapper._();

  static List<MediaItem> fromTrackList(
    List<Track> tracks, {
    required List<int> likedSongIds,
  }) {
    return tracks.where((track) => track.id.isNotEmpty).map((track) {
      final localArtworkPath = track.localArtworkPath ?? '';
      final localLyricsPath = track.localLyricsPath ?? '';
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
          'type': _mediaTypeForTrack(track).name,
          'image': imageUrl,
          'url': track.localPath ?? track.remoteUrl ?? '',
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
          'localPath': track.localPath ?? '',
          'localArtworkPath': localArtworkPath,
          'localLyricsPath': localLyricsPath,
          'availability': track.availability.name,
          'downloadState': track.downloadState.name,
          'resourceOrigin': track.resourceOrigin.name,
          'downloadProgress': track.downloadProgress,
          'downloadFailureReason': track.downloadFailureReason ?? '',
          'cache': track.localPath?.isNotEmpty == true,
        },
        title: track.title,
        album: track.albumTitle,
        artist: track.artistNames.join(' / '),
      );
    }).toList();
  }

  static MediaType _mediaTypeForTrack(Track track) {
    if (track.sourceType == SourceType.local) {
      return MediaType.local;
    }
    if (track.localPath?.isNotEmpty == true) {
      return MediaType.neteaseCache;
    }
    return MediaType.playlist;
  }
}
