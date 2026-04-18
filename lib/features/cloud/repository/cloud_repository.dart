import 'package:bujuan/common/netease_api/src/dio_ext.dart';
import 'package:bujuan/common/netease_api/src/netease_handler.dart';

class CloudRepository {
  DioMetaData cloudSongDioMetaData({int offset = 0, int limit = 30}) {
    final params = {'limit': limit, 'offset': offset};
    return DioMetaData(
      joinUri('/weapi/v1/cloud/get'),
      data: params,
      options: joinOptions(),
    );
  }
}
