// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/digests/md5.dart';
import 'package:qr/qr.dart';

import '../../client/dio_ext.dart';
import '../../client/netease_handler.dart';
import '../../client/xeapi_crypto.dart';
import '../../generated/api_enhanced_module.dart';
import '../../generated/api_enhanced_modules.g.dart';

part 'api_enhanced_raw_methods.g.dart';

const _apiDomain = 'https://interface.music.163.com';
const _xeapiDomain = 'https://interface3.music.163.com';
const _eapiKey = 'e82ckenh8dichen8';
const _linuxapiKey = 'rFgB&h#%2?^eDg:Q';
const _upstreamCheckToken = '9ca17ae2e6ffcda170e2e6ee8af14fbabdb988f225b3868eb2c15a879b9a83d274a790ac8ff54a97b889d5d42af0feaec3b92af58cff99c470a7eafd88f75e839a9ea7c14e909da883e83fb692a3abdb6b92adee9e';
const _resourceTypePrefixes = {
  '0': 'R_SO_4_',
  '1': 'R_MV_5_',
  '2': 'A_PL_0_',
  '3': 'R_AL_3_',
  '4': 'A_DJ_1_',
  '5': 'R_VI_62_',
  '6': 'A_EV_2_',
  '7': 'A_DR_14_',
};
const _resourceTypeIds = {
  '0': '4',
  '1': '5',
  '2': '0',
  '3': '3',
  '4': '1',
  '5': '62',
  '6': '2',
  '7': '14',
};

const _rawOptionKeys = {
  'cookie',
  'crypto',
  'ua',
  'proxy',
  'realIP',
  'randomCNIP',
  'e_r',
  'domain',
  'checkToken',
  'method',
  'uri',
  'data',
};

