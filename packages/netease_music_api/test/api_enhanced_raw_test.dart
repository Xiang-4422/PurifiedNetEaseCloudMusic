import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/src/client/dio_ext.dart';
import 'package:netease_music_api/src/client/netease_handler.dart';
import 'package:netease_music_api/src/endpoints/raw/api_enhanced_raw.dart';
import 'package:netease_music_api/src/generated/api_enhanced_modules.g.dart';

void main() {
  group('ApiEnhancedRaw manifest', () {
    late _RawApi api;

    setUp(() {
      api = _RawApi();
    });

    test('covers every upstream module', () {
      final moduleDir = _findUpstreamModuleDir();
      final upstreamModules = moduleDir.listSync().whereType<File>().where((file) => file.path.endsWith('.js')).map((file) => file.uri.pathSegments.last.replaceFirst('.js', '')).toSet();

      expect(apiEnhancedModuleByName.keys.toSet(), upstreamModules);
      expect(apiEnhancedModules, hasLength(upstreamModules.length));
    });

    test('generated method names are unique', () {
      final methodNames = apiEnhancedModules.map((module) => module.methodName).toList();

      expect(methodNames.toSet(), hasLength(methodNames.length));
    });

    test('normal modules build request metadata', () {
      final normalModules = apiEnhancedModules.where((module) => !module.special);

      for (final module in normalModules) {
        final metaData = api.requestModuleDioMetaData(module.module, {
          'id': '1',
          'uid': '2',
          't': 'subscribe',
          'type': '0',
          'threadId': 'R_SO_4_1',
          'year': '2025',
          'key': 'summary',
        });

        expect(metaData.uri.path, isNotEmpty, reason: module.module);
        expect(metaData.method, anyOf('GET', 'POST'), reason: module.module);
        expect(metaData.options, isNotNull, reason: module.module);
      }
    });

    test('special modules are marked for manual override', () {
      final specialModules = apiEnhancedModules.where((module) => module.special).map((module) => module.module).toSet();

      expect(specialModules, {
        'api',
        'audio_match',
        'avatar_upload',
        'cloud',
        'cloud_upload_complete',
        'cloud_upload_token',
        'decrypt',
        'eapi_decrypt',
        'inner_version',
        'login_qr_create',
        'playlist_cover_update',
        'register_anonimous',
        'register_xeapikey',
        'related_playlist',
        'song_url_match',
        'song_url_ncmget',
        'song_url_v1',
        'vip_sign_history',
        'vip_tasks_v1',
        'voice_upload',
      });
    });

    test('normal modules use supported crypto and concrete paths', () {
      const supportedCrypto = {'weapi', 'eapi', 'linuxapi', 'api', 'xeapi'};

      for (final module in apiEnhancedModules.where((module) => !module.special)) {
        expect(module.pathTemplate, isNotEmpty, reason: module.module);
        expect(supportedCrypto, contains(module.crypto), reason: module.module);
      }
    });

    test('modules that require xeapi-specific data shaping are explicit special modules', () {
      final xeapiModules = apiEnhancedModules.where((module) => module.crypto == 'xeapi').toList();

      expect(xeapiModules.map((module) => module.module), containsAll(['register_anonimous', 'song_url_v1', 'vip_sign_history', 'vip_tasks_v1']));
      expect(xeapiModules.every((module) => module.special), isTrue);
    });

    test('modules without request path are explicit special modules', () {
      final pathlessModules = apiEnhancedModules.where((module) => module.pathTemplate.isEmpty).toList();

      expect(pathlessModules, isNotEmpty);
      expect(pathlessModules.every((module) => module.special), isTrue);
    });
  });

  group('ApiEnhancedRaw metadata', () {
    late _RawApi api;

    setUp(() {
      api = _RawApi();
    });

    test('maps crypto options', () {
      expect(api.requestModuleDioMetaData('album', {'id': '1'}).options!.extra!['encryptType'], EncryptType.WeApi);
      expect(api.requestModuleDioMetaData('album_privilege', {'id': '1'}).options!.extra!['encryptType'], EncryptType.EApi);
      expect(api.requestModuleDioMetaData('login', {'crypto': 'api'}).options!.extra!['encryptType'], EncryptType.Api);
      expect(api.requestModuleDioMetaData('login', {'crypto': 'linuxapi'}).options!.extra!['encryptType'], EncryptType.LinuxForward);
      expect(api.requestModuleDioMetaData('album', {'id': '1', 'crypto': 'xeapi'}).options!.extra!['encryptType'], EncryptType.XeApi);
    });

    test('xeapi metadata uses interface3 domain', () {
      final metaData = api.requestModuleDioMetaData('album', {'id': '1', 'crypto': 'xeapi'});

      expect(metaData.uri.toString(), 'https://interface3.music.163.com/api/v1/album/1');
    });

    test('maps request options', () {
      final metaData = api.requestModuleDioMetaData('album', {
        'id': '1',
        'realIP': '1.2.3.4',
        'ua': 'unit-test',
        'domain': 'https://example.test',
        'checkToken': true,
        'proxy': 'http://127.0.0.1:8080',
        'cookie': {'MUSIC_U': 'token'},
      });

      expect(metaData.uri.toString(), 'https://example.test/api/v1/album/1');
      expect(metaData.options!.extra!['realIP'], '1.2.3.4');
      expect(metaData.options!.extra!['rawUserAgent'], 'unit-test');
      expect(metaData.options!.extra!['domain'], 'https://example.test');
      expect(metaData.options!.extra!['checkToken'], isTrue);
      expect(metaData.options!.extra!['proxy'], 'http://127.0.0.1:8080');
      expect(metaData.options!.extra!['cookies'], {'MUSIC_U': 'token'});
    });

    test('maps proxy option to native proxy rules', () {
      expect(neteaseProxyRule('http://127.0.0.1:8080'), 'PROXY 127.0.0.1:8080');
      expect(neteaseProxyRule('https://proxy.example.test'), 'PROXY proxy.example.test:443');
      expect(neteaseProxyRule('127.0.0.1:8080'), 'PROXY 127.0.0.1:8080');
      expect(neteaseProxyRule(''), isNull);
    });

    test('reports unsupported proxy forms explicitly', () {
      expect(() => neteaseProxyRule('http://example.test/proxy.pac'), throwsUnsupportedError);
      expect(() => neteaseProxyRule('http://user:pass@127.0.0.1:8080'), throwsUnsupportedError);
      expect(() => neteaseProxyRule('socks5://127.0.0.1:1080'), throwsUnsupportedError);
    });

    test('installs proxy-aware Dio adapter once', () {
      final dio = Dio();
      Https.ensureProxyAdapter(dio);
      final adapter = dio.httpClientAdapter;

      expect(adapter, isA<NeteaseProxyHttpClientAdapter>());

      Https.ensureProxyAdapter(dio);
      expect(identical(dio.httpClientAdapter, adapter), isTrue);
    });

    test('maps randomCNIP to a generated real IP', () {
      final metaData = api.requestModuleDioMetaData('album', {
        'id': '1',
        'randomCNIP': true,
      });
      final realIP = metaData.options!.extra!['realIP'];

      expect(realIP, isA<String>());
      expect(_isIpv4(realIP as String), isTrue);
      expect(metaData.options!.extra!['randomCNIP'], isTrue);
    });

    test('keeps explicit realIP before randomCNIP', () {
      final metaData = api.requestModuleDioMetaData('album', {
        'id': '1',
        'realIP': '1.2.3.4',
        'randomCNIP': true,
      });

      expect(metaData.options!.extra!['realIP'], '1.2.3.4');
    });

    test('maps dynamic path templates', () {
      final album = api.requestModuleDioMetaData('album', {'id': '456'});
      expect(album.uri.path, '/api/v1/album/456');
    });

    test('DioProxy dispatches request metadata by method', () async {
      final proxy = _RecordingDioProxy();

      await proxy.requestUri(DioMetaData(Uri.parse('https://example.test/get'), method: 'GET'));
      expect(proxy.called, 'GET');

      await proxy.requestUri(DioMetaData(Uri.parse('https://example.test/post')));
      expect(proxy.called, 'POST');
    });

    test('eapi decrypt reports missing input', () {
      expect(api.eapiDecrypt({}), {'code': 400, 'message': 'data is required'});
    });

    test('eapi decrypt decodes request and response payloads', () {
      final requestHex = _encryptEapiText('/api/test-36cd479b6b5-{"id":1}-36cd479b6b5-digest');
      final responseHex = _encryptEapiText('{"code":200,"ok":true}');

      expect(api.eapiDecrypt({'hexString': requestHex})['data'], {
        'url': '/api/test',
        'data': {'id': 1},
      });
      expect(api.eapiDecrypt({'hexString': responseHex, 'isReq': 'false'})['data'], {
        'code': 200,
        'ok': true,
      });
    });

    test('song url v1 special module rewrites upstream xeapi data shape', () async {
      final proxy = _CaptureDioProxy();
      Https.setDioProxyForTesting(proxy);

      await api.songUrlV1Raw({'id': '123', 'level': 'sky'});

      expect(proxy.metaData!.uri.toString(), 'https://interface3.music.163.com/api/song/enhance/player/url/v1');
      expect(proxy.metaData!.options!.extra!['encryptType'], EncryptType.XeApi);
      expect(proxy.metaData!.data, {
        'ids': '[123]',
        'level': 'sky',
        'encodeType': 'flac',
        'immerseType': 'c51',
      });
    });

    test('image upload special module uses token allocation and binary upload', () async {
      final proxy = _UploadDioProxy();
      final adapter = _UploadAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      Https.setDioProxyForTesting(proxy);
      Https.setDioForTesting(dio);

      final result = await api.avatarUpload({
        'filename': 'avatar.jpg',
        'bytes': [1, 2, 3],
      });

      expect(proxy.paths, ['/api/nos/token/alloc', '/api/user/avatar/upload/v1']);
      expect(adapter.uploadUrl, contains('https://nosup-hz1.127.net/yyimgs/object-key'));
      expect(adapter.uploadToken, 'upload-token');
      expect(result['data']['imgId'], 123);
      expect(result['data']['code'], 200);
    });
  });
}

