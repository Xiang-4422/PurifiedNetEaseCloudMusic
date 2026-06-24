import 'package:bujuan/core/entities/liked_song_ids.dart';

/// 本地优先详情页的本地读取函数。
typedef LocalDetailLoader<T> = Future<T?> Function({
  required String id,
  required List<int> likedSongIds,
});

/// 本地优先详情页的远程刷新函数。
typedef RemoteDetailFetcher<T> = Future<T> Function({
  required String id,
  required List<int> likedSongIds,
});

/// 本地优先详情页的初始数据。
class LocalFirstDetailInitialData<T> {
  /// 创建本地优先详情页初始数据。
  const LocalFirstDetailInitialData({
    required this.localDetail,
  });

  /// 可立即展示的本地详情。
  final T? localDetail;

  /// 是否已有本地详情。
  bool get hasLocalDetail => localDetail != null;

  /// 有本地详情时应后台刷新，避免阻塞首屏。
  bool get shouldRefreshInBackground => hasLocalDetail;
}

/// 本地优先详情页控制器，统一处理本地缓存容错和喜欢歌曲上下文。
class LocalFirstDetailController<T> {
  /// 创建本地优先详情页控制器。
  LocalFirstDetailController({
    required LocalDetailLoader<T> loadLocalDetail,
    required RemoteDetailFetcher<T> fetchRemoteDetail,
    required List<int> Function() likedSongIds,
  })  : _loadLocalDetail = loadLocalDetail,
        _fetchRemoteDetail = fetchRemoteDetail,
        _likedSongIds = likedSongIds;

  final LocalDetailLoader<T> _loadLocalDetail;
  final RemoteDetailFetcher<T> _fetchRemoteDetail;
  final List<int> Function() _likedSongIds;

  /// 加载初始详情，优先返回本地缓存。
  Future<LocalFirstDetailInitialData<T>> loadInitialDetail(String id) async {
    return LocalFirstDetailInitialData<T>(
      localDetail: await loadLocalDetail(id),
    );
  }

  /// 从本地缓存加载详情；本地缓存损坏时按无缓存处理。
  Future<T?> loadLocalDetail(String id) async {
    try {
      return await _loadLocalDetail(
        id: id,
        likedSongIds: _likedSongIdsSnapshot(),
      );
    } catch (_) {
      return null;
    }
  }

  /// 从远端刷新详情。
  Future<T> fetchDetail(String id) {
    return _fetchRemoteDetail(
      id: id,
      likedSongIds: _likedSongIdsSnapshot(),
    );
  }

  List<int> _likedSongIdsSnapshot() {
    return normalizeLikedSongIds(_likedSongIds());
  }
}