/// Raw api-enhanced module dispatcher.
mixin ApiEnhancedRaw {
  /// Upstream api-enhanced module metadata.
  List<ApiEnhancedModule> get enhancedModules => apiEnhancedModules;

  /// Builds request metadata for a raw api-enhanced module.
  DioMetaData requestModuleDioMetaData(String module, Map<String, dynamic> query) {
    final metadata = apiEnhancedModuleByName[module];
    if (metadata == null) {
      return DioMetaData.error(ArgumentError('Unknown api-enhanced module: $module'));
    }
    if (metadata.special) {
      return DioMetaData.error(UnsupportedError('Module $module uses a manual override and cannot be represented by one request metadata object.'));
    }
    try {
      return _buildRawMetaData(metadata, query);
    } on Error catch (error) {
      return DioMetaData.error(error);
    }
  }

  /// Calls a raw api-enhanced module and returns the raw response body.
  Future<dynamic> requestModule(String module, Map<String, dynamic> query) async {
    switch (module) {
      case 'api':
        return enhancedApi(query);
      case 'decrypt':
        return decryptRaw(query);
      case 'eapi_decrypt':
        return eapiDecrypt(query);
      case 'audio_match':
        return audioMatchRaw(query);
      case 'avatar_upload':
        return avatarUpload(query);
      case 'playlist_cover_update':
        return playlistCoverUpdate(query);
      case 'playlist_track_all':
        return playlistTrackAllRaw(query);
      case 'playlist_tracks':
        return playlistTracksRaw(query);
      case 'cloud':
        return cloud(query);
      case 'cloud_import':
        return cloudImportRaw(query);
      case 'cloud_upload_token':
        return cloudUploadToken(query);
      case 'cloud_upload_complete':
        return cloudUploadComplete(query);
      case 'voice_upload':
        return voiceUpload(query);
      case 'inner_version':
        return innerVersion();
      case 'login_qr_create':
        return loginQrCreate(query);
      case 'related_playlist':
        return relatedPlaylistRaw(query);
      case 'register_xeapikey':
        return registerXeapiKey(query);
      case 'register_anonimous':
        return registerAnonimousRaw(query);
      case 'scrobble':
        return scrobbleRaw(query);
      case 'song_url_v1':
        return songUrlV1Raw(query);
      case 'song_url_v1_302':
        return songUrlV1302Raw(query);
      case 'vip_sign_history':
        return vipSignHistoryRaw(query);
      case 'vip_tasks_v1':
        return vipTasksV1Raw(query);
      case 'song_url_match':
        return songUrlMatchRaw(query);
      case 'song_url_ncmget':
        return songUrlNcmgetRaw(query);
      case 'top_list':
        return topListRaw(query);
    }
    final response = await Https.dioProxy.requestUri(requestModuleDioMetaData(module, query));
    return response.data;
  }

  DioMetaData _buildRawMetaData(ApiEnhancedModule metadata, Map<String, dynamic> query) {
    final path = _requestPath(metadata, query);
    final crypto = _cryptoFromQuery(_cryptoName(query, metadata.crypto));
    final data = _requestData(metadata.module, query);
    final method = (query['method']?.toString() ?? metadata.httpMethod).toUpperCase();
    final uri = _rawUri(path, crypto, query['domain']?.toString(), data: method == 'GET' ? data : null);
    final optionsQuery = _requestOptionsQuery(metadata.module, query);
    return DioMetaData(
      uri,
      data: method == 'GET' ? null : data,
      method: method,
      options: _rawOptions(crypto, path, optionsQuery),
    );
  }

  /// Generic upstream `api` module.
  Future<dynamic> enhancedApi(Map<String, dynamic> query) async {
    final uri = query['uri']?.toString();
    if (uri == null || uri.isEmpty) {
      throw ArgumentError('uri is required');
    }
    var data = <String, dynamic>{};
    try {
      data = _asMap(query['data']);
    } catch (_) {
      data = <String, dynamic>{};
    }
    final optionsQuery = Map<String, dynamic>.from(query);
    if (data['cookie'] is String) {
      final cookies = _stringMap(data['cookie']);
      data = {...data, 'cookie': cookies};
      optionsQuery['cookie'] = cookies;
    }
    final crypto = _cryptoFromQuery(query['crypto']?.toString() ?? '');
    final metadata = DioMetaData(
      _rawUri(uri, crypto, query['domain']?.toString()),
      data: data,
      method: query['method']?.toString().toUpperCase() ?? 'POST',
      options: _rawOptions(crypto, uri, optionsQuery),
    );
    return (await Https.dioProxy.requestUri(metadata)).data;
  }

  /// Local upstream-compatible multi-crypto decrypt helper.
  dynamic decryptRaw(Map<String, dynamic> query) {
    final crypto = query['crypto']?.toString() ?? 'eapi';
    final input = query['data'] ?? query['hexString'];
    if (input == null || input == '') {
      return {
        'code': 400,
        'message': 'data is required',
      };
    }
    final isReq = query['isReq']?.toString() != 'false';

    try {
      switch (crypto) {
        case 'eapi':
          return {
            'code': 200,
            'data': isReq ? _eapiReqDecrypt(input.toString()) : eapiResDecrypt(_hexBytes(input.toString())),
          };
        case 'weapi':
          if (isReq) {
            return {
              'code': 400,
              'message': 'weapi 请求解密需要 RSA 私钥，暂不支持；仅支持 weapi 返回数据解密（e_r=true 时与 eapi 相同）',
            };
          }
          return {
            'code': 200,
            'data': eapiResDecrypt(_hexBytes(input.toString())),
          };
        case 'linuxapi':
          return {
            'code': 200,
            'data': isReq ? jsonDecode(_aesEcbDecryptHex(input.toString(), key: _linuxapiKey)) : _jsonOrValue(input),
          };
        case 'xeapi':
          if (isReq) {
            return {
              'code': 400,
              'message': 'xeapi 请求解密涉及 X25519 ECDH 密钥交换，流程复杂，暂不支持；仅支持 xeapi 返回数据解密',
            };
          }
          return {
            'code': 200,
            'data': xeapiResDecrypt(base64Decode(input.toString())),
          };
        case 'api':
          return {
            'code': 200,
            'data': _jsonOrValue(input),
          };
        default:
          return {
            'code': 400,
            'message': '未知加密方式: $crypto',
          };
      }
    } catch (error) {
      return {
        'code': 400,
        'message': '解密失败: $error',
      };
    }
  }

  /// Local upstream-compatible EAPI decrypt helper.
  dynamic eapiDecrypt(Map<String, dynamic> query) {
    final input = query['hexString'];
    if (input == null || input == '') {
      return {
        'status': 400,
        'body': {
          'code': 400,
          'message': 'hex string is required',
        },
      };
    }
    final hexString = input.toString();
    final isReq = query['isReq']?.toString() != 'false';

    try {
      return {
        'status': 200,
        'body': {
          'code': 200,
          'data': isReq ? _eapiReqDecrypt(hexString) : eapiResDecrypt(_hexBytes(hexString)),
        },
      };
    } catch (error) {
      return {
        'status': 400,
        'body': {
          'code': 400,
          'message': '解密失败: $error',
        },
      };
    }
  }

  /// Direct audio fingerprint match helper.
  Future<dynamic> audioMatchRaw(Map<String, dynamic> query) async {
    final response = await Https.dio.get(
      'https://interface.music.163.com/api/music/audio/match',
      queryParameters: {
        'sessionId': '0123456789abcdef',
        'algorithmCode': 'shazam_v2',
        'duration': query['duration'],
        'rawdata': query['audioFP'],
        'times': 1,
        'decrypt': 1,
      },
    );
    return {
      'status': response.statusCode ?? 200,
      'body': {
        'code': 200,
        'data': _asMap(response.data)['data'],
      },
    };
  }

  /// Returns the bundled upstream-compatible package version.
  dynamic innerVersion() {
    return {
      'code': 200,
      'status': 200,
      'body': {
        'code': 200,
        'data': {'version': apiEnhancedUpstreamVersion},
      },
    };
  }

  /// Builds QR login URL data.
  dynamic loginQrCreate(Map<String, dynamic> query) {
    final url = _loginQrUrl(query);
    return {
      'code': 200,
      'status': 200,
      'body': {
        'code': 200,
        'data': {
          'qrurl': url,
          'qrimg': _jsTruthy(query['qrimg']) ? _qrPngDataUrl(url) : '',
        },
      },
    };
  }

  /// Parses related playlists from the upstream playlist page HTML.
  Future<dynamic> relatedPlaylistRaw(Map<String, dynamic> query) async {
    final response = await Https.dio.get('https://music.163.com/playlist', queryParameters: {'id': query['id']});
    final html = response.data?.toString() ?? '';
    return {
      'status': response.statusCode ?? 200,
      'data': html,
      'body': {
        'code': 200,
        'playlists': _parseRelatedPlaylists(html),
      },
    };
  }

  /// Registers and persists xeapi public key state.
  Future<dynamic> registerXeapiKey(Map<String, dynamic> query) async {
    final nonce = query['nonce']?.toString() ?? generateXeApiNonce();
    final timestamp = query['timestamp']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    final deviceId = query['deviceId']?.toString() ?? XeApiStateStore.loadPublicKey()?.deviceId ?? '';
    final currentKeyVersion = query['currentKeyVersion']?.toString() ?? XeApiStateStore.loadPublicKey()?.version ?? '';
    final data = {
      'appVersion': '9.1.65',
      'currentKeyVersion': currentKeyVersion,
      'deviceId': deviceId,
      'nonce': nonce,
      'os': 'android',
      'requestType': 'active',
      'signature': xeapiSign(timestamp, nonce),
      't1': '',
      't2': '',
      'timestamp': timestamp,
      'uid': '',
    };
    final response = await Https.dio.post(
      '$_apiDomain/api/gorilla/anti/crawler/security/key/get',
      data: formEncode(data),
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'User-Agent': 'NeteaseMusic/9.1.65.240927161425(9001065);Dalvik/2.1.0 (Linux; U; Android 14; 23013RK75C Build/UKQ1.230804.001)',
          if (deviceId.isNotEmpty) HttpHeaders.cookieHeader: 'deviceId=${Uri.encodeComponent(deviceId)}',
        },
      ),
    );
    final responseData = _asMap(response.data);
    final bodyData = _asMap(responseData['data']);
    if (responseData['code'] != 200 || bodyData['encryptedData'] == null) {
      throw StateError('xeapi public key request failed');
    }
    if (bodyData['signature'] == null || xeapiSign(bodyData['timestamp'].toString(), nonce) != bodyData['signature']) {
      throw StateError('xeapi public key response signature mismatch');
    }
    final publicKeyState = xeapiDecryptPublicKey(bodyData['encryptedData'].toString(), deviceId: deviceId);
    if (publicKeyState.sk == null || publicKeyState.sk!.isEmpty) {
      throw StateError('xeapi public key response missing sk');
    }
    await XeApiStateStore.savePublicKey(publicKeyState);
    return {
      'status': 200,
      'body': publicKeyState.toJson(),
      'cookie': const <String>[],
    };
  }

  /// Anonymous login through the upstream xeapi module.
  Future<dynamic> registerAnonimousRaw(Map<String, dynamic> query) async {
    final deviceId = query['deviceId']?.toString() ?? generateXeApiDeviceId();
    if (XeApiStateStore.loadPublicKey() == null) {
      await registerXeapiKey({...query, 'deviceId': deviceId});
    }
    final response = await Https.dioProxy.postUri(
      DioMetaData(
        _rawUri('/api/register/anonimous', EncryptType.XeApi, query['domain']?.toString()),
        data: {'username': buildXeApiAnonymousUsername(deviceId)},
        options: _rawOptions(EncryptType.XeApi, '/api/register/anonimous', query),
      ),
    );
    final body = _asMap(response.data);
    if (body['code'] == 200) {
      final cookies = response.headers[HttpHeaders.setCookieHeader] ?? const <String>[];
      return {
        'status': 200,
        'body': {
          ...body,
          'cookie': cookies.join(';'),
        },
        'cookie': cookies,
      };
    }
    return body;
  }

  /// Song URL v1 xeapi module.
  Future<dynamic> songUrlV1Raw(Map<String, dynamic> query) async {
    if (query['unblock']?.toString() == 'true') {
      return {
        'status': 500,
        'body': {
          'code': 500,
          'msg': 'song_url_v1 unblock and source order depend on upstream unblockmusic-utils; use App playback fallback until a Dart replacement is available',
          'data': [],
        },
      };
    }
    final level = query['level'] ?? 'standard';
    return _xeapiPost(
      '/api/song/enhance/player/url/v1',
      {
        'ids': '[${query['id']}]',
        'level': level,
        'encodeType': 'flac',
        if (level == 'sky') 'immerseType': 'c51',
      },
      query,
    );
  }

  /// Song URL v1 302 module, including upstream download-url fallback behavior.
  Future<dynamic> songUrlV1302Raw(Map<String, dynamic> query) async {
    final level = query['level'];
    final downloadResponse = await _rawPost(
      '/api/song/enhance/download/url/v1',
      {
        'id': query['id'],
        'immerseType': 'c51',
        'level': level,
      },
      query,
    );
    final downloadUrl = _firstSongUrl(downloadResponse.data);
    if (downloadUrl.isNotEmpty) {
      return _redirectResponse(downloadUrl, downloadResponse);
    }

    final fallbackData = {
      'ids': '[${query['id']}]',
      'level': level,
      'encodeType': 'flac',
      if (level == 'sky') 'immerseType': 'c51',
    };
    final fallbackResponse = await _rawPost(
      '/api/song/enhance/player/url/v1',
      fallbackData,
      query,
    );
    final fallbackUrl = _firstSongUrl(fallbackResponse.data);
    if (fallbackUrl.isEmpty) {
      return fallbackResponse.data;
    }
    return _redirectResponse(fallbackUrl, fallbackResponse);
  }

  /// Song URL match depends on upstream Node unblockmusic-utils.
  dynamic songUrlMatchRaw(Map<String, dynamic> query) {
    return {
      'status': 500,
      'body': {
        'code': 500,
        'msg': 'song_url_match depends on upstream unblockmusic-utils and is not available in the Dart client',
        'data': [],
      },
    };
  }

  /// Upstream song_url_ncmget intentionally returns an empty successful body.
  dynamic songUrlNcmgetRaw(Map<String, dynamic> query) {
    return {
      'status': 200,
      'body': {'code': 200, 'data': []},
    };
  }

  /// Top list module mirrors the upstream idx guard before requesting by id.
  Future<dynamic> topListRaw(Map<String, dynamic> query) async {
    if (_jsTruthy(query['idx'])) {
      return {
        'status': 500,
        'body': {
          'code': 500,
          'msg': '不支持此方式调用,只支持id调用',
        },
      };
    }
    final response = await _rawPost(
      '/api/playlist/v4/detail',
      {
        'id': query['id'],
        'n': '500',
        's': '0',
      },
      query,
    );
    return response.data;
  }

  /// VIP sign history xeapi module.
  Future<dynamic> vipSignHistoryRaw(Map<String, dynamic> query) {
    return _xeapiPost('/api/vipnewcenter/app/minidesk/music/sign/pc', {'type': '0'}, query);
  }

  /// VIP task center xeapi module.
  Future<dynamic> vipTasksV1Raw(Map<String, dynamic> query) {
    return _xeapiPost(
        '/api/middle/vip/mission/user/progress/list',
        {
          'taskType': 'app_vip_task_center',
          'userId': query['id'],
        },
        query);
  }

  Future<dynamic> _xeapiPost(String path, Map<String, dynamic> data, Map<String, dynamic> query) async {
    final response = await Https.dioProxy.postUri(
      DioMetaData(
        _rawUri(path, EncryptType.XeApi, query['domain']?.toString()),
        data: data,
        options: _rawOptions(EncryptType.XeApi, path, query),
      ),
    );
    return response.data;
  }

  Future<Response<dynamic>> _rawPost(
    String path,
    Map<String, dynamic> data,
    Map<String, dynamic> query,
  ) {
    final crypto = _cryptoFromQuery(_cryptoName(query, 'eapi'));
    return Https.dioProxy.postUri(
      DioMetaData(
        _rawUri(path, crypto, query['domain']?.toString()),
        data: data,
        options: _rawOptions(crypto, path, query),
      ),
    );
  }

  /// Fetches all playlist tracks through the upstream two-step detail flow.
  Future<dynamic> playlistTrackAllRaw(Map<String, dynamic> query) async {
    final detailResponse = await _rawPost(
      '/api/v6/playlist/detail',
      {
        'id': query['id'],
        'n': 100000,
        's': _jsDefault(query['s'], 8),
      },
      query,
    );
    final trackIds = _asList(_asMap(_asMap(detailResponse.data)['playlist'])['trackIds']);
    final limit = _jsParseIntOrDefault(query['limit'], 1000);
    final offset = _jsParseIntOrDefault(query['offset'], 0);
    final selectedIds = _jsSlice(trackIds, offset, offset + limit).map(_trackIdValue).where((id) => id.isNotEmpty);
    final detailData = {
      'c': '[${selectedIds.map((id) => '{"id":$id}').join(',')}]',
    };
    final songsResponse = await _rawPost('/api/v3/song/detail', detailData, query);
    return songsResponse.data;
  }

  /// Adds or removes playlist tracks, including upstream 512 retry behavior.
  Future<dynamic> playlistTracksRaw(Map<String, dynamic> query) async {
    final tracks = _splitCommaValues(query['tracks']);
    try {
      final response = await _rawPost(
        '/api/playlist/manipulate/tracks',
        _playlistTracksData(query, tracks),
        query,
      );
      return {
        'status': 200,
        'body': _asMap(response.data),
      };
    } catch (error) {
      final body = _dioErrorBody(error);
      if (body['code'] == 512) {
        final response = await _rawPost(
          '/api/playlist/manipulate/tracks',
          _playlistTracksData(query, [...tracks, ...tracks]),
          query,
        );
        return response.data;
      }
      return {
        'status': 200,
        'body': body,
      };
    }
  }

  /// Reports listening history with upstream startplay and play weblog events.
  Future<dynamic> scrobbleRaw(Map<String, dynamic> query) async {
    final scrobbleQuery = {
      ...query,
      'cookie': _scrobbleCookie(query['cookie']),
      'domain': 'https://clientlog.music.163.com',
    };
    final startplayResponse = await _rawPost(
      '/api/feedback/weblog',
      {
        'logs': jsonEncode([
          {
            'action': 'startplay',
            'json': {
              'id': query['id'],
              'type': 'song',
              'mainsite': '1',
              'mainsiteWeb': '1',
              'content': 'id=${query['sourceid']}',
            },
          },
        ]),
      },
      scrobbleQuery,
    );
    final playResponse = await _rawPost(
      '/api/feedback/weblog',
      {
        'logs': jsonEncode([
          {
            'action': 'play',
            'json': {
              'download': 0,
              'end': 'playend',
              'id': query['id'],
              'sourceId': query['sourceid'],
              'time': query['time'],
              'type': 'song',
              'wifi': 0,
              'source': 'list',
              'mainsite': '1',
              'mainsiteWeb': '1',
              'content': 'id=${query['sourceid']}',
            },
          },
        ]),
      },
      scrobbleQuery,
    );
    return {
      'status': 200,
      'body': {
        'code': 200,
        'data': 'success',
        'details': {
          'startplay': startplayResponse.data,
          'play': playResponse.data,
        },
      },
    };
  }

  /// Uploads a user avatar image.
  Future<dynamic> avatarUpload(Map<String, dynamic> query) async {
    final uploadInfo = await _uploadImage(query);
    final response = await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/user/avatar/upload/v1'),
        data: {'imgid': uploadInfo['imgId']},
        options: _rawOptions(EncryptType.EApi, '/api/user/avatar/upload/v1', query),
      ),
    );
    return {
      'status': 200,
      'body': {
        'code': 200,
        'data': {...uploadInfo, ..._asMap(response.data)},
      },
    };
  }

  /// Uploads and updates playlist cover image.
  Future<dynamic> playlistCoverUpdate(Map<String, dynamic> query) async {
    if (!_hasUploadData(query)) {
      return {
        'status': 400,
        'body': {
          'code': 400,
          'msg': 'imgFile is required',
        },
      };
    }
    final uploadInfo = await _uploadImage(query);
    final response = await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/playlist/cover/update'),
        data: {'id': query['id'], 'coverImgId': uploadInfo['imgId']},
        options: _rawOptions(EncryptType.WeApi, '/api/playlist/cover/update', query),
      ),
    );
    return {
      'status': 200,
      'body': {
        'code': 200,
        'data': {...uploadInfo, ..._asMap(response.data)},
      },
    };
  }

  /// Cloud upload full flow.
  Future<dynamic> cloud(Map<String, dynamic> query) async {
    final token = await cloudUploadToken(query);
    final tokenBody = _asMap(token['body']);
    if (token['status'] != 200) {
      return token;
    }
    final data = _asMap(tokenBody['data']);
    if (data['needUpload'] == true && data['uploadUrl'] != null) {
      await _uploadBinary(data['uploadUrl'].toString(), query, token: data['uploadToken']?.toString(), contentMd5: data['md5']?.toString());
    }
    return cloudUploadComplete({
      ...query,
      'songId': data['songId'],
      'resourceId': data['resourceId'],
      'md5': data['md5'],
      'filename': data['filename'],
    });
  }

  /// Imports a cloud song through upstream check and import requests.
  Future<dynamic> cloudImportRaw(Map<String, dynamic> query) async {
    final songId = _jsDefault(query['id'], -2);
    final artist = _jsDefault(query['artist'], '未知');
    final album = _jsDefault(query['album'], '未知');
    final checkResponse = await _rawPost(
      '/api/cloud/upload/check/v2',
      {
        'uploadType': 0,
        'songs': jsonEncode([
          {
            'md5': query['md5'],
            'songId': songId,
            'bitrate': query['bitrate'],
            'fileSize': query['fileSize'],
          },
        ]),
      },
      query,
    );
    final cloudSongId = _cloudImportSongId(checkResponse.data);
    final importResponse = await _rawPost(
      '/api/cloud/user/song/import',
      {
        'uploadType': 0,
        'songs': jsonEncode([
          {
            'songId': cloudSongId,
            'bitrate': query['bitrate'],
            'song': query['song'],
            'artist': artist,
            'album': album,
            'fileName': '${query['song']}.${query['fileType']}',
          },
        ]),
      },
      query,
    );
    return importResponse.data;
  }

  /// Gets cloud upload token and upload URL.
  Future<dynamic> cloudUploadToken(Map<String, dynamic> query) async {
    final filename = _filename(query);
    final fileSize = query['fileSize'] ?? await _fileSize(query);
    final md5 = query['md5']?.toString();
    if (md5 == null || fileSize == null || filename.isEmpty) {
      return {
        'status': 400,
        'body': {
          'code': 400,
          'msg': '缺少必要参数: md5, fileSize, filename',
        },
      };
    }
    final bitrate = query['bitrate'] ?? 999000;
    final checkRes = await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/cloud/upload/check'),
        data: {'bitrate': '$bitrate', 'ext': '', 'length': fileSize, 'md5': md5, 'songId': '0', 'version': 1},
        options: _rawOptions(EncryptType.EApi, '/api/cloud/upload/check', query),
      ),
    );
    const bucket = 'jd-musicrep-privatecloud-audio-public';
    final tokenRes = await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/nos/token/alloc'),
        data: {
          'bucket': bucket,
          'ext': filename.contains('.') ? filename.split('.').last : 'mp3',
          'filename': filename.replaceAll(RegExp(r'\.[^.]+$'), '').replaceAll(RegExp(r'\s'), '').replaceAll('.', '_'),
          'local': false,
          'nos_product': 3,
          'type': 'audio',
          'md5': md5,
        },
        options: _rawOptions(EncryptType.WeApi, '/api/nos/token/alloc', query),
      ),
    );
    final result = _asMap(_asMap(tokenRes.data)['result']);
    if (result['objectKey'] == null) {
      return {
        'status': 500,
        'body': {
          'code': 500,
          'msg': '获取上传token失败',
          'detail': tokenRes.data,
        },
      };
    }

    dynamic lbs;
    try {
      lbs = (await Https.dio.get('https://wanproxy.127.net/lbs', queryParameters: {'version': '1.0', 'bucketname': bucket})).data;
    } catch (error) {
      return {
        'status': 500,
        'body': {
          'code': 500,
          'msg': '获取上传服务器地址失败',
          'detail': error.toString(),
        },
      };
    }
    final uploadHosts = _asMap(lbs)['upload'];
    if (uploadHosts is! List || uploadHosts.isEmpty) {
      return {
        'status': 500,
        'body': {
          'code': 500,
          'msg': '获取上传服务器地址无效',
          'detail': lbs,
        },
      };
    }
    final uploadHost = uploadHosts.first.toString();
    return {
      'status': 200,
      'body': {
        'code': 200,
        'data': {
          'needUpload': _asMap(checkRes.data)['needUpload'],
          'songId': _asMap(checkRes.data)['songId'],
          'uploadToken': result['token'],
          'objectKey': result['objectKey'],
          'resourceId': result['resourceId'],
          'uploadUrl': '$uploadHost/$bucket/${result['objectKey'].toString().replaceAll('/', '%2F')}?offset=0&complete=true&version=1.0',
          'bucket': bucket,
          'md5': md5,
          'fileSize': fileSize,
          'filename': filename,
        },
      },
      'cookie': checkRes.headers[HttpHeaders.setCookieHeader]?.join(';') ?? '',
    };
  }

  /// Completes cloud upload after binary upload has finished.
  Future<dynamic> cloudUploadComplete(Map<String, dynamic> query) async {
    final songId = query['songId'];
    final resourceId = query['resourceId'];
    final md5 = query['md5'];
    final filename = query['filename'];
    if (songId == null || resourceId == null || md5 == null || filename == null) {
      return {
        'status': 400,
        'body': {
          'code': 400,
          'msg': '缺少必要参数: songId, resourceId, md5, filename',
        },
      };
    }
    final songName = query['song'] ?? filename.toString().replaceAll(RegExp(r'\.[^.]+$'), '');
    final infoRes = await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/upload/cloud/info/v2'),
        data: {
          'md5': md5,
          'songid': songId,
          'filename': filename,
          'song': songName,
          'album': query['album'] ?? '未知专辑',
          'artist': query['artist'] ?? '未知艺术家',
          'bitrate': '${query['bitrate'] ?? 999000}',
          'resourceId': resourceId,
        },
        options: _rawOptions(EncryptType.EApi, '/api/upload/cloud/info/v2', query),
      ),
    );
    final infoBody = _asMap(infoRes.data);
    if (infoBody['code'] != 200) {
      return {
        'status': infoRes.statusCode ?? 500,
        'body': {
          'code': infoBody['code'] ?? 500,
          'msg': infoBody['msg'] ?? '上传云盘信息失败',
          'detail': infoBody,
        },
      };
    }
    final publishRes = await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/cloud/pub/v2'),
        data: {'songid': infoBody['songId']},
        options: _rawOptions(EncryptType.EApi, '/api/cloud/pub/v2', query),
      ),
    );
    return {
      'status': 200,
      'body': {
        'code': 200,
        'data': {'songId': infoBody['songId'], ..._asMap(publishRes.data)},
      },
      'cookie': infoRes.headers[HttpHeaders.setCookieHeader]?.join(';') ?? '',
    };
  }

  /// Uploads a voice file using the same module name as upstream.
  Future<dynamic> voiceUpload(Map<String, dynamic> query) async {
    final filename = _filename(query);
    if (filename.isEmpty || !_hasVoiceUploadData(query)) {
      return {
        'status': 500,
        'body': {
          'msg': '请上传音频文件',
          'code': 500,
        },
      };
    }
    final ext = _fileExtension(filename, fallback: 'mp3');
    final voiceName = query['songName']?.toString() ?? _voiceUploadName(filename, ext);
    final tokenRes = await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/nos/token/alloc'),
        data: {
          'bucket': 'ymusic',
          'ext': ext,
          'filename': voiceName,
          'local': false,
          'nos_product': 0,
          'type': 'other',
        },
        options: _rawOptions(EncryptType.WeApi, '/api/nos/token/alloc', query),
      ),
    );
    final result = _asMap(_asMap(tokenRes.data)['result']);
    final token = result['token']?.toString();
    await _uploadVoiceMultipart(
      result['objectKey'].toString(),
      query,
      token: token,
    );
    final voiceData = _voiceUploadData(
      query,
      name: voiceName,
      dfsId: result['docId'],
    );
    await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/voice/workbench/voice/batch/upload/preCheck'),
        data: {
          'dupkey': _createDupkey(),
          'voiceData': jsonEncode([voiceData]),
        },
        options: _rawOptionsWithHeaders(
          EncryptType.EApi,
          '/api/voice/workbench/voice/batch/upload/preCheck',
          query,
          {
            if (token != null) 'x-nos-token': token,
          },
        ),
      ),
    );
    final uploadRes = await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/voice/workbench/voice/batch/upload/v2'),
        data: {
          'dupkey': _createDupkey(),
          'voiceData': jsonEncode([voiceData]),
        },
        options: _rawOptionsWithHeaders(
          EncryptType.EApi,
          '/api/voice/workbench/voice/batch/upload/v2',
          query,
          {
            if (token != null) 'x-nos-token': token,
          },
        ),
      ),
    );
    return {
      'status': 200,
      'body': {
        'code': 200,
        'data': _asMap(_asMap(uploadRes.data)['data']),
      },
    };
  }

  Future<void> _uploadVoiceMultipart(
    String objectKey,
    Map<String, dynamic> query, {
    String? token,
  }) async {
    final encodedObjectKey = objectKey.replaceAll('/', '%2F');
    final contentType = _uploadMimeType(query);
    final initResponse = await Https.dio.post(
      'https://ymusic.nos-hz.163yun.com/$encodedObjectKey?uploads',
      options: Options(headers: {
        if (token != null) 'x-nos-token': token,
        'X-Nos-Meta-Content-Type': contentType,
      }),
    );
    final uploadId = _xmlText(initResponse.data?.toString() ?? '', 'UploadId');
    final bytes = await _uploadBytes(query);
    const blockSize = 10 * 1024 * 1024;
    final etags = <String>[];
    var offset = 0;
    var blockIndex = 1;
    while (offset < bytes.length) {
      final end = min(offset + blockSize, bytes.length);
      final chunk = bytes.sublist(offset, end);
      final partResponse = await Https.dio.put(
        'https://ymusic.nos-hz.163yun.com/$encodedObjectKey?partNumber=$blockIndex&uploadId=$uploadId',
        data: Stream<List<int>>.fromIterable([chunk]),
        options: Options(headers: {
          if (token != null) 'x-nos-token': token,
          'Content-Type': contentType,
        }),
      );
      etags.add(partResponse.headers.value('etag') ?? '');
      offset = end;
      blockIndex++;
    }

    final completeXml = StringBuffer('<CompleteMultipartUpload>');
    for (var i = 0; i < etags.length; i++) {
      completeXml.write('<Part><PartNumber>${i + 1}</PartNumber><ETag>${etags[i]}</ETag></Part>');
    }
    completeXml.write('</CompleteMultipartUpload>');
    await Https.dio.post(
      'https://ymusic.nos-hz.163yun.com/$encodedObjectKey?uploadId=$uploadId',
      data: completeXml.toString(),
      options: Options(headers: {
        'Content-Type': 'text/plain;charset=UTF-8',
        'X-Nos-Meta-Content-Type': contentType,
        if (token != null) 'x-nos-token': token,
      }),
    );
  }

  Future<Map<String, dynamic>> _uploadImage(Map<String, dynamic> query) async {
    final filename = _filename(query).isEmpty ? 'image.jpg' : _filename(query);
    final allocRes = await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/nos/token/alloc'),
        data: {'bucket': 'yyimgs', 'ext': 'jpg', 'filename': filename, 'local': false, 'nos_product': 0, 'return_body': '{"code":200,"size":"\$(ObjectSize)"}', 'type': 'other'},
        options: _rawOptions(EncryptType.WeApi, '/api/nos/token/alloc', query),
      ),
    );
    final result = _asMap(_asMap(allocRes.data)['result']);
    await _uploadBinary('https://nosup-hz1.127.net/yyimgs/${result['objectKey']}?offset=0&complete=true&version=1.0', query, token: result['token']?.toString());
    return {
      'url_pre': 'https://p1.music.126.net/${result['objectKey']}',
      'imgId': result['docId'],
    };
  }

  Future<void> _uploadBinary(String url, Map<String, dynamic> query, {String? token, String? contentMd5}) async {
    final data = query['bytes'] ?? query['data'] ?? (query['filePath'] != null ? await File(query['filePath'].toString()).readAsBytes() : null);
    if (data == null) {
      throw ArgumentError('filePath or bytes is required');
    }
    await Https.dio.post(
      url,
      data: data is Uint8List
          ? Stream<List<int>>.fromIterable([data])
          : data is List<int>
              ? Stream<List<int>>.fromIterable([data])
              : data,
      options: Options(headers: {
        if (token != null) 'x-nos-token': token,
        if (contentMd5 != null) 'Content-MD5': contentMd5,
        if (query['mimetype'] != null) 'Content-Type': query['mimetype'],
      }),
    );
  }
}

