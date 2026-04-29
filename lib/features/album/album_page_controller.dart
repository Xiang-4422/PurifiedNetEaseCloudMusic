import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:get/get.dart';

/// 专辑详情页的应用入口，页面只消费详情结果，不直接拼装 repository 参数。
class AlbumPageController {
  AlbumPageController({required AlbumRepository repository})
      : _repository = repository;

  factory AlbumPageController.create() {
    return AlbumPageController(repository: Get.find<AlbumRepository>());
  }

  final AlbumRepository _repository;

  Future<AlbumDetailData?> loadLocalDetail(String albumId) {
    return _repository.loadLocalAlbumDetail(
      albumId: albumId,
      likedSongIds: _likedSongIds,
    );
  }

  Future<AlbumDetailData> fetchDetail(String albumId) {
    return _repository.fetchAlbumDetail(
      albumId: albumId,
      likedSongIds: _likedSongIds,
    );
  }

  List<int> get _likedSongIds => UserLibraryController.to.likedSongIds.toList();
}
