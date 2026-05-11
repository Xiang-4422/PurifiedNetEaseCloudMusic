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
      expect(apiEnhancedModuleByName['api']?.special, isTrue);
      expect(apiEnhancedModuleByName['eapi_decrypt']?.special, isTrue);
      expect(apiEnhancedModuleByName['avatar_upload']?.special, isTrue);
      expect(apiEnhancedModuleByName['playlist_cover_update']?.special, isTrue);
      expect(apiEnhancedModuleByName['cloud']?.special, isTrue);
      expect(apiEnhancedModuleByName['cloud_upload_token']?.special, isTrue);
      expect(apiEnhancedModuleByName['cloud_upload_complete']?.special, isTrue);
      expect(apiEnhancedModuleByName['voice_upload']?.special, isTrue);
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
    });

    test('maps request options', () {
      final metaData = api.requestModuleDioMetaData('album', {
        'id': '1',
        'realIP': '1.2.3.4',
        'ua': 'unit-test',
        'domain': 'https://example.test',
        'checkToken': true,
        'cookie': {'MUSIC_U': 'token'},
      });

      expect(metaData.uri.toString(), 'https://example.test/api/v1/album/1');
      expect(metaData.options!.extra!['realIP'], '1.2.3.4');
      expect(metaData.options!.extra!['rawUserAgent'], 'unit-test');
      expect(metaData.options!.extra!['domain'], 'https://example.test');
      expect(metaData.options!.extra!['checkToken'], isTrue);
      expect(metaData.options!.extra!['cookies'], {'MUSIC_U': 'token'});
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
      expect(api.eapiDecrypt({}), {'code': 400, 'message': 'hex string is required'});
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
