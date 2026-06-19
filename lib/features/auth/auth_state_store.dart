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

  /// 是否存在本地登录标记。
  bool get hasCachedLogin => _keyValueStore.get(isLoginSP) == true;

  /// 是否存在可用的本地 session。
  bool get hasCachedSession {
    final userInfo = _keyValueStore.get(userInfoSp) as String?;
    return hasCachedLogin && userInfo?.isNotEmpty == true;
  }

  /// 保存本地登录标记。
  Future<void> saveLoginFlag(bool value) {
    return _keyValueStore.put(isLoginSP, value);
  }
}
