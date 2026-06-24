// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const ncblUploadUrl = 'https://clientlog3.music.163.com/api/clientlog/encrypt/upload?multiupload=true';
const ncblMagic = [0x4e, 0x43, 0x42, 0x4c];

const _sigma = [0x61707865, 0x3320646e, 0x79622d32, 0x6b206574];
const _rsaN = 'fd90bd466ff9bc8a3fec2fbcf263b90d5c564879fa5d7aab89b31c1d5cb4139d';
const _rsaE = 65537;
const _ncblVersion = 3;
const _headerFixedLength = 70;
const _metaBlockType = 0x4343;
const _defaultMaxFrame = 0x8000;
const _fieldSeparator = '\x01';

final _secureRandom = Random.secure();

Map<String, String> parseNcblCookie(dynamic cookie) {
  if (cookie is Map) {
    return cookie.map((key, value) => MapEntry(key.toString(), value?.toString() ?? ''));
  }
  final text = cookie?.toString() ?? '';
  final parsed = <String, String>{};
  for (final part in text.split(';')) {
    final index = part.indexOf('=');
    if (index <= 0) {
      continue;
    }
    final key = part.substring(0, index).trim();
    if (key.isEmpty) {
      continue;
    }
    parsed[key] = part.substring(index + 1).trim();
  }
  return parsed;
}

NcblContext ncblContextFromCookie(Map<String, String> cookie) {
  return NcblContext(
    app: NcblAppContext(
      id: cookie['appid'] ?? '',
      nsm: cookie['WEVNSM'] ?? '1.0.0',
      cid: cookie['WNMCID'] ?? '${_randomHex(3)}.${DateTime.now().millisecondsSinceEpoch}.01.0',
      channel: cookie['channel'] ?? 'netease',
      version: cookie['appver'] ?? '3.1.35',
      versionCode: cookie['versioncode'] ?? '205293',
      buildCode: cookie['buildver'] ?? '',
    ),
    device: NcblDeviceContext(
      id: cookie['deviceId'] ?? cookie['sDeviceId'] ?? '',
      ti: cookie['NMTID'] ?? '',
      sign: cookie['clientSign'] ?? '',
      model: cookie['mode'] ?? cookie['mobilename'] ?? '',
      nnid: cookie['_ntes_nnid'] ?? ',',
      nuid: cookie['_ntes_nuid'] ?? '',
      csrf: cookie['__csrf'] ?? '',
      systemType: cookie['os'] ?? 'pc',
      systemVersion: cookie['osver'] ?? 'Microsoft-Windows-10-Professional-build-19045-64bit',
    ),
    auth: NcblAuthContext(
      id: cookie['uid'] ?? '',
      token: cookie['MUSIC_U'] ?? '',
      sessionId: cookie['JSESSIONID-WYYY'] ?? '',
      vipType: cookie['vipType'] ?? '',
    ),
    startTime: DateTime.now().millisecondsSinceEpoch,
    processId: _secureRandom.nextInt(90000) + 10000,
  );
}

String buildNcblCookieString(NcblContext ctx) {
  return [
    'JSESSIONID-WYYY=${ctx.auth.sessionId}',
    'MUSIC_U=${ctx.auth.token}',
    'NMTID=${ctx.device.ti}',
    'WEVNSM=${ctx.app.nsm}',
    'WNMCID=${ctx.app.cid}',
    '__csrf=${ctx.device.csrf}',
    '__remember_me=true',
    '_iuqxldmzr_=33',
    '_ntes_nnid=${ctx.device.nnid}',
    '_ntes_nuid=${ctx.device.nuid}',
    'appver=${ctx.app.version}.${ctx.app.versionCode}',
    'channel=${ctx.app.channel}',
    'clientSign=${ctx.device.sign}',
    'deviceId=${ctx.device.id}',
    'mode=${ctx.device.model}',
    'ntes_kaola_ad=1',
    'os=${ctx.device.systemType}',
    'osver=${ctx.device.systemVersion}',
  ].join('; ');
}

