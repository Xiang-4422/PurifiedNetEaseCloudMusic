import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/user/user_library_controller.dart';

/// 歌手详情页的应用入口，负责补齐当前用户相关的喜欢歌曲参数。
class ArtistPageController {
  /// 创建歌手详情页控制器。
  ArtistPageController({
    required ArtistRepository repository,
    List<int> Function()? likedSongIds,
  })  : _repository = repository,
        _likedSongIds = likedSongIds ?? _currentLikedSongIds;

  final ArtistRepository _repository;
  final List<int> Function() _likedSongIds;

  /// 从本地缓存加载歌手详情。
  Future<ArtistDetailData?> loadLocalDetail(String artistId) async {
    try {
      return await _repository.loadLocalArtistDetail(
        artistId: artistId,
        likedSongIds: _likedSongIds(),
      );
    } catch (_) {
      return null;
    }
  }

  /// 从远端刷新歌手详情。
  Future<ArtistDetailData> fetchDetail(String artistId) {
    return _repository.fetchArtistDetail(
      artistId: artistId,
      likedSongIds: _likedSongIds(),
    );
  }

  static List<int> _currentLikedSongIds() {
    return UserLibraryController.to.likedSongIds.toList();
  }
}