Map<String, dynamic> _requestData(String module, Map<String, dynamic> query) {
  switch (module) {
    case 'activate_init_profile':
      return {
        'nickname': query['nickname'],
      };
    case 'album':
      return {};
    case 'album_detail_dynamic':
      return {
        'id': query['id'],
      };
    case 'album_list_style':
      return {
        'limit': _jsDefault(query['limit'], 10),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
        'area': _jsDefault(query['area'], 'Z_H'),
      };
    case 'album_songsaleboard':
      final type = _jsDefault(query['type'], 'daily');
      return {
        'albumType': _jsDefault(query['albumType'], 0),
        if (type == 'year') 'year': query['year'],
      };
    case 'album_sub':
      return {
        'id': query['id'],
      };
    case 'album_sublist':
      return {
        'limit': _jsDefault(query['limit'], 25),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
      };
    case 'aidj_content_rcmd':
      final now = DateTime.now();
      final extInfo = <String, dynamic>{};
      if (query['latitude'] != null) {
        extInfo['lbsInfoList'] = [
          {
            'lat': query['latitude'],
            'lon': query['longitude'],
            'time': now.millisecondsSinceEpoch ~/ 1000,
          },
        ];
      }
      extInfo['noAidjToAidj'] = false;
      extInfo['lastRequestTimestamp'] = now.millisecondsSinceEpoch;
      extInfo['listenedTs'] = false;
      return {
        'extInfo': jsonEncode(extInfo),
      };
    case 'batch':
      return Map.fromEntries(
        query.entries.where((entry) => entry.key.startsWith('/api/')),
      );
    case 'calendar':
      final now = DateTime.now().millisecondsSinceEpoch;
      return {
        'startTime': _jsDefault(query['startTime'], now),
        'endTime': _jsDefault(query['endTime'], now),
      };
    case 'digitalAlbum_detail':
      return {
        'id': query['id'],
      };
    case 'digitalAlbum_ordering':
      return {
        'business': 'Album',
        'paymentMethod': query['payment'],
        'digitalResources': jsonEncode([
          {
            'business': 'Album',
            'resourceID': query['id'],
            'quantity': query['quantity'],
          },
        ]),
        'from': 'web',
      };
    case 'digitalAlbum_purchased':
      return {
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
      };
    case 'digitalAlbum_sales':
      return {
        'albumIds': query['ids'],
      };
    case 'search':
      if (query['type']?.toString() == '2000') {
        return {
          'keyword': query['keywords'],
          'scene': 'normal',
          'limit': _jsDefault(query['limit'], 30),
          'offset': _jsDefault(query['offset'], 0),
        };
      }
      return {
        's': query['keywords'],
        'type': _jsDefault(query['type'], 1),
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'cloudsearch':
      return {
        's': query['keywords'],
        'type': _jsDefault(query['type'], 1),
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
      };
    case 'search_hot':
      return {
        'type': 1111,
      };
    case 'search_match':
      return {
        'songs': jsonEncode([
          {
            'title': _jsDefault(query['title'], ''),
            'album': _jsDefault(query['album'], ''),
            'artist': _jsDefault(query['artist'], ''),
            'duration': _jsDefault(query['duration'], 0),
            if (query.containsKey('md5')) 'persistId': query['md5'],
          },
        ]),
      };
    case 'search_multimatch':
      return {
        'type': _jsDefault(query['type'], 1),
        's': _jsDefault(query['keywords'], ''),
      };
    case 'like':
      return {
        'alg': 'itembased',
        'trackId': query['id'],
        'like': query['like']?.toString() == 'false' ? false : true,
        'time': '3',
      };
    case 'hot_topic':
      return {
        'limit': _jsDefault(query['limit'], 20),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'lbs_city_code':
      return {
        'bizCode': _jsDefault(query['bizCode'], ''),
      };
    case 'music_first_listen_info':
      return {
        'songId': query['id'],
      };
    case 'personal_fm_mode':
      return {
        'mode': query['mode'],
        if (query.containsKey('submode')) 'subMode': query['submode'],
        'limit': _jsDefault(query['limit'], 3),
      };
    case 'related_allvideo':
      final id = query['id'];
      return {
        'id': id,
        'type': RegExp(r'^\d+$').hasMatch(id?.toString() ?? '') ? 0 : 1,
      };
    case 'relay_play_state_submit':
      final sessionId = _jsDefault(query['sessionId'], _generateSessionId());
      return {
        'playStateSubmitReq': jsonEncode({
          'resource': {
            'id': query['id'].toString(),
            'type': _jsDefault(query['type'], 'song'),
          },
          'progress': _jsNumberValue(query['progress']),
          'sessionId': sessionId,
          'playMode': _jsDefault(query['playMode'], 'list_loop'),
        }),
      };
    case 'resource_like':
      final prefix = _resourceTypePrefix(query['type']);
      return {
        'threadId': prefix == 'A_EV_2_' ? query['threadId'] : '$prefix${query['id']}',
      };
    case 'share_resource':
      return {
        'type': _jsDefault(query['type'], 'song'),
        'msg': _jsDefault(query['msg'], ''),
        'id': _jsDefault(query['id'], ''),
      };
    case 'simi_artist':
      return {
        'artistid': query['id'],
      };
    case 'simi_mv':
      return {
        'mvid': query['mvid'],
      };
    case 'simi_playlist':
    case 'simi_song':
    case 'simi_user':
      return {
        'songid': query['id'],
        'limit': _jsDefault(query['limit'], 50),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'song_detail':
      return {
        'c': '[${_splitIds(query['ids']).map((id) => '{"id":$id}').join(',')}]',
      };
    case 'song_url':
      return {
        'ids': jsonEncode(_splitCommaValues(query['id'])),
        'br': _songUrlBitrate(query['br']),
      };
    case 'lyric_new':
      return {
        'id': query['id'],
        'cp': false,
        'tv': 0,
        'lv': 0,
        'rv': 0,
        'kv': 0,
        'yv': 0,
        'ytv': 0,
        'yrv': 0,
      };
    case 'lyric':
      return {
        'id': query['id'],
        'tv': -1,
        'lv': -1,
        'rv': -1,
        'kv': -1,
        '_nmclfl': 1,
      };
    case 'song_music_detail':
    case 'song_dynamic_cover':
    case 'song_wiki_summary':
    case 'song_red_count':
    case 'song_lyrics_mark':
      return {
        'songId': query['id'],
      };
    case 'song_copyright_rcmd':
      return {
        'songid': _jsDefault(query['songid'], query['id']),
      };
    case 'song_creators':
      return {
        'songId': query['id'],
      };
    case 'song_like':
      return {
        'trackId': query['id'],
        'userid': query['uid'],
        'like': query['like']?.toString() != 'false',
      };
    case 'song_order_update':
      return {
        'pid': query['pid'],
        'trackIds': query['ids'],
        'op': 'update',
      };
    case 'song_chorus':
      return {
        'ids': jsonEncode([query['id']]),
      };
    case 'cloud_lyric_get':
      return {
        'userId': query['uid'],
        'songId': query['sid'],
        'lv': -1,
        'kv': -1,
      };
    case 'cloud_match':
      return {
        'userId': query['uid'],
        'songId': query['sid'],
        'adjustSongId': query['asid'],
      };
    case 'song_cloud_download':
      return {
        'songId': query['id'],
      };
    case 'song_downlist':
    case 'song_monthdownlist':
    case 'song_singledownlist':
      return {
        'limit': _jsDefault(query['limit'], '20'),
        'offset': _jsDefault(query['offset'], '0'),
        'total': 'true',
      };
    case 'song_purchased':
      return {
        'limit': _jsDefault(query['limit'], 20),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'song_lyrics_mark_add':
      return {
        'songId': query['id'],
        'markId': _jsDefault(query['markId'], ''),
        'data': _jsDefault(query['data'], '[]'),
      };
    case 'song_lyrics_mark_del':
      return {
        'markIds': query['id'],
      };
    case 'song_lyrics_mark_user_page':
      return {
        'limit': _jsDefault(query['limit'], 10),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'login':
      return {
        'type': '0',
        'https': 'true',
        'username': query['email'],
        'password': _loginPassword(query),
        'rememberLogin': 'true',
      };
    case 'login_cellphone':
      final captcha = query['captcha'];
      final hasCaptcha = _jsTruthy(captcha);
      return {
        'type': '1',
        'https': 'true',
        'phone': query['phone'],
        'countrycode': _jsDefault(query['countrycode'], '86'),
        if (!hasCaptcha && query.containsKey('captcha')) 'captcha': captcha,
        hasCaptcha ? 'captcha' : 'password': hasCaptcha ? captcha : _loginPassword(query),
        'remember': 'true',
      };
    case 'login_qr_key':
      return {
        'type': 3,
      };
    case 'login_qr_check':
      return {
        'key': query['key'],
        'type': 3,
      };
    case 'captcha_sent':
      return {
        'ctcode': _jsDefault(query['ctcode'], '86'),
        'secrete': 'music_middleuser_pclogin',
        'cellphone': query['phone'],
      };
    case 'captcha_verify':
      return {
        'ctcode': _jsDefault(query['ctcode'], '86'),
        'cellphone': query['phone'],
        'captcha': query['captcha'],
      };
    case 'cellphone_existence_check':
      return {
        'cellphone': query['phone'],
        'countrycode': query['countrycode'],
      };
    case 'creator_authinfo_get':
      return {};
    case 'countries_code_list':
      return {};
    case 'verify_getQr':
      return {
        'verifyConfigId': query['vid'],
        'verifyType': query['type'],
        'token': query['token'],
        'params': jsonEncode({
          'event_id': query['evid'],
          'sign': query['sign'],
        }),
        'size': 150,
      };
    case 'verify_qrcodestatus':
      return {
        'qrCode': query['qr'],
      };
    case 'register_cellphone':
      return {
        'captcha': query['captcha'],
        'phone': query['phone'],
        'password': _md5Hex(query['password']?.toString() ?? ''),
        'nickname': query['nickname'],
        'countrycode': _jsDefault(query['countrycode'], '86'),
        'force': 'false',
      };
    case 'rebind':
      return {
        'captcha': query['captcha'],
        'phone': query['phone'],
        'oldcaptcha': query['oldcaptcha'],
        'ctcode': _jsDefault(query['ctcode'], '86'),
      };
    case 'login_status':
    case 'login_refresh':
    case 'logout':
    case 'follow':
    case 'pl_count':
    case 'setting':
    case 'sign_happy_info':
      return {};
    case 'likelist':
      return {
        'uid': query['uid'],
      };
    case 'daily_signin':
      return {
        'type': _jsDefault(query['type'], 0),
      };
    case 'recommend_resource':
    case 'personal_fm':
    case 'homepage_dragon_ball':
      return {};
    case 'fm_trash':
      return {
        'songId': query['id'],
        'alg': 'RT',
        'time': _jsDefault(query['time'], 25),
      };
    case 'check_music':
      return {
        'ids': '[${_jsParseIntString(query['id'])}]',
        'br': _jsParseIntOrDefault(query['br'], 999000),
      };
    case 'broadcast_category_region_get':
    case 'listen_data_today_song':
    case 'listen_data_total':
    case 'listen_data_year_report':
    case 'listentogether_status':
    case 'sati_resource_sub_list':
    case 'sati_tag_list':
    case 'vip_growthpoint':
    case 'vip_sign':
    case 'vip_sign_info':
    case 'vip_tasks':
    case 'yunbei':
    case 'yunbei_info':
    case 'yunbei_sign':
    case 'yunbei_tasks':
    case 'yunbei_tasks_todo':
    case 'yunbei_today':
      return {};
    case 'broadcast_channel_collect_list':
      return {
        'contentType': 'BROADCAST',
        'limit': _jsDefault(query['limit'], '99999'),
        'timeReverseOrder': 'true',
        'startDate': '4762584922000',
      };
    case 'broadcast_channel_currentinfo':
      return {
        'channelId': query['id'],
      };
    case 'broadcast_channel_list':
      return {
        'categoryId': _jsDefault(query['categoryId'], '0'),
        'regionId': _jsDefault(query['regionId'], '0'),
        'limit': _jsDefault(query['limit'], '20'),
        'lastId': _jsDefault(query['lastId'], '0'),
        'score': _jsDefault(query['score'], '-1'),
      };
    case 'broadcast_sub':
      return {
        'contentType': 'BROADCAST',
        'contentId': query['id'],
        'cancelCollect': _jsLooseEqualsOne(query['t']) ? 'false' : 'true',
      };
    case 'radio_sport_get':
      return {
        'bpm': _jsDefault(query['bpm'], 50),
      };
    case 'listen_data_realtime_report':
      return {
        'type': _jsDefault(query['type'], 'week'),
      };
    case 'listen_data_report':
      return {
        'type': _jsDefault(query['type'], 'week'),
        if (query.containsKey('endTime')) 'endTime': query['endTime'],
      };
    case 'listentogether_accept':
      return {
        'refer': 'inbox_invite',
        'roomId': query['roomId'],
        'inviterId': query['inviterId'],
      };
    case 'listentogether_end':
    case 'listentogether_room_check':
    case 'listentogether_sync_playlist_get':
      return {
        'roomId': query['roomId'],
      };
    case 'listentogether_heatbeat':
      return {
        'roomId': query['roomId'],
        'songId': query['songId'],
        'playStatus': query['playStatus'],
        'progress': query['progress'],
      };
    case 'listentogether_play_command':
      return {
        'roomId': query['roomId'],
        'commandInfo': jsonEncode({
          if (query.containsKey('commandType')) 'commandType': query['commandType'],
          'progress': _jsDefault(query['progress'], 0),
          if (query.containsKey('playStatus')) 'playStatus': query['playStatus'],
          if (query.containsKey('formerSongId')) 'formerSongId': query['formerSongId'],
          if (query.containsKey('targetSongId')) 'targetSongId': query['targetSongId'],
          if (query.containsKey('clientSeq')) 'clientSeq': query['clientSeq'],
        }),
      };
    case 'listentogether_room_create':
      return {
        'refer': 'songplay_more',
      };
    case 'listentogether_sync_list_command':
      return {
        'roomId': query['roomId'],
        'playlistParam': jsonEncode({
          if (query.containsKey('commandType')) 'commandType': query['commandType'],
          'version': [
            {
              if (query.containsKey('userId')) 'userId': query['userId'],
              if (query.containsKey('version')) 'version': query['version'],
            },
          ],
          'anchorSongId': '',
          'anchorPosition': -1,
          'randomList': _splitCommaValues(query['randomList']),
          'displayList': _splitCommaValues(query['displayList']),
        }),
      };
    case 'vip_growthpoint_details':
      return {
        'limit': _jsDefault(query['limit'], 20),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'vip_growthpoint_get':
      return {
        'taskIds': query['ids'],
      };
    case 'vip_info':
    case 'vip_info_v2':
      return {
        'userId': _jsDefault(query['uid'], ''),
      };
    case 'vip_sign_detail':
      return {
        if (query.containsKey('timestamp')) 'signDayTime': query['timestamp'],
        'type': '1',
      };
    case 'vip_timemachine':
      if (_jsTruthy(query['startTime']) && _jsTruthy(query['endTime'])) {
        return {
          'startTime': query['startTime'],
          'endTime': query['endTime'],
          'type': 1,
          'limit': _jsDefault(query['limit'], 60),
        };
      }
      return {};
    case 'yunbei_expense':
    case 'yunbei_receipt':
      return {
        'limit': _jsDefault(query['limit'], 10),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'yunbei_rcmd_song':
      return {
        'songId': query['id'],
        'reason': _jsDefault(query['reason'], '好歌献给你'),
        'scene': '',
        'fromUserId': -1,
        'yunbeiNum': _jsDefault(query['yunbeiNum'], 10),
      };
    case 'yunbei_rcmd_song_history':
      return {
        'page': jsonEncode({
          'size': _jsDefault(query['size'], 20),
          'cursor': _jsDefault(query['cursor'], ''),
        }),
      };
    case 'yunbei_task_finish':
      return {
        'userTaskId': query['userTaskId'],
        'depositCode': _jsDefault(query['depositCode'], '0'),
      };
    case 'sati_resource_list':
      return {
        'tag': query['tag'],
        'firstQuery': false,
      };
    case 'sati_resource_list_more':
      return {
        'id': query['id'],
      };
    case 'sati_resource_sub':
      return {
        'id': query['id'],
        'cancel': _jsDefault(query['cancel'], false),
      };
    case 'sati_timescene_resources_get':
      return {
        'firstQuery': false,
      };
    case 'chart_detail':
    case 'chart_song_detail':
      return {
        'chartCode': query['chartCode'],
        'targetId': query['targetId'],
        'targetType': query['targetType'],
      };
    case 'banner':
      return {
        'clientType': _bannerClientType(query['type']),
      };
    case 'comment_music':
    case 'comment_playlist':
    case 'comment_album':
    case 'comment_dj':
    case 'comment_mv':
    case 'comment_video':
    case 'comment_hot':
      return {
        'rid': query['id'],
        'limit': _jsDefault(query['limit'], 20),
        'offset': _jsDefault(query['offset'], 0),
        'beforeTime': _jsDefault(query['before'], 0),
      };
    case 'comment_event':
      return {
        'limit': _jsDefault(query['limit'], 20),
        'offset': _jsDefault(query['offset'], 0),
        'beforeTime': _jsDefault(query['before'], 0),
      };
    case 'comment':
      return _commentData(query);
    case 'comment_report':
      return {
        'threadId': 'R_SO_4_${query['id']}',
        'commentId': query['cid'],
        'reason': query['reason'],
      };
    case 'hug_comment':
      return {
        'targetUserId': query['uid'],
        'commentId': query['cid'],
        'threadId': '${_resourceTypePrefix(_jsDefault(query['type'], 0))}${query['sid']}',
      };
    case 'comment_new':
      final pageSize = _jsDefault(query['pageSize'], 20);
      final pageNo = _jsDefault(query['pageNo'], 1);
      var sortType = _jsNumberOrDefault(query['sortType'], 99);
      if (sortType == 1) {
        sortType = 99;
      }
      return {
        'threadId': '${_resourceTypePrefix(query['type'])}${query['id']}',
        'pageNo': pageNo,
        'showInner': _jsDefault(query['showInner'], true),
        'pageSize': pageSize,
        'cursor': _commentNewCursor(
          sortType,
          pageNo: pageNo,
          pageSize: pageSize,
          query: query,
        ),
        'sortType': sortType,
      };
    case 'comment_like':
      final prefix = _resourceTypePrefix(query['type']);
      return {
        'threadId': prefix == 'A_EV_2_' ? query['threadId'] : '$prefix${query['id']}',
        'commentId': query['cid'],
      };
    case 'comment_floor':
      return {
        'parentCommentId': query['parentCommentId'],
        'threadId': '${_resourceTypePrefix(query['type'])}${query['id']}',
        'time': _jsDefault(query['time'], -1),
        'limit': _jsDefault(query['limit'], 20),
      };
    case 'comment_hug_list':
      return {
        'targetUserId': query['uid'],
        'commentId': query['cid'],
        'cursor': _jsDefault(query['cursor'], '-1'),
        'threadId': '${_resourceTypePrefix(query['type'], fallbackType: '0')}${query['sid']}',
        'pageNo': _jsDefault(query['page'], 1),
        'idCursor': _jsDefault(query['idCursor'], -1),
        'pageSize': _jsDefault(query['pageSize'], 100),
      };
    case 'comment_info_list':
      return {
        'resourceType': _resourceTypeId(_jsDefault(query['type'], 0)),
        'resourceIds': jsonEncode(_splitIds(query['ids'] ?? query['id'] ?? '')),
      };
    case 'playlist_detail':
      return {
        'id': query['id'],
        'n': 100000,
        's': _jsDefault(query['s'], 8),
      };
    case 'playlist_detail_dynamic':
      return {
        'id': query['id'],
        'n': 100000,
        's': _jsDefault(query['s'], 8),
      };
    case 'playlist_detail_rcmd_get':
      return {
        'scene': 'playlist_head',
        'playlistId': query['id'],
        'newStyle': 'true',
      };
    case 'playlist_video_recent':
      return {};
    case 'playlist_hot':
      return {};
    case 'top_playlist':
      return {
        'cat': _jsDefault(query['cat'], '全部'),
        'order': _jsDefault(query['order'], 'hot'),
        'limit': _jsDefault(query['limit'], 50),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
      };
    case 'top_playlist_highquality':
      return {
        'cat': _jsDefault(query['cat'], '全部'),
        'limit': _jsDefault(query['limit'], 50),
        'lasttime': _jsDefault(query['before'], 0),
        'total': true,
      };
    case 'playlist_subscribe':
      return {
        'id': query['id'],
        if (query['t'] is int && query['t'] == 1) 'checkToken': _jsDefault(query['checkToken'], _upstreamCheckToken),
      };
    case 'playlist_create':
      return {
        'name': query['name'],
        'privacy': _jsDefault(query['privacy'], '0'),
        'type': _jsDefault(query['type'], 'NORMAL'),
      };
    case 'playlist_delete':
      return {
        'ids': '[${query['id']}]',
      };
    case 'playlist_desc_update':
      return {
        'id': query['id'],
        'desc': query['desc'],
      };
    case 'playlist_highquality_tags':
      return {};
    case 'playlist_mylike':
      return {
        'time': _jsDefault(query['time'], '-1'),
        'limit': _jsDefault(query['limit'], '12'),
      };
    case 'playlist_category_list':
      return {
        'cat': _jsDefault(query['cat'], '全部'),
        'limit': _jsDefault(query['limit'], 24),
        'newStyle': true,
      };
    case 'playlist_name_update':
      return {
        'id': query['id'],
        'name': query['name'],
      };
    case 'playlist_order_update':
      return {
        'ids': query['ids'],
      };
    case 'playlist_privacy':
      return {
        'id': query['id'],
        'privacy': 0,
      };
    case 'playlist_subscribers':
      return {
        'id': query['id'],
        'limit': _jsDefault(query['limit'], 20),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'playlist_tags_update':
      return {
        'id': query['id'],
        'tags': query['tags'],
      };
    case 'playlist_track_add':
      return {
        'id': query['pid'],
        'tracks': jsonEncode(_playlistTrackObjects(_jsDefault(query['ids'], ''))),
      };
    case 'playlist_track_delete':
      return {
        'id': query['id'],
        'tracks': jsonEncode(_playlistTrackObjects(_jsDefault(query['ids'], ''))),
      };
    case 'playlist_import_name_task_create':
      return _playlistImportNameTaskCreateData(query);
    case 'playlist_import_task_status':
      return {
        'taskIds': jsonEncode([query['id']]),
      };
    case 'playlist_update':
      return {
        '/api/playlist/desc/update': '{"id":${query['id']},"desc":"${_jsDefault(query['desc'], '')}"}',
        '/api/playlist/tags/update': '{"id":${query['id']},"tags":"${_jsDefault(query['tags'], '')}"}',
        '/api/playlist/update/name': '{"id":${query['id']},"name":"${query['name']}"}',
      };
    case 'playlist_update_playcount':
      return {
        'id': query['id'],
      };
    case 'playlist_tracks':
      return {
        'op': query['op'],
        'pid': query['pid'],
        'trackIds': jsonEncode(_splitCommaValues(query['tracks'])),
        'imme': 'true',
      };
    case 'playmode_intelligence_list':
      return {
        'songId': query['id'],
        'type': 'fromPlayOne',
        'playlistId': query['pid'],
        'startMusicId': _jsDefault(query['sid'], query['id']),
        'count': _jsDefault(query['count'], 1),
      };
    case 'playmode_song_vector':
      return {
        'ids': query['ids'],
      };
    case 'personalized':
      return {
        'limit': _jsDefault(query['limit'], 30),
        'total': true,
        'n': 1000,
      };
    case 'homepage_block_page':
      return {
        'refresh': _jsDefault(query['refresh'], false),
        if (query.containsKey('cursor')) 'cursor': query['cursor'],
      };
    case 'personalized_newsong':
      return {
        'type': 'recommend',
        'limit': _jsDefault(query['limit'], 10),
        'areaId': _jsDefault(query['areaId'], 0),
      };
    case 'personalized_mv':
    case 'personalized_djprogram':
    case 'personalized_privatecontent':
      return {};
    case 'personalized_privatecontent_list':
      return {
        'offset': _jsDefault(query['offset'], 0),
        'total': 'true',
        'limit': _jsDefault(query['limit'], 60),
      };
    case 'program_recommend':
      return {
        'cateId': query['type'],
        'limit': _jsDefault(query['limit'], 10),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'top_song':
      return {
        'areaId': _jsDefault(query['type'], 0),
        'total': true,
      };
    case 'topic_detail':
    case 'topic_detail_event_hot':
      return {
        'actid': query['actid'],
      };
    case 'topic_sublist':
      return {
        'limit': _jsDefault(query['limit'], 50),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
      };
    case 'top_artists':
      return {
        'limit': _jsDefault(query['limit'], 50),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
      };
    case 'top_album':
      final now = DateTime.now();
      return {
        'area': _jsDefault(query['area'], 'ALL'),
        'limit': _jsDefault(query['limit'], 50),
        'offset': _jsDefault(query['offset'], 0),
        'type': _jsDefault(query['type'], 'new'),
        'year': _jsDefault(query['year'], now.year),
        'month': _jsDefault(query['month'], now.month),
        'total': false,
        'rcmd': true,
      };
    case 'album_list':
      return {
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
        'area': _jsDefault(query['area'], 'ALL'),
        if (query.containsKey('type')) 'type': query['type'],
      };
    case 'recommend_songs':
      return {
        if (query.containsKey('afresh')) 'afresh': query['afresh'],
      };
    case 'recommend_songs_dislike':
      return {
        'resId': query['id'],
        'resType': 4,
        'sceneType': 1,
      };
    case 'history_recommend_songs':
      return {};
    case 'history_recommend_songs_detail':
      return {
        'date': _jsDefault(query['date'], ''),
      };
    case 'search_hot_detail':
      return {};
    case 'search_suggest':
      return {
        's': query['keywords'] ?? '',
      };
    case 'search_suggest_pc':
      return {
        'keyword': _jsDefault(query['keyword'], ''),
      };
    case 'signin_progress':
      return {
        'moduleId': _jsDefault(query['moduleId'], '1207signin-1207signin'),
      };
    case 'starpick_comments_summary':
      return {
        'cursor': jsonEncode({
          'offset': 0,
          'blockCodeOrderList': ['HOMEPAGE_BLOCK_NEW_HOT_COMMENT'],
          'refresh': true,
        }),
      };
    case 'summary_annual':
    case 'threshold_detail_get':
      return {};
    case 'get_userids':
      return {
        'nicknames': query['nicknames'],
      };
    case 'nickname_check':
      return {
        'nickname': query['nickname'],
      };
    case 'sheet_list':
      return {
        'id': query['id'],
        'abTest': _jsDefault(query['ab'], 'b'),
      };
    case 'sheet_preview':
      return {
        'id': query['id'],
      };
    case 'user_playlist':
      return {
        'uid': query['uid'],
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
        'includeVideo': true,
      };
    case 'voice_delete':
      return {
        'ids': query['ids'],
      };
    case 'voice_detail':
      return {
        'id': query['id'],
      };
    case 'voice_lyric':
      return {
        'programId': query['id'],
      };
    case 'weblog':
      return _jsTruthy(query['data']) ? _asMap(query['data']) : <String, dynamic>{};
    case 'voicelist_detail':
      return {
        'id': query['id'],
      };
    case 'voicelist_list':
      return {
        'limit': _jsDefault(query['limit'], '200'),
        'offset': _jsDefault(query['offset'], '0'),
        'voiceListId': query['voiceListId'],
      };
    case 'voicelist_list_search':
      return {
        'limit': _jsDefault(query['limit'], '200'),
        'offset': _jsDefault(query['offset'], '0'),
        'name': _jsDefault(query['name'], null),
        'displayStatus': _jsDefault(query['displayStatus'], null),
        'type': _jsDefault(query['type'], null),
        'voiceFeeType': _jsDefault(query['voiceFeeType'], null),
        'radioId': query['voiceListId'],
      };
    case 'voicelist_my_created':
      return {
        'limit': _jsDefault(query['limit'], 20),
      };
    case 'voicelist_search':
      return {
        'keyword': query['keyword'] ?? '',
        'scene': 'normal',
        'limit': _jsDefault(query['limit'], '10'),
        'offset': _jsDefault(query['offset'], '30'),
        'e_r': true,
      };
    case 'voicelist_trans':
      return {
        'limit': _jsDefault(query['limit'], '200'),
        'offset': _jsDefault(query['offset'], '0'),
        'radioId': _jsDefault(query['radioId'], null),
        'programId': _jsDefault(query['programId'], '0'),
        'position': _jsDefault(query['position'], '1'),
      };
    case 'album_new':
      return {
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
        'area': _jsDefault(query['area'], 'ALL'),
      };
    case 'album_newest':
      return {};
    case 'artist_desc':
    case 'artist_top_song':
      return {
        'id': query['id'],
      };
    case 'artist_album':
      return {
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
      };
    case 'artist_mv':
      return {
        'artistId': query['id'],
        if (query.containsKey('limit')) 'limit': query['limit'],
        if (query.containsKey('offset')) 'offset': query['offset'],
        'total': true,
      };
    case 'artists':
      return {};
    case 'artist_songs':
      return {
        'id': query['id'],
        'private_cloud': 'true',
        'work_type': 1,
        'order': _jsDefault(query['order'], 'hot'),
        'offset': _jsDefault(query['offset'], 0),
        'limit': _jsDefault(query['limit'], 100),
      };
    case 'artist_list':
      return {
        if (_artistInitial(query['initial']) != null) 'initial': _artistInitial(query['initial']),
        'offset': _jsDefault(query['offset'], 0),
        'limit': _jsDefault(query['limit'], 30),
        'total': true,
        'type': _jsDefault(query['type'], '1'),
        if (query.containsKey('area')) 'area': query['area'],
      };
    case 'artist_detail':
    case 'artist_detail_dynamic':
      return {
        'id': query['id'],
      };
    case 'artist_fans':
      return {
        'id': query['id'],
        'limit': _jsDefault(query['limit'], 20),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'artist_follow_count':
      return {
        'id': query['id'],
      };
    case 'artist_new_mv':
    case 'artist_new_song':
      return {
        'limit': _jsDefault(query['limit'], 20),
        'startTimestamp': _jsDefault(query['before'], DateTime.now().millisecondsSinceEpoch),
      };
    case 'artist_sub':
      return {
        'artistId': query['id'],
        'artistIds': '[${query['id']}]',
      };
    case 'artist_sublist':
      return {
        'limit': _jsDefault(query['limit'], 25),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
      };
    case 'artist_video':
      return {
        'artistId': query['id'],
        'page': jsonEncode({
          'size': _jsDefault(query['size'], 10),
          'cursor': _jsDefault(query['cursor'], 0),
        }),
        'tab': 0,
        'order': _jsDefault(query['order'], 0),
      };
    case 'ugc_album_get':
      return {
        'albumId': query['id'],
      };
    case 'ugc_artist_get':
      return {
        'artistId': query['id'],
      };
    case 'ugc_artist_search':
      return {
        'keyword': query['keyword'],
        'limit': _jsDefault(query['limit'], 40),
      };
    case 'ugc_detail':
      return {
        'auditStatus': _jsDefault(query['auditStatus'], ''),
        'limit': _jsDefault(query['limit'], 10),
        'offset': _jsDefault(query['offset'], 0),
        'order': _jsDefault(query['order'], 'desc'),
        'sortBy': _jsDefault(query['sortBy'], 'createTime'),
        'type': _jsDefault(query['type'], 1),
      };
    case 'ugc_mv_get':
      return {
        'mvId': query['id'],
      };
    case 'ugc_song_get':
      return {
        'songId': query['id'],
      };
    case 'ugc_user_devote':
      return {};
    case 'event':
      return {
        'pagesize': _jsDefault(query['pagesize'], 20),
        'lasttime': _jsDefault(query['lasttime'], -1),
      };
    case 'event_del':
      return {
        'id': query['evId'],
      };
    case 'event_forward':
      return {
        'forwards': query['forwards'],
        'id': query['evId'],
        'eventUserId': query['uid'],
      };
    case 'user_detail':
      return {};
    case 'user_detail_new':
      return {
        'all': 'true',
        'userId': query['uid'],
      };
    case 'user_account':
    case 'user_subcount':
    case 'user_level':
    case 'user_binding':
      return {};
    case 'user_bindingcellphone':
      return {
        'phone': query['phone'],
        'countrycode': _jsDefault(query['countrycode'], '86'),
        'captcha': query['captcha'],
        'password': _userBindingPassword(query),
      };
    case 'user_cloud':
      return {
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'user_cloud_detail':
      return {
        'songIds': query['id'].toString().replaceAll(RegExp(r'\s'), '').split(','),
      };
    case 'user_cloud_del':
      return {
        'songIds': [query['id']],
      };
    case 'user_record':
      return {
        'uid': query['uid'],
        'type': _jsDefault(query['type'], 0),
      };
    case 'user_follows':
      return {
        'offset': _jsDefault(query['offset'], 0),
        'limit': _jsDefault(query['limit'], 30),
        'order': true,
      };
    case 'user_followeds':
      return {
        'userId': query['uid'],
        'time': '0',
        'limit': _jsDefault(query['limit'], 20),
        'offset': _jsDefault(query['offset'], 0),
        'getcounts': 'true',
      };
    case 'user_dj':
      return {
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'user_event':
      return {
        'getcounts': true,
        'time': _jsDefault(query['lasttime'], -1),
        'limit': _jsDefault(query['limit'], 30),
        'total': false,
      };
    case 'user_audio':
      return {
        'userId': query['uid'],
      };
    case 'user_comment_history':
      return {
        'compose_reminder': 'true',
        'compose_hot_comment': 'true',
        'limit': _jsDefault(query['limit'], 10),
        'user_id': query['uid'],
        'time': _jsDefault(query['time'], 0),
      };
    case 'user_playlist_collect':
    case 'user_playlist_create':
      return {
        'limit': _jsDefault(query['limit'], '100'),
        'offset': _jsDefault(query['offset'], '0'),
        'userId': query['uid'],
        'isWebview': 'true',
        'includeRedHeart': 'true',
        'includeTop': 'true',
      };
    case 'user_medal':
      return {
        'uid': query['uid'],
      };
    case 'user_mutualfollow_get':
      return {
        'friendid': query['uid'],
      };
    case 'user_replacephone':
      return {
        'phone': query['phone'],
        'captcha': query['captcha'],
        'oldcaptcha': query['oldcaptcha'],
        'countrycode': _jsDefault(query['countrycode'], '86'),
      };
    case 'user_social_status':
      return {
        'visitorId': query['uid'],
      };
    case 'user_social_status_edit':
      return {
        'content': jsonEncode({
          'type': query['type'],
          'iconUrl': query['iconUrl'],
          'content': query['content'],
          'actionUrl': query['actionUrl'],
        }),
      };
    case 'user_social_status_rcmd':
    case 'user_social_status_support':
      return {};
    case 'user_update':
      return {
        'birthday': query['birthday'],
        'city': query['city'],
        'gender': query['gender'],
        'nickname': query['nickname'],
        'province': query['province'],
        'signature': query['signature'],
      };
    case 'musician_cloudbean':
    case 'musician_data_overview':
    case 'musician_sign':
    case 'musician_tasks':
    case 'musician_tasks_new':
    case 'musician_vip_tasks':
      return {};
    case 'musician_cloudbean_obtain':
      return {
        'userMissionId': query['id'],
        'period': query['period'],
      };
    case 'musician_play_trend':
      return {
        'startTime': query['startTime'],
        'endTime': query['endTime'],
      };
    case 'style_album':
    case 'style_song':
      return {
        'cursor': _jsDefault(query['cursor'], 0),
        'size': _jsDefault(query['size'], 20),
        'tagId': query['tagId'],
        'sort': _jsDefault(query['sort'], 0),
      };
    case 'style_artist':
    case 'style_playlist':
      return {
        'cursor': _jsDefault(query['cursor'], 0),
        'size': _jsDefault(query['size'], 20),
        'tagId': query['tagId'],
        'sort': 0,
      };
    case 'style_detail':
      return {
        'tagId': query['tagId'],
      };
    case 'style_list':
    case 'style_preference':
      return {};
    case 'msg_comments':
      return {
        'beforeTime': _jsDefault(query['before'], '-1'),
        'limit': _jsDefault(query['limit'], 30),
        'total': 'true',
        'uid': query['uid'],
      };
    case 'msg_forwards':
    case 'msg_private':
      return {
        'offset': _jsDefault(query['offset'], 0),
        'limit': _jsDefault(query['limit'], 30),
        'total': 'true',
      };
    case 'msg_notices':
      return {
        'limit': _jsDefault(query['limit'], 30),
        'time': _jsDefault(query['lasttime'], -1),
      };
    case 'msg_private_history':
      return {
        'userId': query['uid'],
        'limit': _jsDefault(query['limit'], 30),
        'time': _jsDefault(query['before'], 0),
        'total': 'true',
      };
    case 'msg_recentcontact':
      return {};
    case 'send_album':
      return {
        'id': query['id'],
        'msg': _jsDefault(query['msg'], ''),
        'type': 'album',
        'userIds': '[${_jsString(query['user_ids'])}]',
      };
    case 'send_playlist':
      return {
        'id': query['playlist'],
        'type': 'playlist',
        'msg': query['msg'],
        'userIds': '[${_jsString(query['user_ids'])}]',
      };
    case 'send_song':
      return {
        'id': query['id'],
        'msg': _jsDefault(query['msg'], ''),
        'type': 'song',
        'userIds': '[${_jsString(query['user_ids'])}]',
      };
    case 'send_text':
      return {
        'type': 'text',
        'msg': query['msg'],
        'userIds': '[${_jsString(query['user_ids'])}]',
      };
    case 'fanscenter_basicinfo_age_get':
    case 'fanscenter_basicinfo_gender_get':
    case 'fanscenter_basicinfo_province_get':
    case 'fanscenter_overview_get':
      return {};
    case 'fanscenter_trend_list':
      final now = DateTime.now().millisecondsSinceEpoch;
      return {
        'startTime': _jsDefault(query['startTime'], now - 7 * 24 * 3600 * 1000),
        'endTime': _jsDefault(query['endTime'], now),
        'type': _jsDefault(query['type'], 0),
      };
    case 'mlog_music_rcmd':
      return {
        'id': _jsDefault(query['mvid'], 0),
        'type': 2,
        'rcmdType': 20,
        'limit': _jsDefault(query['limit'], 10),
        'extInfo': jsonEncode({
          if (query.containsKey('songid')) 'songId': query['songid'],
        }),
      };
    case 'mlog_to_video':
      return {
        'mlogId': query['id'],
      };
    case 'mlog_url':
      return {
        'id': query['id'],
        'resolution': _jsDefault(query['res'], 1080),
        'type': 1,
      };
    case 'mv_all':
      return {
        'tags': jsonEncode({
          '地区': _jsDefault(query['area'], '全部'),
          '类型': _jsDefault(query['type'], '全部'),
          '排序': _jsDefault(query['order'], '上升最快'),
        }),
        'offset': _jsDefault(query['offset'], 0),
        'total': 'true',
        'limit': _jsDefault(query['limit'], 30),
      };
    case 'mv_detail':
      return {
        'id': query['mvid'],
      };
    case 'mv_detail_info':
      return {
        'threadid': 'R_MV_5_${query['mvid']}',
        'composeliked': true,
      };
    case 'mv_exclusive_rcmd':
      return {
        'offset': _jsDefault(query['offset'], 0),
        'limit': _jsDefault(query['limit'], 30),
      };
    case 'mv_first':
      return {
        'area': _jsDefault(query['area'], ''),
        'limit': _jsDefault(query['limit'], 30),
        'total': true,
      };
    case 'mv_sub':
      return {
        'mvId': query['mvid'],
        'mvIds': '["${query['mvid']}"]',
      };
    case 'mv_sublist':
      return {
        'limit': _jsDefault(query['limit'], 25),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
      };
    case 'mv_url':
      return {
        'id': query['id'],
        'r': _jsDefault(query['r'], 1080),
      };
    case 'video_category_list':
      return {
        'offset': _jsDefault(query['offset'], 0),
        'total': 'true',
        'limit': _jsDefault(query['limit'], 99),
      };
    case 'video_detail':
      return {
        'id': query['id'],
      };
    case 'video_detail_info':
      return {
        'threadid': 'R_VI_62_${query['vid']}',
        'composeliked': true,
      };
    case 'video_group':
      return {
        'groupId': query['id'],
        'offset': _jsDefault(query['offset'], 0),
        'need_preview_url': 'true',
        'total': true,
      };
    case 'video_group_list':
      return {};
    case 'video_sub':
      return {
        'id': query['id'],
      };
    case 'video_timeline_all':
      return {
        'groupId': 0,
        'offset': _jsDefault(query['offset'], 0),
        'need_preview_url': 'true',
        'total': true,
      };
    case 'video_timeline_recommend':
      return {
        'offset': _jsDefault(query['offset'], 0),
        'filterLives': '[]',
        'withProgramInfo': 'true',
        'needUrl': '1',
        'resolution': '480',
      };
    case 'video_url':
      return {
        'ids': jsonEncode([query['id']?.toString() ?? '']),
        'resolution': _jsDefault(query['res'], 1080),
      };
    case 'record_recent_song':
    case 'record_recent_video':
    case 'record_recent_album':
    case 'record_recent_dj':
    case 'record_recent_playlist':
    case 'record_recent_voice':
      return {
        'limit': _jsDefault(query['limit'], 100),
      };
    case 'recent_listen_list':
      return {};
    case 'song_download_url':
      return {
        'id': query['id'],
        'br': _jsParseIntOrDefault(query['br'], 999000),
      };
    case 'song_download_url_v1':
      return {
        'id': query['id'],
        'immerseType': 'c51',
        'level': query['level'],
      };
    case 'song_like_check':
      return {
        'trackIds': query['ids'],
      };
    case 'user_follow_mixed':
      final size = _jsDefault(query['size'], 30);
      final cursor = _jsDefault(query['cursor'], 0);
      final scene = _jsDefault(query['scene'], 0);
      return {
        'authority': 'false',
        'page': jsonEncode({
          'size': size,
          'cursor': cursor,
        }),
        'scene': scene,
        'size': size,
        'sortType': '0',
      };
    case 'playlist_catlist':
    case 'toplist':
    case 'toplist_detail':
    case 'toplist_detail_v2':
      return {};
    case 'toplist_artist':
      return {
        'type': _jsDefault(query['type'], 1),
        'limit': 100,
        'offset': 0,
        'total': true,
      };
    case 'top_mv':
      return {
        'area': _jsDefault(query['area'], ''),
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
      };
    case 'djRadio_top':
      return {
        'djRadioId': _jsDefault(query['djRadioId'], null),
        'sortIndex': _jsDefault(query['sortIndex'], 1),
        'dataGapDays': _jsDefault(query['dataGapDays'], 7),
        'dataType': _jsDefault(query['dataType'], 3),
      };
    case 'dj_banner':
    case 'dj_category_excludehot':
    case 'dj_category_recommend':
    case 'dj_catelist':
    case 'dj_recommend':
      return {};
    case 'dj_detail':
      return {
        'id': query['rid'],
      };
    case 'dj_difm_all_style_channel':
    case 'dj_difm_subscribe_channels_get':
      return {
        'sources': _jsDefault(query['sources'], '[0]'),
      };
    case 'dj_difm_channel_subscribe':
    case 'dj_difm_channel_unsubscribe':
      return {
        'id': query['id'],
      };
    case 'dj_difm_playing_tracks_list':
      return {
        'limit': _jsDefault(query['limit'], 5),
        'source': _jsDefault(query['source'], 0),
        'channelId': query['channelId'],
      };
    case 'dj_hot':
      return {
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'dj_paygift':
      return {
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
        '_nmclfl': 1,
      };
    case 'dj_personalize_recommend':
      return {
        'limit': _jsDefault(query['limit'], 6),
      };
    case 'dj_program':
      return {
        'radioId': query['rid'],
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
        'asc': _jsToBoolean(query['asc']),
      };
    case 'dj_program_detail':
      return {
        'id': query['id'],
      };
    case 'dj_toplist':
      return {
        'limit': _jsDefault(query['limit'], 100),
        'offset': _jsDefault(query['offset'], 0),
        'type': _djToplistType(query['type']),
      };
    case 'dj_program_toplist':
      return {
        'limit': _jsDefault(query['limit'], 100),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'dj_program_toplist_hours':
    case 'dj_toplist_pay':
    case 'dj_toplist_hours':
    case 'dj_toplist_popular':
      return {
        'limit': _jsDefault(query['limit'], 100),
      };
    case 'dj_radio_hot':
      return {
        'cateId': query['cateId'],
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
      };
    case 'dj_recommend_type':
      return {
        'cateId': query['type'],
      };
    case 'dj_sub':
      return {
        'id': query['rid'],
      };
    case 'dj_sublist':
      return {
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
        'total': true,
      };
    case 'dj_subscriber':
      return {
        'time': _jsDefault(query['time'], '-1'),
        'id': query['id'],
        'limit': _jsDefault(query['limit'], '20'),
        'total': 'true',
      };
    case 'dj_today_perfered':
      return {
        'page': _jsDefault(query['page'], 0),
      };
    case 'dj_toplist_newcomer':
      return {
        'limit': _jsDefault(query['limit'], 100),
        'offset': _jsDefault(query['offset'], 0),
      };
  }
  final data = <String, dynamic>{};
  query.forEach((key, value) {
    if (!_rawOptionKeys.contains(key)) {
      data[key] = value;
    }
  });
  return data;
}

List<String> _splitIds(dynamic value) {
  if (value is Iterable) {
    return value.map((id) => id.toString()).where((id) => id.isNotEmpty).toList();
  }
  return value.toString().split(RegExp(r'\s*,\s*')).where((id) => id.isNotEmpty).toList();
}

List<String> _splitCommaValues(dynamic value) {
  if (value is Iterable) {
    return value.map((id) => id.toString()).toList();
  }
  return value.toString().split(',');
}

List<Map<String, dynamic>> _playlistTrackObjects(dynamic value) {
  final ids = value.toString().split(',');
  return ids.map((id) => {'type': 3, 'id': id}).toList();
}

Map<String, dynamic> _playlistImportNameTaskCreateData(Map<String, dynamic> query) {
  final data = <String, dynamic>{
    'importStarPlaylist': _jsDefault(query['importStarPlaylist'], false),
  };
  final local = query['local'];
  if (_jsTruthy(local)) {
    final rows = _asList(jsonDecode(local.toString()));
    data['multiSongs'] = jsonEncode(rows.map((entry) {
      final song = _asMap(entry);
      return {
        'songName': song['name'],
        'artistName': song['artist'],
        'albumName': song['album'],
      };
    }).toList());
    return data;
  }

  final playlistName = _jsDefault(query['playlistName'], '导入音乐 ${DateTime.now().toLocal()}');
  var songs = '';
  if (_jsTruthy(query['text'])) {
    songs = jsonEncode([
      {
        'name': playlistName,
        'type': '',
        'url': Uri.encodeFull('rpc://playlist/import?text=${query['text']}'),
      },
    ]);
  }
  if (_jsTruthy(query['link'])) {
    final links = _asList(jsonDecode(query['link'].toString()));
    songs = jsonEncode(links.map((link) {
      return {
        'name': playlistName,
        'type': '',
        'url': Uri.encodeFull(link.toString()),
      };
    }).toList());
  }
  return {
    ...data,
    'playlistName': playlistName,
    'taskIdForLog': '',
    'songs': songs,
  };
}

int _songUrlBitrate(dynamic value) {
  if (value == null || value == false || value == 0 || value == '') {
    return 999000;
  }
  return int.tryParse(value.toString()) ?? 999000;
}

dynamic _jsDefault(dynamic value, dynamic fallback) {
  if (value == null || value == false || value == 0 || value == '') {
    return fallback;
  }
  return value;
}

bool _jsTruthy(dynamic value) {
  if (value == null || value == false || value == 0 || value == '') {
    return false;
  }
  return true;
}

String _jsString(dynamic value) {
  if (value == null) {
    return 'null';
  }
  if (value is List) {
    return value.map(_jsString).join(',');
  }
  return value.toString();
}

bool _jsLooseEqualsOne(dynamic value) {
  return value == 1 || value == true || value?.toString() == '1';
}

dynamic _jsToBoolean(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value == '') {
    return value;
  }
  return value == 'true' || value?.toString() == '1';
}

dynamic _artistInitial(dynamic value) {
  if (value == null || value == false || value == '') {
    return null;
  }
  if (value is num || num.tryParse(value.toString()) != null) {
    return value;
  }
  return value.toString().toUpperCase().codeUnitAt(0);
}

dynamic _djToplistType(dynamic value) {
  final key = _jsDefault(value, 'new').toString();
  if (key == 'hot') {
    return 1;
  }
  return '0';
}

int _jsNumberOrDefault(dynamic value, int fallback) {
  if (!_jsTruthy(value)) {
    return fallback;
  }
  final parsed = num.tryParse(value.toString());
  if (parsed == null || parsed == 0) {
    return fallback;
  }
  return parsed.toInt();
}

num _jsNumberValue(dynamic value) {
  if (value is num) {
    return value;
  }
  return num.tryParse(value?.toString() ?? '') ?? 0;
}

String _resourceTypePrefix(dynamic type, {String? fallbackType}) {
  final key = type == null || type == '' ? fallbackType : type.toString();
  return _resourceTypePrefixes[key] ?? '';
}

String _resourceTypeId(dynamic type) {
  return _resourceTypeIds[type.toString()] ?? '';
}

dynamic _commentNewCursor(
  int sortType, {
  required dynamic pageNo,
  required dynamic pageSize,
  required Map<String, dynamic> query,
}) {
  switch (sortType) {
    case 99:
      return (_jsNumberValue(pageNo) - 1) * _jsNumberValue(pageSize);
    case 2:
      return 'normalHot#${(_jsNumberValue(pageNo) - 1) * _jsNumberValue(pageSize)}';
    case 3:
      return _jsDefault(query['cursor'], '0');
    default:
      return '';
  }
}

String _loginPassword(Map<String, dynamic> query) {
  final md5Password = query['md5_password'];
  if (_jsTruthy(md5Password)) {
    return md5Password.toString();
  }
  return _md5Hex(query['password']?.toString() ?? '');
}

String _userBindingPassword(Map<String, dynamic> query) {
  final password = query['password'];
  if (!_jsTruthy(password)) {
    return '';
  }
  return _md5Hex(password.toString());
}

String _md5Hex(String value) {
  return Encrypted(MD5Digest().process(Uint8List.fromList(utf8.encode(value)))).base16;
}

String? _commentAction(dynamic value) {
  switch (value?.toString()) {
    case '1':
      return 'add';
    case '0':
      return 'delete';
    case '2':
      return 'reply';
  }
  return null;
}

Map<String, dynamic> _commentData(Map<String, dynamic> query) {
  final action = _commentAction(query['t']);
  final prefix = _resourceTypePrefix(query['type']);
  return {
    'threadId': prefix == 'A_EV_2_' ? query['threadId'] : '$prefix${query['id']}',
    if (action == 'add') 'content': query['content'],
    if (action == 'delete') 'commentId': query['commentId'],
    if (action == 'reply') ...{
      'commentId': query['commentId'],
      'content': query['content'],
    },
  };
}

String _requestPath(ApiEnhancedModule metadata, Map<String, dynamic> query) {
  switch (metadata.module) {
    case 'album_songsaleboard':
      return '/api/feealbum/songsaleboard/${_jsDefault(query['type'], 'daily')}/type';
    case 'album_sub':
      return '/api/album/${query['t']?.toString() == '1' ? 'sub' : 'unsub'}';
    case 'artist_sub':
      return '/api/artist/${query['t']?.toString() == '1' ? 'sub' : 'unsub'}';
    case 'comment':
      return '/api/resource/comments/${_commentAction(query['t'])}';
    case 'comment_hot':
      return '/api/v1/resource/hotcomments/${_resourceTypePrefix(query['type'])}${query['id']}';
    case 'comment_like':
      return '/api/v1/comment/${query['t']?.toString() == '1' ? 'like' : 'unlike'}';
    case 'dj_sub':
      return '/api/djradio/${query['t']?.toString() == '1' ? 'sub' : 'unsub'}';
    case 'follow':
      return '/api/user/${query['t']?.toString() == '1' ? 'follow' : 'delfollow'}/${query['id']}';
    case 'mv_sub':
      return '/api/mv/${query['t']?.toString() == '1' ? 'sub' : 'unsub'}';
    case 'playlist_subscribe':
      return query['t']?.toString() == '1' ? '/api/playlist/subscribe' : '/api/playlist/unsubscribe';
    case 'resource_like':
      return '/api/resource/${query['t']?.toString() == '1' ? 'like' : 'unlike'}';
    case 'search':
      return query['type']?.toString() == '2000' ? '/api/search/voice/get' : '/api/search/get';
    case 'search_suggest':
      return '/api/search/suggest/${query['type'] == 'mobile' ? 'keyword' : 'web'}';
    case 'summary_annual':
      final key = query['year'] == '2017' || query['year'] == '2018' || query['year'] == '2019' ? 'userdata' : 'data';
      return '/api/activity/summary/annual/${query['year']}/$key';
    case 'video_sub':
      return '/api/cloudvideo/video/${query['t']?.toString() == '1' ? 'sub' : 'unsub'}';
  }
  return _resolvePath(metadata.pathTemplate, query);
}

Map<String, dynamic> _requestOptionsQuery(String module, Map<String, dynamic> query) {
  switch (module) {
    case 'playlist_subscribe':
      return {
        ...query,
        'checkToken': true,
      };
  }
  return query;
}

String _firstSongUrl(dynamic value) {
  final data = _asMap(value)['data'];
  if (data is! List || data.isEmpty) {
    return '';
  }
  final first = data.first;
  if (first is! Map) {
    return '';
  }
  return first['url']?.toString() ?? '';
}

Map<String, dynamic> _redirectResponse(String url, Response<dynamic> response) {
  return {
    'status': 302,
    'body': '',
    'cookie': response.headers[HttpHeaders.setCookieHeader] ?? const <String>[],
    'redirectUrl': url,
  };
}

List<dynamic> _asList(dynamic value) {
  return value is List ? value : const [];
}

String _trackIdValue(dynamic value) {
  if (value is Map) {
    return value['id']?.toString() ?? '';
  }
  return value?.toString() ?? '';
}

Map<String, dynamic> _playlistTracksData(Map<String, dynamic> query, List<String> tracks) {
  return {
    'op': query['op'],
    'pid': query['pid'],
    'trackIds': jsonEncode(tracks),
    'imme': 'true',
  };
}

Map<String, dynamic> _dioErrorBody(Object error) {
  if (error is DioException) {
    return _asMap(error.response?.data);
  }
  return <String, dynamic>{};
}

dynamic _cloudImportSongId(dynamic value) {
  final data = _asMap(value)['data'];
  if (data is List && data.isNotEmpty) {
    return _asMap(data.first)['songId'];
  }
  return null;
}

int _jsParseIntOrDefault(dynamic value, int fallback) {
  if (value == null || value == false) {
    return fallback;
  }
  final match = RegExp(r'^\s*[+-]?\d+').firstMatch(value.toString());
  if (match == null) {
    return fallback;
  }
  final parsed = int.tryParse(match.group(0)!.trim());
  if (parsed == null || parsed == 0) {
    return fallback;
  }
  return parsed;
}

String _jsParseIntString(dynamic value) {
  final match = RegExp(r'^\s*[+-]?\d+').firstMatch(value?.toString() ?? '');
  if (match == null) {
    return 'NaN';
  }
  return int.tryParse(match.group(0)!.trim())?.toString() ?? 'NaN';
}

String _bannerClientType(dynamic value) {
  const clientTypes = {
    '0': 'pc',
    '1': 'android',
    '2': 'iphone',
    '3': 'ipad',
  };
  return clientTypes[_jsDefault(value, 0).toString()] ?? 'pc';
}

List<dynamic> _jsSlice(List<dynamic> values, int start, int end) {
  int normalize(int index) {
    if (index < 0) {
      final fromEnd = values.length + index;
      return fromEnd < 0 ? 0 : fromEnd;
    }
    return index > values.length ? values.length : index;
  }

  final normalizedStart = normalize(start);
  final normalizedEnd = normalize(end);
  if (normalizedEnd <= normalizedStart) {
    return const [];
  }
  return values.sublist(normalizedStart, normalizedEnd);
}

dynamic _scrobbleCookie(dynamic cookie) {
  if (cookie is Map) {
    return {'os': 'osx', ..._stringMap(cookie)};
  }
  final text = cookie?.toString() ?? '';
  if (text.contains('os=')) {
    return text.replaceAll(RegExp(r'os=[^;]+'), 'os=osx');
  }
  return '$text; os=osx';
}

String _loginQrUrl(Map<String, dynamic> query) {
  final key = query['key']?.toString() ?? '';
  final url = StringBuffer('https://music.163.com/login?codekey=$key');
  if ((query['platform']?.toString() ?? 'pc') == 'web') {
    url.write('&chainId=${Uri.encodeQueryComponent(_generateChainId(query['cookie']))}');
  }
  return url.toString();
}

String _generateChainId(dynamic cookie) {
  final randomNum = DateTime.now().microsecondsSinceEpoch.remainder(1000000);
  final deviceId = _cookieValue(cookie, 'sDeviceId') ?? 'unknown-$randomNum';
  return 'v1_${deviceId}_web_login_${DateTime.now().millisecondsSinceEpoch}';
}

String? _cookieValue(dynamic cookie, String name) {
  final cookies = _stringMap(cookie);
  final value = cookies[name];
  return value == null || value.isEmpty ? null : value;
}

List<Map<String, dynamic>> _parseRelatedPlaylists(String html) {
  final pattern = RegExp(
    r'<div class="cver u-cover u-cover-3">[\s\S]*?<img src="([^"]+)">[\s\S]*?<a class="sname f-fs1 s-fc0" href="([^"]+)"[^>]*>([^<]+?)</a>[\s\S]*?<a class="nm nm f-thide s-fc3" href="([^"]+)"[^>]*>([^<]+?)</a>',
  );
  return pattern.allMatches(html).map((match) {
    final coverUrl = match.group(1)!;
    final playlistHref = match.group(2)!;
    final creatorHref = match.group(4)!;
    return {
      'creator': {
        'userId': creatorHref.startsWith('/user/home?id=') ? creatorHref.substring('/user/home?id='.length) : creatorHref,
        'nickname': match.group(5),
      },
      'coverImgUrl': coverUrl.endsWith('?param=50y50') ? coverUrl.substring(0, coverUrl.length - '?param=50y50'.length) : coverUrl,
      'name': match.group(3),
      'id': playlistHref.startsWith('/playlist?id=') ? playlistHref.substring('/playlist?id='.length) : playlistHref,
    };
  }).toList(growable: false);
}

String _qrPngDataUrl(String data) {
  final qrCode = QrCode.fromData(
    data: data,
    errorCorrectLevel: QrErrorCorrectLevel.M,
  );
  final qrImage = QrImage(qrCode);
  const quietZone = 4;
  const scale = 4;
  final modules = qrImage.moduleCount + quietZone * 2;
  final size = modules * scale;
  final raw = <int>[];
  for (var y = 0; y < size; y++) {
    raw.add(0);
    final row = y ~/ scale - quietZone;
    for (var x = 0; x < size; x++) {
      final col = x ~/ scale - quietZone;
      final dark = row >= 0 && row < qrImage.moduleCount && col >= 0 && col < qrImage.moduleCount && qrImage.isDark(row, col);
      raw.add(dark ? 0 : 255);
    }
  }
  final bytes = <int>[
    0x89,
    0x50,
    0x4e,
    0x47,
    0x0d,
    0x0a,
    0x1a,
    0x0a,
    ..._pngChunk('IHDR', [
      ..._uint32Bytes(size),
      ..._uint32Bytes(size),
      8,
      0,
      0,
      0,
      0,
    ]),
    ..._pngChunk('IDAT', ZLibEncoder().convert(raw)),
    ..._pngChunk('IEND', const []),
  ];
  return 'data:image/png;base64,${base64Encode(bytes)}';
}

List<int> _pngChunk(String type, List<int> data) {
  final typeBytes = ascii.encode(type);
  return [
    ..._uint32Bytes(data.length),
    ...typeBytes,
    ...data,
    ..._uint32Bytes(_crc32([...typeBytes, ...data])),
  ];
}

List<int> _uint32Bytes(int value) {
  return [
    (value >> 24) & 0xff,
    (value >> 16) & 0xff,
    (value >> 8) & 0xff,
    value & 0xff,
  ];
}

int _crc32(List<int> bytes) {
  var crc = 0xffffffff;
  for (final byte in bytes) {
    crc ^= byte;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 1) == 1 ? (crc >> 1) ^ 0xedb88320 : crc >> 1;
    }
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  if (value is String && value.isNotEmpty) {
    final decoded = jsonDecode(value);
    return decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
  }
  return <String, dynamic>{};
}

EncryptType _cryptoFromQuery(String crypto) {
  switch (crypto) {
    case 'eapi':
      return EncryptType.EApi;
    case 'linuxapi':
      return EncryptType.LinuxForward;
    case 'api':
      return EncryptType.Api;
    case 'xeapi':
      return EncryptType.XeApi;
    case 'weapi':
    case '':
    default:
      return EncryptType.WeApi;
  }
}

String _cryptoName(Map<String, dynamic> query, String fallback) {
  final override = query['crypto']?.toString();
  if (override != null && override.isNotEmpty) {
    return override;
  }
  return fallback.isEmpty ? 'eapi' : fallback;
}

Options _rawOptions(EncryptType crypto, String path, Map<String, dynamic> query) {
  return joinOptions(
    encryptType: crypto,
    eApiUrl: path,
    realIP: query['realIP']?.toString(),
    rawUserAgent: query['ua']?.toString(),
    domain: query['domain']?.toString(),
    checkToken: _boolOption(query['checkToken']),
    randomCNIP: _boolOption(query['randomCNIP']),
    proxy: query['proxy']?.toString(),
    encryptedResponse: query.containsKey('e_r') ? _boolOption(query['e_r']) : null,
    cookies: _stringMap(query['cookie']),
  );
}

Options _rawOptionsWithHeaders(
  EncryptType crypto,
  String path,
  Map<String, dynamic> query,
  Map<String, String> headers,
) {
  final options = _rawOptions(crypto, path, query);
  options.headers = {...?options.headers, ...headers};
  return options;
}

bool _boolOption(dynamic value) {
  if (value is bool) {
    return value;
  }
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}

Map<String, String> _stringMap(dynamic value) {
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value.toString()));
  }
  if (value is String && value.trim().isNotEmpty) {
    final result = <String, String>{};
    for (final part in value.split(';')) {
      final index = part.indexOf('=');
      if (index > 0) {
        result[Uri.decodeComponent(part.substring(0, index).trim())] = Uri.decodeComponent(part.substring(index + 1).trim());
      }
    }
    return result;
  }
  return const {};
}

Uri _rawUri(String path, EncryptType crypto, String? domain, {Map<String, dynamic>? data}) {
  final base = domain ??
      (crypto == EncryptType.XeApi
          ? _xeapiDomain
          : crypto == EncryptType.EApi || crypto == EncryptType.Api
              ? _apiDomain
              : HOST);
  var uri = Uri.parse(path.startsWith('http') ? path : '$base$path');
  if (data != null && data.isNotEmpty) {
    uri = uri.replace(queryParameters: {...uri.queryParameters, ...data.map((key, value) => MapEntry(key, value?.toString() ?? ''))});
  }
  return uri;
}

String _resolvePath(String template, Map<String, dynamic> query) {
  return template.replaceAllMapped(RegExp(r'\$\{([^}]+)\}'), (match) {
    final expr = match.group(1)!.trim();
    if (expr.startsWith('query.')) {
      return Uri.encodeComponent(query[expr.substring(6)]?.toString() ?? '');
    }
    return Uri.encodeComponent(query[expr]?.toString() ?? '');
  });
}

dynamic _eapiReqDecrypt(String hexString) {
  final text = _aesEcbDecryptHex(hexString);
  final match = RegExp(r'(.*?)-36cd479b6b5-(.*?)-36cd479b6b5-(.*)').firstMatch(text);
  if (match == null) {
    return null;
  }
  return {
    'url': match.group(1),
    'data': jsonDecode(match.group(2)!),
  };
}

dynamic _jsonOrValue(dynamic value) {
  if (value is! String) {
    return value;
  }
  return jsonDecode(value);
}

List<int> _hexBytes(String hexString) {
  return Encrypted.fromBase16(hexString.replaceAll(RegExp(r'\s+'), '')).bytes;
}

String _aesEcbDecryptHex(String hexString, {String key = _eapiKey}) {
  final encrypted = Encrypted.fromBase16(hexString.replaceAll(RegExp(r'\s+'), ''));
  final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.ecb));
  return encrypter.decrypt(encrypted, iv: IV.fromLength(0));
}

String _filename(Map<String, dynamic> query) {
  final explicit = query['filename'] ?? query['name'];
  if (explicit != null) {
    return explicit.toString();
  }
  final songFileName = _songFileMap(query)['name'];
  if (songFileName != null) {
    return songFileName.toString();
  }
  final filePath = query['filePath']?.toString();
  if (filePath != null && filePath.isNotEmpty) {
    return filePath.split(Platform.pathSeparator).last;
  }
  final tempFilePath = _songFileMap(query)['tempFilePath']?.toString();
  if (tempFilePath != null && tempFilePath.isNotEmpty) {
    return tempFilePath.split(Platform.pathSeparator).last;
  }
  return '';
}

bool _hasUploadData(Map<String, dynamic> query) {
  final filePath = query['filePath']?.toString();
  return query['bytes'] != null || query['data'] != null || query['imgFile'] != null || (filePath != null && filePath.isNotEmpty);
}

bool _hasVoiceUploadData(Map<String, dynamic> query) {
  final songFile = _songFileMap(query);
  final filePath = query['filePath']?.toString();
  final tempFilePath = songFile['tempFilePath']?.toString();
  return query['bytes'] != null || query['data'] != null || songFile['data'] != null || (filePath != null && filePath.isNotEmpty) || (tempFilePath != null && tempFilePath.isNotEmpty);
}

String _fileExtension(String filename, {String fallback = ''}) {
  final basename = filename.split(Platform.pathSeparator).last;
  final index = basename.lastIndexOf('.');
  if (index < 0 || index == basename.length - 1) {
    return fallback;
  }
  return basename.substring(index + 1);
}

String _voiceUploadName(String filename, String ext) {
  final withoutExt = ext.isEmpty ? filename : filename.replaceFirst('.$ext', '');
  return withoutExt.replaceAll(RegExp(r'\s'), '').replaceAll('.', '_');
}

Map<String, dynamic> _voiceUploadData(
  Map<String, dynamic> query, {
  required String name,
  required dynamic dfsId,
}) {
  final data = <String, dynamic>{
    'name': name,
    'autoPublish': _looseEqualsOne(query['autoPublish']),
    'autoPublishText': query['autoPublishText'] ?? '',
    'dfsId': dfsId,
    'composedSongs': _splitCommaValuesOrEmpty(query['composedSongs']),
    'privacy': _looseEqualsOne(query['privacy']),
    'publishTime': query['publishTime'] ?? 0,
    'orderNo': query['orderNo'] ?? 1,
  };
  for (final key in ['description', 'voiceListId', 'coverImgId', 'categoryId', 'secondCategoryId']) {
    if (query.containsKey(key) && query[key] != null) {
      data[key] = query[key];
    }
  }
  return data;
}

bool _looseEqualsOne(dynamic value) {
  return value == true || value == 1 || value?.toString() == '1';
}

List<String> _splitCommaValuesOrEmpty(dynamic value) {
  if (!_jsTruthy(value)) {
    return const [];
  }
  return value.toString().split(',');
}

String _uploadMimeType(Map<String, dynamic> query) {
  return query['mimetype']?.toString() ?? query['contentType']?.toString() ?? _songFileMap(query)['mimetype']?.toString() ?? 'audio/mpeg';
}

Future<Uint8List> _uploadBytes(Map<String, dynamic> query) async {
  final songFile = _songFileMap(query);
  final inMemory = _bytesFromUploadValue(query['bytes'] ?? query['data'] ?? songFile['data']);
  if (inMemory != null) {
    return inMemory;
  }
  final filePath = query['filePath']?.toString();
  if (filePath != null && filePath.isNotEmpty) {
    return File(filePath).readAsBytes();
  }
  final tempFilePath = songFile['tempFilePath']?.toString();
  if (tempFilePath != null && tempFilePath.isNotEmpty) {
    return File(tempFilePath).readAsBytes();
  }
  throw ArgumentError('filePath or bytes is required');
}

Uint8List? _bytesFromUploadValue(dynamic value) {
  if (value is Uint8List) {
    return value;
  }
  if (value is List<int>) {
    return Uint8List.fromList(value);
  }
  if (value is List && value.every((item) => item is num)) {
    return Uint8List.fromList(value.map((item) => (item as num).toInt()).toList(growable: false));
  }
  return null;
}

Map<String, dynamic> _songFileMap(Map<String, dynamic> query) {
  final songFile = query['songFile'];
  if (songFile is Map<String, dynamic>) {
    return songFile;
  }
  if (songFile is Map) {
    return Map<String, dynamic>.from(songFile);
  }
  return const {};
}

String _xmlText(String xml, String tag) {
  final match = RegExp('<$tag>([\\s\\S]*?)</$tag>').firstMatch(xml);
  final value = match?.group(1)?.trim() ?? '';
  if (value.isEmpty) {
    throw StateError('$tag is missing from XML response');
  }
  return value;
}

String _generateSessionId() {
  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return List.generate(12, (_) => alphabet[random.nextInt(alphabet.length)]).join();
}

String _createDupkey() {
  const hexDigits = '0123456789abcdef';
  final random = Random();
  final chars = List.generate(36, (_) => hexDigits[random.nextInt(16)]);
  chars[14] = '4';
  chars[19] = hexDigits[(int.parse(chars[19], radix: 16) & 0x3) | 0x8];
  chars[8] = chars[13] = chars[18] = chars[23] = '-';
  return chars.join();
}

Future<int?> _fileSize(Map<String, dynamic> query) async {
  final bytes = query['bytes'];
  if (bytes is List<int>) {
    return bytes.length;
  }
  final filePath = query['filePath']?.toString();
  if (filePath != null && filePath.isNotEmpty) {
    return File(filePath).length();
  }
  return null;
}
