import 'dart:async';

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

    test('falls back to remote profile when cached profile read fails', () async {
      final repository = _FakeUserRepository(
        cacheError: StateError('broken profile cache'),
      );
      final controller = UserProfileController(
        userId: '42',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(controller.state.value.status, LoadStatus.data);
      expect(controller.state.value.data?.nickname, 'fresh');
      expect(controller.state.value.error, isNull);
    });

    test('uses remote error when cached profile read and refresh both fail', () async {
      final remoteError = StateError('offline');
      final repository = _FakeUserRepository(
        cacheError: StateError('broken profile cache'),
        fetchError: remoteError,
      );
      final controller = UserProfileController(
        userId: '42',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(controller.state.value.status, LoadStatus.error);
      expect(controller.state.value.data, isNull);
      expect(controller.state.value.error, same(remoteError));
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

    test('ignores stale profile refresh after newer refresh completes', () async {
      final repository = _FakeUserRepository(delayFetches: true);
      final controller = UserProfileController(
        userId: '42',
        repository: repository,
      );
      addTearDown(controller.dispose);

      final oldRefresh = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      final newRefresh = controller.refresh();
      await Future<void>.delayed(Duration.zero);

      repository.completeFetchAt(
        1,
        _profile('42', nickname: 'fresh'),
      );
      await newRefresh;

      expect(controller.state.value.status, LoadStatus.data);
      expect(controller.state.value.data?.nickname, 'fresh');

      repository.completeFetchAt(
        0,
        _profile('42', nickname: 'stale'),
      );
      await oldRefresh;

      expect(controller.state.value.status, LoadStatus.data);
      expect(controller.state.value.data?.nickname, 'fresh');
    });

    test('ignores profile refresh completion after dispose', () async {
      final repository = _FakeUserRepository(delayFetches: true);
      final controller = UserProfileController(
        userId: '42',
        repository: repository,
      );

      final refresh = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      controller.dispose();

      repository.completeFetchAt(
        0,
        _profile('42', nickname: 'fresh'),
      );

      await refresh;
    });
  });
}

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({
    this.cachedProfile,
    this.cacheError,
    this.fetchError,
    this.delayFetches = false,
  });

  final UserProfileData? cachedProfile;
  final Object? cacheError;
  final Object? fetchError;
  final bool delayFetches;
  final List<Completer<UserProfileData>> _pendingFetches = [];

  @override
  Future<UserProfileData?> loadCachedUserDetail(String userId) async {
    final error = cacheError;
    if (error != null) {
      throw error;
    }
    return cachedProfile;
  }

  @override
  Future<UserProfileData> fetchUserDetail(String userId) async {
    if (delayFetches) {
      final completer = Completer<UserProfileData>();
      _pendingFetches.add(completer);
      return completer.future;
    }
    final error = fetchError;
    if (error != null) {
      throw error;
    }
    return _profile(userId, nickname: 'fresh');
  }

  void completeFetchAt(int index, UserProfileData value) {
    _pendingFetches.removeAt(index).complete(value);
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
