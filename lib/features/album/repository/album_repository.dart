import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/shared/mappers/media_item_mapper.dart';

class AlbumDetailData {
  const AlbumDetailData({
    required this.album,
    required this.albumSongs,
  });

  final Album album;
  final List<MediaItem> albumSongs;
}

class AlbumRepository {
  Future<AlbumDetailData> fetchAlbumDetail({
    required String albumId,
    required List<int> likedSongIds,
  }) async {
    final albumDetail = await NeteaseMusicApi().albumDetail(albumId);
    return AlbumDetailData(
      album: albumDetail.album!,
      albumSongs: MediaItemMapper.fromSong2List(
        albumDetail.songs ?? const [],
        likedSongIds: likedSongIds,
      ),
    );
  }
}
