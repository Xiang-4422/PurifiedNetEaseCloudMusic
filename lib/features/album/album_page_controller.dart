import 'package:bujuan/features/album/album_repository.dart';

/// 专辑详情页初始数据。
class AlbumInitialDetailData {
  /// 创建专辑详情页初始数据。
  const AlbumInitialDetailData({
    required this.localDetail,
  });

  /// 本地缓存详情。
  final AlbumDetailData? localDetail;

  /// 是否已有本地缓存详情。
  bool get hasLocalDetail => localDetail != null;

  /// 有本地详情时应后台刷新，避免阻塞首屏展示。
  bool get shouldRefreshInBackground => hasLocalDetail;
}

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

  /// 加载专辑详情页初始数据。
  Future<AlbumInitialDetailData> loadInitialDetail(String albumId) async {
    return AlbumInitialDetailData(
      localDetail: await loadLocalDetail(albumId),
    );
  }

  /// 从本地缓存加载专辑详情。
  Future<AlbumDetailData?> loadLocalDetail(String albumId) async {
    try {
      return await _repository.loadLocalAlbumDetail(
        albumId: albumId,
        likedSongIds: _likedSongIdsSnapshot(),
      );
    } catch (_) {
      return null;
    }
  }

  /// 从远端刷新专辑详情。
  Future<AlbumDetailData> fetchDetail(String albumId) {
    return _repository.fetchAlbumDetail(
      albumId: albumId,
      likedSongIds: _likedSongIdsSnapshot(),
    );
  }

  List<int> _likedSongIdsSnapshot() {
    return _likedSongIds().toSet().toList()..sort();
  }
}
