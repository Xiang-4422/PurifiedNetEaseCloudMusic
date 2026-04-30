import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_album_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_artist_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';

/// 网易云歌手远程数据源。
class NeteaseArtistRemoteDataSource {
  /// 创建网易云歌手远程数据源。
  NeteaseArtistRemoteDataSource({NeteaseMusicApi? api})
      : _api = api ?? NeteaseMusicApi();

  final NeteaseMusicApi _api;

  /// 获取歌手资料、热门歌曲和热门专辑。
  Future<
      ({
        ArtistEntity? artist,
        List<Track> topTracks,
        List<AlbumEntity> hotAlbums,
      })> fetchArtistDetail({
    required String artistId,
  }) async {
    final artistDetail = await _api.artistDetail(artistId);
    final artistSongs = await _api.artistTopSongList(artistId);
    final artistAlbums = await _api.artistAlbumList(artistId);
    final artist = artistDetail.data?.artist == null
        ? null
        : NeteaseArtistMapper.fromArtist(artistDetail.data!.artist!);
    final tracks =
        NeteaseTrackMapper.fromSong2List(artistSongs.songs ?? const []);
    final albums =
        NeteaseAlbumMapper.fromAlbumList(artistAlbums.hotAlbums ?? const []);
    return (
      artist: artist,
      topTracks: tracks,
      hotAlbums: albums,
    );
  }
}
