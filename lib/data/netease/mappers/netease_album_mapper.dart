import 'package:bujuan/data/netease/api/src/api/play/bean.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/source_type.dart';

class NeteaseAlbumMapper {
  const NeteaseAlbumMapper._();

  static AlbumEntity fromAlbum(Album album) {
    return AlbumEntity(
      id: 'netease:${album.id}',
      sourceType: SourceType.netease,
      sourceId: album.id,
      title: album.name ?? '',
      artworkUrl: album.picUrl,
      artistNames: {
        if (album.artist?.name?.isNotEmpty ?? false) album.artist!.name!,
        ...(album.artists ?? [])
            .map((artist) => artist.name ?? '')
            .where((name) => name.isNotEmpty),
      }.toList(),
      description: album.description ?? album.briefDesc,
      trackCount: album.size,
      publishTime: album.publishTime,
    );
  }

  static List<AlbumEntity> fromAlbumList(List<Album> albums) {
    return albums.map(fromAlbum).toList();
  }
}
