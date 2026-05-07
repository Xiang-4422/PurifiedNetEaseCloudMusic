import 'package:bujuan/data/music_data/sources/netease/api/netease_music_api.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/core/entities/track.dart';

/// 云盘远程访问先集中在 data/music_data/sources/netease，避免 feature 继续直接触碰平台 API。
class NeteaseCloudRemoteDataSource {
  /// 创建网易云云盘远程数据源。
  NeteaseCloudRemoteDataSource({required NeteaseMusicApi api}) : _api = api;

  final NeteaseMusicApi _api;

  /// 分页获取云盘歌曲。
  Future<({List<Track> tracks, int itemCount})> fetchCloudSongs({
    required int offset,
    required int limit,
  }) {
    return _api.cloudSong(offset: offset, limit: limit).then((wrap) {
      final songs = wrap.data ?? const [];
      final tracks = NeteaseTrackMapper.fromCloudSongList(songs);
      return (
        tracks: tracks,
        itemCount: songs.length,
      );
    });
  }
}
