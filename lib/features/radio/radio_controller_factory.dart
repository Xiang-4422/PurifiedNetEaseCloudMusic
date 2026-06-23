import 'package:bujuan/features/radio/radio_detail_controller.dart';
import 'package:bujuan/features/radio/radio_list_controller.dart';
import 'package:bujuan/features/radio/radio_repository.dart';

/// Creates page-local radio controllers with app-scoped dependencies injected.
class RadioControllerFactory {
  /// Creates a factory for radio list and detail controllers.
  const RadioControllerFactory({
    required RadioRepository repository,
    required String Function() currentUserId,
    required List<int> Function() likedSongIds,
  })  : _repository = repository,
        _currentUserId = currentUserId,
        _likedSongIds = likedSongIds;

  final RadioRepository _repository;
  final String Function() _currentUserId;
  final List<int> Function() _likedSongIds;

  /// Creates a controller owned and disposed by the subscribed radio page.
  RadioListController createList({int pageSize = 30}) {
    return RadioListController(
      userId: _currentUserId(),
      repository: _repository,
      pageSize: pageSize,
    );
  }

  /// Creates a controller owned and disposed by a radio detail page.
  RadioDetailController createDetail({
    required String radioId,
    int pageSize = 30,
    bool asc = true,
  }) {
    return RadioDetailController(
      radioId: radioId,
      userId: _currentUserId(),
      repository: _repository,
      likedSongIds: _likedSongIds,
      pageSize: pageSize,
      asc: asc,
    );
  }
}
