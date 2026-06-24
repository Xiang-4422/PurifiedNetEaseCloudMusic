import 'package:netease_music_api/netease_music_api.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/source_type.dart';

/// 网易云专辑 mapper。
class NeteaseAlbumMapper {
  /// 禁止实例化网易云专辑 mapper。
  const NeteaseAlbumMapper._();

  /// 将网易云专辑模型转换为领域专辑实体。
  static AlbumEntity fromAlbum(Album album) {
    final albumId = _normalizedAlbumId(album.id);
    return AlbumEntity(
      id: _neteaseAlbumEntityId(albumId),
      sourceType: SourceType.netease,
      sourceId: albumId,
      title: album.name ?? '',
      artworkUrl: album.picUrl,
      artistNames: {
        if (album.artist?.name?.isNotEmpty ?? false) album.artist!.name!,
        ...(album.artists ?? []).map((artist) => artist.name ?? '').where((name) => name.isNotEmpty),
      }.toList(),
      description: album.description ?? album.briefDesc,
      trackCount: album.size,
      publishTime: album.publishTime,
    );
  }

  /// 将网易云专辑列表转换为领域专辑实体列表。
  static List<AlbumEntity> fromAlbumList(List<Album> albums) {
    return albums.where((album) => _normalizedAlbumId(album.id).isNotEmpty).map(fromAlbum).toList();
  }

  static String _neteaseAlbumEntityId(String albumId) {
    return albumId.isEmpty ? '' : 'netease:$albumId';
  }

  static String _normalizedAlbumId(String id) {
    return id.trim();
  }
}
