import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';

class AuthStateStore {
  const AuthStateStore();

  bool get hasCachedLogin => CacheBox.instance.get(isLoginSP) == true;

  Future<void> saveLoginFlag(bool value) {
    return CacheBox.instance.put(isLoginSP, value);
  }
}