String buildNcblMetaJson(NcblContext ctx) {
  return jsonEncode({
    'JSESSIONID-WYYY': ctx.auth.sessionId,
    'MUSIC_U': ctx.auth.token,
    'NMTID': ctx.device.ti,
    'WEVNSM': ctx.app.nsm,
    'WNMCID': ctx.app.cid,
    '__csrf': ctx.device.csrf,
    '_iuqxldmzr_': '33',
    '_ntes_nnid': ctx.device.nnid,
    '_ntes_nuid': ctx.device.nuid,
    'appver': '${ctx.app.version}.${ctx.app.versionCode}',
    'channel': ctx.app.channel,
    'clientSign': ctx.device.sign,
    'deviceId': ctx.device.id,
    'mode': ctx.device.model,
    'ntes_kaola_ad': '1',
    'os': ctx.device.systemType,
    'osver': ctx.device.systemVersion,
  });
}

String buildNcblRecords(List<NcblRecord> records) {
  return records.map((record) {
    final data = record.data is String ? record.data : jsonEncode(record.data);
    return [record.time, record.action, data].join(_fieldSeparator);
  }).join();
}

Map<String, dynamic> buildNcblPlv(NcblContext ctx, NcblSong song, NcblSource source) {
  final now = DateTime.now().millisecondsSinceEpoch;
  final addRefer = '[F:63][$now#933#${ctx.app.version}#${ctx.app.versionCode}#c9156c3][e][2][23][cell_pc_songlist_song:2|page_pc_songlist_songflow|page_mine_like_music][${song.id}:song:x:x|:::|${source.id}:list::]';
  return {
    'mode': 'circulation',
    'download': 0,
    'alg': '',
    'status': 'front',
    'id': song.id.toString(),
    'bitrate': song.bitrate,
    'type': 'song',
    'is_listentogether': 0,
    'source': source.name,
    'is_heart': 0,
    'resource_ratio': '',
    'resource_time': song.time,
    'musiceffect_id': '',
    'app_mode': 2,
    'bitrate_level': song.level,
    '_addrefer': addRefer,
    '_multirefers': [
      '[F:26][s][18][_ai]',
      '[F:26][s][12][_ai]',
      '[F:63][$now#933#${ctx.app.version}#${ctx.app.versionCode}#c9156c3][e][2][8][cell_pc_main_tab_entrance:6|page_pc_main_tab][我喜欢的音乐:spm::|:::]',
      '[F:26][s][5][_ai]',
      '[F:26][s][0][_ai]',
    ],
    'vipType': ctx.auth.vipType,
    'fee': 1,
    'file': 4,
    'rightSource': 0,
    'sourceId': source.id,
    'sourcetype': source.type,
    'libra_abt': '',
    'channel': ctx.app.channel,
    'curStartChannel': '',
  };
}

Map<String, dynamic> buildNcblPld(NcblContext ctx, NcblSong song, NcblSource source, num played) {
  final now = DateTime.now().millisecondsSinceEpoch;
  final addRefer = '[F:63][$now#616#${ctx.app.version}#${ctx.app.versionCode}#c9156c3][e][2][92][btn_pc_cover_play|cell_pc_songlist_song:6|page_pc_songlist_songflow|page_mine_like_music][:::|${song.id}:song:x:x|:::|${source.id}:list::]';
  return {
    'mode': 'circulation',
    'download': 0,
    'alg': '',
    'status': 'front',
    'id': song.id.toString(),
    'time': played,
    'type': 'song',
    'is_listentogether': 0,
    'source': source.name,
    'is_heart': 0,
    'realtime': played,
    'resource_ratio': '',
    'resource_time': song.time,
    'musiceffect_id': '1001',
    'app_mode': 1,
    'lyriceffect': 'default',
    'displayMode': 'classic',
    'bitrate': song.bitrate,
    'bitrate_level': song.level,
    '_addrefer': addRefer,
    '_multirefers': [
      '[F:26][s][87][_ai]',
      '[F:26][s][81][_ai]',
      '[F:26][s][75][_ai]',
      '[F:26][s][69][_ai]',
      '[F:26][s][63][_ai]',
    ],
    'vipType': ctx.auth.vipType,
    'fee': 8,
    'file': 4,
    'rightSource': 0,
    'sourceId': source.id,
    'sourcetype': source.type,
    'end': 'interrupt',
    'libra_abt': '',
    'channel': ctx.app.channel,
    'curStartChannel': '',
  };
}

