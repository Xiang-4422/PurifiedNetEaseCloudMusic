import 'package:bujuan/data/netease/api/netease_music_api.dart';

/// 网易云搜索远程数据源。
class NeteaseSearchRemoteDataSource {
  /// 创建网易云搜索远程数据源。
  NeteaseSearchRemoteDataSource({NeteaseMusicApi? api})
      : _api = api ?? NeteaseMusicApi();

  final NeteaseMusicApi _api;

  /// 获取热门搜索关键词。
  Future<List<String>> fetchHotKeywords() async {
    final wrap = await _api.searchHotKey();
    if (wrap.code != 200) {
      return const [];
    }
    return wrap.result.hots
        .map((item) => item.first ?? '')
        .where((keyword) => keyword.isNotEmpty)
        .toList();
  }
}
