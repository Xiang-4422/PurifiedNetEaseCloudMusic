import 'package:bujuan/core/entities/user_profile_data.dart';
import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/features/user/user_profile_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfileController', () {
    test('keeps cached profile when background refresh fails', () async {
      final cachedProfile = _profile('42', nickname: 'cached');
      final repository = _FakeUserRepository(
        cachedProfile: cachedProfile,
        fetchError: StateError('offline'),
      );
      final controller = UserProfileController(
        userId: '42',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      await _flushAsync();

      expect(controller.state.value.status, LoadStatus.error);
      expect(controller.state.value.data, same(cachedProfile));
      expect(controller.state.value.error, isA<StateError>());
    });

    test('uses initial error when no cached profile exists', () async {
      final repository = _FakeUserRepository(
        fetchError: StateError('offline'),
      );
      final controller = UserProfileController(
        userId: '42',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(controller.state.value.status, LoadStatus.error);
      expect(controller.state.value.data, isNull);
      expect(controller.state.value.error, isA<StateError>());
    });
  });
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({
    this.cachedProfile,
    this.fetchError,
  });

  final UserProfileData? cachedProfile;
  final Object? fetchError;

  @override
  Future<UserProfileData?> loadCachedUserDetail(String userId) async {
    return cachedProfile;
  }

  @override
  Future<UserProfileData> fetchUserDetail(String userId) async {
    final error = fetchError;
    if (error != null) {
      throw error;
    }
    return _profile(userId, nickname: 'fresh');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

UserProfileData _profile(String userId, {required String nickname}) {
  return UserProfileData(
    userId: userId,
    nickname: nickname,
    signature: '',
    follows: 1,
    followeds: 2,
    playlistCount: 3,
    avatarUrl: '',
  );
}

Future<void> _flushAsync() async {
  for (var i = 0; i < 4; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
