import 'package:netease_music_api/netease_music_api.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_playlist_mapper.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/data/music_data/sources/netease/netease_song_detail_batch_planner.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/track.dart';

/// 网易云歌单远程数据源。
class NeteasePlaylistRemoteDataSource implements PlaylistRemoteDataSource {
  /// 创建网易云歌单远程数据源。
  NeteasePlaylistRemoteDataSource({required NeteaseMusicApi api}) : _api = api;

  final NeteaseMusicApi _api;

  /// 获取歌单索引，包括歌单摘要、曲目 id 和订阅状态。
  @override
  Future<
      ({
        PlaylistEntity? playlist,
        List<String> trackIds,
        bool isSubscribed,
        String name,
        String? creatorUserId,
        bool isLikedSongs,
      })> fetchPlaylistIndex(String playlistId) async {
    final wrap = await _api.playListDetail(playlistId);
    final playlist = wrap.playlist;
    final playlistEntity = playlist == null ? null : NeteasePlaylistMapper.fromPlaylist(playlist);
    return (
      playlist: playlistEntity,
      trackIds: normalizeNeteaseSongIds((playlist?.trackIds ?? const []).map((track) => track.id)),
      isSubscribed: playlist?.subscribed ?? false,
      name: playlist?.name ?? '无名歌单',
      creatorUserId: playlist?.creator?.userId,
      isLikedSongs: playlist?.specialType == 5,
    );
  }

  /// 分页获取歌单歌曲详情。
  @override
  Future<List<Track>> fetchPlaylistSongs({
    required List<String> songIds,
    required int offset,
    required int limit,
  }) async {
    final tracks = <Track>[];
    final batches = planNeteaseSongDetailBatches(
      ids: songIds,
      offset: offset,
      limit: limit,
    );
    for (final batch in batches) {
      final wrap = await _api.songDetail(batch);
      tracks.addAll(NeteaseTrackMapper.fromSong2List(wrap.songs ?? const []));
    }

    return tracks;
  }

  /// 切换歌单订阅状态。
  @override
  Future<({bool success, String? message})> toggleSubscription(
    String playlistId, {
    required bool subscribe,
  }) async {
    final result = await _api.subscribePlayList(playlistId, subscribe: subscribe);
    return (
      success: result.code == 200,
      message: result.message,
    );
  }

  /// 添加或移除歌单中的歌曲。
  @override
  Future<({bool success, String? message})> manipulateTracks(
    String playlistId,
    String songId, {
    required bool add,
  }) async {
    final result = await _api.playlistManipulateTracks(playlistId, songId, add);
    return (
      success: result.code == 200,
      message: result.message,
    );
  }
}
