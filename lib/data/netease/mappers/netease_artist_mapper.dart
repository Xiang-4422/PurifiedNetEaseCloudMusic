import 'package:bujuan/data/netease/api/models/play/bean.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/source_type.dart';

/// 网易云歌手 mapper。
class NeteaseArtistMapper {
  /// 禁止实例化网易云歌手 mapper。
  const NeteaseArtistMapper._();

  /// 将网易云歌手模型转换为领域歌手实体。
  static ArtistEntity fromArtist(Artist artist) {
    return ArtistEntity(
      id: 'netease:${artist.id}',
      sourceType: SourceType.netease,
      sourceId: artist.id,
      name: artist.name ?? '',
      artworkUrl: artist.picUrl ?? artist.img1v1Url,
      description: artist.briefDesc,
    );
  }

  /// 将网易云歌手列表转换为领域歌手实体列表。
  static List<ArtistEntity> fromArtistList(List<Artist> artists) {
    return artists.map(fromArtist).toList();
  }
}
