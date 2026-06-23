import 'package:bujuan/features/playlist/playlist_artwork_color_service.dart';
import 'package:bujuan/features/playlist/playlist_page_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';

/// Creates page-local playlist dependencies with app-scoped dependencies injected.
class PlaylistPageControllerFactory {
  /// Creates a factory for playlist page controllers.
  const PlaylistPageControllerFactory({
    required PlaylistRepository repository,
    required PlaylistArtworkColorService artworkColorService,
    required List<int> Function() likedSongIds,
    required String Function() currentUserId,
  })  : _repository = repository,
        _artworkColorService = artworkColorService,
        _likedSongIds = likedSongIds,
        _currentUserId = currentUserId;

  final PlaylistRepository _repository;
  final PlaylistArtworkColorService _artworkColorService;
  final List<int> Function() _likedSongIds;
  final String Function() _currentUserId;

  /// Creates a controller owned by a playlist page instance.
  PlaylistPageController create() {
    return PlaylistPageController(
      repository: _repository,
      likedSongIds: _likedSongIds,
      currentUserId: _currentUserId,
    );
  }

  /// Returns the app-scoped artwork color resolver used by playlist pages.
  PlaylistArtworkColorService createArtworkColorService() {
    return _artworkColorService;
  }
}