class _RawApi with ApiEnhancedRaw {}

Directory _findUpstreamModuleDir() {
  var current = Directory.current;
  for (var i = 0; i < 5; i++) {
    final candidate = Directory('${current.path}/third_party/api-enhanced/module');
    if (candidate.existsSync()) {
      return candidate;
    }
    current = current.parent;
  }
  throw StateError('Cannot find third_party/api-enhanced/module');
}

class _RecordingDioProxy extends DioProxy {
  String? called;

  @override
  Future<Response<T>> getUri<T>(
    DioMetaData metaData, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    called = 'GET';
    return Response<T>(requestOptions: RequestOptions(path: metaData.uri.toString()));
  }

  @override
  Future<Response<T>> postUri<T>(
    DioMetaData metaData, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    called = 'POST';
    return Response<T>(requestOptions: RequestOptions(path: metaData.uri.toString()));
  }
}

class _UploadDioProxy extends DioProxy {
  final paths = <String>[];

  @override
  Future<Response<T>> postUri<T>(
    DioMetaData metaData, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    paths.add(metaData.uri.path);
    if (metaData.uri.path == '/api/nos/token/alloc') {
      return Response<T>(
        requestOptions: RequestOptions(path: metaData.uri.toString()),
        data: {
          'result': {
            'objectKey': 'object-key',
            'token': 'upload-token',
            'docId': 123,
          }
        } as T,
      );
    }
    return Response<T>(
      requestOptions: RequestOptions(path: metaData.uri.toString()),
      data: {'code': 200} as T,
    );
  }
}

class _CaptureDioProxy extends DioProxy {
  DioMetaData? metaData;

  @override
  Future<Response<T>> postUri<T>(
    DioMetaData metaData, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    this.metaData = metaData;
    return Response<T>(
      requestOptions: RequestOptions(path: metaData.uri.toString()),
      data: {'code': 200} as T,
    );
  }
}

class _UploadAdapter implements HttpClientAdapter {
  String? uploadUrl;
  String? uploadToken;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    uploadUrl = options.uri.toString();
    uploadToken = options.headers['x-nos-token']?.toString();
    return ResponseBody.fromString('{"code":200}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

String _encryptEapiText(String text) {
  final encrypter = Encrypter(AES(Key.fromUtf8('e82ckenh8dichen8'), mode: AESMode.ecb));
  return encrypter.encrypt(text, iv: IV.fromLength(0)).base16;
}

bool _isIpv4(String value) {
  final parts = value.split('.');
  if (parts.length != 4) {
    return false;
  }
  return parts.every((part) {
    final parsed = int.tryParse(part);
    return parsed != null && parsed >= 0 && parsed <= 255;
  });
}
