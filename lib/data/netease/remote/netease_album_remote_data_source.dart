import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_album_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/track.dart';

/// 网易云专辑远程数据源。
class NeteaseAlbumRemoteDataSource {
  /// 创建网易云专辑远程数据源。
  const NeteaseAlbumRemoteDataSource();

  /// 获取专辑详情和专辑曲目。
  Future<
      ({
        AlbumEntity? album,
        List<Track> tracks,
      })> fetchAlbumDetail({
    required String albumId,
  }) async {
    final albumDetail = await NeteaseMusicApi().albumDetail(albumId);
    final album = albumDetail.album == null
        ? null
        : NeteaseAlbumMapper.fromAlbum(albumDetail.album!);
    final tracks =
        NeteaseTrackMapper.fromSong2List(albumDetail.songs ?? const []);
    return (
      album: album,
      tracks: tracks,
    );
  }
}