Uint8List encryptNcbl(
  String meta,
  String body, {
  NcblEncryptOptions? options,
}) {
  final metaBytes = Uint8List.fromList(utf8.encode(meta));
  final bodyBytes = Uint8List.fromList(utf8.encode(body));
  final keyA = options?.keyA == null ? _randomBytes(32) : Uint8List.fromList(options!.keyA!);
  if (keyA[0] >= 0xa3) {
    keyA[0] = 0xa2;
  }
  final keyB = _rsaWrap(keyA);
  final uuid = options?.uuid == null ? _randomUuidBytes() : Uint8List.fromList(options!.uuid!);
  final nonce = Uint8List.sublistView(uuid, 0, 12);
  final counter = _readUint32Le(uuid, 12) >>> 2;
  final baseSeq = options?.baseSeq ?? _readUint16Le(_randomBytes(2), 0);
  final metaCipher = _chacha20(keyB, counter, nonce, metaBytes);
  final metaBlock = _concatBytes([
    _uint16Le(_metaBlockType),
    _uint16Le(metaCipher.length),
    metaCipher,
  ]);
  final headerLength = _headerFixedLength + metaBlock.length;
  final compressed = Uint8List.fromList(gzip.encode(bodyBytes));
  final frames = <Uint8List>[];
  var seq = baseSeq;
  final maxFrame = options?.maxFrame ?? _defaultMaxFrame;
  for (var offset = 0; offset < compressed.length || offset == 0; offset += maxFrame) {
    final end = min(offset + maxFrame, compressed.length);
    final slice = Uint8List.sublistView(compressed, offset, end);
    final cipher = _chacha20(keyA, counter, nonce, slice);
    frames.add(_uint16Le(cipher.length));
    frames.add(_uint32Le(seq));
    frames.add(cipher);
    seq++;
    if (compressed.isEmpty) {
      break;
    }
  }
  final trailing = _concatBytes(frames);
  final frameCount = seq - baseSeq;
  final header = Uint8List(_headerFixedLength);
  header.setRange(0, 4, ncblMagic);
  _writeUint32Le(header, 4, _ncblVersion);
  _writeUint16Le(header, 8, headerLength);
  header.setRange(10, 26, uuid);
  header.setRange(26, 58, keyB);
  _writeUint32Le(header, 58, baseSeq);
  _writeUint32Le(header, 62, baseSeq + frameCount - 1);
  _writeUint32Le(header, 66, trailing.length);
  return _concatBytes([header, metaBlock, trailing]);
}

NcblMultipartPayload buildNcblMultipart(
  Uint8List payload, {
  String? boundary,
  String? fileName,
}) {
  final resolvedBoundary = boundary ?? _randomUuidHex();
  final resolvedFileName = fileName ?? 'op_${_secureRandom.nextInt(90000) + 10000}_0_${_secureRandom.nextInt(0xffffffff) + 1}';
  const crlf = '\r\n';
  final header = [
    '--$resolvedBoundary',
    'Content-Disposition: form-data; name="file"; filename="$resolvedFileName"',
    'Content-Type: multipart/form-data',
    '',
    '',
  ].join(crlf);
  final footer = '$crlf--$resolvedBoundary--$crlf';
  return NcblMultipartPayload(
    boundary: resolvedBoundary,
    fileName: resolvedFileName,
    multipartBody: _concatBytes([
      Uint8List.fromList(utf8.encode(header)),
      payload,
      Uint8List.fromList(utf8.encode(footer)),
    ]),
    payload: payload,
  );
}

