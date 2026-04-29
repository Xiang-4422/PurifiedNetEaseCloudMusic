import 'package:bujuan/data/netease/netease_auth_remote_data_source.dart';
import 'package:bujuan/features/auth/qr_login_data.dart';
import 'package:bujuan/domain/entities/user_session_data.dart';

import 'auth_state_store.dart';

/// 登录仓库，聚合远程登录接口和本地登录态标记。
class AuthRepository {
  /// 创建登录仓库。
  AuthRepository({
    AuthStateStore? stateStore,
    NeteaseAuthRemoteDataSource? remoteDataSource,
  })  : _stateStore = stateStore ?? const AuthStateStore(),
        _remoteDataSource =
            remoteDataSource ?? const NeteaseAuthRemoteDataSource();

  final AuthStateStore _stateStore;
  final NeteaseAuthRemoteDataSource _remoteDataSource;

  /// 是否存在本地缓存登录标记。
  bool get hasCachedLogin => _stateStore.hasCachedLogin;

  /// 创建二维码登录 key。
  Future<QrCodeCreationResult> createQrCodeKey() async {
    final result = await _remoteDataSource.createQrCodeKey();
    return QrCodeCreationResult(
      success: result.success,
      unikey: result.unikey,
      message: result.message,
    );
  }

  /// 构建二维码登录地址。
  String buildQrCodeUrl(String unikey) {
    return _remoteDataSource.buildQrCodeUrl(unikey);
  }

  /// 检查二维码登录状态。
  Future<QrCodeStatusResult> checkQrCodeStatus(String unikey) async {
    final result = await _remoteDataSource.checkQrCodeStatus(unikey);
    return QrCodeStatusResult(
      code: result.code,
      message: result.message,
    );
  }

  /// 获取当前登录账号信息。
  Future<UserSessionData> fetchLoginAccountInfo() async {
    return _remoteDataSource.fetchLoginAccountInfo();
  }

  /// 保存本地登录标记。
  Future<void> setLoginFlag(bool value) {
    return _stateStore.saveLoginFlag(value);
  }
}
