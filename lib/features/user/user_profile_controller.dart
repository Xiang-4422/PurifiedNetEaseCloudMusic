import 'dart:async';

import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/user_profile_data.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:flutter/foundation.dart';

/// 个人资料页只消费最终用户详情状态，页面不再感知接口路径或请求时机。
class UserProfileController {
  /// 创建 UserProfileController。
  UserProfileController({
    required this.userId,
    required UserRepository repository,
  }) : _repository = repository;

  /// userId。
  final String userId;
  final UserRepository _repository;

  /// state。
  final ValueNotifier<LoadState<UserProfileData>> state =
      ValueNotifier(const LoadState.loading());

  /// loadInitial。
  Future<void> loadInitial() async {
    final cachedDetail = await _repository.loadCachedUserDetail(userId);
    if (cachedDetail != null && cachedDetail.userId.isNotEmpty) {
      state.value = LoadState.data(cachedDetail);
      unawaited(refresh());
      return;
    }
    state.value = const LoadState.loading();
    await refresh();
  }

  /// refresh。
  Future<void> refresh() async {
    try {
      final detail = await _repository.fetchUserDetail(userId);
      state.value = detail.userId.isEmpty
          ? const LoadState.empty()
          : LoadState.data(detail);
    } catch (error, stackTrace) {
      if (state.value.data != null) {
        return;
      }
      state.value = LoadState.error(error, stackTrace: stackTrace);
    }
  }

  /// dispose。
  void dispose() {
    state.dispose();
  }
}
