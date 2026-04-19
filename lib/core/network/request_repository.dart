import 'package:dio/dio.dart';

import '../../data/netease/api/src/dio_ext.dart';

class RequestRepository {
  // 通用请求组件只需要一个稳定入口，先在这里隔离底层代理，避免后续继续把 Https 直接扩散到 UI 层。
  Future<Response<dynamic>> post(
    DioMetaData dioMetaData, {
    CancelToken? cancelToken,
  }) {
    return Https.dioProxy.postUri(dioMetaData, cancelToken: cancelToken);
  }
}
