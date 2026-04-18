import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/netease_api/src/api/play/bean.dart';
import 'package:bujuan/common/netease_api/src/netease_api.dart';
import 'package:bujuan/shared/mappers/media_item_mapper.dart';

class ArtistDetailData {
  const ArtistDetailData({
    required this.artist,
    required this.topSongs,
    required this.hotAlbums,
  });

  final Artist artist;
  final List<MediaItem> topSongs;
  final List<Album> hotAlbums;
}

class ArtistRepository {
  Future<ArtistDetailData> fetchArtistDetail({
    required String artistId,
    required List<int> likedSongIds,
  }) async {
    final artistDetail = await NeteaseMusicApi().artistDetail(artistId);
    final artistSongs = await NeteaseMusicApi().artistTopSongList(artistId);
    final artistAlbums = await NeteaseMusicApi().artistAlbumList(artistId);

    return ArtistDetailData(
      artist: artistDetail.data!.artist!,
      topSongs: MediaItemMapper.fromSong2List(
        artistSongs.songs ?? const [],
        likedSongIds: likedSongIds,
      ),
      hotAlbums: artistAlbums.hotAlbums ?? const [],
    );
  }
}
