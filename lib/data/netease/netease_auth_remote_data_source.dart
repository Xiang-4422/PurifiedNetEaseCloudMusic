import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/features/user/user_session_data.dart';

/// 集中封装登录相关远程访问，避免 feature 直接持有网易云 API 入口。
class NeteaseAuthRemoteDataSource {
  const NeteaseAuthRemoteDataSource();

  Future<({bool success, String unikey, String? message})> createQrCodeKey() async {
    final result = await NeteaseMusicApi().loginQrCodeKey();
    return (
      success: result.code == 200,
      unikey: result.unikey,
      message: result.message,
    );
  }

  String buildQrCodeUrl(String unikey) {
    return NeteaseMusicApi().loginQrCodeUrl(unikey);
  }

  Future<({int code, String? message})> checkQrCodeStatus(String unikey) async {
    final result = await NeteaseMusicApi().loginQrCodeCheck(unikey);
    return (code: result.code, message: result.message);
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
}
