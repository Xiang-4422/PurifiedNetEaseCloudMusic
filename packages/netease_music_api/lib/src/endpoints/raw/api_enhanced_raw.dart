// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';

import '../../client/dio_ext.dart';
import '../../client/netease_handler.dart';
import '../../generated/api_enhanced_module.dart';
import '../../generated/api_enhanced_modules.g.dart';

part 'api_enhanced_raw_methods.g.dart';

const _apiDomain = 'https://interface.music.163.com';
const _eapiKey = 'e82ckenh8dichen8';

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
    return _buildRawMetaData(metadata, query);
  }

  /// Calls a raw api-enhanced module and returns the raw response body.
  Future<dynamic> requestModule(String module, Map<String, dynamic> query) async {
    switch (module) {
      case 'api':
        return enhancedApi(query);
      case 'eapi_decrypt':
        return eapiDecrypt(query);
      case 'audio_match':
        return audioMatchRaw(query);
      case 'avatar_upload':
        return avatarUpload(query);
      case 'playlist_cover_update':
        return playlistCoverUpdate(query);
      case 'cloud':
        return cloud(query);
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
      case 'song_url_match':
        return {'code': 500, 'msg': 'song_url_match depends on upstream unblockmusic-utils and is not available in the Dart client', 'data': []};
      case 'song_url_ncmget':
        return {'code': 200, 'data': []};
    }
    final response = await Https.dioProxy.requestUri(requestModuleDioMetaData(module, query));
    return response.data;
  }

  DioMetaData _buildRawMetaData(ApiEnhancedModule metadata, Map<String, dynamic> query) {
    final path = _resolvePath(metadata.pathTemplate, query);
    final crypto = _cryptoFromQuery(query['crypto']?.toString() ?? metadata.crypto);
    final data = _requestData(query);
    final method = (query['method']?.toString() ?? metadata.httpMethod).toUpperCase();
    final uri = _rawUri(path, crypto, query['domain']?.toString(), data: method == 'GET' ? data : null);
    return DioMetaData(
      uri,
      data: method == 'GET' ? null : data,
      method: method,
      options: _rawOptions(crypto, path, query),
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

  /// Local EAPI request/response decrypt helper.
  dynamic eapiDecrypt(Map<String, dynamic> query) {
    final hexString = query['hexString']?.toString().replaceAll(RegExp(r'\s+'), '');
    if (hexString == null || hexString.isEmpty) {
      return {
        'code': 400,
        'message': 'hex string is required',
      };
    }
    final isReq = query['isReq']?.toString() != 'false';
    final text = _aesEcbDecryptHex(hexString);
    if (isReq) {
      final match = RegExp(r'(.*?)-36cd479b6b5-(.*?)-36cd479b6b5-(.*)').firstMatch(text);
      if (match == null) {
        return {'code': 200, 'data': null};
      }
      return {
        'code': 200,
        'data': {
          'url': match.group(1),
          'data': jsonDecode(match.group(2)!),
        },
      };
    }
    dynamic data;
    try {
      data = jsonDecode(text);
    } catch (_) {
      data = text;
    }
    return {'code': 200, 'data': data};
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

Map<String, dynamic> _requestData(Map<String, dynamic> query) {
  final data = <String, dynamic>{};
  query.forEach((key, value) {
    if (!_rawOptionKeys.contains(key)) {
      data[key] = value;
    }
  });
  return data;
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
    case 'weapi':
    case '':
    default:
      return EncryptType.WeApi;
  }
}

Options _rawOptions(EncryptType crypto, String path, Map<String, dynamic> query) {
  return joinOptions(
    encryptType: crypto,
    eApiUrl: path,
    realIP: query['realIP']?.toString(),
    rawUserAgent: query['ua']?.toString(),
    domain: query['domain']?.toString(),
    checkToken: query['checkToken'] == true,
    cookies: _stringMap(query['cookie']),
  );
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
  final base = domain ?? (crypto == EncryptType.EApi || crypto == EncryptType.Api ? _apiDomain : HOST);
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

String _aesEcbDecryptHex(String hexString) {
  final encrypted = Encrypted.fromBase16(hexString);
  final encrypter = Encrypter(AES(Key.fromUtf8(_eapiKey), mode: AESMode.ecb));
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
