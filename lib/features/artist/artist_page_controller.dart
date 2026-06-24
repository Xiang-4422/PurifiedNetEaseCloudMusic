import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/music_detail/local_first_detail_controller.dart';

export 'package:bujuan/features/artist/artist_repository.dart' show ArtistDetailData;

/// 歌手详情页初始数据。
typedef ArtistInitialDetailData = LocalFirstDetailInitialData<ArtistDetailData>;

/// 歌手详情页的应用入口，负责补齐当前用户相关的喜欢歌曲参数。
class ArtistPageController {
  /// 创建歌手详情页控制器。
  ArtistPageController({
    required ArtistRepository repository,
    required List<int> Function() likedSongIds,
  }) : _detailController = LocalFirstDetailController<ArtistDetailData>(
          loadLocalDetail: ({required id, required likedSongIds}) {
            return repository.loadLocalArtistDetail(
              artistId: id,
              likedSongIds: likedSongIds,
            );
          },
          fetchRemoteDetail: ({required id, required likedSongIds}) {
            return repository.fetchArtistDetail(
              artistId: id,
              likedSongIds: likedSongIds,
            );
          },
          likedSongIds: likedSongIds,
        );

  final LocalFirstDetailController<ArtistDetailData> _detailController;

  /// 加载歌手详情页初始数据。
  Future<ArtistInitialDetailData> loadInitialDetail(String artistId) async {
    return _detailController.loadInitialDetail(artistId);
  }

  /// 从本地缓存加载歌手详情。
  Future<ArtistDetailData?> loadLocalDetail(String artistId) {
    return _detailController.loadLocalDetail(artistId);
  }

  /// 从远端刷新歌手详情。
  Future<ArtistDetailData> fetchDetail(String artistId) {
    return _detailController.fetchDetail(artistId);
  }
}
