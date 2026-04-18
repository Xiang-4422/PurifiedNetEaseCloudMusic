import 'package:bujuan/common/netease_api/src/dio_ext.dart';
import 'package:bujuan/common/netease_api/src/netease_handler.dart';

class SearchRepository {
  DioMetaData buildSearchRequest(
    String keyword,
    int type, {
    int offset = 0,
    int limit = 30,
  }) {
    return DioMetaData(
      joinUri('/weapi/cloudsearch/pc'),
      data: {
        's': keyword,
        'type': type,
        'limit': limit,
        'offset': offset,
      },
      options: joinOptions(),
    );
  }

  DioMetaData buildHotKeywordRequest() {
    return DioMetaData(
      joinUri('/weapi/search/hot'),
      data: {'type': 1111},
      options: joinOptions(userAgent: UserAgent.Mobile),
    );
  }
}
