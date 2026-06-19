// ignore_for_file: constant_identifier_names, empty_catches

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart' hide Algorithm;

import 'encrypt_ext.dart';
import 'netease_api.dart';
import 'xeapi_crypto.dart';

/// [option.extra] 'hookRequestData' [bool] 是否对request body加密
/// [option.extra] 'userAgent' [UserAgent]
/// [option.extra] 'cookies' [Map<String,String>]
/// [option.extra] 'encryptType' [EncryptType]
/// [option.extra] 'eApiUrl' [String] eApi请求方式请求url 只能eApi方式使用
/// 拦截网易云 SDK 请求并按接口要求补充 Cookie、User-Agent 和加密参数。
void neteaseInterceptor(RequestOptions option, RequestInterceptorHandler handler) async {
  if (option.method == 'POST' && HOSTS.contains(option.uri.host) && option.extra['hookRequestData']) {
    // debugPrint('$TAG   interceptor before: ${option.uri}   ${option.data}');

    option.contentType = Headers.formUrlEncodedContentType;
    option.headers[HttpHeaders.refererHeader] = HOST;

    var realIP = option.extra['realIP'];
    if (realIP != null) {
      option.headers['X-Real-IP'] = realIP;
      option.headers['X-Forwarded-For'] = realIP;
    }
    option.headers[HttpHeaders.userAgentHeader] = _chooseUserAgent(option.extra['userAgent'], rawUserAgent: option.extra['rawUserAgent']);

    var cookies = await loadCookies(host: option.uri);

    var cookiesSb = StringBuffer(CookieManager.getCookies(cookies));
    option.extra['cookies'].forEach((key, value) {
      cookiesSb.write(' ;${Uri.encodeComponent(key)}=${Uri.encodeComponent(value)}');
    });
    option.headers[HttpHeaders.cookieHeader] = cookiesSb.toString();
    option.extra['cookiesHash'] = await loadCookiesHash(cookies: cookies) + NeteaseMusicApi().loginRefreshVersion;

    if (!(option.extra['hookRequestDataSuccess'] ?? false)) {
      _applyEncryptedResponseOverride(option);
      final encryptType = option.extra['encryptType'];
      if ((encryptType == EncryptType.EApi || encryptType == EncryptType.WeApi) && _usesEncryptedResponse(option)) {
        option.responseType = ResponseType.bytes;
        option.extra['encryptedResponse'] = true;
      }
      switch (option.extra['encryptType']) {
        case EncryptType.LinuxForward:
          _handleLinuxForward(option);
          break;
        case EncryptType.WeApi:
          _handleWeApi(option);
          break;
        case EncryptType.EApi:
          _handleEApi(option, cookies);
          break;
        case EncryptType.Api:
          break;
        case EncryptType.XeApi:
          await _handleXeApi(option, cookies);
          break;
      }
      option.extra['hookRequestDataSuccess'] = true;
    }
  }
  handler.next(option);
}

void _applyEncryptedResponseOverride(RequestOptions option) {
  if (!option.extra.containsKey('e_r') || option.extra['e_r'] == null) {
    return;
  }
  final data = option.data;
  if (data is! Map) {
    return;
  }
  option.data = Map<String, dynamic>.from(data)..['e_r'] = _boolRequestFlag(option.extra['e_r']);
}

bool _usesEncryptedResponse(RequestOptions option) {
  if (option.extra.containsKey('e_r') && option.extra['e_r'] != null) {
    return _boolRequestFlag(option.extra['e_r']);
  }
  final data = option.data;
  if (data is Map && data.containsKey('e_r')) {
    return _boolRequestFlag(data['e_r']);
  }
  return false;
}

bool _boolRequestFlag(dynamic value) {
  if (value is bool) {
    return value;
  }
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}

/// 网易云接口请求体加密方式。
enum EncryptType {
  /// Linux forward 接口加密。
  LinuxForward,

  /// weapi 接口加密。
  WeApi,

  /// eapi 接口加密。
  EApi,

  /// 原始 api 请求，不加密请求体。
  Api,

  /// xeapi 接口加密。
  XeApi,
}

/// 请求使用的 User-Agent 类型。
enum UserAgent {
  /// 从内置列表随机选择。
  Random,

