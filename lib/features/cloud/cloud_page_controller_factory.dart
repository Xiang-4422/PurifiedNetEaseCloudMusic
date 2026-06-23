import 'package:bujuan/features/cloud/cloud_page_controller.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';

/// Creates page-local cloud controllers with app-scoped dependencies injected.
class CloudPageControllerFactory {
  /// Creates a factory for cloud page controllers.
  const CloudPageControllerFactory({
    required CloudRepository repository,
    required String Function() currentUserId,
    required List<int> Function() likedSongIds,
  })  : _repository = repository,
        _currentUserId = currentUserId,
        _likedSongIds = likedSongIds;

  final CloudRepository _repository;
  final String Function() _currentUserId;
  final List<int> Function() _likedSongIds;

  /// Creates a controller owned and disposed by the cloud page.
  CloudPageController create({int pageSize = 30}) {
    return CloudPageController(
      repository: _repository,
      userId: _currentUserId(),
      likedSongIds: _likedSongIds,
      pageSize: pageSize,
    );
  }
}