class NcblEncryptOptions {
  const NcblEncryptOptions({
    this.keyA,
    this.uuid,
    this.baseSeq,
    this.maxFrame,
  });

  final List<int>? keyA;
  final List<int>? uuid;
  final int? baseSeq;
  final int? maxFrame;
}

class NcblContext {
  const NcblContext({
    required this.app,
    required this.device,
    required this.auth,
    required this.startTime,
    required this.processId,
  });

  final NcblAppContext app;
  final NcblDeviceContext device;
  final NcblAuthContext auth;
  final int startTime;
  final int processId;
}

class NcblAppContext {
  const NcblAppContext({
    required this.id,
    required this.nsm,
    required this.cid,
    required this.channel,
    required this.version,
    required this.versionCode,
    required this.buildCode,
  });

  final String id;
  final String nsm;
  final String cid;
  final String channel;
  final String version;
  final String versionCode;
  final String buildCode;
}

class NcblDeviceContext {
  const NcblDeviceContext({
    required this.id,
    required this.ti,
    required this.sign,
    required this.model,
    required this.nnid,
    required this.nuid,
    required this.csrf,
    required this.systemType,
    required this.systemVersion,
  });

  final String id;
  final String ti;
  final String sign;
  final String model;
  final String nnid;
  final String nuid;
  final String csrf;
  final String systemType;
  final String systemVersion;
}

class NcblAuthContext {
  const NcblAuthContext({
    required this.id,
    required this.token,
    required this.sessionId,
    required this.vipType,
  });

  final String id;
  final String token;
  final String sessionId;
  final String vipType;
}

class NcblSong {
  const NcblSong({
    required this.id,
    required this.name,
    required this.artist,
    required this.bitrate,
    required this.level,
    required this.vip,
    required this.time,
  });

  final num id;
  final String name;
  final String artist;
  final num bitrate;
  final String level;
  final bool vip;
  final num time;
}

class NcblSource {
  const NcblSource({
    required this.id,
    required this.type,
    required this.name,
  });

  final String id;
  final String type;
  final String name;
}

class NcblRecord {
  const NcblRecord({
    required this.time,
    required this.action,
    required this.data,
  });

  final int time;
  final String action;
  final Object data;
}

class NcblMultipartPayload {
  const NcblMultipartPayload({
    required this.boundary,
    required this.fileName,
    required this.multipartBody,
    required this.payload,
  });

  final String boundary;
  final String fileName;
  final Uint8List multipartBody;
  final Uint8List payload;
}

Uint8List _chacha20(Uint8List key, int counter, Uint8List nonce, Uint8List data) {
  final out = Uint8List(data.length);
  for (var offset = 0; offset < data.length; offset += 64) {
    final keyStream = _chachaBlock(key, (counter + (offset >> 6)) & 0xffffffff, nonce);
    final end = min(offset + 64, data.length);
    for (var i = offset; i < end; i++) {
      out[i] = data[i] ^ keyStream[i - offset];
    }
  }
  return out;
}

