import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/common/netease_api/src/api/bean.dart';
import 'package:bujuan/common/netease_api/src/api/login/bean.dart';
import 'package:bujuan/common/netease_api/src/netease_api.dart';
import 'package:bujuan/core/storage/cache_box.dart';

class AuthRepository {
  bool get hasCachedLogin => CacheBox.instance.get(isLoginSP) == true;

  Future<QrCodeLoginKey> createQrCodeKey() {
    return NeteaseMusicApi().loginQrCodeKey();
  }

  String buildQrCodeUrl(String unikey) {
    return NeteaseMusicApi().loginQrCodeUrl(unikey);
  }

  Future<ServerStatusBean> checkQrCodeStatus(String unikey) {
    return NeteaseMusicApi().loginQrCodeCheck(unikey);
  }

  Future<NeteaseAccountInfoWrap> fetchLoginAccountInfo() {
    return NeteaseMusicApi().loginAccountInfo();
  }

  Future<void> setLoginFlag(bool value) {
    return CacheBox.instance.put(isLoginSP, value);
  }
}
