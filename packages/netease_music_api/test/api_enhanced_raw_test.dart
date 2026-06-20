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
        'top_list',
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

    test('maps album request data like upstream', () {
      expect(api.requestModuleDioMetaData('album_detail_dynamic', {'id': '456'}).data, {
        'id': '456',
      });
      expect(api.requestModuleDioMetaData('album_list_style', {}).data, {
        'limit': 10,
        'offset': 0,
        'total': true,
        'area': 'Z_H',
      });

      final dailyBoard = api.requestModuleDioMetaData('album_songsaleboard', {});
      expect(dailyBoard.uri.path, '/api/feealbum/songsaleboard/daily/type');
      expect(dailyBoard.data, {
        'albumType': 0,
      });

      final yearBoard = api.requestModuleDioMetaData('album_songsaleboard', {
        'type': 'year',
        'albumType': 1,
        'year': 2025,
      });
      expect(yearBoard.uri.path, '/api/feealbum/songsaleboard/year/type');
      expect(yearBoard.data, {
        'albumType': 1,
        'year': 2025,
      });

      final sub = api.requestModuleDioMetaData('album_sub', {
        'id': '456',
        't': 1,
      });
      expect(sub.uri.path, '/api/album/sub');
      expect(sub.data, {
        'id': '456',
      });

      final unsub = api.requestModuleDioMetaData('album_sub', {
        'id': '456',
        't': 0,
      });
      expect(unsub.uri.path, '/api/album/unsub');

      expect(api.requestModuleDioMetaData('album_sublist', {}).data, {
        'limit': 25,
        'offset': 0,
        'total': true,
      });
    });

    test('maps digital album request data like upstream', () {
      expect(api.requestModuleDioMetaData('digitalAlbum_detail', {'id': '456'}).data, {
        'id': '456',
      });
      expect(
        api.requestModuleDioMetaData('digitalAlbum_ordering', {
          'id': '456',
          'payment': 'alipay',
          'quantity': 2,
        }).data,
        {
          'business': 'Album',
          'paymentMethod': 'alipay',
          'digitalResources': jsonEncode([
            {
              'business': 'Album',
              'resourceID': '456',
              'quantity': 2,
            },
          ]),
          'from': 'web',
        },
      );
      expect(api.requestModuleDioMetaData('digitalAlbum_purchased', {}).data, {
        'limit': 30,
        'offset': 0,
        'total': true,
      });
      expect(api.requestModuleDioMetaData('digitalAlbum_sales', {'ids': '456,789'}).data, {
        'albumIds': '456,789',
      });
    });

    test('maps search suggest web and mobile branch paths', () {
      final web = api.requestModuleDioMetaData('search_suggest', {
        'keywords': 'hello',
      });
      expect(web.uri.path, '/api/search/suggest/web');
      expect(web.data, {'s': 'hello'});

      final mobile = api.requestModuleDioMetaData('search_suggest', {
        'keywords': 'hello',
        'type': 'mobile',
      });
      expect(mobile.uri.path, '/api/search/suggest/keyword');
      expect(mobile.data, {'s': 'hello'});
    });

    test('maps search request data like upstream', () {
      expect(api.requestModuleDioMetaData('search_hot', {}).data, {
        'type': 1111,
      });

      final match = api.requestModuleDioMetaData('search_match', {
        'title': 'Song A',
        'album': 'Album A',
        'artist': 'Artist A',
        'duration': 240000,
        'md5': 'abc123',
      });
      expect(match.data, {
        'songs': jsonEncode([
          {
            'title': 'Song A',
            'album': 'Album A',
            'artist': 'Artist A',
            'duration': 240000,
            'persistId': 'abc123',
          },
        ]),
      });

      expect(api.requestModuleDioMetaData('search_multimatch', {'keywords': 'hello'}).data, {
        'type': 1,
        's': 'hello',
      });
      expect(api.requestModuleDioMetaData('search_suggest_pc', {'keyword': 'hello'}).data, {
        'keyword': 'hello',
      });
    });

    test('maps similar recommendation request data like upstream', () {
      expect(api.requestModuleDioMetaData('simi_artist', {'id': '6452'}).data, {
        'artistid': '6452',
      });
      expect(api.requestModuleDioMetaData('simi_mv', {'mvid': '5436712'}).data, {
        'mvid': '5436712',
      });
      expect(api.requestModuleDioMetaData('simi_playlist', {'id': '101'}).data, {
        'songid': '101',
        'limit': 50,
        'offset': 0,
      });
      expect(api.requestModuleDioMetaData('simi_song', {'id': '101', 'limit': 10, 'offset': 20}).data, {
        'songid': '101',
        'limit': 10,
        'offset': 20,
      });
      expect(api.requestModuleDioMetaData('simi_user', {'id': '101'}).data, {
        'songid': '101',
        'limit': 50,
        'offset': 0,
      });
    });

    test('maps artist album id into path only', () {
      final metaData = api.requestModuleDioMetaData('artist_album', {
        'id': '6452',
        'limit': 12,
        'offset': 24,
      });

      expect(metaData.uri.path, '/api/artist/albums/6452');
      expect(metaData.data, {
        'limit': 12,
        'offset': 24,
        'total': true,
      });
    });

    test('maps artist module request data like upstream', () {
      expect(api.requestModuleDioMetaData('artists', {'id': '6452'}).data, isEmpty);

      final artistMv = api.requestModuleDioMetaData('artist_mv', {
        'id': '6452',
        'limit': 10,
        'offset': 20,
      });
      expect(artistMv.data, {
        'artistId': '6452',
        'limit': 10,
        'offset': 20,
        'total': true,
      });

      final artistSongs = api.requestModuleDioMetaData('artist_songs', {
        'id': '6452',
        'order': 'time',
        'limit': 10,
        'offset': 20,
      });
      expect(artistSongs.data, {
        'id': '6452',
        'private_cloud': 'true',
        'work_type': 1,
        'order': 'time',
        'offset': 20,
        'limit': 10,
      });

      final artistList = api.requestModuleDioMetaData('artist_list', {
        'initial': 'a',
        'type': 2,
        'area': 7,
        'limit': 10,
        'offset': 20,
      });
      expect(artistList.data, {
        'initial': 65,
        'offset': 20,
        'limit': 10,
        'total': true,
        'type': 2,
        'area': 7,
      });

      expect(api.requestModuleDioMetaData('artist_fans', {'id': '6452'}).data, {
        'id': '6452',
        'limit': 20,
        'offset': 0,
      });
      expect(api.requestModuleDioMetaData('artist_follow_count', {'id': '6452'}).data, {
        'id': '6452',
      });
      expect(api.requestModuleDioMetaData('artist_new_mv', {'limit': 10, 'before': 1700000000000}).data, {
        'limit': 10,
        'startTimestamp': 1700000000000,
      });
      expect(api.requestModuleDioMetaData('artist_new_song', {'limit': 10, 'before': 1700000000000}).data, {
        'limit': 10,
        'startTimestamp': 1700000000000,
      });
      final artistSub = api.requestModuleDioMetaData('artist_sub', {'id': '6452', 't': 1});
      expect(artistSub.uri.path, '/api/artist/sub');
      expect(artistSub.data, {
        'artistId': '6452',
        'artistIds': '[6452]',
      });
      expect(api.requestModuleDioMetaData('artist_sub', {'id': '6452', 't': 0}).uri.path, '/api/artist/unsub');
      expect(api.requestModuleDioMetaData('artist_sublist', {}).data, {
        'limit': 25,
        'offset': 0,
        'total': true,
      });
      expect(api.requestModuleDioMetaData('artist_video', {'id': '6452', 'size': 20, 'cursor': 'cursor-1', 'order': 1}).data, {
        'artistId': '6452',
        'page': '{"size":20,"cursor":"cursor-1"}',
        'tab': 0,
        'order': 1,
      });
    });

    test('maps ugc request data like upstream', () {
      expect(api.requestModuleDioMetaData('ugc_album_get', {'id': '100'}).data, {
        'albumId': '100',
      });
      expect(api.requestModuleDioMetaData('ugc_artist_get', {'id': '200'}).data, {
        'artistId': '200',
      });
      expect(api.requestModuleDioMetaData('ugc_artist_search', {'keyword': 'artist'}).data, {
        'keyword': 'artist',
        'limit': 40,
      });
      expect(api.requestModuleDioMetaData('ugc_detail', {}).data, {
        'auditStatus': '',
        'limit': 10,
        'offset': 0,
        'order': 'desc',
        'sortBy': 'createTime',
        'type': 1,
      });
      expect(api.requestModuleDioMetaData('ugc_mv_get', {'id': '300'}).data, {
        'mvId': '300',
      });
      expect(api.requestModuleDioMetaData('ugc_song_get', {'id': '400'}).data, {
        'songId': '400',
      });
      expect(api.requestModuleDioMetaData('ugc_user_devote', {}).data, isEmpty);
    });

    test('maps event request data like upstream', () {
      final eventMetaData = api.requestModuleDioMetaData('event', {'pagesize': 0, 'lasttime': 0});
      expect(eventMetaData.data, {
        'pagesize': 20,
        'lasttime': -1,
      });
      expect(eventMetaData.options!.extra!['encryptType'], EncryptType.WeApi);

      final deleteMetaData = api.requestModuleDioMetaData('event_del', {'evId': '900'});
      expect(deleteMetaData.data, {
        'id': '900',
      });
      expect(deleteMetaData.options!.extra!['encryptType'], EncryptType.WeApi);

      final forwardMetaData = api.requestModuleDioMetaData('event_forward', {
        'forwards': '转发内容',
        'evId': '900',
        'uid': '42',
      });
      expect(forwardMetaData.uri.path, '/api/event/forward');
      expect(forwardMetaData.data, {
        'forwards': '转发内容',
        'id': '900',
        'eventUserId': '42',
      });
      expect(forwardMetaData.options!.extra!['encryptType'], EncryptType.EApi);
    });

    test('maps playlist management request data like upstream', () {
      expect(api.requestModuleDioMetaData('playlist_create', {'name': 'New List'}).data, {
        'name': 'New List',
        'privacy': '0',
        'type': 'NORMAL',
      });
      expect(api.requestModuleDioMetaData('playlist_delete', {'id': '888'}).data, {
        'ids': '[888]',
      });
      expect(api.requestModuleDioMetaData('playlist_mylike', {}).data, {
        'time': '-1',
        'limit': '12',
      });
      expect(api.requestModuleDioMetaData('playlist_category_list', {}).data, {
        'cat': '全部',
        'limit': 24,
        'newStyle': true,
      });
      expect(api.requestModuleDioMetaData('playlist_privacy', {'id': '888', 'privacy': 10}).data, {
        'id': '888',
        'privacy': 0,
      });
      expect(api.requestModuleDioMetaData('playlist_track_add', {'pid': '888', 'ids': '101,202'}).data, {
        'id': '888',
        'tracks': '[{"type":3,"id":"101"},{"type":3,"id":"202"}]',
      });
      expect(
        api.requestModuleDioMetaData('playlist_import_name_task_create', {
          'importStarPlaylist': true,
          'local': '[{"name":"Song A","artist":"Alice","album":"Album A"}]',
        }).data,
        {
          'importStarPlaylist': true,
          'multiSongs': '[{"songName":"Song A","artistName":"Alice","albumName":"Album A"}]',
        },
      );
      expect(api.requestModuleDioMetaData('playlist_import_task_status', {'id': 'task-1'}).data, {
        'taskIds': '["task-1"]',
      });
      expect(api.requestModuleDioMetaData('playlist_update', {'id': '888', 'name': 'Renamed'}).data, {
        '/api/playlist/desc/update': '{"id":888,"desc":""}',
        '/api/playlist/tags/update': '{"id":888,"tags":""}',
        '/api/playlist/update/name': '{"id":888,"name":"Renamed"}',
      });
      expect(api.requestModuleDioMetaData('playlist_detail_rcmd_get', {'id': '888'}).data, {
        'scene': 'playlist_head',
        'playlistId': '888',
        'newStyle': 'true',
      });
      expect(api.requestModuleDioMetaData('playlist_video_recent', {'limit': 5}).data, isEmpty);
    });

    test('maps playmode request data like upstream', () {
      expect(api.requestModuleDioMetaData('playmode_intelligence_list', {'id': '101', 'pid': '888'}).data, {
        'songId': '101',
        'type': 'fromPlayOne',
        'playlistId': '888',
        'startMusicId': '101',
        'count': 1,
      });
      expect(
        api.requestModuleDioMetaData('playmode_intelligence_list', {
          'id': '101',
          'pid': '888',
          'sid': '202',
          'count': 0,
        }).data,
        {
          'songId': '101',
          'type': 'fromPlayOne',
          'playlistId': '888',
          'startMusicId': '202',
          'count': 1,
        },
      );
      expect(api.requestModuleDioMetaData('playmode_song_vector', {'ids': '101,202'}).data, {
        'ids': '101,202',
      });
    });

    test('maps voice request data like upstream', () {
      final deleteMetaData = api.requestModuleDioMetaData('voice_delete', {'ids': '101,202'});

      expect(deleteMetaData.uri.path, '/api/content/voice/delete');
      expect(deleteMetaData.data, {
        'ids': '101,202',
      });
      expect(deleteMetaData.options!.extra!['encryptType'], EncryptType.EApi);
      expect(api.requestModuleDioMetaData('voice_detail', {'id': 'voice-1'}).data, {
        'id': 'voice-1',
      });
      expect(api.requestModuleDioMetaData('voice_lyric', {'id': 'voice-1'}).data, {
        'programId': 'voice-1',
      });
    });

    test('maps voicelist request data like upstream', () {
      expect(api.requestModuleDioMetaData('voicelist_detail', {'id': '500'}).data, {
        'id': '500',
      });
      expect(api.requestModuleDioMetaData('voicelist_list', {'voiceListId': '300', 'limit': 0, 'offset': ''}).data, {
        'limit': '200',
        'offset': '0',
        'voiceListId': '300',
      });
      expect(api.requestModuleDioMetaData('voicelist_list_search', {'voiceListId': '300'}).data, {
        'limit': '200',
        'offset': '0',
        'name': null,
        'displayStatus': null,
        'type': null,
        'voiceFeeType': null,
        'radioId': '300',
      });
      final createdMetaData = api.requestModuleDioMetaData('voicelist_my_created', {'limit': 0});
      expect(createdMetaData.data, {
        'limit': 20,
      });
      expect(createdMetaData.options!.extra!['encryptType'], EncryptType.WeApi);
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
      expect(api.requestModuleDioMetaData('voicelist_trans', {'radioId': '300'}).data, {
        'limit': '200',
        'offset': '0',
        'radioId': '300',
        'programId': '0',
        'position': '1',
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
      expect(api.requestModuleDioMetaData('login_qr_key', {}).data, {
        'type': 3,
      });
      expect(api.requestModuleDioMetaData('login_qr_check', {'key': 'qr-key'}).data, {
        'key': 'qr-key',
        'type': 3,
      });
      expect(api.requestModuleDioMetaData('captcha_sent', {'phone': '13000000000'}).data, {
        'ctcode': '86',
        'secrete': 'music_middleuser_pclogin',
        'cellphone': '13000000000',
      });
      expect(api.requestModuleDioMetaData('captcha_verify', {'phone': '13000000000', 'ctcode': '1', 'captcha': '1234'}).data, {
        'ctcode': '1',
        'cellphone': '13000000000',
        'captcha': '1234',
      });
      expect(api.requestModuleDioMetaData('cellphone_existence_check', {'phone': '13000000000', 'countrycode': '86'}).data, {
        'cellphone': '13000000000',
        'countrycode': '86',
      });
      expect(api.requestModuleDioMetaData('countries_code_list', {}).data, isEmpty);
      expect(
        api.requestModuleDioMetaData(
          'verify_getQr',
          {'vid': 'verify-id', 'type': 'login', 'token': 'token-1', 'evid': 'event-1', 'sign': 'sign-1'},
        ).data,
        {
          'verifyConfigId': 'verify-id',
          'verifyType': 'login',
          'token': 'token-1',
          'params': '{"event_id":"event-1","sign":"sign-1"}',
          'size': 150,
        },
      );
      expect(api.requestModuleDioMetaData('verify_qrcodestatus', {'qr': 'qr-code'}).data, {
        'qrCode': 'qr-code',
      });
    });

    test('maps account and library request data like upstream', () {
      expect(api.requestModuleDioMetaData('login_status', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('login_refresh', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('logout', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('recommend_resource', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('personal_fm', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('homepage_dragon_ball', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('likelist', {'uid': '42'}).data, {
        'uid': '42',
      });
      expect(api.requestModuleDioMetaData('daily_signin', {}).data, {
        'type': 0,
      });
      expect(api.requestModuleDioMetaData('fm_trash', {'id': '101'}).data, {
        'songId': '101',
        'alg': 'RT',
        'time': 25,
      });
      expect(api.requestModuleDioMetaData('fm_trash', {'id': '101', 'time': 0}).data, {
        'songId': '101',
        'alg': 'RT',
        'time': 25,
      });
      expect(api.requestModuleDioMetaData('check_music', {'id': '101abc', 'br': '320000abc'}).data, {
        'ids': '[101]',
        'br': 320000,
      });
      expect(api.requestModuleDioMetaData('banner', {}).data, {
        'clientType': 'pc',
      });
      expect(api.requestModuleDioMetaData('banner', {'type': 2}).data, {
        'clientType': 'iphone',
      });
    });

    test('maps chart request data like upstream', () {
      const query = {
        'chartCode': 'weekly',
        'targetId': '19723756',
        'targetType': 'song',
      };

      expect(api.requestModuleDioMetaData('chart_detail', query).data, query);
      expect(api.requestModuleDioMetaData('chart_song_detail', query).data, query);
    });

    test('maps topic request data like upstream', () {
      final detailMetaData = api.requestModuleDioMetaData('topic_detail', {'actid': 'act-1'});
      expect(detailMetaData.data, {
        'actid': 'act-1',
      });
      expect(detailMetaData.options!.extra!['encryptType'], EncryptType.WeApi);

      final hotMetaData = api.requestModuleDioMetaData('topic_detail_event_hot', {'actid': 'act-1'});
      expect(hotMetaData.uri.path, '/api/act/event/hot');
      expect(hotMetaData.data, {
        'actid': 'act-1',
      });
      expect(hotMetaData.options!.extra!['encryptType'], EncryptType.WeApi);

      final sublistMetaData = api.requestModuleDioMetaData('topic_sublist', {'limit': 0, 'offset': 0});
      expect(sublistMetaData.data, {
        'limit': 50,
        'offset': 0,
        'total': true,
      });
      expect(sublistMetaData.options!.extra!['encryptType'], EncryptType.WeApi);
    });

    test('maps broadcast and ambient radio request data like upstream', () {
      expect(api.requestModuleDioMetaData('broadcast_category_region_get', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('broadcast_channel_collect_list', {}).data, {
        'contentType': 'BROADCAST',
        'limit': '99999',
        'timeReverseOrder': 'true',
        'startDate': '4762584922000',
      });
      expect(api.requestModuleDioMetaData('broadcast_channel_currentinfo', {'id': '5'}).data, {
        'channelId': '5',
      });
      expect(api.requestModuleDioMetaData('broadcast_channel_list', {}).data, {
        'categoryId': '0',
        'regionId': '0',
        'limit': '20',
        'lastId': '0',
        'score': '-1',
      });
      expect(api.requestModuleDioMetaData('broadcast_sub', {'id': '5', 't': 1}).data, {
        'contentType': 'BROADCAST',
        'contentId': '5',
        'cancelCollect': 'false',
      });
      expect(api.requestModuleDioMetaData('broadcast_sub', {'id': '5', 't': 0}).data, {
        'contentType': 'BROADCAST',
        'contentId': '5',
        'cancelCollect': 'true',
      });
      expect(api.requestModuleDioMetaData('radio_sport_get', {}).data, {
        'bpm': 50,
      });
      expect(api.requestModuleDioMetaData('sati_resource_list', {'tag': 'rain'}).data, {
        'tag': 'rain',
        'firstQuery': false,
      });
      expect(api.requestModuleDioMetaData('sati_resource_list_more', {'id': '167003'}).data, {
        'id': '167003',
      });
      expect(api.requestModuleDioMetaData('sati_resource_sub', {'id': '167003'}).data, {
        'id': '167003',
        'cancel': false,
      });
      expect(api.requestModuleDioMetaData('sati_resource_sub_list', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('sati_tag_list', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('sati_timescene_resources_get', {}).data, {
        'firstQuery': false,
      });
    });

    test('maps dj radio request data like upstream', () {
      expect(api.requestModuleDioMetaData('djRadio_top', {}).data, {
        'djRadioId': null,
        'sortIndex': 1,
        'dataGapDays': 7,
        'dataType': 3,
      });
      expect(api.requestModuleDioMetaData('dj_banner', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('dj_category_excludehot', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('dj_category_recommend', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('dj_catelist', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('dj_detail', {'rid': '336355127'}).data, {
        'id': '336355127',
      });
      expect(api.requestModuleDioMetaData('dj_difm_all_style_channel', {}).data, {
        'sources': '[0]',
      });
      expect(api.requestModuleDioMetaData('dj_difm_channel_subscribe', {'id': 'channel-1'}).data, {
        'id': 'channel-1',
      });
      expect(api.requestModuleDioMetaData('dj_difm_channel_unsubscribe', {'id': 'channel-1'}).data, {
        'id': 'channel-1',
      });
      expect(api.requestModuleDioMetaData('dj_difm_playing_tracks_list', {'channelId': 'channel-1'}).data, {
        'limit': 5,
        'source': 0,
        'channelId': 'channel-1',
      });
      expect(api.requestModuleDioMetaData('dj_difm_subscribe_channels_get', {}).data, {
        'sources': '[0]',
      });
      expect(api.requestModuleDioMetaData('dj_hot', {}).data, {
        'limit': 30,
        'offset': 0,
      });
      expect(api.requestModuleDioMetaData('dj_paygift', {}).data, {
        'limit': 30,
        'offset': 0,
        '_nmclfl': 1,
      });
      expect(api.requestModuleDioMetaData('dj_personalize_recommend', {}).data, {
        'limit': 6,
      });
      expect(api.requestModuleDioMetaData('dj_program_toplist', {}).data, {
        'limit': 100,
        'offset': 0,
      });
      expect(api.requestModuleDioMetaData('dj_program_toplist_hours', {}).data, {
        'limit': 100,
      });
      expect(api.requestModuleDioMetaData('dj_radio_hot', {'cateId': 10001}).data, {
        'cateId': 10001,
        'limit': 30,
        'offset': 0,
      });
      expect(api.requestModuleDioMetaData('dj_recommend', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('dj_recommend_type', {'type': 10001}).data, {
        'cateId': 10001,
      });
      final subMetaData = api.requestModuleDioMetaData('dj_sub', {'rid': '336355127', 't': 1});
      expect(subMetaData.uri.path, '/api/djradio/sub');
      expect(subMetaData.data, {
        'id': '336355127',
      });
      expect(api.requestModuleDioMetaData('dj_sub', {'rid': '336355127', 't': 0}).uri.path, '/api/djradio/unsub');
      expect(api.requestModuleDioMetaData('dj_sublist', {}).data, {
        'limit': 30,
        'offset': 0,
        'total': true,
      });
      expect(api.requestModuleDioMetaData('dj_subscriber', {'id': '336355127'}).data, {
        'time': '-1',
        'id': '336355127',
        'limit': '20',
        'total': 'true',
      });
      expect(api.requestModuleDioMetaData('dj_today_perfered', {}).data, {
        'page': 0,
      });
      expect(api.requestModuleDioMetaData('dj_toplist_pay', {}).data, {
        'limit': 100,
      });
    });

    test('maps listen data request data like upstream', () {
      expect(api.requestModuleDioMetaData('listen_data_realtime_report', {}).data, {
        'type': 'week',
      });
      expect(api.requestModuleDioMetaData('listen_data_realtime_report', {'type': 'month'}).data, {
        'type': 'month',
      });
      expect(api.requestModuleDioMetaData('listen_data_report', {}).data, {
        'type': 'week',
      });
      expect(api.requestModuleDioMetaData('listen_data_report', {'type': 'year', 'endTime': 1767110400000}).data, {
        'type': 'year',
        'endTime': 1767110400000,
      });
      expect(api.requestModuleDioMetaData('listen_data_today_song', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('listen_data_total', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('listen_data_year_report', {}).data, isEmpty);
    });

    test('maps listen together request data like upstream', () {
      expect(api.requestModuleDioMetaData('listentogether_accept', {'roomId': 'room-1', 'inviterId': '42'}).data, {
        'refer': 'inbox_invite',
        'roomId': 'room-1',
        'inviterId': '42',
      });
      expect(api.requestModuleDioMetaData('listentogether_end', {'roomId': 'room-1'}).data, {
        'roomId': 'room-1',
      });
      expect(
        api.requestModuleDioMetaData('listentogether_heatbeat', {
          'roomId': 'room-1',
          'songId': '101',
          'playStatus': 1,
          'progress': 120000,
        }).data,
        {
          'roomId': 'room-1',
          'songId': '101',
          'playStatus': 1,
          'progress': 120000,
        },
      );
      expect(
        api.requestModuleDioMetaData('listentogether_play_command', {
          'roomId': 'room-1',
          'commandType': 'play',
          'playStatus': 1,
          'formerSongId': '101',
          'targetSongId': '202',
          'clientSeq': 7,
        }).data,
        {
          'roomId': 'room-1',
          'commandInfo': '{"commandType":"play","progress":0,"playStatus":1,"formerSongId":"101","targetSongId":"202","clientSeq":7}',
        },
      );
      expect(api.requestModuleDioMetaData('listentogether_room_check', {'roomId': 'room-1'}).data, {
        'roomId': 'room-1',
      });
      expect(api.requestModuleDioMetaData('listentogether_room_create', {}).data, {
        'refer': 'songplay_more',
      });
      expect(api.requestModuleDioMetaData('listentogether_status', {}).data, isEmpty);
      expect(
        api.requestModuleDioMetaData('listentogether_sync_list_command', {
          'roomId': 'room-1',
          'commandType': 'sync',
          'userId': '42',
          'version': 3,
          'randomList': '101,202',
          'displayList': '202,101',
        }).data,
        {
          'roomId': 'room-1',
          'playlistParam': '{"commandType":"sync","version":[{"userId":"42","version":3}],"anchorSongId":"","anchorPosition":-1,"randomList":["101","202"],"displayList":["202","101"]}',
        },
      );
      expect(api.requestModuleDioMetaData('listentogether_sync_playlist_get', {'roomId': 'room-1'}).data, {
        'roomId': 'room-1',
      });
    });

    test('maps vip request data like upstream', () {
      expect(api.requestModuleDioMetaData('vip_growthpoint', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('vip_growthpoint_details', {}).data, {
        'limit': 20,
        'offset': 0,
      });
      expect(api.requestModuleDioMetaData('vip_growthpoint_get', {'ids': 'task-1,task-2'}).data, {
        'taskIds': 'task-1,task-2',
      });
      expect(api.requestModuleDioMetaData('vip_info', {}).data, {
        'userId': '',
      });
      expect(api.requestModuleDioMetaData('vip_info_v2', {'uid': '42'}).data, {
        'userId': '42',
      });
      expect(api.requestModuleDioMetaData('vip_sign', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('vip_sign_detail', {'timestamp': 1767110400000}).data, {
        'signDayTime': 1767110400000,
        'type': '1',
      });
      expect(api.requestModuleDioMetaData('vip_sign_info', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('vip_tasks', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('vip_timemachine', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('vip_timemachine', {'startTime': 1, 'endTime': 2}).data, {
        'startTime': 1,
        'endTime': 2,
        'type': 1,
        'limit': 60,
      });
    });

    test('maps yunbei request data like upstream', () {
      expect(api.requestModuleDioMetaData('yunbei', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('yunbei_expense', {}).data, {
        'limit': 10,
        'offset': 0,
      });
      expect(api.requestModuleDioMetaData('yunbei_info', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('yunbei_rcmd_song', {'id': '101'}).data, {
        'songId': '101',
        'reason': '好歌献给你',
        'scene': '',
        'fromUserId': -1,
        'yunbeiNum': 10,
      });
      expect(api.requestModuleDioMetaData('yunbei_rcmd_song_history', {}).data, {
        'page': '{"size":20,"cursor":""}',
      });
      expect(api.requestModuleDioMetaData('yunbei_receipt', {'limit': 5, 'offset': 10}).data, {
        'limit': 5,
        'offset': 10,
      });
      expect(api.requestModuleDioMetaData('yunbei_sign', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('yunbei_task_finish', {'userTaskId': 'task-1'}).data, {
        'userTaskId': 'task-1',
        'depositCode': '0',
      });
      expect(api.requestModuleDioMetaData('yunbei_tasks', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('yunbei_tasks_todo', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('yunbei_today', {}).data, isEmpty);
    });

    test('maps musician request data like upstream', () {
      expect(api.requestModuleDioMetaData('musician_cloudbean', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('musician_cloudbean_obtain', {'id': 'mission-1', 'period': 7}).data, {
        'userMissionId': 'mission-1',
        'period': 7,
      });
      expect(api.requestModuleDioMetaData('musician_data_overview', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('musician_play_trend', {'startTime': 1700000000000, 'endTime': 1700604800000}).data, {
        'startTime': 1700000000000,
        'endTime': 1700604800000,
      });
      expect(api.requestModuleDioMetaData('musician_sign', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('musician_tasks', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('musician_tasks_new', {}).data, isEmpty);
      expect(Uri.decodeFull(api.requestModuleDioMetaData('musician_tasks_new', {}).uri.path), '/api/nmusician/workbench/mission/stage/list ');
      expect(api.requestModuleDioMetaData('musician_vip_tasks', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('musician_vip_tasks', {}).options!.extra!['encryptType'], EncryptType.EApi);
    });

    test('maps style tag request data like upstream', () {
      expect(api.requestModuleDioMetaData('style_album', {'tagId': '1000', 'cursor': 20, 'size': 10, 'sort': 1}).data, {
        'cursor': 20,
        'size': 10,
        'tagId': '1000',
        'sort': 1,
      });
      expect(api.requestModuleDioMetaData('style_artist', {'tagId': '1000', 'cursor': 20, 'size': 10, 'sort': 1}).data, {
        'cursor': 20,
        'size': 10,
        'tagId': '1000',
        'sort': 0,
      });
      expect(api.requestModuleDioMetaData('style_detail', {'tagId': '1000'}).data, {
        'tagId': '1000',
      });
      expect(api.requestModuleDioMetaData('style_list', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('style_playlist', {'tagId': '1000', 'cursor': 0, 'size': 0, 'sort': 1}).data, {
        'cursor': 0,
        'size': 20,
        'tagId': '1000',
        'sort': 0,
      });
      expect(api.requestModuleDioMetaData('style_preference', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('style_song', {'tagId': '1000'}).data, {
        'cursor': 0,
        'size': 20,
        'tagId': '1000',
        'sort': 0,
      });
    });

    test('maps message request data like upstream', () {
      final commentsMetaData = api.requestModuleDioMetaData('msg_comments', {'uid': '42'});
      expect(commentsMetaData.uri.path, '/api/v1/user/comments/42');
      expect(commentsMetaData.data, {
        'beforeTime': '-1',
        'limit': 30,
        'total': 'true',
        'uid': '42',
      });
      expect(api.requestModuleDioMetaData('msg_comments', {'uid': '42', 'before': 123456, 'limit': 0}).data, {
        'beforeTime': 123456,
        'limit': 30,
        'total': 'true',
        'uid': '42',
      });
      expect(api.requestModuleDioMetaData('msg_forwards', {'offset': 20, 'limit': 10}).data, {
        'offset': 20,
        'limit': 10,
        'total': 'true',
      });
      expect(api.requestModuleDioMetaData('msg_notices', {}).data, {
        'limit': 30,
        'time': -1,
      });
      expect(api.requestModuleDioMetaData('msg_private', {}).data, {
        'offset': 0,
        'limit': 30,
        'total': 'true',
      });
      expect(api.requestModuleDioMetaData('msg_private_history', {'uid': '42', 'before': 123456, 'limit': 10}).data, {
        'userId': '42',
        'limit': 10,
        'time': 123456,
        'total': 'true',
      });
      expect(api.requestModuleDioMetaData('msg_recentcontact', {}).data, isEmpty);
    });

    test('maps send private message request data like upstream', () {
      final albumMetaData = api.requestModuleDioMetaData('send_album', {
        'id': '100',
        'msg': 0,
        'user_ids': [101, 202],
      });
      expect(albumMetaData.uri.path, '/api/msg/private/send');
      expect(albumMetaData.data, {
        'id': '100',
        'msg': '',
        'type': 'album',
        'userIds': '[101,202]',
      });
      expect(api.requestModuleDioMetaData('send_playlist', {'playlist': '200', 'msg': '歌单', 'user_ids': '101,202'}).data, {
        'id': '200',
        'type': 'playlist',
        'msg': '歌单',
        'userIds': '[101,202]',
      });
      expect(api.requestModuleDioMetaData('send_song', {'id': '300', 'user_ids': '101'}).data, {
        'id': '300',
        'msg': '',
        'type': 'song',
        'userIds': '[101]',
      });
      expect(api.requestModuleDioMetaData('send_text', {'msg': 'hello', 'user_ids': '101,202'}).data, {
        'type': 'text',
        'msg': 'hello',
        'userIds': '[101,202]',
      });
    });

    test('maps fanscenter request data like upstream', () {
      expect(api.requestModuleDioMetaData('fanscenter_basicinfo_age_get', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('fanscenter_basicinfo_gender_get', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('fanscenter_basicinfo_province_get', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('fanscenter_overview_get', {}).data, isEmpty);
      expect(
        api.requestModuleDioMetaData('fanscenter_trend_list', {
          'startTime': 1700000000000,
          'endTime': 1700604800000,
          'type': 1,
        }).data,
        {
          'startTime': 1700000000000,
          'endTime': 1700604800000,
          'type': 1,
        },
      );
    });

    test('maps mlog request data like upstream', () {
      final musicRcmdMetaData = api.requestModuleDioMetaData('mlog_music_rcmd', {
        'mvid': 0,
        'limit': 0,
        'songid': '101',
      });
      expect(musicRcmdMetaData.uri.path, '/api/mlog/rcmd/feed/list');
      expect(musicRcmdMetaData.data, {
        'id': 0,
        'type': 2,
        'rcmdType': 20,
        'limit': 10,
        'extInfo': '{"songId":"101"}',
      });
      expect(musicRcmdMetaData.options!.extra!['encryptType'], EncryptType.EApi);

      final toVideoMetaData = api.requestModuleDioMetaData('mlog_to_video', {'id': 'mlog-1'});
      expect(toVideoMetaData.data, {
        'mlogId': 'mlog-1',
      });
      expect(toVideoMetaData.options!.extra!['encryptType'], EncryptType.WeApi);

      final urlMetaData = api.requestModuleDioMetaData('mlog_url', {'id': 'mlog-1', 'res': 0});
      expect(urlMetaData.data, {
        'id': 'mlog-1',
        'resolution': 1080,
        'type': 1,
      });
      expect(urlMetaData.options!.extra!['encryptType'], EncryptType.WeApi);
    });

    test('maps mv request data like upstream', () {
      expect(api.requestModuleDioMetaData('mv_all', {}).data, {
        'tags': '{"地区":"全部","类型":"全部","排序":"上升最快"}',
        'offset': 0,
        'total': 'true',
        'limit': 30,
      });
      expect(api.requestModuleDioMetaData('mv_detail', {'mvid': '5436712'}).data, {
        'id': '5436712',
      });
      expect(api.requestModuleDioMetaData('mv_detail_info', {'mvid': '5436712'}).data, {
        'threadid': 'R_MV_5_5436712',
        'composeliked': true,
      });
      expect(api.requestModuleDioMetaData('mv_exclusive_rcmd', {}).data, {
        'offset': 0,
        'limit': 30,
      });
      expect(api.requestModuleDioMetaData('mv_first', {'area': '内地', 'limit': 10}).data, {
        'area': '内地',
        'limit': 10,
        'total': true,
      });
      final subMetaData = api.requestModuleDioMetaData('mv_sub', {'mvid': '5436712', 't': 1});
      expect(subMetaData.uri.path, '/api/mv/sub');
      expect(subMetaData.data, {
        'mvId': '5436712',
        'mvIds': '["5436712"]',
      });
      expect(api.requestModuleDioMetaData('mv_sub', {'mvid': '5436712', 't': 0}).uri.path, '/api/mv/unsub');
      expect(api.requestModuleDioMetaData('mv_sublist', {}).data, {
        'limit': 25,
        'offset': 0,
        'total': true,
      });
    });

    test('maps video request data like upstream', () {
      expect(api.requestModuleDioMetaData('video_category_list', {}).data, {
        'offset': 0,
        'total': 'true',
        'limit': 99,
      });
      expect(api.requestModuleDioMetaData('video_detail', {'id': 'video-1'}).data, {
        'id': 'video-1',
      });
      expect(api.requestModuleDioMetaData('video_detail_info', {'vid': 'video-1'}).data, {
        'threadid': 'R_VI_62_video-1',
        'composeliked': true,
      });
      expect(api.requestModuleDioMetaData('video_group', {'id': 'group-1'}).data, {
        'groupId': 'group-1',
        'offset': 0,
        'need_preview_url': 'true',
        'total': true,
      });
      expect(api.requestModuleDioMetaData('video_group_list', {}).data, isEmpty);
      final subMetaData = api.requestModuleDioMetaData('video_sub', {'id': 'video-1', 't': 1});
      expect(subMetaData.uri.path, '/api/cloudvideo/video/sub');
      expect(subMetaData.data, {'id': 'video-1'});
      expect(api.requestModuleDioMetaData('video_sub', {'id': 'video-1', 't': 0}).uri.path, '/api/cloudvideo/video/unsub');
      expect(api.requestModuleDioMetaData('video_timeline_all', {'offset': 20}).data, {
        'groupId': 0,
        'offset': 20,
        'need_preview_url': 'true',
        'total': true,
      });
      expect(api.requestModuleDioMetaData('video_timeline_recommend', {}).data, {
        'offset': 0,
        'filterLives': '[]',
        'withProgramInfo': 'true',
        'needUrl': '1',
        'resolution': '480',
      });
    });

    test('maps user library request data like upstream', () {
      expect(api.requestModuleDioMetaData('user_account', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('user_subcount', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('user_level', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('user_bindingcellphone', {'phone': '13000000000', 'captcha': '1234', 'password': 'secret'}).data, {
        'phone': '13000000000',
        'countrycode': '86',
        'captcha': '1234',
        'password': '5ebe2294ecd0e0f08eab7690d2a6ee69',
      });
      expect(api.requestModuleDioMetaData('user_cloud', {}).data, {
        'limit': 30,
        'offset': 0,
      });
      expect(api.requestModuleDioMetaData('user_cloud_detail', {'id': '101, 202'}).data, {
        'songIds': ['101', '202'],
      });
      expect(api.requestModuleDioMetaData('user_cloud_del', {'id': '101'}).data, {
        'songIds': ['101'],
      });
      expect(api.requestModuleDioMetaData('user_record', {'uid': '42'}).data, {
        'uid': '42',
        'type': 0,
      });
      expect(api.requestModuleDioMetaData('user_follows', {'uid': '42'}).data, {
        'offset': 0,
        'limit': 30,
        'order': true,
      });
      expect(api.requestModuleDioMetaData('user_followeds', {'uid': '42'}).data, {
        'userId': '42',
        'time': '0',
        'limit': 20,
        'offset': 0,
        'getcounts': 'true',
      });
      expect(api.requestModuleDioMetaData('user_playlist_collect', {'uid': '42'}).data, {
        'limit': '100',
        'offset': '0',
        'userId': '42',
        'isWebview': 'true',
        'includeRedHeart': 'true',
        'includeTop': 'true',
      });
      expect(api.requestModuleDioMetaData('user_medal', {'uid': '42'}).data, {
        'uid': '42',
      });
      expect(api.requestModuleDioMetaData('user_mutualfollow_get', {'uid': '42'}).data, {
        'friendid': '42',
      });
      expect(api.requestModuleDioMetaData('user_replacephone', {'phone': '13000000000', 'captcha': '1234', 'oldcaptcha': '5678'}).data, {
        'phone': '13000000000',
        'captcha': '1234',
        'oldcaptcha': '5678',
        'countrycode': '86',
      });
      expect(api.requestModuleDioMetaData('user_social_status', {'uid': '42'}).data, {
        'visitorId': '42',
      });
      expect(
        api.requestModuleDioMetaData('user_social_status_edit', {
          'type': 'music',
          'iconUrl': 'https://example.test/icon.png',
          'content': 'listening',
          'actionUrl': 'orpheus://song/1',
        }).data,
        {
          'content': '{"type":"music","iconUrl":"https://example.test/icon.png","content":"listening","actionUrl":"orpheus://song/1"}',
        },
      );
      expect(api.requestModuleDioMetaData('user_social_status_rcmd', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('user_social_status_support', {}).data, isEmpty);
      expect(
          api.requestModuleDioMetaData('user_update', {
            'birthday': 1700000000000,
            'city': 110101,
            'gender': 1,
            'nickname': 'nick',
            'province': 110000,
            'signature': 'hello',
          }).data,
          {
            'birthday': 1700000000000,
            'city': 110101,
            'gender': 1,
            'nickname': 'nick',
            'province': 110000,
            'signature': 'hello',
          });
      expect(api.requestModuleDioMetaData('record_recent_album', {}).data, {
        'limit': 100,
      });
      expect(api.requestModuleDioMetaData('recent_listen_list', {'limit': 5}).data, isEmpty);
    });

    test('maps home discovery request data like upstream', () {
      expect(api.requestModuleDioMetaData('homepage_block_page', {}).data, {
        'refresh': false,
      });
      expect(api.requestModuleDioMetaData('homepage_block_page', {'refresh': true, 'cursor': 'page-2'}).data, {
        'refresh': true,
        'cursor': 'page-2',
      });
      expect(api.requestModuleDioMetaData('personalized_newsong', {}).data, {
        'type': 'recommend',
        'limit': 10,
        'areaId': 0,
      });
      expect(api.requestModuleDioMetaData('personalized_mv', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('personalized_djprogram', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('personalized_privatecontent', {}).data, isEmpty);
      expect(api.requestModuleDioMetaData('personalized_privatecontent_list', {'offset': 20, 'limit': 10}).data, {
        'offset': 20,
        'total': 'true',
        'limit': 10,
      });
      expect(api.requestModuleDioMetaData('program_recommend', {'type': 10001}).data, {
        'cateId': 10001,
        'limit': 10,
        'offset': 0,
      });
      expect(api.requestModuleDioMetaData('program_recommend', {'type': 10001, 'limit': 0, 'offset': 5}).data, {
        'cateId': 10001,
        'limit': 10,
        'offset': 5,
      });
      expect(api.requestModuleDioMetaData('top_song', {'type': 7}).data, {
        'areaId': 7,
        'total': true,
      });
      expect(api.requestModuleDioMetaData('top_artists', {}).data, {
        'limit': 50,
        'offset': 0,
        'total': true,
      });
      expect(api.requestModuleDioMetaData('top_album', {'year': 2025, 'month': 6}).data, {
        'area': 'ALL',
        'limit': 50,
        'offset': 0,
        'type': 'new',
        'year': 2025,
        'month': 6,
        'total': false,
        'rcmd': true,
      });
      expect(api.requestModuleDioMetaData('album_list', {}).data, {
        'limit': 30,
        'offset': 0,
        'total': true,
        'area': 'ALL',
      });
      expect(api.requestModuleDioMetaData('recommend_songs_dislike', {'id': '101'}).data, {
        'resId': '101',
        'resType': 4,
        'sceneType': 1,
      });
      expect(api.requestModuleDioMetaData('history_recommend_songs', {'date': '2026-06-20'}).data, isEmpty);
      expect(api.requestModuleDioMetaData('history_recommend_songs_detail', {}).data, {
        'date': '',
      });
      expect(api.requestModuleDioMetaData('history_recommend_songs_detail', {'date': '2026-06-20'}).data, {
        'date': '2026-06-20',
      });
    });

    test('maps song detail and lyric request data like upstream', () {
      expect(api.requestModuleDioMetaData('lyric', {'id': '101'}).data, {
        'id': '101',
        'tv': -1,
        'lv': -1,
        'rv': -1,
        'kv': -1,
        '_nmclfl': 1,
      });
      expect(api.requestModuleDioMetaData('song_music_detail', {'id': '101'}).data, {
        'songId': '101',
      });
      expect(api.requestModuleDioMetaData('song_copyright_rcmd', {'id': '101'}).data, {
        'songid': '101',
      });
      expect(api.requestModuleDioMetaData('song_copyright_rcmd', {'songid': '202', 'id': '101'}).data, {
        'songid': '202',
      });
      expect(api.requestModuleDioMetaData('song_creators', {'id': '101'}).data, {
        'songId': '101',
      });
      expect(api.requestModuleDioMetaData('song_like', {'id': '101', 'uid': '42'}).data, {
        'trackId': '101',
        'userid': '42',
        'like': true,
      });
      expect(api.requestModuleDioMetaData('song_like', {'id': '101', 'uid': '42', 'like': 'false'}).data, {
        'trackId': '101',
        'userid': '42',
        'like': false,
      });
      expect(api.requestModuleDioMetaData('song_order_update', {'pid': '888', 'ids': '101,202'}).data, {
        'pid': '888',
        'trackIds': '101,202',
        'op': 'update',
      });
      expect(api.requestModuleDioMetaData('song_chorus', {'id': '101'}).data, {
        'ids': '["101"]',
      });
      expect(api.requestModuleDioMetaData('cloud_lyric_get', {'uid': '42', 'sid': '101'}).data, {
        'userId': '42',
        'songId': '101',
        'lv': -1,
        'kv': -1,
      });
      expect(api.requestModuleDioMetaData('cloud_match', {'uid': '42', 'sid': '101', 'asid': '202'}).data, {
        'userId': '42',
        'songId': '101',
        'adjustSongId': '202',
      });
      expect(api.requestModuleDioMetaData('song_downlist', {}).data, {
        'limit': '20',
        'offset': '0',
        'total': 'true',
      });
      expect(api.requestModuleDioMetaData('song_purchased', {}).data, {
        'limit': 20,
        'offset': 0,
      });
      expect(api.requestModuleDioMetaData('song_lyrics_mark_add', {'id': '101'}).data, {
        'songId': '101',
        'markId': '',
        'data': '[]',
      });
      expect(api.requestModuleDioMetaData('song_lyrics_mark_del', {'id': 'mark-1'}).data, {
        'markIds': 'mark-1',
      });
      expect(api.requestModuleDioMetaData('song_lyrics_mark_user_page', {}).data, {
        'limit': 10,
        'offset': 0,
      });
    });

    test('maps comment request data like upstream', () {
      final commentAdd = api.requestModuleDioMetaData('comment', {
        't': 1,
        'type': 0,
        'id': '101',
        'content': 'nice',
      });
      expect(commentAdd.uri.path, '/api/resource/comments/add');
      expect(commentAdd.data, {
        'threadId': 'R_SO_4_101',
        'content': 'nice',
      });

      final eventReply = api.requestModuleDioMetaData('comment', {
        't': 2,
        'type': 6,
        'id': 'ignored',
        'threadId': 'A_EV_2_101',
        'commentId': '555',
        'content': 'reply',
      });
      expect(eventReply.uri.path, '/api/resource/comments/reply');
      expect(eventReply.data, {
        'threadId': 'A_EV_2_101',
        'commentId': '555',
        'content': 'reply',
      });

      expect(api.requestModuleDioMetaData('comment_album', {'id': '123'}).data, {
        'rid': '123',
        'limit': 20,
        'offset': 0,
        'beforeTime': 0,
      });
      expect(api.requestModuleDioMetaData('comment_dj', {'id': '336355127'}).data, {
        'rid': '336355127',
        'limit': 20,
        'offset': 0,
        'beforeTime': 0,
      });
      expect(api.requestModuleDioMetaData('comment_mv', {'id': '5436712'}).data, {
        'rid': '5436712',
        'limit': 20,
        'offset': 0,
        'beforeTime': 0,
      });
      expect(api.requestModuleDioMetaData('comment_video', {'id': '89ADDE33C0AAE8EC14B99F6750DB954D'}).data, {
        'rid': '89ADDE33C0AAE8EC14B99F6750DB954D',
        'limit': 20,
        'offset': 0,
        'beforeTime': 0,
      });
      expect(
        api.requestModuleDioMetaData('comment_event', {
          'threadId': 'A_EV_2_101',
          'limit': 10,
          'offset': 20,
          'before': 123456,
        }).data,
        {
          'limit': 10,
          'offset': 20,
          'beforeTime': 123456,
        },
      );
      expect(api.requestModuleDioMetaData('comment_report', {'id': '101', 'cid': '555', 'reason': 'spam'}).data, {
        'threadId': 'R_SO_4_101',
        'commentId': '555',
        'reason': 'spam',
      });
      expect(api.requestModuleDioMetaData('hug_comment', {'type': 0, 'sid': '101', 'uid': '42', 'cid': '555'}).data, {
        'targetUserId': '42',
        'commentId': '555',
        'threadId': 'R_SO_4_101',
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

    test('top list special module mirrors idx guard and id request', () async {
      expect(await api.requestModule('top_list', {'idx': 1}), {
        'status': 500,
        'body': {
          'code': 500,
          'msg': '不支持此方式调用,只支持id调用',
        },
      });

      final proxy = _CaptureDioProxy();
      Https.setDioProxyForTesting(proxy);

      expect(await api.requestModule('top_list', {'id': '3779629'}), {'code': 200});
      expect(proxy.metaData!.uri.path, '/api/playlist/v4/detail');
      expect(proxy.metaData!.data, {
        'id': '3779629',
        'n': '500',
        's': '0',
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

    test('voice upload special module mirrors upstream multipart flow and envelope', () async {
      expect(await api.voiceUpload({}), {
        'status': 500,
        'body': {
          'msg': '请上传音频文件',
          'code': 500,
        },
      });

      final proxy = _QueuedPostDioProxy([
        {
          'result': {
            'objectKey': 'voice/object-key',
            'token': 'voice-token',
            'docId': 321,
          },
        },
        {
          'code': 200,
          'preCheck': true,
        },
        {
          'data': {
            'voiceId': 999,
          },
        },
      ]);
      final adapter = _MultipartUploadAdapter();
      Https.setDioProxyForTesting(proxy);
      Https.setDioForTesting(Dio()..httpClientAdapter = adapter);

      final result = await api.voiceUpload({
        'filename': 'My Voice.mp3',
        'bytes': [1, 2, 3],
        'mimetype': 'audio/mpeg',
        'autoPublish': '1',
        'privacy': 1,
        'composedSongs': '100,200',
        'voiceListId': 'list-1',
        'categoryId': 'cat-1',
      });

      expect(proxy.paths, [
        '/api/nos/token/alloc',
        '/api/voice/workbench/voice/batch/upload/preCheck',
        '/api/voice/workbench/voice/batch/upload/v2',
      ]);
      expect(proxy.requests.first.data, {
        'bucket': 'ymusic',
        'ext': 'mp3',
        'filename': 'MyVoice',
        'local': false,
        'nos_product': 0,
        'type': 'other',
      });
      expect(adapter.requests.map((request) => request.method).toList(), ['POST', 'PUT', 'POST']);
      expect(adapter.requests.first.uri.toString(), 'https://ymusic.nos-hz.163yun.com/voice%2Fobject-key?uploads');
      expect(adapter.requests.first.headers['x-nos-token'], 'voice-token');
      expect(adapter.requests.first.headers['X-Nos-Meta-Content-Type'], 'audio/mpeg');
      expect(adapter.requests[1].uri.toString(), 'https://ymusic.nos-hz.163yun.com/voice%2Fobject-key?partNumber=1&uploadId=upload-id');
      expect(adapter.requests[1].headers['Content-Type'], 'audio/mpeg');
      expect(adapter.requests[1].bodyBytes, [1, 2, 3]);
      expect(adapter.requests.last.uri.toString(), 'https://ymusic.nos-hz.163yun.com/voice%2Fobject-key?uploadId=upload-id');
      expect(adapter.requests.last.bodyText, contains('<PartNumber>1</PartNumber><ETag>etag-1</ETag>'));

      final preCheckData = proxy.requests[1].data as Map<String, dynamic>;
      final uploadData = proxy.requests[2].data as Map<String, dynamic>;
      expect(preCheckData['dupkey'], isA<String>());
      expect(uploadData['dupkey'], isA<String>());
      expect(proxy.requests[1].options!.headers!['x-nos-token'], 'voice-token');
      expect(proxy.requests[2].options!.headers!['x-nos-token'], 'voice-token');
      expect(jsonDecode(preCheckData['voiceData'] as String), [
        {
          'name': 'MyVoice',
          'autoPublish': true,
          'autoPublishText': '',
          'dfsId': 321,
          'composedSongs': ['100', '200'],
          'privacy': true,
          'publishTime': 0,
          'orderNo': 1,
          'voiceListId': 'list-1',
          'categoryId': 'cat-1',
        }
      ]);
      expect(uploadData['voiceData'], preCheckData['voiceData']);
      expect(result, {
        'status': 200,
        'body': {
          'code': 200,
          'data': {
            'voiceId': 999,
          },
        },
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
    case 'top_list':
      return _captureSpecialMetaData(() => api.topListRaw(query));
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
    case 'cloud_upload_token':
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
      Https.setDioProxyForTesting(proxy);
      Https.setDioForTesting(Dio()
        ..httpClientAdapter = _JsonResponseAdapter({
          'upload': ['https://upload.test'],
        }));
      await api.requestModule(module, query);
      return proxy.requests;
    case 'avatar_upload':
      final proxy = _UploadDioProxy();
      Https.setDioProxyForTesting(proxy);
      Https.setDioForTesting(Dio()..httpClientAdapter = _UploadAdapter());
      await api.requestModule(module, query);
      return proxy.requests;
    case 'playlist_cover_update':
      final proxy = _UploadDioProxy();
      Https.setDioProxyForTesting(proxy);
      Https.setDioForTesting(Dio()..httpClientAdapter = _UploadAdapter());
      await api.requestModule(module, query);
      return proxy.requests;
    case 'cloud_upload_complete':
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
      await api.requestModule(module, query);
      return proxy.requests;
    case 'voice_upload':
      final proxy = _QueuedPostDioProxy([
        {
          'result': {
            'objectKey': 'voice/object-key',
            'token': 'voice-token',
            'docId': 321,
          },
        },
        {
          'code': 200,
          'preCheck': true,
        },
        {
          'data': {
            'voiceId': 999,
          },
        },
      ]);
      Https.setDioProxyForTesting(proxy);
      Https.setDioForTesting(Dio()..httpClientAdapter = _MultipartUploadAdapter());
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

  expect(Uri.decodeFull(metaData.uri.path), nodeRequest['uri'], reason: reason);
  expect(_normalizedRequestData(metaData.data), _normalizedRequestData(nodeRequest['data']), reason: reason);
  expect(_encryptTypeName(extra['encryptType'] as EncryptType), _effectiveNodeCrypto(nodeOptions), reason: reason);
  expect(extra['realIP'], nodeOptions['realIP'], reason: reason);
  expect(_optionString(extra['rawUserAgent']), _optionString(nodeOptions['ua']), reason: reason);
  expect(_optionString(extra['domain']), _optionString(nodeOptions['domain']), reason: reason);
  expect(extra['checkToken'], nodeOptions['checkToken'] == true, reason: reason);
  expect(_optionString(extra['proxy']), _optionString(nodeOptions['proxy']), reason: reason);
  expect(extra['cookies'], nodeOptions.containsKey('cookie') ? _stringJsonMap(nodeOptions['cookie']) : <String, String>{}, reason: reason);
  expect(_stringJsonMap(metaData.options?.headers), _stringJsonMap(nodeOptions['headers']), reason: reason);
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

class _MultipartUploadAdapter implements HttpClientAdapter {
  final requests = <_CapturedHttpRequest>[];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    final bodyBytes = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bodyBytes.addAll(chunk);
      }
    }
    requests.add(_CapturedHttpRequest(options.method, options.uri, Map<String, dynamic>.from(options.headers), bodyBytes));
    final query = options.uri.query;
    if (options.method == 'POST' && query == 'uploads') {
      return ResponseBody.fromString('<InitiateMultipartUploadResult><UploadId>upload-id</UploadId></InitiateMultipartUploadResult>', 200);
    }
    if (options.method == 'PUT') {
      return ResponseBody.fromString('', 200, headers: {
        'etag': ['etag-1'],
      });
    }
    return ResponseBody.fromString('', 200);
  }

  @override
  void close({bool force = false}) {}
}

class _CapturedHttpRequest {
  _CapturedHttpRequest(this.method, this.uri, this.headers, this.bodyBytes);

  final String method;
  final Uri uri;
  final Map<String, dynamic> headers;
  final List<int> bodyBytes;

  String get bodyText => utf8.decode(bodyBytes);
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

Map<String, dynamic> _normalizedRequestData(dynamic value) {
  final data = _jsonMap(value);
  final result = <String, dynamic>{};
  for (final entry in data.entries) {
    if (entry.key == 'dupkey') {
      result[entry.key] = '<dynamic>';
      continue;
    }
    if (entry.key == 'voiceData' && entry.value is String) {
      result[entry.key] = jsonDecode(entry.value as String);
      continue;
    }
    result[entry.key] = entry.value;
  }
  return result;
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
