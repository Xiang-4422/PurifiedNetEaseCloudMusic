import 'dart:async';

import 'package:bujuan/core/network/load_state.dart';
import 'package:bujuan/domain/entities/user_profile_data.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:flutter/foundation.dart';

/// 个人资料页只消费最终用户详情状态，页面不再感知接口路径或请求时机。
class UserProfileController {
  /// 创建用户资料控制器。
  UserProfileController({
    required this.userId,
    required UserRepository repository,
  }) : _repository = repository;

  /// 当前资料页对应的用户 id。
  final String userId;
  final UserRepository _repository;

  /// 用户资料加载状态。
  final ValueNotifier<LoadState<UserProfileData>> state =
      ValueNotifier(const LoadState.loading());

  /// 首次加载用户资料，优先展示缓存并后台刷新。
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

  /// 刷新用户资料。
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

  /// 释放资料页状态监听器。
  void dispose() {
    state.dispose();
  }
}
