import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// 网易云 SDK 使用的 Dio 单例和代理入口。
class Https {
  /// 禁止外部实例化。
  Https._inner();

  static Dio? _dio;
  static DioProxy? _dioProxy;

  /// SDK 请求默认请求头。
  static Map<String, String> optHeader = {};

  /// SDK 共享 Dio 实例。
  static Dio get dio => _dio ??= _createDio();

  /// SDK 共享 Dio 代理。
  static DioProxy get dioProxy => _dioProxy ??= DioProxy();

  /// 测试时替换 SDK 共享 Dio 实例。
  static void setDioForTesting(Dio dio) {
    _dio = dio;
  }

  /// 测试时替换 SDK 共享 Dio 代理。
  static void setDioProxyForTesting(DioProxy dioProxy) {
    _dioProxy = dioProxy;
  }

  /// 为 Dio 安装支持 query proxy option 的 native adapter。
  static void ensureProxyAdapter(Dio dio) {
    if (dio.httpClientAdapter is NeteaseProxyHttpClientAdapter) {
      return;
    }
    dio.httpClientAdapter = NeteaseProxyHttpClientAdapter(
      dio.httpClientAdapter,
    );
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(connectTimeout: const Duration(seconds: 8), headers: optHeader),
    );
    ensureProxyAdapter(dio);
    return dio;
  }
}

/// Dio native adapter wrapper that honors the upstream-compatible `proxy` option.
class NeteaseProxyHttpClientAdapter implements HttpClientAdapter {
  /// Wraps [directAdapter] for non-proxy requests.
  NeteaseProxyHttpClientAdapter(this._directAdapter);

  final HttpClientAdapter _directAdapter;
  final Map<String, IOHttpClientAdapter> _proxyAdapters = {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    final proxy = options.extra['proxy']?.toString().trim();
    if (proxy == null || proxy.isEmpty) {
      return _directAdapter.fetch(options, requestStream, cancelFuture);
    }
    final adapter = _proxyAdapters.putIfAbsent(proxy, () {
      final proxySettings = neteaseProxySettings(proxy);
      if (proxySettings == null) {
        return IOHttpClientAdapter();
      }
      return IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.findProxy = (_) => proxySettings.rule;
          final credentials = proxySettings.credentials;
          if (credentials != null) {
            client.authenticateProxy = (host, port, scheme, realm) {
              if (host != proxySettings.host || port != proxySettings.port) {
                return Future.value(false);
              }
              client.addProxyCredentials(
                host,
                port,
                realm?.toString() ?? '',
                HttpClientBasicCredentials(
                  credentials.username,
                  credentials.password,
                ),
              );
              return Future.value(true);
            };
          }
          return client;
        },
      );
    });
    return adapter.fetch(options, requestStream, cancelFuture);
  }

  @override
  void close({bool force = false}) {
    _directAdapter.close(force: force);
    for (final adapter in _proxyAdapters.values) {
      adapter.close(force: force);
    }
    _proxyAdapters.clear();
  }
}

/// Parsed upstream-compatible proxy settings.
class NeteaseProxySettings {
  /// Creates proxy settings used by the Dio adapter.
  const NeteaseProxySettings({
    required this.rule,
    required this.host,
    required this.port,
    this.credentials,
  });

  /// [HttpClient.findProxy] rule.
  final String rule;

  /// Proxy host.
  final String host;

  /// Proxy port.
  final int port;

  /// Optional proxy credentials.
  final NeteaseProxyCredentials? credentials;
}

/// Basic proxy credentials parsed from the proxy URL user info.
class NeteaseProxyCredentials {
  /// Creates proxy credentials.
  const NeteaseProxyCredentials({
    required this.username,
    required this.password,
  });

  /// Proxy username.
  final String username;

  /// Proxy password.
  final String password;
}

/// Converts an upstream-style proxy URL into a Dart [HttpClient.findProxy] rule.
String? neteaseProxyRule(String? proxy) {
  return neteaseProxySettings(proxy)?.rule;
}

/// Converts an upstream-style proxy URL into Dart proxy settings.
NeteaseProxySettings? neteaseProxySettings(String? proxy) {
  final trimmed = proxy?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  final lower = trimmed.toLowerCase();
  if (lower.contains('pac')) {
    throw UnsupportedError('PAC proxy is not supported by the Dart client.');
  }
  final value = lower.contains('://') ? trimmed : 'http://$trimmed';
  final uri = Uri.tryParse(value);
  if (uri == null || uri.host.isEmpty) {
    throw ArgumentError.value(proxy, 'proxy', 'Invalid proxy URL.');
  }
  final scheme = uri.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') {
    throw UnsupportedError('Only HTTP and HTTPS proxy URLs are supported.');
  }
  final port = uri.hasPort
      ? uri.port
      : scheme == 'https'
          ? 443
          : 80;
  return NeteaseProxySettings(
    rule: 'PROXY ${uri.host}:$port',
    host: uri.host,
    port: port,
    credentials: _proxyCredentials(uri.userInfo),
  );
}

NeteaseProxyCredentials? _proxyCredentials(String userInfo) {
  if (userInfo.isEmpty) {
    return null;
  }
  final splitIndex = userInfo.indexOf(':');
  final username = splitIndex == -1 ? userInfo : userInfo.substring(0, splitIndex);
  final password = splitIndex == -1 ? '' : userInfo.substring(splitIndex + 1);
  return NeteaseProxyCredentials(
    username: Uri.decodeComponent(username),
    password: Uri.decodeComponent(password),
  );
}

/// SDK 请求元数据，允许把请求构造和实际发起分离。
class DioMetaData {
  /// 请求 URI。
  late Uri uri;

  /// 请求体数据。
  dynamic data;

  /// 请求选项。
  Options? options;

  /// 请求方法。
  String method;

  /// 构造阶段产生的错误。
  Error? error;

  /// 创建正常请求元数据。
  DioMetaData(this.uri, {this.data, this.options, this.method = 'POST'});

  /// 创建携带错误的请求元数据。
  DioMetaData.error(this.error) : method = 'POST';
}

/// Dio 调用代理，统一处理 [DioMetaData] 中的延迟错误。
class DioProxy {
  /// 根据元数据中的 HTTP 方法发起 URI 请求。
  Future<Response<T>> requestUri<T>(
    DioMetaData metaData, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final method = metaData.method.toUpperCase();
    if (method == 'GET') {
      return getUri(metaData, cancelToken: cancelToken, onReceiveProgress: onReceiveProgress);
    }
    return postUri(metaData, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);
  }

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
      return await Https.dio.postUri(
        metaData.uri,
        data: metaData.data,
        options: metaData.options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
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
    return Https.dio.getUri(
      metaData.uri,
      options: metaData.options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// 发起 GET 路径请求。
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return Https.dio.get(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onReceiveProgress: onReceiveProgress);
  }

  /// 发起 POST 路径请求。
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return Https.dio.post(
      path,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
