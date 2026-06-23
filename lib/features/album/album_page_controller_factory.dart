import 'package:bujuan/features/album/album_page_controller.dart';
import 'package:bujuan/features/album/album_repository.dart';

/// Creates page-local album detail controllers with app-scoped dependencies injected.
class AlbumPageControllerFactory {
  /// Creates a factory for album detail page controllers.
  const AlbumPageControllerFactory({
    required AlbumRepository repository,
    required List<int> Function() likedSongIds,
  })  : _repository = repository,
        _likedSongIds = likedSongIds;

  final AlbumRepository _repository;
  final List<int> Function() _likedSongIds;

  /// Creates a controller owned by one album detail page.
  AlbumPageController create() {
    return AlbumPageController(
      repository: _repository,
      likedSongIds: _likedSongIds,
    );
  }
}