  /// 使用桌面端 User-Agent。
  Pc,

  /// 使用移动端 User-Agent。
  Mobile,
}

/// 网易云接口请求时可选的 User-Agent 池。
const userAgentList = [
  'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
  'Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1',
  'Mozilla/5.0 (Linux; Android 5.0; SM-G900P Build/LRX21T) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Mobile Safari/537.36',
  'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Mobile Safari/537.36',
  'Mozilla/5.0 (Linux; Android 5.1.1; Nexus 6 Build/LYZ28E) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Mobile Safari/537.36',
  'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_2 like Mac OS X) AppleWebKit/603.2.4 (KHTML, like Gecko) Mobile/14F89;GameHelper',
  'Mozilla/5.0 (iPhone; CPU iPhone OS 10_0 like Mac OS X) AppleWebKit/602.1.38 (KHTML, like Gecko) Version/10.0 Mobile/14A300 Safari/602.1',
  'Mozilla/5.0 (iPad; CPU OS 10_0 like Mac OS X) AppleWebKit/602.1.38 (KHTML, like Gecko) Version/10.0 Mobile/14A300 Safari/602.1',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:46.0) Gecko/20100101 Firefox/46.0',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:46.0) Gecko/20100101 Firefox/46.0',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/13.10586'
];

const _BASE62 = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
const String _presetKeyLinuxForward = 'rFgB&h#%2?^eDg:Q';

const _presetKeyWeApi = '0CoJUm6Qyw8W8jud';
const _ivWeApi = '0102030405060708';
const _checkToken = '9ca17ae2e6ffcda170e2e6ee8af14fbabdb988f225b3868eb2c15a879b9a83d274a790ac8ff54a97b889d5d42af0feaec3b92af58cff99c470a7eafd88f75e839a9ea7c14e909da883e83fb692a3abdb6b92adee9e';
const _publicKeyWeApi =
    '-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDgtQn2JZ34ZC28NWYpAUd98iZ37BUrX/aKzmFbt7clFSs6sXqHauqKWqdtLkF2KexO40H1YTX8z2lSgBBOAxLsvaklV8k4cBFK9snQXE9/DDaFt6Rr7iVZMldczhC0JNgTz+SHXT6CBHuX3e9SdB1Ua44oncaTWz7OBGLbCiK45wIDAQAB\n-----END PUBLIC KEY-----';

/// SDK 日志标签。
const String TAG = 'NeteaseMusicApi';

/// 网易云 Web 主站地址。
const String HOST = 'https://music.163.com';

/// 需要执行加密拦截的网易云域名列表。
const HOSTS = ['music.163.com', 'interface.music.163.com', 'interface3.music.163.com'];

/// linux forward 加密过程
/// body:
/// eparams=hex(aes_cbc(_presetKeyLinuxForward,'{method:"$option.method", url:"RegExp('\\w*api')", params:"$option.data"}'))
/// url: $HOST/api/linux/forward
void _handleLinuxForward(RequestOptions option) {
  var oldUriStr = option.uri.toString();

  option.path = Uri(scheme: option.uri.scheme, host: option.uri.host, path: 'api/linux/forward').toString();

  var newData = {'method': option.method, 'url': oldUriStr.replaceAll(RegExp(r'\w*api'), 'api'), 'params': option.data};

  final key = Key.fromUtf8(_presetKeyLinuxForward);
  final encrypter = Encrypter(AES(key, mode: AESMode.ecb));
  final encrypted = encrypter.encrypt(jsonEncode(newData));

  option.data = 'eparams=${Uri.encodeQueryComponent(encrypted.base16)}';
}

