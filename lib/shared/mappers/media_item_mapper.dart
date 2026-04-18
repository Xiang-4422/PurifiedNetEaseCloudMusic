import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/netease_api/src/api/play/bean.dart';
import 'package:bujuan/domain/entities/track.dart';

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
    return tracks
        .where((track) => track.id.isNotEmpty)
        .map((track) => MediaItem(
              id: track.id,
              duration: Duration(milliseconds: track.durationMs ?? 0),
              artUri: Uri.tryParse('${track.artworkUrl ?? ''}?param=200y200'),
              extras: {
                'type': MediaType.playlist.name,
                'image': track.artworkUrl ?? '',
                'liked': likedSongIds.contains(int.tryParse(track.sourceId)),
                'artist': track.artistNames.join(' / '),
              },
              title: track.title,
              album: track.albumTitle,
              artist: track.artistNames.join(' / '),
            ))
        .toList();
  }
}
