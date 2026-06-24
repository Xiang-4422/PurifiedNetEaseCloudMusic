import 'package:netease_music_api/netease_music_api.dart';
import 'package:bujuan/core/entities/music_resource_id.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_album_mapper.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_artist_mapper.dart';
import 'package:bujuan/data/music_data/sources/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/track.dart';

/// 网易云歌手远程数据源。
class NeteaseArtistRemoteDataSource implements ArtistRemoteDataSource {
  /// 创建网易云歌手远程数据源。
  NeteaseArtistRemoteDataSource({required NeteaseMusicApi api}) : _api = api;

  final NeteaseMusicApi _api;

  /// 获取歌手资料、热门歌曲和热门专辑。
  @override
  Future<
      ({
        ArtistEntity? artist,
        List<Track> topTracks,
        List<AlbumEntity> hotAlbums,
      })> fetchArtistDetail({
    required String artistId,
  }) async {
    final normalizedArtistId = _normalizedArtistSourceId(artistId);
    if (normalizedArtistId.isEmpty) {
      throw ArgumentError.value(artistId, 'artistId', 'Expected a non-empty netease artist id');
    }
    final artistDetail = await _api.artistDetail(normalizedArtistId);
    final artistSongs = await _api.artistTopSongList(normalizedArtistId);
    final artistAlbums = await _api.artistAlbumList(normalizedArtistId);
    final artist = artistDetail.data?.artist == null ? null : NeteaseArtistMapper.fromArtist(artistDetail.data!.artist!);
    final tracks = NeteaseTrackMapper.fromSong2List(artistSongs.songs ?? const []);
    final albums = NeteaseAlbumMapper.fromAlbumList(artistAlbums.hotAlbums ?? const []);
    return (
      artist: artist,
      topTracks: tracks,
      hotAlbums: albums,
    );
  }

  String _normalizedArtistSourceId(String artistId) {
    final sourceArtistId = MusicResourceId.toNeteaseSourceId(artistId).trim();
    if (sourceArtistId.isEmpty || MusicResourceId.hasKnownPrefix(sourceArtistId)) {
      return '';
    }
    return sourceArtistId;
  }
}
