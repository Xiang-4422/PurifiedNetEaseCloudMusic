import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';

class AuthStateStore {
  const AuthStateStore();

  bool get hasCachedLogin => CacheBox.instance.get(isLoginSP) == true;

  bool get hasCachedSession {
    final userInfo = CacheBox.instance.get(userInfoSp) as String?;
    return hasCachedLogin && userInfo?.isNotEmpty == true;
  }

  Future<void> saveLoginFlag(bool value) {
    return CacheBox.instance.put(isLoginSP, value);
  }
}
