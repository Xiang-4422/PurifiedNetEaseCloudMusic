import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/data/netease/api/src/api/play/bean.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';

/// `MediaItem` 只服务播放适配层，所以统一放在 playback 下，避免各个 feature 再维护一份音频服务专用映射。
class MediaItemMapper {
  const MediaItemMapper._();

  static List<MediaItem> fromSong2List(
    List<Song2> songs, {
    required List<int> likedSongIds,
  }) {
    return songs
        .where((song) => song.id.isNotEmpty)
        .map((song) => MediaItem(
              id: song.id,
              duration: Duration(milliseconds: song.dt ?? 0),
              artUri: Uri.parse('${song.al?.picUrl ?? ''}?param=200y200'),
              extras: {
                'type': MediaType.playlist.name,
                'image': song.al?.picUrl ?? '',
                'liked': likedSongIds.contains(int.tryParse(song.id)),
                'artist': (song.ar ?? [])
                    .map((artist) => jsonEncode(artist.toJson()))
                    .toList()
                    .join(' / '),
                'albumId': song.al?.id ?? '',
                'mv': song.mv,
                'fee': song.fee,
              },
              title: song.name ?? '',
              album: song.al?.name,
              artist: (song.ar ?? []).map((artist) => artist.name).join(' / '),
            ))
        .toList();
  }

  static List<MediaItem> fromCloudSongItemList(
    List<CloudSongItem> songs, {
    required List<int> likedSongIds,
  }) {
    return songs
        .where((song) => song.simpleSong.id.isNotEmpty)
        .map((song) => MediaItem(
              id: song.simpleSong.id,
              duration: Duration(milliseconds: song.simpleSong.dt ?? 0),
              artUri: Uri.parse(
                  '${song.simpleSong.al?.picUrl ?? ''}?param=500y500'),
              extras: {
                'url': '',
                'image': song.simpleSong.al?.picUrl ?? '',
                'type': MediaType.playlist.name,
                'liked':
                    likedSongIds.contains(int.tryParse(song.simpleSong.id)),
                'artist': (song.simpleSong.ar ?? [])
                    .map((artist) => jsonEncode(artist.toJson()))
                    .toList()
                    .join(' / '),
              },
              title: song.simpleSong.name ?? '',
              album: song.simpleSong.al?.name,
              artist: (song.simpleSong.ar ?? [])
                  .map((artist) => artist.name)
                  .join(' / '),
            ))
        .toList();
  }

  static List<MediaItem> fromTrackList(
    List<Track> tracks, {
    required List<int> likedSongIds,
  }) {
    return tracks.where((track) => track.id.isNotEmpty).map((track) {
      final localArtworkPath = track.localArtworkPath ?? '';
      final localLyricsPath = track.localLyricsPath ?? '';
      final imageUrl = localArtworkPath.isNotEmpty
          ? localArtworkPath
          : track.artworkUrl ?? '';
      final artUri = localArtworkPath.isNotEmpty
          ? Uri.file(File(localArtworkPath).path)
          : Uri.tryParse('${track.artworkUrl ?? ''}?param=200y200');
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
          'albumTitle': track.albumTitle ?? '',
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