/// weapi 加密过程
/// body: option.data + {csrfToken:''}
/// params: base64(aes_cbc(16_random_key, base64(aes_cbc(_presetKeyWeApi,body))))
/// encSecKey: hex(rsa_nopadding(_publicKeyWeApi,array_reversed(16_random_key)))
void _handleWeApi(RequestOptions option) {
  var oldUriStr = option.uri.toString();
  option.path = oldUriStr.replaceAll(RegExp(r'\w*api'), 'weapi');

  //weApi方式请求body里面需要带上csrfToken字段，这个是登录请求set-cookie返回的
  String csrfToken = '';
  try {
    csrfToken = RegExp(r'_csrf=([^(;|$)]+)').firstMatch(option.headers[HttpHeaders.cookieHeader] ?? '')?.group(1) ?? '';
  } catch (e) {}
  if (csrfToken.isNotEmpty) {
    // map可能是<String,Int>类型的，默认转换成<String,dynamic>
    option.data = Map.from(option.data);
    option.data['csrf_token'] = csrfToken;
  }

  String body = jsonEncode(option.data);

  //1. 固定密钥加密原始数据
  final key = Key.fromUtf8(_presetKeyWeApi);
  final iv = IV.fromUtf8(_ivWeApi);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(body, iv: iv);

  //2. 生成一个16位密钥A
  Uint8List randomKeyBytes = Uint8List.fromList(List.generate(16, (int index) {
    return _BASE62.codeUnitAt(Random().nextInt(62));
  }));

  //3. 用密钥A再次加密步骤1的结果
  final key2 = Key(randomKeyBytes);
  final encrypterBody = Encrypter(AES(key2, mode: AESMode.cbc));
  final encryptedBody = encrypterBody.encrypt(encrypted.base64, iv: iv);

  //4. RSA加密密钥A
  final parser = RSAKeyParser();
  final encrypter3 = Encrypter(RSAExt(publicKey: parser.parse(_publicKeyWeApi) as RSAPublicKey?));
  final encrypted3 = encrypter3.encryptBytes(List.from(randomKeyBytes.reversed));

  //5. 组合结果
  option.data = 'params=${Uri.encodeQueryComponent(encryptedBody.base64)}&encSecKey=${Uri.encodeQueryComponent(encrypted3.base16)}';
}

void _handleEApi(RequestOptions option, List<Cookie> cookies) {
  var oldUriStr = option.uri.toString();
  option.path = oldUriStr.replaceAll(RegExp(r'\w*api'), 'eapi');

  var header = {};
  Map<String, String> cookiesMap = cookies.fold(<String, String>{}, (map, element) {
    map[element.name] = element.value;
    return map;
  });
  header['osver'] = cookiesMap['osver'];
  header['deviceId'] = cookiesMap['deviceId'];
  header['appver'] = cookiesMap['appver'] ?? '8.0.00';
  header['versioncode'] = cookiesMap['versioncode'] ?? '140';
  header['mobilename'] = cookiesMap['mobilename'];
  header['buildver'] = cookiesMap['mobilename'] ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
  header['resolution'] = cookiesMap['resolution'] ?? '1920x1080';
  header['os'] = cookiesMap['os'] ?? 'android';
  header['channel'] = cookiesMap['channel'];
  header['__csrf'] = cookiesMap['__csrf'] ?? '';
  if (option.extra['checkToken'] == true) {
    header['X-antiCheatToken'] = _checkToken;
  }
  if (cookiesMap['MUSIC_U'] != null) {
    header['MUSIC_U'] = cookiesMap['MUSIC_U'];
  }
  if (cookiesMap['MUSIC_A'] != null) {
    header['MUSIC_A'] = cookiesMap['MUSIC_A'];
  }
  header['requestId'] = '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(1000).toString().padLeft(4, '0')}';

  // map可能是<String,Int>类型的，默认转换成<String,dynamic>
  option.data = Map.from(option.data);
  option.data['header'] = header;

  var url = option.extra['eApiUrl'];
  var body = jsonEncode(option.data);
  var message = 'nobody${url}use${body}md5forencrypt';
  var digest = Encrypted(MD5Digest().process(Uint8List.fromList(utf8.encode(message)))).base16;
  var data = '$url-36cd479b6b5-$body-36cd479b6b5-$digest';

  const KeyEApi = 'e82ckenh8dichen8';

  final encrypted = Encrypter(AES(Key.fromUtf8(KeyEApi), mode: AESMode.ecb)).encrypt(data, iv: IV.fromLength(0)).base16.toUpperCase();

  option.data = 'params=${Uri.encodeComponent(encrypted)}';
}

