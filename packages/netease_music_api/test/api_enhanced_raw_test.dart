import 'dart:convert';
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

    test('generator check mode keeps generated files in sync', () async {
      final repoRoot = _findRepoRoot();
      final result = await Process.run(
        'node',
        [
          '${repoRoot.path}/packages/netease_music_api/tool/generate_api_enhanced_modules.js',
          '--check',
        ],
        workingDirectory: repoRoot.path,
      );

      expect(
        result.exitCode,
        0,
        reason: '${result.stdout}\n${result.stderr}',
      );
      expect(result.stdout, contains('Generated api-enhanced files are up to date'));
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
        'cloud_import',
        'cloud_upload_complete',
        'cloud_upload_token',
        'decrypt',
        'eapi_decrypt',
        'inner_version',
        'login_qr_create',
        'playlist_track_all',
        'playlist_tracks',
        'playlist_cover_update',
        'register_anonimous',
        'register_xeapikey',
        'related_playlist',
        'scrobble',
        'song_url_match',
        'song_url_ncmget',
        'song_url_v1',
        'song_url_v1_302',
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

    test('multi request modules are explicit special modules', () {
      const branchOnlyModules = {'search'};
      final moduleDir = _findUpstreamModuleDir();

      for (final file in moduleDir.listSync().whereType<File>().where((file) => file.path.endsWith('.js'))) {
        final module = file.uri.pathSegments.last.replaceFirst('.js', '');
        if (branchOnlyModules.contains(module)) {
          continue;
        }
        final requestCount = RegExp(r'\brequest\s*\(').allMatches(file.readAsStringSync()).length;
        if (requestCount > 1) {
          expect(apiEnhancedModuleByName[module]!.special, isTrue, reason: module);
        }
      }
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

    test('keeps module default crypto when query crypto is empty', () {
      expect(api.requestModuleDioMetaData('album_privilege', {'id': '1', 'crypto': ''}).options!.extra!['encryptType'], EncryptType.EApi);
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

    test('maps e_r runtime option for encrypted responses', () {
      final metaData = api.requestModuleDioMetaData('album', {
        'id': '1',
        'e_r': true,
      });

      expect(metaData.options!.extra!['e_r'], isTrue);
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

    test('maps voicelist search defaults and encrypted response flag', () {
      final metaData = api.requestModuleDioMetaData('voicelist_search', {
        'keyword': 'podcast',
      });

      expect(metaData.uri.path, '/api/search/voicelist/get');
      expect(metaData.data, {
        'keyword': 'podcast',
        'scene': 'normal',
        'limit': '10',
        'offset': '30',
        'e_r': true,
      });
    });

    test('maps login request data shapes', () {
      expect(api.requestModuleDioMetaData('login', {'email': 'user@example.test', 'md5_password': '0123456789abcdef0123456789abcdef'}).data, {
        'type': '0',
        'https': 'true',
        'username': 'user@example.test',
        'password': '0123456789abcdef0123456789abcdef',
        'rememberLogin': 'true',
      });
      expect(api.requestModuleDioMetaData('login', {'email': 'user@example.test', 'password': 'password'}).data, {
        'type': '0',
        'https': 'true',
        'username': 'user@example.test',
        'password': '5f4dcc3b5aa765d61d8327deb882cf99',
        'rememberLogin': 'true',
      });
      expect(api.requestModuleDioMetaData('login_cellphone', {'phone': '13000000000', 'md5_password': 'fedcba9876543210fedcba9876543210'}).data, {
        'type': '1',
        'https': 'true',
        'phone': '13000000000',
        'countrycode': '86',
        'password': 'fedcba9876543210fedcba9876543210',
        'remember': 'true',
      });
      expect(api.requestModuleDioMetaData('login_cellphone', {'phone': '13000000000', 'countrycode': '1', 'captcha': '1234'}).data, {
        'type': '1',
        'https': 'true',
        'phone': '13000000000',
        'countrycode': '1',
        'captcha': '1234',
        'remember': 'true',
      });
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
      expect(api.eapiDecrypt({'data': '00'}), {'code': 400, 'message': 'hex string is required'});
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

    test('decrypt reports missing input', () async {
      expect(await api.requestModule('decrypt', {}), {'code': 400, 'message': 'data is required'});
    });

    test('decrypt supports api, linuxapi, weapi response, and xeapi response', () async {
      final linuxHex = _encryptAesEcbText(
        '{"method":"POST","url":"https://music.163.com/api/test","params":{"id":1}}',
        'rFgB&h#%2?^eDg:Q',
      );
      final encryptedResponseHex = _encryptEapiText('{"code":200,"encrypted":true}');
      final xeapiResponse = base64Encode(Encrypted.fromBase16(encryptedResponseHex).bytes);

      expect((await api.requestModule('decrypt', {'crypto': 'api', 'data': '{"code":200,"plain":true}'}))['data'], {
        'code': 200,
        'plain': true,
      });
      expect((await api.requestModule('decrypt', {'crypto': 'linuxapi', 'data': linuxHex}))['data'], {
        'method': 'POST',
        'url': 'https://music.163.com/api/test',
        'params': {'id': 1},
      });
      expect((await api.requestModule('decrypt', {'crypto': 'linuxapi', 'data': '{"code":200}', 'isReq': 'false'}))['data'], {
        'code': 200,
      });
      expect((await api.requestModule('decrypt', {'crypto': 'weapi', 'data': encryptedResponseHex, 'isReq': 'false'}))['data'], {
        'code': 200,
        'encrypted': true,
      });
      expect((await api.requestModule('decrypt', {'crypto': 'xeapi', 'data': xeapiResponse, 'isReq': 'false'}))['data'], {
        'code': 200,
        'encrypted': true,
      });
    });

    test('decrypt reports unsupported request crypto forms', () async {
      expect(await api.requestModule('decrypt', {'crypto': 'weapi', 'data': '00'}), {
        'code': 400,
        'message': 'weapi 请求解密需要 RSA 私钥，暂不支持；仅支持 weapi 返回数据解密（e_r=true 时与 eapi 相同）',
      });
      expect(await api.requestModule('decrypt', {'crypto': 'xeapi', 'data': 'AA=='}), {
        'code': 400,
        'message': 'xeapi 请求解密涉及 X25519 ECDH 密钥交换，流程复杂，暂不支持；仅支持 xeapi 返回数据解密',
      });
      expect(await api.requestModule('decrypt', {'crypto': 'unknown', 'data': '00'}), {
        'code': 400,
        'message': '未知加密方式: unknown',
      });
    });

    test('inner version mirrors upstream package version', () async {
      final packageJson = _jsonMap(jsonDecode(File('${_findRepoRoot().path}/third_party/api-enhanced/package.json').readAsStringSync()));

      expect(await api.requestModule('inner_version', {}), {
        'code': 200,
        'status': 200,
        'body': {
          'code': 200,
          'data': {'version': packageJson['version']},
        },
      });
      expect(apiEnhancedUpstreamVersion, packageJson['version']);
    });

    test('audio match mirrors upstream fixed query and response envelope', () async {
      final adapter = _TextResponseAdapter('{"data":{"songId":123,"name":"Matched"}}');
      Https.setDioForTesting(Dio()..httpClientAdapter = adapter);

      final result = await api.requestModule('audio_match', {
        'duration': 12,
        'audioFP': 'finger print +/=?',
        'sessionId': 'ignored',
        'algorithmCode': 'ignored',
        'times': 9,
        'decrypt': 0,
      });
      final requestedUri = adapter.requestedUri!;

      expect(requestedUri.toString(), startsWith('https://interface.music.163.com/api/music/audio/match?'));
      expect(requestedUri.queryParameters, {
        'sessionId': '0123456789abcdef',
        'algorithmCode': 'shazam_v2',
        'duration': '12',
        'rawdata': 'finger print +/=?',
        'times': '1',
        'decrypt': '1',
      });
      expect(result, {
        'status': 200,
        'body': {
          'code': 200,
          'data': {'songId': 123, 'name': 'Matched'},
        },
      });
    });

    test('login qr create mirrors upstream envelope and optional web qr image', () async {
      final pc = await api.requestModule('login_qr_create', {'key': 'abc'});
      expect(pc, {
        'code': 200,
        'status': 200,
        'body': {
          'code': 200,
          'data': {
            'qrurl': 'https://music.163.com/login?codekey=abc',
            'qrimg': '',
          },
        },
      });

      final web = await api.requestModule('login_qr_create', {
        'key': 'abc',
        'platform': 'web',
        'qrimg': true,
        'cookie': 'sDeviceId=device-1; MUSIC_U=token',
      });
      final data = _jsonMap(_jsonMap(web['body'])['data']);
      final qrUrl = data['qrurl'].toString();
      final qrImg = data['qrimg'].toString();

      expect(web['code'], 200);
      expect(web['status'], 200);
      expect(_jsonMap(web['body'])['code'], 200);
      expect(qrUrl, startsWith('https://music.163.com/login?codekey=abc&chainId='));
      expect(Uri.decodeComponent(qrUrl.split('chainId=').last), startsWith('v1_device-1_web_login_'));
      expect(qrImg, startsWith('data:image/png;base64,'));
      expect(base64Decode(qrImg.split(',').last).take(8), [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
    });

    test('related playlist special module parses upstream playlist html', () async {
      const html = '''
<div class="cver u-cover u-cover-3">
  <img src="https://p1.music.126.net/cover-a.jpg?param=50y50">
  <a class="sname f-fs1 s-fc0" href="/playlist?id=123" title="ignored">Related A</a>
  <a class="nm nm f-thide s-fc3" href="/user/home?id=42" title="ignored">Alice</a>
</div>
<div class="cver u-cover u-cover-3">
  <img src="https://p1.music.126.net/cover-b.jpg?param=50y50">
  <a class="sname f-fs1 s-fc0" href="/playlist?id=456">Related B</a>
  <a class="nm nm f-thide s-fc3" href="/user/home?id=77">Bob</a>
</div>
''';
      final adapter = _TextResponseAdapter(html);
      Https.setDioForTesting(Dio()..httpClientAdapter = adapter);

      final result = await api.requestModule('related_playlist', {'id': '888'});

      expect(adapter.requestedUri.toString(), 'https://music.163.com/playlist?id=888');
      expect(result, {
        'status': 200,
        'body': {
          'code': 200,
          'playlists': [
            {
              'creator': {
                'userId': '42',
                'nickname': 'Alice',
              },
              'coverImgUrl': 'https://p1.music.126.net/cover-a.jpg',
              'name': 'Related A',
              'id': '123',
            },
            {
              'creator': {
                'userId': '77',
                'nickname': 'Bob',
              },
              'coverImgUrl': 'https://p1.music.126.net/cover-b.jpg',
              'name': 'Related B',
              'id': '456',
            },
          ],
        },
      });
    });

    test('song url v1 special module rewrites upstream xeapi data shape', () async {
      final proxy = _CaptureDioProxy();
      Https.setDioProxyForTesting(proxy);

      await api.songUrlV1Raw({
        'id': '123',
        'level': 'sky',
        'source': 'qq,kugou,kuwo',
      });

      expect(proxy.metaData!.uri.toString(), 'https://interface3.music.163.com/api/song/enhance/player/url/v1');
      expect(proxy.metaData!.options!.extra!['encryptType'], EncryptType.XeApi);
      expect(proxy.metaData!.data, {
        'ids': '[123]',
        'level': 'sky',
        'encodeType': 'flac',
        'immerseType': 'c51',
      });
    });

    test('song url v1 keeps source order scoped to unsupported unblock path', () async {
      final proxy = _CaptureDioProxy();
      Https.setDioProxyForTesting(proxy);

      await api.songUrlV1Raw({
        'id': '123',
        'level': 'lossless',
        'source': 'qq,kugou,kuwo',
      });

      expect(proxy.metaData!.data, isNot(contains('source')));
      expect(proxy.metaData!.data, containsPair('encodeType', 'flac'));
    });

    test('song url v1 302 special module returns redirect from download url', () async {
      final proxy = _QueuedPostDioProxy([
        {
          'data': [
            {'url': 'https://audio.test/download.flac'}
          ],
        },
      ]);
      Https.setDioProxyForTesting(proxy);

      final result = await api.requestModule('song_url_v1_302', {
        'id': '123',
        'level': 'lossless',
      });

      expect(proxy.paths, ['/api/song/enhance/download/url/v1']);
      expect(proxy.requests.first.data, {
        'id': '123',
        'immerseType': 'c51',
        'level': 'lossless',
      });
      expect(result, {
        'status': 302,
        'body': '',
        'cookie': ['cookie-1=value'],
        'redirectUrl': 'https://audio.test/download.flac',
      });
    });

    test('song url v1 302 special module falls back to player url', () async {
      final proxy = _QueuedPostDioProxy([
        {
          'data': [
            {'url': null}
          ],
        },
        {
          'data': [
            {'url': 'https://audio.test/player.flac'}
          ],
        },
      ]);
      Https.setDioProxyForTesting(proxy);

      final result = await api.requestModule('song_url_v1_302', {
        'id': '123',
        'level': 'sky',
      });

      expect(proxy.paths, [
        '/api/song/enhance/download/url/v1',
        '/api/song/enhance/player/url/v1',
      ]);
      expect(proxy.requests.last.data, {
        'ids': '[123]',
        'level': 'sky',
        'encodeType': 'flac',
        'immerseType': 'c51',
      });
      expect(result, {
        'status': 302,
        'body': '',
        'cookie': ['cookie-2=value'],
        'redirectUrl': 'https://audio.test/player.flac',
      });
    });

    test('playlist track all special module fetches details before song detail', () async {
      final proxy = _QueuedPostDioProxy([
        {
          'playlist': {
            'trackIds': [
              {'id': 100},
              {'id': 101},
              {'id': 102},
              {'id': 103},
            ],
          },
        },
        {
          'songs': [
            {'id': 101},
            {'id': 102},
          ],
        },
      ]);
      Https.setDioProxyForTesting(proxy);

      final result = await api.requestModule('playlist_track_all', {
        'id': '888',
        's': 4,
        'limit': '2',
        'offset': '1',
      });

      expect(proxy.paths, ['/api/v6/playlist/detail', '/api/v3/song/detail']);
      expect(proxy.requests.first.data, {
        'id': '888',
        'n': 100000,
        's': 4,
      });
      expect(proxy.requests.last.data, {
        'c': '[{"id":101},{"id":102}]',
      });
      expect(result, {
        'songs': [
          {'id': 101},
          {'id': 102},
        ],
      });
    });

    test('playlist tracks special module wraps successful manipulate response', () async {
      final proxy = _QueuedPostDioProxy([
        {
          'code': 200,
          'ok': true,
        },
      ]);
      Https.setDioProxyForTesting(proxy);

      final result = await api.requestModule('playlist_tracks', {
        'op': 'add',
        'pid': '888',
        'tracks': '101,202',
      });

      expect(proxy.paths, ['/api/playlist/manipulate/tracks']);
      expect(proxy.requests.single.data, {
        'op': 'add',
        'pid': '888',
        'trackIds': '["101","202"]',
        'imme': 'true',
      });
      expect(result, {
        'status': 200,
        'body': {
          'code': 200,
          'ok': true,
        },
      });
    });

    test('playlist tracks special module retries duplicated tracks on 512', () async {
      final proxy = _QueuedPostDioProxy([
        DioException(
          requestOptions: RequestOptions(path: '/api/playlist/manipulate/tracks'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/playlist/manipulate/tracks'),
            data: {'code': 512},
          ),
        ),
        {
          'code': 200,
          'retry': true,
        },
      ]);
      Https.setDioProxyForTesting(proxy);

      final result = await api.requestModule('playlist_tracks', {
        'op': 'add',
        'pid': '888',
        'tracks': '101,202',
      });

      expect(proxy.paths, ['/api/playlist/manipulate/tracks', '/api/playlist/manipulate/tracks']);
      expect(proxy.requests.first.data, containsPair('trackIds', '["101","202"]'));
      expect(proxy.requests.last.data, containsPair('trackIds', '["101","202","101","202"]'));
      expect(result, {
        'code': 200,
        'retry': true,
      });
    });

    test('scrobble special module sends startplay and play weblog events', () async {
      final proxy = _QueuedPostDioProxy([
        {'ok': 'startplay'},
        {'ok': 'play'},
      ]);
      Https.setDioProxyForTesting(proxy);

      final result = await api.requestModule('scrobble', {
        'id': '100',
        'sourceid': '200',
        'time': 30,
        'cookie': {'MUSIC_U': 'token'},
        'domain': 'https://ignored.test',
      });

      expect(proxy.paths, ['/api/feedback/weblog', '/api/feedback/weblog']);
      expect(proxy.requests.map((request) => request.uri.host), ['clientlog.music.163.com', 'clientlog.music.163.com']);
      expect(proxy.requests.first.options!.extra!['cookies'], {
        'os': 'osx',
        'MUSIC_U': 'token',
      });
      final startplayLog = (jsonDecode((proxy.requests.first.data as Map)['logs'] as String) as List).single as Map<String, dynamic>;
      final playLog = (jsonDecode((proxy.requests.last.data as Map)['logs'] as String) as List).single as Map<String, dynamic>;

      expect(startplayLog['action'], 'startplay');
      expect(startplayLog['json'], containsPair('content', 'id=200'));
      expect(playLog['action'], 'play');
      expect(playLog['json'], containsPair('sourceId', '200'));
      expect(playLog['json'], containsPair('time', 30));
      expect(result, {
        'status': 200,
        'body': {
          'code': 200,
          'data': 'success',
          'details': {
            'startplay': {'ok': 'startplay'},
            'play': {'ok': 'play'},
          },
        },
      });
    });

    test('unblock special modules expose explicit Dart behavior', () async {
      expect(await api.songUrlV1Raw({'id': '123', 'level': 'lossless', 'unblock': 'true'}), {
        'status': 500,
        'body': {
          'code': 500,
          'msg': 'song_url_v1 unblock and source order depend on upstream unblockmusic-utils; use App playback fallback until a Dart replacement is available',
          'data': [],
        },
      });

      expect(await api.requestModule('song_url_match', {'id': '123'}), {
        'status': 500,
        'body': {
          'code': 500,
          'msg': 'song_url_match depends on upstream unblockmusic-utils and is not available in the Dart client',
          'data': [],
        },
      });

      expect(await api.requestModule('song_url_ncmget', {'id': '123'}), {
        'status': 200,
        'body': {'code': 200, 'data': []},
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
      expect(result['status'], 200);
      expect(result['body']['data']['imgId'], 123);
      expect(result['body']['data']['code'], 200);
    });

    test('playlist cover update special module mirrors upload envelope and missing image guard', () async {
      expect(await api.playlistCoverUpdate({'id': '888'}), {
        'status': 400,
        'body': {
          'code': 400,
          'msg': 'imgFile is required',
        },
      });

      final proxy = _UploadDioProxy();
      final adapter = _UploadAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      Https.setDioProxyForTesting(proxy);
      Https.setDioForTesting(dio);

      final result = await api.playlistCoverUpdate({
        'id': '888',
        'filename': 'cover.jpg',
        'bytes': [1, 2, 3],
      });

      expect(proxy.paths, ['/api/nos/token/alloc', '/api/playlist/cover/update']);
      expect(proxy.requests.last.data, {'id': '888', 'coverImgId': 123});
      expect(adapter.uploadUrl, contains('https://nosup-hz1.127.net/yyimgs/object-key'));
      expect(result, {
        'status': 200,
        'body': {
          'code': 200,
          'data': {
            'url_pre': 'https://p1.music.126.net/object-key',
            'imgId': 123,
            'code': 200,
          },
        },
      });
    });

    test('cloud upload token special module mirrors upstream envelope and guards', () async {
      expect(await api.cloudUploadToken({'filename': 'demo.mp3'}), {
        'status': 400,
        'body': {
          'code': 400,
          'msg': '缺少必要参数: md5, fileSize, filename',
        },
      });

      final proxy = _QueuedPostDioProxy([
        {
          'needUpload': true,
          'songId': 456,
        },
        {
          'result': {
            'objectKey': 'cloud/object key',
            'token': 'cloud-token',
            'resourceId': 'resource-1',
          },
        },
      ]);
      final adapter = _JsonResponseAdapter({
        'upload': ['https://upload.test'],
      });
      Https.setDioProxyForTesting(proxy);
      Https.setDioForTesting(Dio()..httpClientAdapter = adapter);

      final result = await api.cloudUploadToken({
        'md5': 'abc',
        'fileSize': 12345,
        'filename': 'My Song.flac',
      });

      expect(proxy.paths, ['/api/cloud/upload/check', '/api/nos/token/alloc']);
      expect(proxy.requests.first.data, {
        'bitrate': '999000',
        'ext': '',
        'length': 12345,
        'md5': 'abc',
        'songId': '0',
        'version': 1,
      });
      expect(proxy.requests.last.data, containsPair('filename', 'MySong'));
      expect(adapter.requestedUri.toString(), 'https://wanproxy.127.net/lbs?version=1.0&bucketname=jd-musicrep-privatecloud-audio-public');
      expect(result, {
        'status': 200,
        'body': {
          'code': 200,
          'data': {
            'needUpload': true,
            'songId': 456,
            'uploadToken': 'cloud-token',
            'objectKey': 'cloud/object key',
            'resourceId': 'resource-1',
            'uploadUrl': 'https://upload.test/jd-musicrep-privatecloud-audio-public/cloud%2Fobject key?offset=0&complete=true&version=1.0',
            'bucket': 'jd-musicrep-privatecloud-audio-public',
            'md5': 'abc',
            'fileSize': 12345,
            'filename': 'My Song.flac',
          },
        },
        'cookie': 'cookie-1=value',
      });
    });

    test('cloud upload complete special module mirrors upstream envelope and error branch', () async {
      expect(await api.cloudUploadComplete({'songId': 456}), {
        'status': 400,
        'body': {
          'code': 400,
          'msg': '缺少必要参数: songId, resourceId, md5, filename',
        },
      });

      final errorProxy = _QueuedPostDioProxy([
        {
          'code': 501,
          'msg': 'bad cloud info',
        },
      ]);
      Https.setDioProxyForTesting(errorProxy);

      expect(await api.cloudUploadComplete({'songId': 456, 'resourceId': 'resource-1', 'md5': 'abc', 'filename': 'My Song.flac'}), {
        'status': 500,
        'body': {
          'code': 501,
          'msg': 'bad cloud info',
          'detail': {
            'code': 501,
            'msg': 'bad cloud info',
          },
        },
      });

      final proxy = _QueuedPostDioProxy([
        {
          'code': 200,
          'songId': 789,
        },
        {
          'code': 200,
          'published': true,
        },
      ]);
      Https.setDioProxyForTesting(proxy);

      final result = await api.cloudUploadComplete({
        'songId': 456,
        'resourceId': 'resource-1',
        'md5': 'abc',
        'filename': 'My Song.flac',
      });

      expect(proxy.paths, ['/api/upload/cloud/info/v2', '/api/cloud/pub/v2']);
      expect(proxy.requests.first.data, {
        'md5': 'abc',
        'songid': 456,
        'filename': 'My Song.flac',
        'song': 'My Song',
        'album': '未知专辑',
        'artist': '未知艺术家',
        'bitrate': '999000',
        'resourceId': 'resource-1',
      });
      expect(proxy.requests.last.data, {'songid': 789});
      expect(result, {
        'status': 200,
        'body': {
          'code': 200,
          'data': {
            'songId': 789,
            'code': 200,
            'published': true,
          },
        },
        'cookie': 'cookie-1=value',
      });
    });

    test('cloud special module consumes upload token envelope before completion', () async {
      final proxy = _QueuedPostDioProxy([
        {
          'needUpload': false,
          'songId': 456,
        },
        {
          'result': {
            'objectKey': 'cloud/object-key',
            'token': 'cloud-token',
            'resourceId': 'resource-1',
          },
        },
        {
          'code': 200,
          'songId': 789,
        },
        {
          'code': 200,
          'published': true,
        },
      ]);
      Https.setDioProxyForTesting(proxy);
      Https.setDioForTesting(Dio()
        ..httpClientAdapter = _JsonResponseAdapter({
          'upload': ['https://upload.test'],
        }));

      final result = await api.cloud({
        'md5': 'abc',
        'fileSize': 12345,
        'filename': 'My Song.flac',
      });

      expect(proxy.paths, ['/api/cloud/upload/check', '/api/nos/token/alloc', '/api/upload/cloud/info/v2', '/api/cloud/pub/v2']);
      expect(result, {
        'status': 200,
        'body': {
          'code': 200,
          'data': {
            'songId': 789,
            'code': 200,
            'published': true,
          },
        },
        'cookie': 'cookie-3=value',
      });
    });

    test('cloud import special module checks upload before import', () async {
      final proxy = _QueuedPostDioProxy([
        {
          'data': [
            {'songId': 456}
          ],
        },
        {
          'code': 200,
          'imported': true,
        },
      ]);
      Https.setDioProxyForTesting(proxy);

      final result = await api.requestModule('cloud_import', {
        'md5': 'abc',
        'bitrate': 320000,
        'fileSize': 12345,
        'song': 'Imported Song',
        'fileType': 'flac',
      });

      expect(proxy.paths, ['/api/cloud/upload/check/v2', '/api/cloud/user/song/import']);
      final checkSongs = jsonDecode((proxy.requests.first.data as Map)['songs'] as String) as List;
      expect(proxy.requests.first.data, containsPair('uploadType', 0));
      expect(checkSongs.single, {
        'md5': 'abc',
        'songId': -2,
        'bitrate': 320000,
        'fileSize': 12345,
      });

      final importSongs = jsonDecode((proxy.requests.last.data as Map)['songs'] as String) as List;
      expect(proxy.requests.last.data, containsPair('uploadType', 0));
      expect(importSongs.single, {
        'songId': 456,
        'bitrate': 320000,
        'song': 'Imported Song',
        'artist': '未知',
        'album': '未知',
        'fileName': 'Imported Song.flac',
      });
      expect(result, {
        'code': 200,
        'imported': true,
      });
    });

    test('matches upstream Node request metadata for oracle fixtures', () async {
      final fixtures = await _loadNodeOracleFixtures();

      for (final fixture in fixtures) {
        final module = fixture['module'] as String;
        final query = _jsonMap(fixture['query']);
        final nodeRequests = _jsonMapList(fixture['requests']);
        if (nodeRequests.isNotEmpty) {
          final dartRequests = await _dartRequestSequenceForOracleFixture(api, module, query);
          expect(dartRequests, hasLength(nodeRequests.length), reason: module);
          for (var i = 0; i < nodeRequests.length; i++) {
            _expectDartRequestMatchesNode(dartRequests[i], nodeRequests[i], '$module request #${i + 1}');
          }
          continue;
        }
        final metaData = await _dartMetaDataForOracleFixture(api, module, query);
        _expectDartRequestMatchesNode(metaData, fixture, module);
      }
    });
  });
}

class _RawApi with ApiEnhancedRaw {}

Future<DioMetaData> _dartMetaDataForOracleFixture(
  _RawApi api,
  String module,
  Map<String, dynamic> query,
) async {
  switch (module) {
    case 'song_url_v1':
      return _captureSpecialMetaData(() => api.songUrlV1Raw(query));
    case 'vip_sign_history':
      return _captureSpecialMetaData(() => api.vipSignHistoryRaw(query));
    case 'vip_tasks_v1':
      return _captureSpecialMetaData(() => api.vipTasksV1Raw(query));
    default:
      return api.requestModuleDioMetaData(module, query);
  }
}

Future<List<DioMetaData>> _dartRequestSequenceForOracleFixture(
  _RawApi api,
  String module,
  Map<String, dynamic> query,
) async {
  switch (module) {
    case 'song_url_v1_302':
      final proxy = _QueuedPostDioProxy([
        {
          'data': [
            {'url': null}
          ],
        },
        {
          'data': [
            {'url': 'https://audio.test/player.flac'}
          ],
        },
      ]);
      Https.setDioProxyForTesting(proxy);
      await api.requestModule(module, query);
      return proxy.requests;
    case 'playlist_track_all':
      final proxy = _QueuedPostDioProxy([
        {
          'playlist': {
            'trackIds': [
              {'id': 100},
              {'id': 101},
              {'id': 102},
              {'id': 103},
            ],
          },
        },
        {
          'songs': [
            {'id': 101},
            {'id': 102},
          ],
        },
      ]);
      Https.setDioProxyForTesting(proxy);
      await api.requestModule(module, query);
      return proxy.requests;
    case 'scrobble':
      final proxy = _QueuedPostDioProxy([
        {'ok': 'startplay'},
        {'ok': 'play'},
      ]);
      Https.setDioProxyForTesting(proxy);
      await api.requestModule(module, query);
      return proxy.requests;
    case 'cloud_import':
      final proxy = _QueuedPostDioProxy([
        {
          'data': [
            {'songId': 456}
          ],
        },
        {
          'code': 200,
          'imported': true,
        },
      ]);
      Https.setDioProxyForTesting(proxy);
      await api.requestModule(module, query);
      return proxy.requests;
    case 'playlist_tracks':
      final proxy = _QueuedPostDioProxy([
        DioException(
          requestOptions: RequestOptions(path: '/api/playlist/manipulate/tracks'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/playlist/manipulate/tracks'),
            data: {'code': 512},
          ),
        ),
        {
          'code': 200,
          'retry': true,
        },
      ]);
      Https.setDioProxyForTesting(proxy);
      await api.requestModule(module, query);
      return proxy.requests;
    default:
      fail('No request sequence capture configured for $module');
  }
}

Future<DioMetaData> _captureSpecialMetaData(Future<dynamic> Function() call) async {
  final proxy = _CaptureDioProxy();
  Https.setDioProxyForTesting(proxy);

  await call();

  final metaData = proxy.metaData;
  if (metaData == null) {
    fail('Special raw module did not send request metadata');
  }
  return metaData;
}

void _expectDartRequestMatchesNode(
  DioMetaData metaData,
  Map<String, dynamic> nodeRequest,
  String reason,
) {
  final nodeOptions = _jsonMap(nodeRequest['options']);
  final extra = metaData.options!.extra!;

  expect(metaData.uri.path, nodeRequest['uri'], reason: reason);
  expect(_jsonMap(metaData.data), _jsonMap(nodeRequest['data']), reason: reason);
  expect(_encryptTypeName(extra['encryptType'] as EncryptType), _effectiveNodeCrypto(nodeOptions), reason: reason);
  expect(extra['realIP'], nodeOptions['realIP'], reason: reason);
  expect(_optionString(extra['rawUserAgent']), _optionString(nodeOptions['ua']), reason: reason);
  expect(_optionString(extra['domain']), _optionString(nodeOptions['domain']), reason: reason);
  expect(extra['checkToken'], nodeOptions['checkToken'] == true, reason: reason);
  expect(_optionString(extra['proxy']), _optionString(nodeOptions['proxy']), reason: reason);
  expect(extra['cookies'], nodeOptions.containsKey('cookie') ? _stringJsonMap(nodeOptions['cookie']) : <String, String>{}, reason: reason);
}

Directory _findUpstreamModuleDir() {
  return Directory('${_findRepoRoot().path}/third_party/api-enhanced/module');
}

Directory _findRepoRoot() {
  var current = Directory.current;
  for (var i = 0; i < 5; i++) {
    final candidate = Directory('${current.path}/third_party/api-enhanced/module');
    if (candidate.existsSync()) {
      return current;
    }
    current = current.parent;
  }
  throw StateError('Cannot find repository root with third_party/api-enhanced/module');
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
  final requests = <DioMetaData>[];

  List<String> get paths => requests.map((request) => request.uri.path).toList();

  @override
  Future<Response<T>> postUri<T>(
    DioMetaData metaData, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    requests.add(metaData);
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

class _QueuedPostDioProxy extends DioProxy {
  _QueuedPostDioProxy(this._responses);

  final List<dynamic> _responses;
  final List<DioMetaData> requests = [];

  List<String> get paths => requests.map((request) => request.uri.path).toList();

  @override
  Future<Response<T>> postUri<T>(
    DioMetaData metaData, {
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    requests.add(metaData);
    final index = requests.length - 1;
    final response = _responses[index];
    if (response is DioException) {
      throw response;
    }
    return Response<T>(
      requestOptions: RequestOptions(path: metaData.uri.toString()),
      data: response as T,
      headers: Headers.fromMap({
        HttpHeaders.setCookieHeader: ['cookie-${index + 1}=value'],
      }),
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

class _JsonResponseAdapter implements HttpClientAdapter {
  _JsonResponseAdapter(this.body);

  final Map<String, dynamic> body;
  Uri? requestedUri;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requestedUri = options.uri;
    return ResponseBody.fromString(jsonEncode(body), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

class _TextResponseAdapter implements HttpClientAdapter {
  _TextResponseAdapter(this.body);

  final String body;
  Uri? requestedUri;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requestedUri = options.uri;
    return ResponseBody.fromString(body, 200, headers: {
      Headers.contentTypeHeader: ['text/html; charset=utf-8'],
    });
  }

  @override
  void close({bool force = false}) {}
}

String _encryptEapiText(String text) {
  return _encryptAesEcbText(text, 'e82ckenh8dichen8');
}

String _encryptAesEcbText(String text, String key) {
  final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.ecb));
  return encrypter.encrypt(text, iv: IV.fromLength(0)).base16;
}

Future<List<Map<String, dynamic>>> _loadNodeOracleFixtures() async {
  final script = _findNodeOracleScript();
  final result = await Process.run('node', [script.path]);
  if (result.exitCode != 0) {
    fail('Node oracle failed: ${result.stderr}');
  }
  final decoded = jsonDecode(result.stdout as String);
  return (decoded as List).map((value) => _jsonMap(value)).toList();
}

File _findNodeOracleScript() {
  var current = Directory.current;
  for (var i = 0; i < 5; i++) {
    final candidate = File('${current.path}/packages/netease_music_api/tool/api_enhanced_node_oracle.js');
    if (candidate.existsSync()) {
      return candidate;
    }
    current = current.parent;
  }
  throw StateError('Cannot find packages/netease_music_api/tool/api_enhanced_node_oracle.js');
}

Map<String, dynamic> _jsonMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> _jsonMapList(dynamic value) {
  if (value is! List) {
    return const [];
  }
  return value.map(_jsonMap).toList(growable: false);
}

Map<String, String> _stringJsonMap(dynamic value) {
  return _jsonMap(value).map((key, value) => MapEntry(key, value.toString()));
}

String _effectiveNodeCrypto(Map<String, dynamic> options) {
  final crypto = options['crypto']?.toString();
  return crypto == null || crypto.isEmpty ? 'eapi' : crypto;
}

String _optionString(dynamic value) {
  return value?.toString() ?? '';
}

String _encryptTypeName(EncryptType type) {
  switch (type) {
    case EncryptType.WeApi:
      return 'weapi';
    case EncryptType.EApi:
      return 'eapi';
    case EncryptType.LinuxForward:
      return 'linuxapi';
    case EncryptType.Api:
      return 'api';
    case EncryptType.XeApi:
      return 'xeapi';
  }
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
