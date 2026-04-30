import 'package:bujuan/data/netease/api/models/play/bean.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/source_type.dart';

/// 网易云专辑 mapper。
class NeteaseAlbumMapper {
  /// 禁止实例化网易云专辑 mapper。
  const NeteaseAlbumMapper._();

  /// 将网易云专辑模型转换为领域专辑实体。
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

  /// 将网易云专辑列表转换为领域专辑实体列表。
  static List<AlbumEntity> fromAlbumList(List<Album> albums) {
    return albums.map(fromAlbum).toList();
  }
}
