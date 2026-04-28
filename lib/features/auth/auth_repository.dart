import 'package:bujuan/data/netease/netease_auth_remote_data_source.dart';
import 'package:bujuan/features/auth/qr_login_data.dart';
import 'package:bujuan/domain/entities/user_session_data.dart';

import 'auth_state_store.dart';

class AuthRepository {
  AuthRepository({
    AuthStateStore? stateStore,
    NeteaseAuthRemoteDataSource? remoteDataSource,
  })  : _stateStore = stateStore ?? const AuthStateStore(),
        _remoteDataSource =
            remoteDataSource ?? const NeteaseAuthRemoteDataSource();

  final AuthStateStore _stateStore;
  final NeteaseAuthRemoteDataSource _remoteDataSource;

  bool get hasCachedLogin => _stateStore.hasCachedLogin;

  Future<QrCodeCreationResult> createQrCodeKey() async {
    final result = await _remoteDataSource.createQrCodeKey();
    return QrCodeCreationResult(
      success: result.success,
      unikey: result.unikey,
      message: result.message,
    );
  }

  String buildQrCodeUrl(String unikey) {
    return _remoteDataSource.buildQrCodeUrl(unikey);
  }

  Future<QrCodeStatusResult> checkQrCodeStatus(String unikey) async {
    final result = await _remoteDataSource.checkQrCodeStatus(unikey);
    return QrCodeStatusResult(
      code: result.code,
      message: result.message,
    );
  }

  Future<UserSessionData> fetchLoginAccountInfo() async {
    return _remoteDataSource.fetchLoginAccountInfo();
  }

  Future<void> setLoginFlag(bool value) {
    return _stateStore.saveLoginFlag(value);
  }
}
