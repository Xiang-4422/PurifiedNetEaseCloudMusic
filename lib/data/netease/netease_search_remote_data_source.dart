import 'package:bujuan/data/netease/api/netease_music_api.dart';

class NeteaseSearchRemoteDataSource {
  const NeteaseSearchRemoteDataSource();

  Future<List<String>> fetchHotKeywords() async {
    final wrap = await NeteaseMusicApi().searchHotKey();
    if (wrap.code != 200) {
      return const [];
    }
    return wrap.result.hots
        .map((item) => item.first ?? '')
        .where((keyword) => keyword.isNotEmpty)
        .toList();
  }
}
