import 'package:bujuan/data/netease/api/src/api/play/bean.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/source_type.dart';

class NeteaseArtistMapper {
  const NeteaseArtistMapper._();

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

  static List<ArtistEntity> fromArtistList(List<Artist> artists) {
    return artists.map(fromArtist).toList();
  }
}
