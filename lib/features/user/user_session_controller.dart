import 'dart:async';
import 'dart:convert';

import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/domain/entities/user_session_data.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// 持有账号 session 与本地登录快照。
class UserSessionController extends GetxController {
  static UserSessionController get to => Get.find();

  UserSessionController({
    required UserRepository repository,
    required Box box,
  })  : _repository = repository,
        _box = box;

  final UserRepository _repository;
  final Box _box;
  Future<void>? _cacheBootstrapFuture;

  final Rx<UserSessionData> userInfo = const UserSessionData.empty().obs;

  Future<void> ensureCacheLoaded() async {
    await (_cacheBootstrapFuture ?? Future<void>.value());
  }

  @override
  void onInit() {
    super.onInit();
    _cacheBootstrapFuture = _loadCache();
    ever<UserSessionData>(userInfo, _persistSession);
  }

  Future<void> clearUser() async {
    final value = await _repository.logout();
    if (value.success) {
      await _clearLocalSession();
      await SettingsController.to.updateLoginStatus(false);
    }
  }

  Future<void> expireLoginSession() async {
    await _clearLocalSession();
    await SettingsController.to.updateLoginStatus(false);
  }

  Future<void> _loadCache() async {
    final String? userInfoStr = _box.get(userInfoSp);
    if (userInfoStr != null) {
      userInfo.value = UserSessionData.fromJson(jsonDecode(userInfoStr));
    }
  }

  Future<void> _persistSession(UserSessionData info) async {
    if (info.isLoggedIn) {
      await _box.put(userInfoSp, jsonEncode(info.toJson()));
    } else {
      await _box.delete(userInfoSp);
    }
  }

  Future<void> _clearLocalSession() async {
    userInfo.value = const UserSessionData.empty();
    await _box.delete(userInfoSp);
  }
}
