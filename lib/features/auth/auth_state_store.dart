import 'dart:convert';

import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/data/app_storage/app_cache_keys.dart';
import 'package:bujuan/data/app_storage/app_key_value_store.dart';
import 'package:bujuan/data/app_storage/hive_key_value_store.dart';

/// 登录态本地存储。
class AuthStateStore {
  /// 创建登录态本地存储。
  const AuthStateStore({
    AppKeyValueStore keyValueStore = const HiveKeyValueStore(),
  }) : _keyValueStore = keyValueStore;

  final AppKeyValueStore _keyValueStore;

  bool get _hasLoginFlag => _keyValueStore.get(isLoginSP) == true;

  /// 是否存在可用的本地 session。
  bool get hasCachedSession {
    if (!_hasLoginFlag) {
      return false;
    }
    final raw = _keyValueStore.get(userInfoSp);
    if (raw is! String || raw.isEmpty) {
      return false;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return false;
      }
      final session = UserSessionData.fromJson(Map<String, dynamic>.from(decoded));
      return session.isLoggedIn;
    } catch (_) {
      return false;
    }
  }

  /// 保存本地登录标记。
  Future<void> saveLoginFlag(bool value) {
    return _keyValueStore.put(isLoginSP, value);
  }
}
