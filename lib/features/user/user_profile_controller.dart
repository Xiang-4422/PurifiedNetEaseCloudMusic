import 'package:bujuan/data/netease/api/src/api/user/bean.dart';
import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:flutter/foundation.dart';

/// 个人资料页只消费最终用户详情状态，页面不再感知接口路径或请求时机。
class UserProfileController {
  UserProfileController({
    required this.userId,
    UserRepository? repository,
  }) : _repository = repository ?? UserRepository();

  final String userId;
  final UserRepository _repository;
  final ValueNotifier<LoadState<NeteaseUserDetail>> state =
      ValueNotifier(const LoadState.loading());

  Future<void> loadInitial() async {
    state.value = const LoadState.loading();
    try {
      final detail = await _repository.fetchUserDetail(userId);
      state.value = detail.profile.userId.isEmpty
          ? const LoadState.empty()
          : LoadState.data(detail);
    } catch (error, stackTrace) {
      state.value = LoadState.error(error, stackTrace: stackTrace);
    }
  }

  void dispose() {
    state.dispose();
  }
}