Uint8List _chachaBlock(Uint8List key, int counter, Uint8List nonce) {
  final state = Uint32List(16);
  state[0] = _sigma[0];
  state[1] = _sigma[1];
  state[2] = _sigma[2];
  state[3] = _sigma[3];
  for (var i = 0; i < 8; i++) {
    state[4 + i] = _readUint32Le(key, i * 4);
  }
  state[12] = counter;
  state[13] = _readUint32Le(nonce, 0);
  state[14] = _readUint32Le(nonce, 4);
  state[15] = _readUint32Le(nonce, 8);
  final work = Uint32List.fromList(state);
  for (var i = 0; i < 10; i++) {
    _quarterRound(work, 0, 4, 8, 12);
    _quarterRound(work, 1, 5, 9, 13);
    _quarterRound(work, 2, 6, 10, 14);
    _quarterRound(work, 3, 7, 11, 15);
    _quarterRound(work, 0, 5, 10, 15);
    _quarterRound(work, 1, 6, 11, 12);
    _quarterRound(work, 2, 7, 8, 13);
    _quarterRound(work, 3, 4, 9, 14);
  }
  final out = Uint8List(64);
  for (var i = 0; i < 16; i++) {
    _writeUint32Le(out, i * 4, (work[i] + state[i]) & 0xffffffff);
  }
  return out;
}

void _quarterRound(Uint32List state, int a, int b, int c, int d) {
  state[a] = (state[a] + state[b]) & 0xffffffff;
  state[d] ^= state[a];
  state[d] = _rotateLeft(state[d], 16);
  state[c] = (state[c] + state[d]) & 0xffffffff;
  state[b] ^= state[c];
  state[b] = _rotateLeft(state[b], 12);
  state[a] = (state[a] + state[b]) & 0xffffffff;
  state[d] ^= state[a];
  state[d] = _rotateLeft(state[d], 8);
  state[c] = (state[c] + state[d]) & 0xffffffff;
  state[b] ^= state[c];
  state[b] = _rotateLeft(state[b], 7);
}

int _rotateLeft(int value, int shift) {
  return ((value << shift) | (value >>> (32 - shift))) & 0xffffffff;
}

Uint8List _rsaWrap(Uint8List keyA) {
  final n = BigInt.parse(_rsaN, radix: 16);
  final e = BigInt.from(_rsaE);
  final value = _bigEndianToBigInt(keyA).modPow(e, n);
  return _bigIntToBigEndian(value, 32);
}

BigInt _bigEndianToBigInt(Uint8List bytes) {
  var result = BigInt.zero;
  for (final byte in bytes) {
    result = (result << 8) | BigInt.from(byte);
  }
  return result;
}

Uint8List _bigIntToBigEndian(BigInt value, int length) {
  final out = Uint8List(length);
  var current = value;
  for (var i = length - 1; i >= 0; i--) {
    out[i] = (current & BigInt.from(0xff)).toInt();
    current >>= 8;
  }
  return out;
}

Uint8List _randomBytes(int length) {
  return Uint8List.fromList(List<int>.generate(length, (_) => _secureRandom.nextInt(256)));
}

Uint8List _randomUuidBytes() {
  final bytes = _randomBytes(16);
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  return bytes;
}

String _randomUuidHex() {
  return _randomBytes(16).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

String _randomHex(int bytes) {
  return _randomBytes(bytes).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

Uint8List _concatBytes(List<Uint8List> parts) {
  final length = parts.fold<int>(0, (sum, part) => sum + part.length);
  final result = Uint8List(length);
  var offset = 0;
  for (final part in parts) {
    result.setRange(offset, offset + part.length, part);
    offset += part.length;
  }
  return result;
}

Uint8List _uint16Le(int value) {
  final out = Uint8List(2);
  _writeUint16Le(out, 0, value);
  return out;
}

Uint8List _uint32Le(int value) {
  final out = Uint8List(4);
  _writeUint32Le(out, 0, value);
  return out;
}

int _readUint16Le(Uint8List bytes, int offset) {
  return ByteData.sublistView(bytes).getUint16(offset, Endian.little);
}

int _readUint32Le(Uint8List bytes, int offset) {
  return ByteData.sublistView(bytes).getUint32(offset, Endian.little);
}

void _writeUint16Le(Uint8List bytes, int offset, int value) {
  ByteData.sublistView(bytes).setUint16(offset, value, Endian.little);
}

void _writeUint32Le(Uint8List bytes, int offset, int value) {
  ByteData.sublistView(bytes).setUint32(offset, value, Endian.little);
}
