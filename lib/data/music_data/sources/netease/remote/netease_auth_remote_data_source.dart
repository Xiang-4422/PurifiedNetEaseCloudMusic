import 'package:netease_music_api/netease_music_api.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/core/entities/user_session_data.dart';

/// 集中封装登录相关远程访问，避免 feature 直接持有网易云 API 入口。
class NeteaseAuthRemoteDataSource implements AuthRemoteDataSource {
  /// 创建网易云登录远程数据源。
  NeteaseAuthRemoteDataSource({required NeteaseMusicApi api}) : _api = api;

  final NeteaseMusicApi _api;

  /// 创建二维码登录 key。
  @override
  Future<({bool success, String unikey, String? message})> createQrCodeKey() async {
    final result = await _api.loginQrCodeKey();
    final normalizedUnikey = _normalizedUnikey(result.unikey);
    return (
      success: result.code == 200 && normalizedUnikey.isNotEmpty,
      unikey: normalizedUnikey,
      message: result.message,
    );
  }

  /// 构建二维码登录地址。
  @override
  String buildQrCodeUrl(String unikey) {
    final normalizedUnikey = _normalizedUnikey(unikey);
    if (normalizedUnikey.isEmpty) {
      return '';
    }
    return _api.loginQrCodeUrl(normalizedUnikey);
  }

  /// 检查二维码登录状态。
  @override
  Future<({int code, String? message})> checkQrCodeStatus(String unikey) async {
    final normalizedUnikey = _normalizedUnikey(unikey);
    if (normalizedUnikey.isEmpty) {
      return (code: 800, message: 'Expected a non-empty qr code key');
    }
    final result = await _api.loginQrCodeCheck(normalizedUnikey);
    return (code: result.code, message: result.message);
  }

  /// 获取当前登录账号信息。
  @override
  Future<UserSessionData> fetchLoginAccountInfo() async {
    final accountInfo = await _api.loginAccountInfo();
    final profile = accountInfo.profile;
    return UserSessionData(
      userId: profile?.userId ?? '',
      nickname: profile?.nickname ?? '',
      avatarUrl: profile?.avatarUrl ?? '',
    );
  }

  String _normalizedUnikey(String unikey) {
    return unikey.trim();
  }
}
