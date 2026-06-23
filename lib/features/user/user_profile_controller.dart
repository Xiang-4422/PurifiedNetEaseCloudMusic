import 'dart:async';

import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/core/entities/user_profile_data.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:flutter/foundation.dart';

/// 个人资料页只消费最终用户详情状态，页面不再感知接口路径或请求时机。
class UserProfileController {
  /// 创建用户资料控制器。
  UserProfileController({
    required this.userId,
    required UserRepository repository,
    required Future<void> Function() logoutCurrentUser,
  })  : _repository = repository,
        _logoutCurrentUser = logoutCurrentUser;

  /// 当前资料页对应的用户 id。
  final String userId;
  final UserRepository _repository;
  final Future<void> Function() _logoutCurrentUser;
  int _loadGeneration = 0;
  bool _disposed = false;

  /// 用户资料加载状态。
  final ValueNotifier<LoadState<UserProfileData>> state = ValueNotifier(const LoadState.loading());

  /// 首次加载用户资料，优先展示缓存并后台刷新。
  Future<void> loadInitial() async {
    final generation = ++_loadGeneration;
    if (userId.isEmpty || userId == '-1') {
      _setStateIfCurrent(generation, const LoadState.empty());
      return;
    }
    final cachedDetail = await _loadCachedUserDetail(userId);
    if (!_isCurrentLoad(generation)) {
      return;
    }
    if (cachedDetail != null && cachedDetail.userId.isNotEmpty) {
      _setStateIfCurrent(generation, LoadState.data(cachedDetail));
      unawaited(refresh());
      return;
    }
    _setStateIfCurrent(generation, const LoadState.loading());
    await _refresh(generation);
  }

  /// 刷新用户资料。
  Future<void> refresh() async {
    await _refresh(++_loadGeneration);
  }

  /// 注销当前登录账号。
  Future<void> logoutCurrentUser() {
    return _logoutCurrentUser();
  }

  Future<void> _refresh(int generation) async {
    if (userId.isEmpty || userId == '-1') {
      _setStateIfCurrent(generation, const LoadState.empty());
      return;
    }
    try {
      final detail = await _repository.fetchUserDetail(userId);
      if (!_isCurrentLoad(generation)) {
        return;
      }
      _setStateIfCurrent(
        generation,
        detail.userId.isEmpty ? const LoadState.empty() : LoadState.data(detail),
      );
    } catch (error, stackTrace) {
      if (!_isCurrentLoad(generation)) {
        return;
      }
      final previousDetail = state.value.data;
      _setStateIfCurrent(
        generation,
        previousDetail == null
            ? LoadState.error(error, stackTrace: stackTrace)
            : LoadState.error(
                error,
                stackTrace: stackTrace,
                data: previousDetail,
              ),
      );
    }
  }

  Future<UserProfileData?> _loadCachedUserDetail(String userId) async {
    try {
      return await _repository.loadCachedUserDetail(userId);
    } catch (_) {
      return null;
    }
  }

  /// 释放资料页状态监听器。
  void dispose() {
    _disposed = true;
    state.dispose();
  }

  bool _isCurrentLoad(int generation) {
    return !_disposed && generation == _loadGeneration;
  }

  void _setStateIfCurrent(
    int generation,
    LoadState<UserProfileData> nextState,
  ) {
    if (_isCurrentLoad(generation)) {
      state.value = nextState;
    }
  }
}
