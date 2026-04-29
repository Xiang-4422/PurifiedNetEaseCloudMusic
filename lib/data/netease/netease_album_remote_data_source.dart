import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_album_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/track.dart';

class NeteaseAlbumRemoteDataSource {
  const NeteaseAlbumRemoteDataSource();

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
