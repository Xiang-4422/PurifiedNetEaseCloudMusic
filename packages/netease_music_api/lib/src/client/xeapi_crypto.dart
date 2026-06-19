import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart' as pointycastle;

const _xeapiStaticKeyHex = 'ab1d5a430f6bb04a3f01e81ddd72bd916d5ce591248ac128714806d7f8fb1b84';
const _xeapiSignKey = 'mUHCwVNWJbunMqAHf5MImuirT6plvs6VSFW62MGHstFQxhBGdEoIhLItH3djc4+FB/OKty3+lL2rGeoFBpVe5g==';
const _eapiKey = 'e82ckenh8dichen8';

/// Supplies random bytes for xeapi encryption; tests inject deterministic data.
typedef XeApiRandomBytes = Uint8List Function(int length);

/// Public key state returned by the upstream `register_xeapikey` module.
class XeApiPublicKeyState {
  /// Base64 encoded X25519 public key.
  final String publicKey;

  /// Public key version.
  final String version;

  /// Server key carried into the xeapi `S` payload.
  final String? sk;

  /// Device id used when registering this key.
  final String? deviceId;

  /// Creates a public key state.
  const XeApiPublicKeyState({
    required this.publicKey,
    required this.version,
    this.sk,
    this.deviceId,
  });

  /// Decodes state from a JSON map.
  factory XeApiPublicKeyState.fromJson(Map<String, dynamic> json) {
    return XeApiPublicKeyState(
      publicKey: json['publicKey']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      sk: json['sk']?.toString(),
      deviceId: json['deviceId']?.toString(),
    );
  }

  /// Encodes state to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'publicKey': publicKey,
      'version': version,
      if (sk != null) 'sk': sk,
      if (deviceId != null) 'deviceId': deviceId,
    };
  }
}

/// SDK-level storage for xeapi public key and encrypted session state.
class XeApiStateStore {
  static String? _dataDirectory;
  static XeApiPublicKeyState? _publicKeyState;
  static String _sessionId = '';
  static String _sessionKey = '';

  /// Configures the directory used for persisting xeapi public key state.
  static void configureDirectory(String directory) {
    _dataDirectory = directory;
  }

