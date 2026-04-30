import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/domain/entities/user_session_data.dart';

/// 集中封装登录相关远程访问，避免 feature 直接持有网易云 API 入口。
class NeteaseAuthRemoteDataSource {
  /// 创建网易云登录远程数据源。
  const NeteaseAuthRemoteDataSource();

  /// 创建二维码登录 key。
  Future<({bool success, String unikey, String? message})>
      createQrCodeKey() async {
    final result = await NeteaseMusicApi().loginQrCodeKey();
    return (
      success: result.code == 200,
      unikey: result.unikey,
      message: result.message,
    );
  }

  /// 构建二维码登录地址。
  String buildQrCodeUrl(String unikey) {
    return NeteaseMusicApi().loginQrCodeUrl(unikey);
  }

  /// 检查二维码登录状态。
  Future<({int code, String? message})> checkQrCodeStatus(String unikey) async {
    final result = await NeteaseMusicApi().loginQrCodeCheck(unikey);
    return (code: result.code, message: result.message);
  }

  /// 获取当前登录账号信息。
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
