import 'package:bujuan/data/netease/api/src/api/bean.dart';
import 'package:bujuan/data/netease/api/src/api/login/bean.dart';
import 'package:bujuan/data/netease/api/src/netease_api.dart';

import 'auth_state_store.dart';

class AuthRepository {
  AuthRepository({AuthStateStore? stateStore})
      : _stateStore = stateStore ?? const AuthStateStore();

  final AuthStateStore _stateStore;

  bool get hasCachedLogin => _stateStore.hasCachedLogin;

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
    return _stateStore.saveLoginFlag(value);
  }
}