Future<void> _handleXeApi(RequestOptions option, List<Cookie> cookies) async {
  final publicKeyState = XeApiStateStore.loadPublicKey();
  if (publicKeyState == null) {
    throw StateError('xeapi public key is missing; call register_xeapikey first');
  }

  final cookiesMap = cookies.fold(<String, String>{}, (map, cookie) {
    map[cookie.name] = cookie.value;
    return map;
  });
  cookiesMap.addAll(Map<String, String>.from(option.extra['cookies'] as Map));

  final xeapiOs = cookiesMap['os'] == 'android' ? cookiesMap['os']! : 'android';
  final xeapiAppver = cookiesMap['os'] == 'android' && (cookiesMap['appver']?.isNotEmpty ?? false) ? cookiesMap['appver']! : '9.1.65';
  final xeapiOsver = cookiesMap['os'] == 'android' && (cookiesMap['osver']?.isNotEmpty ?? false) ? cookiesMap['osver']! : '16';
  final xeapiBuildver = cookiesMap['buildver'] ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
  final deviceId = cookiesMap['deviceId'] ?? publicKeyState.deviceId ?? '';
  final sDeviceId = cookiesMap['sDeviceId'] ?? deviceId;

  option.headers[HttpHeaders.userAgentHeader] = _chooseUserAgent(option.extra['userAgent'], rawUserAgent: option.extra['rawUserAgent']);
  option.headers['X-Client-Enc-State'] = 'ENCRYPTED';
  option.headers['x-aeapi'] = 'true';
  if (deviceId.isNotEmpty) {
    option.headers['x-deviceid'] = deviceId;
    option.headers['x-sdeviceid'] = sDeviceId;
  }
  option.headers['x-os'] = xeapiOs;
  option.headers['x-osver'] = xeapiOsver;
  option.headers['x-appver'] = xeapiAppver;
  option.headers['x-buildver'] = xeapiBuildver;
  if (cookiesMap['MUSIC_U']?.isNotEmpty ?? false) {
    option.headers['x-music-u'] = cookiesMap['MUSIC_U'];
  }

  final xeapiCookie = {
    ...cookiesMap,
    'os': xeapiOs,
    'osver': xeapiOsver,
    'appver': xeapiAppver,
    'buildver': xeapiBuildver,
    if (deviceId.isNotEmpty) 'deviceId': deviceId,
    if (sDeviceId.isNotEmpty) 'sDeviceId': sDeviceId,
  };
  option.headers[HttpHeaders.cookieHeader] = _cookieMapToString(xeapiCookie);

  final originalPath = option.uri.path;
  final originalUri = originalPath + (option.uri.hasQuery ? '?${option.uri.query}' : '');
  final xeapiPath = originalPath.startsWith('/api/') ? '/xeapi/${originalPath.substring(5)}' : '/xeapi/${originalPath.replaceFirst(RegExp(r'^/'), '')}';
  option.path = Uri(
    scheme: option.uri.scheme,
    host: option.uri.host,
    port: option.uri.hasPort ? option.uri.port : null,
    path: xeapiPath,
  ).toString();
  option.responseType = ResponseType.bytes;

  final encryptedData = await xeapiEncrypt(
    originalUri,
    option.data is Map ? Map<String, dynamic>.from(option.data as Map) : <String, dynamic>{},
    publicKeyState: publicKeyState,
    method: option.method,
    contentType: Headers.formUrlEncodedContentType,
    os: xeapiOs,
    sessionId: XeApiStateStore.sessionId,
    sessionKey: XeApiStateStore.sessionKey,
  );
  option.data = formEncode(encryptedData);
}

String _chooseUserAgent(UserAgent agent, {String? rawUserAgent}) {
  if (rawUserAgent != null && rawUserAgent.isNotEmpty) {
    return rawUserAgent;
  }
  var random = Random();
  switch (agent) {
    case UserAgent.Random:
      return userAgentList[random.nextInt(userAgentList.length)];
    case UserAgent.Pc:
      return userAgentList[random.nextInt(5) + 8];
    case UserAgent.Mobile:
      return userAgentList[random.nextInt(7)];
  }
}

String _cookieMapToString(Map<String, String> cookies) {
  return cookies.entries.map((entry) {
    return '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}';
  }).join('; ');
}

