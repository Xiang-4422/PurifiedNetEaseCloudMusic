import 'package:bujuan/common/netease_api/netease_music_api.dart';

class ExploreRepository {
  Future<PlaylistCatalogueWrap> fetchPlaylistCatalogue() {
    return NeteaseMusicApi().playlistCatalogue();
  }

  Future<MultiPlayListWrap> fetchCategoryPlaylists(String category) {
    return NeteaseMusicApi().categorySongList(category: category);
  }
}
