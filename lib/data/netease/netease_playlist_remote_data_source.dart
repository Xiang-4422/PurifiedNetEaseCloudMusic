import 'dart:math';

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

  Future<List<Track>> fetchPlaylistSongs({
    required List<String> songIds,
    required int offset,
    required int limit,
  }) async {
    if (offset >= songIds.length) {
      return const [];
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

    return tracks;
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