  /// Loads the persisted public key state, if one exists.
  static XeApiPublicKeyState? loadPublicKey() {
    final current = _publicKeyState;
    if (current != null) {
      return current;
    }
    final file = _stateFile();
    if (file == null || !file.existsSync()) {
      return null;
    }
    try {
      final json = jsonDecode(file.readAsStringSync());
      if (json is Map) {
        return _publicKeyState = XeApiPublicKeyState.fromJson(
          Map<String, dynamic>.from(json),
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Saves the latest public key state in memory and on disk when possible.
  static Future<void> savePublicKey(XeApiPublicKeyState state) async {
    _publicKeyState = state;
    final file = _stateFile();
    if (file == null) {
      return;
    }
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(state.toJson()), flush: true);
  }

  /// Updates the encrypted xeapi session returned by response headers.
  static void updateSession({String? sessionId, String? sessionKey}) {
    if (sessionId != null && sessionId.isNotEmpty) {
      _sessionId = sessionId;
    }
    if (sessionKey != null && sessionKey.isNotEmpty) {
      _sessionKey = sessionKey;
    }
  }

  /// Current xeapi session id.
  static String get sessionId => _sessionId;

  /// Current xeapi session key.
  static String get sessionKey => _sessionKey;

  /// Resets in-memory state for tests.
  static void resetForTesting() {
    _publicKeyState = null;
    _sessionId = '';
    _sessionKey = '';
    _dataDirectory = null;
  }

  /// Injects public key state for tests.
  static void setPublicKeyForTesting(XeApiPublicKeyState state) {
    _publicKeyState = state;
  }

  static File? _stateFile() {
    final directory = _dataDirectory;
    if (directory == null || directory.isEmpty) {
      return null;
    }
    return File('$directory/xeapi_public_key.json');
  }
}

/// Builds the upstream-compatible xeapi signature.
String xeapiSign(String timestamp, String nonce) {
  return base64Encode(_hmacSha256(utf8.encode(_xeapiSignKey), utf8.encode(timestamp + nonce)));
}

/// Generates the 16-digit nonce used by `register_xeapikey`.
String generateXeApiNonce({Random? random}) {
  final source = random ?? Random.secure();
  return List.generate(16, (_) => source.nextInt(10).toString()).join();
}

/// Generates the 52-character uppercase hex device id used by anonymous login.
String generateXeApiDeviceId({Random? random}) {
  const hexChars = '0123456789ABCDEF';
  final source = random ?? Random.secure();
  return List.generate(52, (_) => hexChars[source.nextInt(hexChars.length)]).join();
}

/// Builds the anonymous-login username field used by upstream.
String buildXeApiAnonymousUsername(String deviceId) {
  const xorKey = '3go8&\$8*3*3h0k(2)2';
  final xored = StringBuffer();
  for (var i = 0; i < deviceId.length; i++) {
    xored.writeCharCode(deviceId.codeUnitAt(i) ^ xorKey.codeUnitAt(i % xorKey.length));
  }
  final digest = pointycastle.MD5Digest().process(Uint8List.fromList(utf8.encode(xored.toString())));
  return base64Encode(utf8.encode('$deviceId ${base64Encode(digest)}'));
}

/// Builds the plaintext JSON used before xeapi `B` encryption.
String buildXeApiPlaintext(
  String uri,
  Map<String, dynamic>? data, {
  String contentType = 'application/x-www-form-urlencoded;charset=utf-8',
  String method = 'POST',
}) {
  final fields = <String, dynamic>{};
  final mediaType = contentType.split(';').first.toLowerCase();
  if (mediaType != 'application/x-www-form-urlencoded') {
    fields['contentType'] = contentType;
  }

  final upperMethod = method.toUpperCase();
  if (upperMethod != 'POST') {
    fields['method'] = upperMethod;
  }

  final parsedUri = Uri.parse(uri.startsWith('http') ? uri : 'https://interface.music.163.com$uri');
  if (parsedUri.hasQuery) {
    fields['queryString'] = parsedUri.query;
  }

  if (data != null) {
    final bodyData = Map<String, dynamic>.from(data)..remove('e_r');
    fields['body'] = base64Encode(utf8.encode(formEncode(bodyData)));
  }

  if (fields.containsKey('queryString')) {
    fields['queryString'] = '${fields['queryString']}&e_r=true';
  } else {
    fields['queryString'] = 'e_r=true';
  }
  return jsonEncode(fields);
}

/// Encrypts the xeapi request body and returns upstream-compatible B/S/R fields.
Future<Map<String, String>> xeapiEncrypt(
  String uri,
  Map<String, dynamic>? data, {
  required XeApiPublicKeyState publicKeyState,
  String method = 'POST',
  String contentType = 'application/x-www-form-urlencoded;charset=utf-8',
  String os = 'android',
  String sessionId = '',
  String sessionKey = '',
  Uint8List? dynamicKey,
  Uint8List? midRandom,
  Uint8List? gcmNonce,
  SimpleKeyPair? ephemeralKeyPair,
  X25519? x25519,
  XeApiRandomBytes? randomBytes,
}) async {
  final activeSessionKey = sessionKey.isNotEmpty ? Uint8List.fromList(utf8.encode(sessionKey)) : null;
  final effectiveDynamicKey = activeSessionKey ?? dynamicKey ?? (randomBytes ?? secureRandomBytes)(16);
  final plaintext = Uint8List.fromList(utf8.encode(buildXeApiPlaintext(uri, data, contentType: contentType, method: method)));
  final firstPass = _aesEcbEncrypt(_xeapiStaticKey, plaintext);
  final transformed = xeapiMidTransform(firstPass, randomBytes: midRandom ?? (randomBytes ?? secureRandomBytes)(16));
  final b = _aesEcbEncrypt(effectiveDynamicKey, transformed);
  final s = await xeapiEncryptS(
    effectiveDynamicKey,
    publicKeyState,
    os,
    gcmNonce: gcmNonce,
    ephemeralKeyPair: ephemeralKeyPair,
    x25519: x25519,
    randomBytes: randomBytes,
  );
  final r = _aesEcbEncrypt(
    _xeapiStaticKey,
    Uint8List.fromList(utf8.encode('${publicKeyState.version}|${activeSessionKey == null ? '' : sessionId}')),
  );
  return {
    'B': base64Encode(b),
    'S': base64Encode(s),
    'R': base64Encode(r),
  };
}

/// Applies the random xor/base64/rotation transform used inside xeapi `B`.
Uint8List xeapiMidTransform(Uint8List ciphertext, {required Uint8List randomBytes}) {
  if (randomBytes.length != 16) {
    throw ArgumentError.value(randomBytes.length, 'randomBytes.length', 'must be 16');
  }
  final xored = Uint8List(ciphertext.length);
  for (var i = 0; i < ciphertext.length; i++) {
    xored[i] = ciphertext[i] ^ randomBytes[i & 0x0f];
  }
  final b64 = Uint8List.fromList(ascii.encode(base64Encode(xored)));
  final rotation = b64.isEmpty ? 0 : (randomBytes[0] & 0x0f) % b64.length;
  return Uint8List.fromList([
    ...randomBytes,
    ...b64.sublist(rotation),
    ...b64.sublist(0, rotation),
  ]);
}

/// Encrypts the xeapi `S` field.
Future<Uint8List> xeapiEncryptS(
  Uint8List dynamicKey,
  XeApiPublicKeyState publicKeyState,
  String os, {
  Uint8List? gcmNonce,
  SimpleKeyPair? ephemeralKeyPair,
  X25519? x25519,
  XeApiRandomBytes? randomBytes,
}) async {
  final algorithm = x25519 ?? X25519();
  final keyPair = ephemeralKeyPair ?? await algorithm.newKeyPair();
  final peerPublicKey = SimplePublicKey(base64Decode(publicKeyState.publicKey), type: KeyPairType.x25519);
  final ephemeralPublicKey = await keyPair.extractPublicKey();
  final sharedSecret = await algorithm.sharedSecretKey(
    keyPair: keyPair,
    remotePublicKey: peerPublicKey,
  );
  final sharedSecretBytes = await sharedSecret.extractBytes();
  final aesKey = _deriveX25519AesKey(
    Uint8List.fromList(sharedSecretBytes),
    Uint8List.fromList(ephemeralPublicKey.bytes),
  );
  final nonce = gcmNonce ?? (randomBytes ?? secureRandomBytes)(12);
  final secretBox = await AesGcm.with128bits().encrypt(
    utf8.encode('${base64Encode(dynamicKey)}|$os|${publicKeyState.sk ?? ''}'),
    secretKey: SecretKey(aesKey),
    nonce: nonce,
  );
  return Uint8List.fromList([
    ...ephemeralPublicKey.bytes,
    ...nonce,
    ...secretBox.cipherText,
    ...secretBox.mac.bytes,
  ]);
}

/// Decrypts a `register_xeapikey` encrypted public key payload.
XeApiPublicKeyState xeapiDecryptPublicKey(String encryptedData, {String? deviceId}) {
  final plaintext = utf8.decode(_aesEcbDecrypt(_xeapiStaticKey, base64Decode(encryptedData)));
  final json = Map<String, dynamic>.from(jsonDecode(plaintext) as Map);
  return XeApiPublicKeyState.fromJson({
    ...json,
    if (deviceId != null) 'deviceId': deviceId,
  });
}

/// Decrypts an encrypted xeapi response body.
dynamic xeapiResDecrypt(List<int> body) {
  final decrypted = _aesEcbDecrypt(Uint8List.fromList(utf8.encode(_eapiKey)), Uint8List.fromList(body));
  final plaintext = decrypted.length >= 2 && decrypted[0] == 0x1f && decrypted[1] == 0x8b ? gzip.decode(decrypted) : decrypted;
  return jsonDecode(utf8.decode(plaintext));
}

/// URL-encodes form data with the same shape as JavaScript URLSearchParams.
String formEncode(Map<String, dynamic> data) {
  return data.entries.map((entry) {
    return '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value?.toString() ?? 'null')}';
  }).join('&');
}

/// Generates secure random bytes.
Uint8List secureRandomBytes(int length) {
  final random = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
}

Uint8List _deriveX25519AesKey(Uint8List sharedSecret, Uint8List ephemeralPublicKey) {
  final prk = _hmacSha256(Uint8List(32), sharedSecret.isNotEmpty ? sharedSecret : Uint8List(32));
  final okm = _hmacSha256(prk, Uint8List.fromList([...ephemeralPublicKey, 1]));
  return Uint8List.fromList(okm.sublist(0, 16));
}

Uint8List _aesEcbEncrypt(Uint8List key, Uint8List data) {
  final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.ecb));
  return Uint8List.fromList(encrypter.encryptBytes(data, iv: encrypt.IV.fromLength(0)).bytes);
}

Uint8List _aesEcbDecrypt(Uint8List key, List<int> data) {
  final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key(key), mode: encrypt.AESMode.ecb));
  return Uint8List.fromList(encrypter.decryptBytes(encrypt.Encrypted(Uint8List.fromList(data)), iv: encrypt.IV.fromLength(0)));
}

Uint8List _hmacSha256(List<int> key, List<int> data) {
  final hmac = pointycastle.HMac(pointycastle.SHA256Digest(), 64)..init(pointycastle.KeyParameter(Uint8List.fromList(key)));
  return hmac.process(Uint8List.fromList(data));
}

Uint8List get _xeapiStaticKey => _hexToBytes(_xeapiStaticKeyHex);

Uint8List _hexToBytes(String hex) {
  final result = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < result.length; i++) {
    result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return result;
}
