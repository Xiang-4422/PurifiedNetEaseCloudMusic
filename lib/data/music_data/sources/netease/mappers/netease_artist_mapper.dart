import 'package:netease_music_api/netease_music_api.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/source_type.dart';

/// 网易云歌手 mapper。
class NeteaseArtistMapper {
  /// 禁止实例化网易云歌手 mapper。
  const NeteaseArtistMapper._();

  /// 将网易云歌手模型转换为领域歌手实体。
  static ArtistEntity fromArtist(Artist artist) {
    final artistId = _normalizedArtistId(artist.id);
    return ArtistEntity(
      id: _neteaseArtistEntityId(artistId),
      sourceType: SourceType.netease,
      sourceId: artistId,
      name: artist.name ?? '',
      artworkUrl: artist.picUrl ?? artist.img1v1Url,
      description: artist.briefDesc,
    );
  }

  /// 将网易云歌手列表转换为领域歌手实体列表。
  static List<ArtistEntity> fromArtistList(List<Artist> artists) {
    return artists.where((artist) => _normalizedArtistId(artist.id).isNotEmpty).map(fromArtist).toList();
  }

  static String _neteaseArtistEntityId(String artistId) {
    return artistId.isEmpty ? '' : 'netease:$artistId';
  }

  static String _normalizedArtistId(String id) {
    return id.trim();
  }
}
