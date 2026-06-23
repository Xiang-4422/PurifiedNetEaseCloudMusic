import 'package:bujuan/features/artist/artist_page_controller.dart';
import 'package:bujuan/features/artist/artist_repository.dart';

/// Creates page-local artist detail controllers with app-scoped dependencies injected.
class ArtistPageControllerFactory {
  /// Creates a factory for artist detail page controllers.
  const ArtistPageControllerFactory({
    required ArtistRepository repository,
    required List<int> Function() likedSongIds,
  })  : _repository = repository,
        _likedSongIds = likedSongIds;

  final ArtistRepository _repository;
  final List<int> Function() _likedSongIds;

  /// Creates a controller owned by one artist detail page.
  ArtistPageController create() {
    return ArtistPageController(
      repository: _repository,
      likedSongIds: _likedSongIds,
    );
  }
}
