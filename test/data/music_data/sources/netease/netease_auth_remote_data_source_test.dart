import 'package:bujuan/data/music_data/sources/netease/remote/netease_auth_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/netease_music_api.dart';

void main() {
  group('NeteaseAuthRemoteDataSource', () {
    test('normalizes created qr key before returning it', () async {
      final api = _FakeNeteaseMusicApi()..nextQrKey = ' key-1 ';
      final dataSource = NeteaseAuthRemoteDataSource(api: api);

      final result = await dataSource.createQrCodeKey();

      expect(result.success, isTrue);
      expect(result.unikey, 'key-1');
      expect(api.qrKeyRequests, 1);
    });

    test('treats blank created qr key as failed result', () async {
      final api = _FakeNeteaseMusicApi()..nextQrKey = ' ';
      final dataSource = NeteaseAuthRemoteDataSource(api: api);

      final result = await dataSource.createQrCodeKey();

      expect(result.success, isFalse);
      expect(result.unikey, isEmpty);
      expect(api.qrKeyRequests, 1);
    });

    test('normalizes qr key before building url and checking status', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseAuthRemoteDataSource(api: api);

      final url = dataSource.buildQrCodeUrl(' key-1 ');
      final status = await dataSource.checkQrCodeStatus(' key-1 ');

      expect(url, 'https://music.test/login?codekey=key-1');
      expect(status.code, 801);
      expect(api.qrUrlKeys, ['key-1']);
      expect(api.qrCheckKeys, ['key-1']);
    });

    test('rejects blank qr keys before SDK calls', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseAuthRemoteDataSource(api: api);

      final url = dataSource.buildQrCodeUrl(' ');
      final status = await dataSource.checkQrCodeStatus(' ');

      expect(url, isEmpty);
      expect(status.code, 800);
      expect(status.message, contains('qr code key'));
      expect(api.qrUrlKeys, isEmpty);
      expect(api.qrCheckKeys, isEmpty);
    });
  });
}

class _FakeNeteaseMusicApi implements NeteaseMusicApi {
  int qrKeyRequests = 0;
  String nextQrKey = 'key-1';
  final qrUrlKeys = <String>[];
  final qrCheckKeys = <String>[];

  @override
  Future<QrCodeLoginKey> loginQrCodeKey() async {
    qrKeyRequests++;
    return QrCodeLoginKey()
      ..code = 200
      ..unikey = nextQrKey;
  }

  @override
  String loginQrCodeUrl(String key) {
    qrUrlKeys.add(key);
    return 'https://music.test/login?codekey=$key';
  }

  @override
  Future<QrCodeLoginKey> loginQrCodeCheck(String key) async {
    qrCheckKeys.add(key);
    return QrCodeLoginKey()
      ..code = 801
      ..message = 'waiting';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
