import 'dart:convert';

import 'package:bujuan/data/app_storage/app_cache_keys.dart';
import 'package:bujuan/data/app_storage/app_key_value_store.dart';
import 'package:bujuan/data/app_storage/hive_key_value_store.dart';
import 'package:bujuan/core/entities/user_session_data.dart';

/// 持久化当前用户 session 快照，避免用户控制器直接触碰 Hive/CacheBox。
class UserSessionStore {
  /// 创建用户 session 持久化入口。
  const UserSessionStore({
    AppKeyValueStore keyValueStore = const HiveKeyValueStore(),
  }) : _keyValueStore = keyValueStore;

  final AppKeyValueStore _keyValueStore;

  /// 读取本地用户 session 快照。
  UserSessionData? loadSession() {
    final raw = _keyValueStore.get(userInfoSp);
    if (raw is! String || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      final session = UserSessionData.fromJson(Map<String, dynamic>.from(decoded));
      return session.isLoggedIn ? session : null;
    } catch (_) {
      return null;
    }
  }

  /// 保存本地用户 session 快照。
  Future<void> saveSession(UserSessionData info) {
    return _keyValueStore.put(userInfoSp, jsonEncode(info.toJson()));
  }

  /// 清除本地用户 session 快照。
  Future<void> clearSession() {
    return _keyValueStore.delete(userInfoSp);
  }
}
