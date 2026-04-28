import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';

class NeteasePlaylistRemoteDataSource {
  const NeteasePlaylistRemoteDataSource();

  Future<
      ({
        PlaylistEntity? playlist,
        List<String> trackIds,
        bool isSubscribed,
        String name,
        String? creatorUserId,
      })> fetchPlaylistSnapshot(String playlistId) async {
    final wrap = await NeteaseMusicApi().playListDetail(playlistId);
    final playlist = wrap.playlist;
    final playlistEntity =
        playlist == null ? null : NeteasePlaylistMapper.fromPlaylist(playlist);
    return (
      playlist: playlistEntity,
      trackIds:
          playlist?.trackIds?.map((track) => track.id).toList() ?? const [],
      isSubscribed: playlist?.subscribed ?? false,
      name: playlist?.name ?? '无名歌单',
      creatorUserId: playlist?.creator?.userId,
    );
  }

  Future<
      ({
        List<Track> tracks,
        List<MediaItem> mediaItems,
      })> fetchPlaylistSongs({
    required List<String> songIds,
    required int offset,
    required int limit,
    required List<int> likedSongIds,
  }) async {
    if (offset >= songIds.length) {
      return (tracks: <Track>[], mediaItems: <MediaItem>[]);
    }

    final targetIds = songIds.sublist(offset);
    final fetchCount =
        limit == -1 || targetIds.length < limit ? targetIds.length : limit;
    final resolvedIds = targetIds.take(fetchCount).toList();

    final tracks = <Track>[];
    while (tracks.length < resolvedIds.length) {
      final wrap = await NeteaseMusicApi().songDetail(
        resolvedIds.sublist(
          tracks.length,
          min(tracks.length + 1000, resolvedIds.length),
        ),
      );
      tracks.addAll(
        NeteaseTrackMapper.fromSong2List(wrap.songs ?? const []),
      );
    }

    return (
      tracks: tracks,
      mediaItems: MediaItemMapper.fromTrackList(
        tracks,
        likedSongIds: likedSongIds,
      ),
    );
  }

  Future<({bool success, String? message})> toggleSubscription(
    String playlistId, {
    required bool subscribe,
  }) async {
    final result = await NeteaseMusicApi()
        .subscribePlayList(playlistId, subscribe: subscribe);
    return (
      success: result.code == 200,
      message: result.message,
    );
  }

  Future<({bool success, String? message})> manipulateTracks(
    String playlistId,
    String songId, {
    required bool add,
  }) async {
    final result = await NeteaseMusicApi()
        .playlistManipulateTracks(playlistId, songId, add);
    return (
      success: result.code == 200,
      message: result.message,
    );
  }
}
