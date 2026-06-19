// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/digests/md5.dart';

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
    final data = _asMap(query['data']);
    final crypto = _cryptoFromQuery(query['crypto']?.toString() ?? '');
    final metadata = DioMetaData(
      _rawUri(uri, crypto, query['domain']?.toString()),
      data: data,
      method: query['method']?.toString().toUpperCase() ?? 'POST',
      options: _rawOptions(crypto, uri, query),
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
        'code': 400,
        'message': 'hex string is required',
      };
    }
    final hexString = input.toString();
    final isReq = query['isReq']?.toString() != 'false';

    try {
      return {
        'code': 200,
        'data': isReq ? _eapiReqDecrypt(hexString) : eapiResDecrypt(_hexBytes(hexString)),
      };
    } catch (error) {
      return {
        'code': 400,
        'message': '解密失败: $error',
      };
    }
  }

  /// Direct audio fingerprint match helper.
  Future<dynamic> audioMatchRaw(Map<String, dynamic> query) async {
    final response = await Https.dio.get(
      'https://interface.music.163.com/api/music/audio/match',
      queryParameters: {
        'sessionId': query['sessionId'] ?? '0123456789abcdef',
        'algorithmCode': query['algorithmCode'] ?? 'shazam_v2',
        'duration': query['duration'],
        'rawdata': query['audioFP'] ?? query['rawdata'],
        'times': query['times'] ?? 1,
        'decrypt': query['decrypt'] ?? 1,
      },
    );
    return {'code': 200, 'data': _asMap(response.data)['data']};
  }

  /// Returns the bundled upstream-compatible package version.
  dynamic innerVersion() {
    return {
      'code': 200,
      'data': {'version': '0.1.0'}
    };
  }

  /// Builds QR login URL data.
  dynamic loginQrCreate(Map<String, dynamic> query) {
    final key = query['key']?.toString() ?? '';
    return {
      'code': 200,
      'data': {
        'qrurl': 'https://music.163.com/login?codekey=$key',
        'qrimg': '',
      },
    };
  }

  /// Loads related playlist HTML. Existing typed API keeps the parsed version.
  Future<dynamic> relatedPlaylistRaw(Map<String, dynamic> query) async {
    final response = await Https.dio.get('https://music.163.com/playlist', queryParameters: {'id': query['id']});
    return response.data;
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
    return publicKeyState.toJson();
  }

  /// Anonymous login through the upstream xeapi module.
  Future<dynamic> registerAnonimousRaw(Map<String, dynamic> query) async {
    final deviceId = query['deviceId']?.toString() ?? generateXeApiDeviceId();
    if (XeApiStateStore.loadPublicKey() == null) {
      await registerXeapiKey({...query, 'deviceId': deviceId});
    }
    final cookies = {..._stringMap(query['cookie']), 'deviceId': deviceId};
    final response = await Https.dioProxy.postUri(
      DioMetaData(
        _rawUri('/api/register/anonimous', EncryptType.XeApi, query['domain']?.toString()),
        data: {'username': buildXeApiAnonymousUsername(deviceId)},
        options: _rawOptions(EncryptType.XeApi, '/api/register/anonimous', {...query, 'cookie': cookies}),
      ),
    );
    final body = _asMap(response.data);
    if (body['code'] == 200) {
      return {
        ...body,
        'cookie': response.headers[HttpHeaders.setCookieHeader]?.join(';') ?? '',
      };
    }
    return body;
  }

  /// Song URL v1 xeapi module.
  Future<dynamic> songUrlV1Raw(Map<String, dynamic> query) async {
    if (query['unblock']?.toString() == 'true') {
      return {
        'code': 500,
        'msg': 'song_url_v1 unblock depends on upstream unblockmusic-utils; use song_url_match when a Dart replacement is available',
        'data': [],
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
      'code': 500,
      'msg': 'song_url_match depends on upstream unblockmusic-utils and is not available in the Dart client',
      'data': [],
    };
  }

  /// Upstream song_url_ncmget intentionally returns an empty successful body.
  dynamic songUrlNcmgetRaw(Map<String, dynamic> query) {
    return {'code': 200, 'data': []};
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
      'code': 200,
      'data': {...uploadInfo, ..._asMap(response.data)}
    };
  }

  /// Uploads and updates playlist cover image.
  Future<dynamic> playlistCoverUpdate(Map<String, dynamic> query) async {
    final uploadInfo = await _uploadImage(query);
    final response = await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/playlist/cover/update'),
        data: {'id': query['id'], 'coverImgId': uploadInfo['imgId']},
        options: _rawOptions(EncryptType.WeApi, '/api/playlist/cover/update', query),
      ),
    );
    return {
      'code': 200,
      'data': {...uploadInfo, ..._asMap(response.data)}
    };
  }

  /// Cloud upload full flow.
  Future<dynamic> cloud(Map<String, dynamic> query) async {
    final token = await cloudUploadToken(query);
    final data = _asMap(token['data']);
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
      throw ArgumentError('md5, fileSize and filename are required');
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
    final lbs = (await Https.dio.get('https://wanproxy.127.net/lbs', queryParameters: {'version': '1.0', 'bucketname': bucket})).data;
    final uploadHost = _asMap(lbs)['upload'] is List && (_asMap(lbs)['upload'] as List).isNotEmpty ? (_asMap(lbs)['upload'] as List).first.toString() : '';
    final result = _asMap(_asMap(tokenRes.data)['result']);
    return {
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
    };
  }

  /// Completes cloud upload after binary upload has finished.
  Future<dynamic> cloudUploadComplete(Map<String, dynamic> query) async {
    final songId = query['songId'];
    final resourceId = query['resourceId'];
    final md5 = query['md5'];
    final filename = query['filename'];
    if (songId == null || resourceId == null || md5 == null || filename == null) {
      throw ArgumentError('songId, resourceId, md5 and filename are required');
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
    final publishRes = await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/cloud/pub/v2'),
        data: {'songid': _asMap(infoRes.data)['songId']},
        options: _rawOptions(EncryptType.EApi, '/api/cloud/pub/v2', query),
      ),
    );
    return {
      'code': 200,
      'data': {'songId': _asMap(infoRes.data)['songId'], ..._asMap(publishRes.data)},
    };
  }

  /// Uploads a voice file using the same module name as upstream.
  Future<dynamic> voiceUpload(Map<String, dynamic> query) async {
    final filename = _filename(query);
    final tokenRes = await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/nos/token/alloc'),
        data: {
          'bucket': 'ymusic',
          'ext': filename.contains('.') ? filename.split('.').last : 'mp3',
          'filename': query['songName'] ?? filename.replaceAll(RegExp(r'\.[^.]+$'), '').replaceAll(RegExp(r'\s'), '').replaceAll('.', '_'),
          'local': false,
          'nos_product': 0,
          'type': 'other',
        },
        options: _rawOptions(EncryptType.WeApi, '/api/nos/token/alloc', query),
      ),
    );
    final result = _asMap(_asMap(tokenRes.data)['result']);
    final objectKey = result['objectKey'].toString().replaceAll('/', '%2F');
    await _uploadBinary('https://ymusic.nos-hz.163yun.com/$objectKey?offset=0&complete=true&version=1.0', query, token: result['token']?.toString());
    final uploadRes = await Https.dioProxy.postUri(
      DioMetaData(
        joinUri('/api/voice/workbench/voice/batch/upload/v2'),
        data: {
          'dupkey': DateTime.now().microsecondsSinceEpoch.toString(),
          'voiceData': jsonEncode([
            {
              'name': query['songName'] ?? filename,
              'autoPublish': query['autoPublish'] == 1,
              'autoPublishText': query['autoPublishText'] ?? '',
              'description': query['description'],
              'voiceListId': query['voiceListId'],
              'coverImgId': query['coverImgId'],
              'dfsId': result['docId'],
              'categoryId': query['categoryId'],
              'secondCategoryId': query['secondCategoryId'],
              'composedSongs': query['composedSongs']?.toString().split(',') ?? [],
              'privacy': query['privacy'] == 1,
              'publishTime': query['publishTime'] ?? 0,
              'orderNo': query['orderNo'] ?? 1,
            }
          ]),
        },
        options: _rawOptions(EncryptType.EApi, '/api/voice/workbench/voice/batch/upload/v2', query),
      ),
    );
    return {'code': 200, 'data': _asMap(_asMap(uploadRes.data)['data'])};
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
    case 'album':
      return {};
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
    case 'like':
      return {
        'alg': 'itembased',
        'trackId': query['id'],
        'like': query['like']?.toString() == 'false' ? false : true,
        'time': '3',
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
    case 'comment_music':
    case 'comment_playlist':
    case 'comment_hot':
      return {
        'rid': query['id'],
        'limit': _jsDefault(query['limit'], 20),
        'offset': _jsDefault(query['offset'], 0),
        'beforeTime': _jsDefault(query['before'], 0),
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
    case 'playlist_tracks':
      return {
        'op': query['op'],
        'pid': query['pid'],
        'trackIds': jsonEncode(_splitCommaValues(query['tracks'])),
        'imme': 'true',
      };
    case 'personalized':
      return {
        'limit': _jsDefault(query['limit'], 30),
        'total': true,
        'n': 1000,
      };
    case 'recommend_songs':
      return {
        if (query.containsKey('afresh')) 'afresh': query['afresh'],
      };
    case 'search_hot_detail':
      return {};
    case 'user_playlist':
      return {
        'uid': query['uid'],
        'limit': _jsDefault(query['limit'], 30),
        'offset': _jsDefault(query['offset'], 0),
        'includeVideo': true,
      };
    case 'voicelist_search':
      return {
        'keyword': query['keyword'] ?? '',
        'scene': 'normal',
        'limit': _jsDefault(query['limit'], '10'),
        'offset': _jsDefault(query['offset'], '30'),
        'e_r': true,
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
  return Encrypted(MD5Digest().process(Uint8List.fromList(utf8.encode(query['password']?.toString() ?? '')))).base16;
}

String _requestPath(ApiEnhancedModule metadata, Map<String, dynamic> query) {
  switch (metadata.module) {
    case 'comment_hot':
      return '/api/v1/resource/hotcomments/${_resourceTypePrefix(query['type'])}${query['id']}';
    case 'comment_like':
      return '/api/v1/comment/${query['t']?.toString() == '1' ? 'like' : 'unlike'}';
    case 'playlist_subscribe':
      return query['t']?.toString() == '1' ? '/api/playlist/subscribe' : '/api/playlist/unsubscribe';
    case 'search':
      return query['type']?.toString() == '2000' ? '/api/search/voice/get' : '/api/search/get';
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
  final filePath = query['filePath']?.toString();
  if (filePath != null && filePath.isNotEmpty) {
    return filePath.split(Platform.pathSeparator).last;
  }
  return '';
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
