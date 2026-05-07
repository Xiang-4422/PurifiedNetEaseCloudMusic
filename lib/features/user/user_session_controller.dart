import 'dart:async';

import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_store.dart';
import 'package:get/get.dart';

/// 持有账号 session 与本地登录快照。
class UserSessionController extends GetxController {
  /// 当前用户 session 控制器实例。
  static UserSessionController get to => Get.find();

  /// 创建用户 session 控制器。
  UserSessionController({
    required UserRepository repository,
    required UserSessionStore sessionStore,
    required Future<void> Function(bool value) saveLoginFlag,
  })  : _repository = repository,
        _sessionStore = sessionStore,
        _saveLoginFlag = saveLoginFlag;

  final UserRepository _repository;
  final UserSessionStore _sessionStore;
  final Future<void> Function(bool value) _saveLoginFlag;
  Future<void>? _cacheBootstrapFuture;

  /// 当前登录用户快照。
  final Rx<UserSessionData> userInfo = const UserSessionData.empty().obs;

  /// 等待本地 session 缓存启动加载完成。
  Future<void> ensureCacheLoaded() async {
    await (_cacheBootstrapFuture ?? Future<void>.value());
  }

  @override
  void onInit() {
    super.onInit();
    _cacheBootstrapFuture = _loadCache();
    ever<UserSessionData>(userInfo, _persistSession);
  }

  /// 远程登出成功后清空本地 session。
  Future<void> clearUser() async {
    final value = await _repository.logout();
    if (value.success) {
      await _clearLocalSession();
      await _saveLoginFlag(false);
    }
  }

  /// 标记登录已过期，并直接清空本地 session。
  Future<void> expireLoginSession() async {
    await _clearLocalSession();
    await _saveLoginFlag(false);
  }

  Future<void> _loadCache() async {
    final cachedSession = _sessionStore.loadSession();
    if (cachedSession != null) {
      userInfo.value = cachedSession;
    }
  }

  Future<void> _persistSession(UserSessionData info) async {
    if (info.isLoggedIn) {
      await _sessionStore.saveSession(info);
    } else {
      await _sessionStore.clearSession();
    }
  }

  Future<void> _clearLocalSession() async {
    userInfo.value = const UserSessionData.empty();
    await _sessionStore.clearSession();
  }
}
