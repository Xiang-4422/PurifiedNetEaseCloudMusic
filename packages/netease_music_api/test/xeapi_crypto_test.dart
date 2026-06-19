import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/src/client/xeapi_crypto.dart';

void main() {
  group('xeapi crypto', () {
    test('sign matches upstream Node crypto output', () {
      expect(
        xeapiSign('1700000000000', '1234567890123456'),
        'AfwKXk83sQ/wAKzoswSsn7/DgRvQ6zfI4O5eOSKnkIA=',
      );
    });

    test('builds upstream plaintext shape', () {
      expect(
        buildXeApiPlaintext(
          '/api/test?x=1',
          {'id': 1, 'name': 'a b', 'e_r': true},
          method: 'GET',
          contentType: 'application/json',
        ),
        '{"contentType":"application/json","method":"GET","queryString":"x=1&e_r=true","body":"aWQ9MSZuYW1lPWErYg=="}',
      );
    });

    test('mid transform matches upstream algorithm for deterministic random bytes', () {
      final transformed = xeapiMidTransform(
        Uint8List.fromList([1, 2, 3, 4, 5]),
        randomBytes: Uint8List.fromList(List.generate(16, (index) => index)),
      );

      expect(_hex(transformed), '000102030405060708090a0b0c0d0e0f41514d424277453d');
    });

    test('decrypts registered public key payload', () {
      const encryptedData = 'Ix+68DGNS+G6Oiwlq/g/+pJlf+CLRzLMsVxgAP9Sq82SZX/gi0cyzLFcYAD/UqvNXpKKq45tTezVfnTCJ+SJPc19vHxGXOOCLiTjXypVtRo2werynr5A9/iH1qGdKGF4';

      final state = xeapiDecryptPublicKey(encryptedData, deviceId: 'device-1');

      expect(state.publicKey, 'BwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwcHBwc=');
      expect(state.version, '1');
      expect(state.sk, 'secret-key');
      expect(state.deviceId, 'device-1');
    });

    test('encrypts request fields with deterministic key material', () async {
      final x25519 = X25519();
      final peerKeyPair = await x25519.newKeyPairFromSeed(Uint8List.fromList(List.filled(32, 4)));
      final peerPublicKey = await peerKeyPair.extractPublicKey();
      final ephemeralKeyPair = await x25519.newKeyPairFromSeed(Uint8List.fromList(List.filled(32, 8)));

      final encrypted = await xeapiEncrypt(
        '/api/test',
        {'id': 1},
        publicKeyState: XeApiPublicKeyState(
          publicKey: base64Encode(peerPublicKey.bytes),
          version: '1',
          sk: 'secret-key',
        ),
        dynamicKey: Uint8List.fromList(List.filled(16, 1)),
        midRandom: Uint8List.fromList(List.generate(16, (index) => index)),
        gcmNonce: Uint8List.fromList(List.filled(12, 2)),
        ephemeralKeyPair: ephemeralKeyPair,
        x25519: x25519,
      );

      expect(encrypted.keys.toSet(), {'B', 'S', 'R'});
      expect(encrypted['B'], isNotEmpty);
      expect(base64Decode(encrypted['S']!).length, greaterThan(32 + 12 + 16));
      expect(encrypted['R'], isNotEmpty);
    });

    test('decrypts xeapi response body', () {
      final encrypted = Encrypter(AES(Key.fromUtf8('e82ckenh8dichen8'), mode: AESMode.ecb)).encrypt(
        '{"code":200,"ok":true}',
        iv: IV.fromLength(0),
      );

      expect(xeapiResDecrypt(encrypted.bytes), {
        'code': 200,
        'ok': true,
      });
    });
  });
}

String _hex(List<int> bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}
