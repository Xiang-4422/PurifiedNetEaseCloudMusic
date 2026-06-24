import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/features/music_detail/local_first_detail_controller.dart';

export 'package:bujuan/features/album/album_repository.dart' show AlbumDetailData;

/// 专辑详情页初始数据。
typedef AlbumInitialDetailData = LocalFirstDetailInitialData<AlbumDetailData>;

/// 专辑详情页的应用入口，页面只消费详情结果，不直接拼装 repository 参数。
class AlbumPageController {
  /// 创建专辑详情页控制器。
  AlbumPageController({
    required AlbumRepository repository,
    required List<int> Function() likedSongIds,
  }) : _detailController = LocalFirstDetailController<AlbumDetailData>(
          loadLocalDetail: ({required id, required likedSongIds}) {
            return repository.loadLocalAlbumDetail(
              albumId: id,
              likedSongIds: likedSongIds,
            );
          },
          fetchRemoteDetail: ({required id, required likedSongIds}) {
            return repository.fetchAlbumDetail(
              albumId: id,
              likedSongIds: likedSongIds,
            );
          },
          likedSongIds: likedSongIds,
        );

  final LocalFirstDetailController<AlbumDetailData> _detailController;

  /// 加载专辑详情页初始数据。
  Future<AlbumInitialDetailData> loadInitialDetail(String albumId) async {
    return _detailController.loadInitialDetail(albumId);
  }

  /// 从本地缓存加载专辑详情。
  Future<AlbumDetailData?> loadLocalDetail(String albumId) {
    return _detailController.loadLocalDetail(albumId);
  }

  /// 从远端刷新专辑详情。
  Future<AlbumDetailData> fetchDetail(String albumId) {
    return _detailController.fetchDetail(albumId);
  }
}