String? _resolveRequestRealIp(String? realIP, {required bool randomCNIP}) {
  final explicit = realIP?.trim();
  if (explicit != null && explicit.isNotEmpty) {
    return explicit;
  }
  return randomCNIP ? _generateRandomChineseIp() : null;
}

String _generateRandomChineseIp({Random? random}) {
  final source = random ?? Random();
  final block = _chinaIpCBlocks[source.nextInt(_chinaIpCBlocks.length)];
  final third = block.thirdStart + source.nextInt(block.thirdEnd - block.thirdStart + 1);
  final fourth = source.nextInt(254) + 1;
  return '${block.first}.${block.second}.$third.$fourth';
}

const _chinaIpCBlocks = [
  _ChinaIpCBlock(1, 1, 8, 8),
  _ChinaIpCBlock(1, 2, 4, 4),
  _ChinaIpCBlock(14, 16, 0, 255),
  _ChinaIpCBlock(14, 112, 0, 255),
  _ChinaIpCBlock(27, 16, 0, 255),
  _ChinaIpCBlock(27, 40, 0, 255),
  _ChinaIpCBlock(36, 128, 0, 255),
  _ChinaIpCBlock(39, 144, 0, 255),
  _ChinaIpCBlock(42, 48, 0, 255),
  _ChinaIpCBlock(58, 30, 0, 255),
  _ChinaIpCBlock(101, 64, 0, 255),
  _ChinaIpCBlock(111, 0, 0, 255),
  _ChinaIpCBlock(112, 64, 0, 255),
  _ChinaIpCBlock(116, 16, 0, 255),
  _ChinaIpCBlock(117, 128, 0, 255),
  _ChinaIpCBlock(121, 32, 0, 255),
  _ChinaIpCBlock(123, 112, 0, 255),
  _ChinaIpCBlock(183, 128, 0, 255),
  _ChinaIpCBlock(223, 64, 0, 255),
];

class _ChinaIpCBlock {
  const _ChinaIpCBlock(
    this.first,
    this.second,
    this.thirdStart,
    this.thirdEnd,
  );

  final int first;
  final int second;
  final int thirdStart;
  final int thirdEnd;
}

/// 创建带网易云加密拦截参数的 Dio 请求选项。
Options joinOptions({
  hookRequestDate = true,
  EncryptType encryptType = EncryptType.WeApi,
  UserAgent userAgent = UserAgent.Random,
  Map<String, String> cookies = const {},
  String eApiUrl = '',
  String? realIP,
  String? rawUserAgent,
  String? domain,
  bool checkToken = false,
  bool randomCNIP = false,
  String? proxy,
  bool? encryptedResponse,
}) =>
    Options(contentType: ContentType.json.value, extra: {
      'hookRequestData': hookRequestDate,
      'encryptType': encryptType,
      'userAgent': userAgent,
      'cookies': cookies,
      'eApiUrl': eApiUrl,
      'realIP': _resolveRequestRealIp(realIP, randomCNIP: randomCNIP),
      'rawUserAgent': rawUserAgent,
      'domain': domain,
      'checkToken': checkToken,
      'randomCNIP': randomCNIP,
      'proxy': proxy,
      'e_r': encryptedResponse,
    });

/// 将相对路径拼成网易云主站 URI。
Uri joinUri(String path) {
  return Uri.parse('$HOST$path');
}

/// 读取指定域名下的持久化 Cookie。
Future<List<Cookie>> loadCookies({Uri? host}) async {
  host ??= Uri.parse(HOST);
  return (NeteaseMusicApi.cookieManager.cookieJar).loadForRequest(host);
}

/// 基于当前 Cookie 和登录刷新版本计算请求重试用 hash。
Future<int> loadCookiesHash({List<Cookie>? cookies}) async {
  cookies ??= await loadCookies();
  int hash = cookies.map((e) => e.toString()).hashCode;
  int loginRefreshVersion = NeteaseMusicApi().loginRefreshVersion;
  return hash + loginRefreshVersion;
}

/// 清空 SDK 持久化 Cookie。
Future<void> deleteAllCookie() async {
  try {
    await (NeteaseMusicApi.cookieManager.cookieJar as PersistCookieJar).deleteAll();
  } catch (e) {
    // 忽略删除失败
  }
}
