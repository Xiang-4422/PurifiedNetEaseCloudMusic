import 'package:bujuan/data/netease/api/netease_music_api.dart';

/// 网易云远程能力初始化入口。
class NeteaseRemoteBootstrap {
  /// 禁止实例化网易云远程初始化入口。
  const NeteaseRemoteBootstrap._();

  /// 应用层只需要知道“初始化网易云远程能力”，不应继续知道底层 SDK 文件布局。
  static Future<void> initialize({
    bool debug = false,
  }) {
    return NeteaseMusicApi.init(debug: debug);
  }
}
