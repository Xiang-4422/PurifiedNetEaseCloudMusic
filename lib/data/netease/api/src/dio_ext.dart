import 'package:dio/dio.dart';

/// 网易云 SDK 使用的 Dio 单例和代理入口。
class Https {
  /// 禁止外部实例化。
  Https._inner();

  static Dio? _dio;
  static DioProxy? _dioProxy;

  /// SDK 请求默认请求头。
  static Map<String, String> optHeader = {};

  /// SDK 共享 Dio 实例。
  static Dio get dio => _dio ??= Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 8), headers: optHeader));

  /// SDK 共享 Dio 代理。
  static DioProxy get dioProxy => _dioProxy ??= DioProxy();
}

/// SDK 请求元数据，允许把请求构造和实际发起分离。
class DioMetaData {
  /// 请求 URI。
  late Uri uri;

  /// 请求体数据。
  dynamic data;

  /// 请求选项。
  Options? options;

  /// 构造阶段产生的错误。
  Error? error;

  /// 创建正常请求元数据。
  DioMetaData(this.uri, {this.data, this.options});

  /// 创建携带错误的请求元数据。
  DioMetaData.error(this.error);
}

/// Dio 调用代理，统一处理 [DioMetaData] 中的延迟错误。
class DioProxy {
  /// 发起 POST URI 请求。
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

  /// 发起 GET URI 请求。
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

  /// 发起 GET 路径请求。
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

  /// 发起 POST 路径请求。
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
