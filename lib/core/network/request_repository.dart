import 'package:dio/dio.dart';

import '../../data/netease/api/src/dio_ext.dart';

/// 通用请求仓库，隔离底层网易云 API 代理实现。
class RequestRepository {
  /// 发送 POST 请求。
  Future<Response<dynamic>> post(
    DioMetaData dioMetaData, {
    CancelToken? cancelToken,
  }) {
    return Https.dioProxy.postUri(dioMetaData, cancelToken: cancelToken);
  }
}
