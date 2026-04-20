import 'package:bujuan/data/netease/api/src/netease_api.dart';
import 'package:bujuan/features/auth/qr_login_data.dart';
import 'package:bujuan/features/user/user_session_data.dart';

import 'auth_state_store.dart';

class AuthRepository {
  AuthRepository({AuthStateStore? stateStore})
      : _stateStore = stateStore ?? const AuthStateStore();

  final AuthStateStore _stateStore;

  bool get hasCachedLogin => _stateStore.hasCachedLogin;

  Future<QrCodeCreationResult> createQrCodeKey() async {
    final result = await NeteaseMusicApi().loginQrCodeKey();
    return QrCodeCreationResult(
      success: result.code == 200,
      unikey: result.unikey,
      message: result.message,
    );
  }

  String buildQrCodeUrl(String unikey) {
    return NeteaseMusicApi().loginQrCodeUrl(unikey);
  }

  Future<QrCodeStatusResult> checkQrCodeStatus(String unikey) async {
    final result = await NeteaseMusicApi().loginQrCodeCheck(unikey);
    return QrCodeStatusResult(
      code: result.code,
      message: result.message,
    );
  }

  Future<UserSessionData> fetchLoginAccountInfo() async {
    final accountInfo = await NeteaseMusicApi().loginAccountInfo();
    final profile = accountInfo.profile;
    return UserSessionData(
      userId: profile?.userId ?? '',
      nickname: profile?.nickname ?? '',
      avatarUrl: profile?.avatarUrl ?? '',
    );
  }

  Future<void> setLoginFlag(bool value) {
    return _stateStore.saveLoginFlag(value);
  }
}
