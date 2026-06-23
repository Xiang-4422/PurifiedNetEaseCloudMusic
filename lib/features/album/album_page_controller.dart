import 'package:bujuan/features/album/album_repository.dart';

/// 专辑详情页的应用入口，页面只消费详情结果，不直接拼装 repository 参数。
class AlbumPageController {
  /// 创建专辑详情页控制器。
  AlbumPageController({
    required AlbumRepository repository,
    required List<int> Function() likedSongIds,
  })  : _repository = repository,
        _likedSongIds = likedSongIds;

  final AlbumRepository _repository;
  final List<int> Function() _likedSongIds;

  /// 从本地缓存加载专辑详情。
  Future<AlbumDetailData?> loadLocalDetail(String albumId) async {
    try {
      return await _repository.loadLocalAlbumDetail(
        albumId: albumId,
        likedSongIds: _likedSongIds(),
      );
    } catch (_) {
      return null;
    }
  }

  /// 从远端刷新专辑详情。
  Future<AlbumDetailData> fetchDetail(String albumId) {
    return _repository.fetchAlbumDetail(
      albumId: albumId,
      likedSongIds: _likedSongIds(),
    );
  }
}
