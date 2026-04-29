import 'package:dio/dio.dart';

/// Https。
class Https {
  Https._inner();

  static Dio? _dio;
  static DioProxy? _dioProxy;

  /// optHeader。
  static Map<String, String> optHeader = {};

  /// dio。
  static Dio get dio => _dio ??= Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 8), headers: optHeader));

  /// dioProxy。
  static DioProxy get dioProxy => _dioProxy ??= DioProxy();
}

/// DioMetaData。
class DioMetaData {
  /// uri。
  late Uri uri;

  /// data。
  dynamic data;

  /// options。
  Options? options;

  /// error。
  Error? error;

  /// 创建 DioMetaData。
  DioMetaData(this.uri, {this.data, this.options});

  /// 创建 DioMetaData。
  DioMetaData.error(this.error);
}

/// DioProxy。
class DioProxy {
  /// 公开成员。
  Future<Response<T>> postUri<T>(
    DioMetaData metaData, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    var error = metaData.error;
    if (error != null) {
      return Future.error(error);
    }
    try {
      return await Https.dio.postUri(metaData.uri,
          data: metaData.data,
          options: metaData.options,
          cancelToken: cancelToken);
    } on DioException catch (e) {
      return Future.error(e);
    }
  }

  /// 公开成员。
  Future<Response<T>> getUri<T>(
    DioMetaData metaData, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    var error = metaData.error;
    if (error != null) {
      return Future.error(error);
    }
    return Https.dio.getUri(metaData.uri, options: metaData.options);
  }

  /// 公开成员。
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return Https.dio.get(path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress);
  }

  /// 公开成员。
  Future<Response<T>> post<T>(
    String path, {
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return Https.dio.post(path,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress);
  }
}
