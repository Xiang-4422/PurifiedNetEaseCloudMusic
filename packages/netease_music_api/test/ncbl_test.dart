import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/src/client/ncbl.dart';

void main() {
  group('NCBL helpers', () {
    test('encrypts and builds multipart like upstream util', () async {
      final oracle = await _nodeNcblOracle();
      final keyA = List<int>.generate(32, (index) => index + 1);
      final uuid = List<int>.generate(16, (index) => 0x20 + index);
      final payload = encryptNcbl(
        'meta-fixture',
        'body-fixture',
        options: NcblEncryptOptions(
          keyA: keyA,
          uuid: uuid,
          baseSeq: 0x1234,
          maxFrame: 8,
        ),
      );

      expect(base64Encode(payload), oracle['payload']);
      expect(
        buildNcblRecords([
          const NcblRecord(
            time: 1700000000,
            action: '_plv',
            data: {'id': '123', 'source': 'list'},
          ),
        ]),
        oracle['records'],
      );

      final multipart = buildNcblMultipart(
        Uint8List.fromList([1, 2, 3, 4]),
        boundary: '00112233445566778899aabbccddeeff',
        fileName: 'op_19000_0_858993460',
      );
      expect(multipart.boundary, oracle['boundary']);
      expect(multipart.fileName, oracle['fileName']);
      expect(base64Encode(multipart.multipartBody), oracle['multipart']);
    });
  });
}

Future<Map<String, dynamic>> _nodeNcblOracle() async {
  final result = await Process.run(
    'node',
    ['-e', _nodeNcblOracleScript],
    workingDirectory: _repoRoot().path,
  );
  expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  return Map<String, dynamic>.from(jsonDecode(result.stdout as String) as Map);
}

Directory _repoRoot() {
  var current = Directory.current;
  for (var i = 0; i < 5; i++) {
    if (File('${current.path}/third_party/api-enhanced/util/ncbl.js').existsSync()) {
      return current;
    }
    current = current.parent;
  }
  throw StateError('Cannot find repository root.');
}

const _nodeNcblOracleScript = r'''
const Module = require('module')
const crypto = require('crypto')

const originalRequire = Module.prototype.require
Module.prototype.require = function patchedRequire(request) {
  if (request === 'axios') {
    return { default: async () => ({ data: {}, headers: {} }) }
  }
  return originalRequire.apply(this, arguments)
}

const ncbl = require('./third_party/api-enhanced/util/ncbl')

crypto.randomUUID = () => '00112233-4455-6677-8899-aabbccddeeff'
let randomIndex = 0
const randomValues = [0.1, 0.2]
Math.random = () => randomValues[randomIndex++]

const payload = ncbl.encryptNCBL(
  'meta-fixture',
  'body-fixture',
  {
    keyA: Buffer.from(Array.from({ length: 32 }, (_, index) => index + 1)),
    uuid: Buffer.from(Array.from({ length: 16 }, (_, index) => 0x20 + index)),
    baseSeq: 0x1234,
    maxFrame: 8,
  },
)
const multipart = ncbl.buildMultipart(Buffer.from([1, 2, 3, 4]))
const records = ncbl.buildRecords([
  {
    time: 1700000000,
    action: '_plv',
    data: { id: '123', source: 'list' },
  },
])

console.log(JSON.stringify({
  payload: payload.toString('base64'),
  boundary: multipart.boundary,
  fileName: multipart.fileName,
  multipart: multipart.multipartBody.toString('base64'),
  records,
}))
''';
