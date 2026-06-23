import 'package:bujuan/features/user/user_profile_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';

/// Creates page-local user profile controllers with app-scoped dependencies injected.
class UserProfileControllerFactory {
  /// Creates a factory for user profile controllers.
  const UserProfileControllerFactory({
    required UserRepository repository,
    required String Function() currentUserId,
  })  : _repository = repository,
        _currentUserId = currentUserId;

  final UserRepository _repository;
  final String Function() _currentUserId;

  /// Creates a controller owned and disposed by the user profile page.
  UserProfileController create() {
    return UserProfileController(
      userId: _currentUserId(),
      repository: _repository,
    );
  }
}
