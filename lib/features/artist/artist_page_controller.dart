import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/user/user_library_controller.dart';

/// 歌手详情页的应用入口，负责补齐当前用户相关的喜欢歌曲参数。
class ArtistPageController {
  /// 创建歌手详情页控制器。
  ArtistPageController({required ArtistRepository repository})
      : _repository = repository;

  final ArtistRepository _repository;

  /// 从本地缓存加载歌手详情。
  Future<ArtistDetailData?> loadLocalDetail(String artistId) {
    return _repository.loadLocalArtistDetail(
      artistId: artistId,
      likedSongIds: _likedSongIds,
    );
  }

  /// 从远端刷新歌手详情。
  Future<ArtistDetailData> fetchDetail(String artistId) {
    return _repository.fetchArtistDetail(
      artistId: artistId,
      likedSongIds: _likedSongIds,
    );
  }

  List<int> get _likedSongIds => UserLibraryController.to.likedSongIds.toList();
}
