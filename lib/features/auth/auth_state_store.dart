import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';

/// 登录态本地存储。
class AuthStateStore {
  /// 创建登录态本地存储。
  const AuthStateStore();

  /// 是否存在本地登录标记。
  bool get hasCachedLogin => CacheBox.instance.get(isLoginSP) == true;

  /// 是否存在可用的本地 session。
  bool get hasCachedSession {
    final userInfo = CacheBox.instance.get(userInfoSp) as String?;
    return hasCachedLogin && userInfo?.isNotEmpty == true;
  }

  /// 保存本地登录标记。
  Future<void> saveLoginFlag(bool value) {
    return CacheBox.instance.put(isLoginSP, value);
  }
}
