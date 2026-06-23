import 'package:netease_music_api/netease_music_api.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';

/// 网易云搜索远程数据源。
class NeteaseSearchRemoteDataSource implements SearchRemoteDataSource {
  /// 创建网易云搜索远程数据源。
  NeteaseSearchRemoteDataSource({required NeteaseMusicApi api}) : _api = api;

  final NeteaseMusicApi _api;

  /// 获取热门搜索关键词。
  @override
  Future<List<String>> fetchHotKeywords() async {
    final wrap = await _api.searchHotKey();
    if (wrap.code != 200) {
      return const [];
    }
    return wrap.result.hots.map((item) => item.first ?? '').where((keyword) => keyword.isNotEmpty).toList();
  }
}
