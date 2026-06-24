import 'package:netease_music_api/netease_music_api.dart';
import 'package:bujuan/core/entities/music_resource_id.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_album_mapper.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/track.dart';

/// 网易云专辑远程数据源。
class NeteaseAlbumRemoteDataSource implements AlbumRemoteDataSource {
  /// 创建网易云专辑远程数据源。
  NeteaseAlbumRemoteDataSource({required NeteaseMusicApi api}) : _api = api;

  final NeteaseMusicApi _api;

  /// 获取专辑详情和专辑曲目。
  @override
  Future<
      ({
        AlbumEntity? album,
        List<Track> tracks,
      })> fetchAlbumDetail({
    required String albumId,
  }) async {
    final normalizedAlbumId = _normalizedAlbumSourceId(albumId);
    if (normalizedAlbumId.isEmpty) {
      throw ArgumentError.value(albumId, 'albumId', 'Expected a non-empty netease album id');
    }
    final albumDetail = await _api.albumDetail(normalizedAlbumId);
    final album = albumDetail.album == null ? null : NeteaseAlbumMapper.fromAlbum(albumDetail.album!);
    final tracks = NeteaseTrackMapper.fromSong2List(albumDetail.songs ?? const []);
    return (
      album: album,
      tracks: tracks,
    );
  }

  String _normalizedAlbumSourceId(String albumId) {
    final sourceAlbumId = MusicResourceId.toNeteaseSourceId(albumId).trim();
    if (sourceAlbumId.isEmpty || MusicResourceId.hasKnownPrefix(sourceAlbumId)) {
      return '';
    }
    return sourceAlbumId;
  }
}
