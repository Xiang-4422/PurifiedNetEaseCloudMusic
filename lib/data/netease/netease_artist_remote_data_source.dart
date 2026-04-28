import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_album_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_artist_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/track.dart';

class NeteaseArtistRemoteDataSource {
  const NeteaseArtistRemoteDataSource();

  Future<
      ({
        ArtistEntity? artist,
        List<Track> topTracks,
        List<MediaItem> topMediaItems,
        List<AlbumEntity> hotAlbums,
      })> fetchArtistDetail({
    required String artistId,
    required List<int> likedSongIds,
  }) async {
    final artistDetail = await NeteaseMusicApi().artistDetail(artistId);
    final artistSongs = await NeteaseMusicApi().artistTopSongList(artistId);
    final artistAlbums = await NeteaseMusicApi().artistAlbumList(artistId);
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
      topMediaItems: MediaItemMapper.fromTrackList(
        tracks,
        likedSongIds: likedSongIds,
      ),
      hotAlbums: albums,
    );
  }
}
