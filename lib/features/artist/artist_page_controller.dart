import 'package:bujuan/features/artist/artist_repository.dart';

/// 歌手详情页初始数据。
class ArtistInitialDetailData {
  /// 创建歌手详情页初始数据。
  const ArtistInitialDetailData({
    required this.localDetail,
  });

  /// 本地缓存详情。
  final ArtistDetailData? localDetail;

  /// 是否已有本地缓存详情。
  bool get hasLocalDetail => localDetail != null;

  /// 有本地详情时应后台刷新，避免阻塞首屏展示。
  bool get shouldRefreshInBackground => hasLocalDetail;
}

/// 歌手详情页的应用入口，负责补齐当前用户相关的喜欢歌曲参数。
class ArtistPageController {
  /// 创建歌手详情页控制器。
  ArtistPageController({
    required ArtistRepository repository,
    required List<int> Function() likedSongIds,
  })  : _repository = repository,
        _likedSongIds = likedSongIds;

  final ArtistRepository _repository;
  final List<int> Function() _likedSongIds;

  /// 加载歌手详情页初始数据。
  Future<ArtistInitialDetailData> loadInitialDetail(String artistId) async {
    return ArtistInitialDetailData(
      localDetail: await loadLocalDetail(artistId),
    );
  }

  /// 从本地缓存加载歌手详情。
  Future<ArtistDetailData?> loadLocalDetail(String artistId) async {
    try {
      return await _repository.loadLocalArtistDetail(
        artistId: artistId,
        likedSongIds: _likedSongIdsSnapshot(),
      );
    } catch (_) {
      return null;
    }
  }

  /// 从远端刷新歌手详情。
  Future<ArtistDetailData> fetchDetail(String artistId) {
    return _repository.fetchArtistDetail(
      artistId: artistId,
      likedSongIds: _likedSongIdsSnapshot(),
    );
  }

  List<int> _likedSongIdsSnapshot() {
    return _likedSongIds().toSet().toList()..sort();
  }
}
