import 'package:bujuan/data/netease/api/netease_music_api.dart';

class NeteaseRemoteBootstrap {
  const NeteaseRemoteBootstrap._();

  /// 应用层只需要知道“初始化网易云远程能力”，不应继续知道底层 SDK 文件布局。
  static Future<void> initialize({
    bool debug = true,
  }) {
    return NeteaseMusicApi.init(debug: debug);
  }
}
