import 'package:bujuan/data/music_data/sources/netease/remote/netease_radio_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/netease_music_api.dart';

void main() {
  group('NeteaseRadioRemoteDataSource', () {
    test('normalizes radio id before fetching programs', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseRadioRemoteDataSource(api: api);

      final page = await dataSource.fetchPrograms(
        ' netease:radio-1 ',
        offset: 10,
        limit: 20,
        asc: false,
      );

      expect(page.items, isEmpty);
      expect(page.itemCount, 0);
      expect(api.programRequests, [
        (radioId: 'radio-1', offset: 10, limit: 20, asc: false),
      ]);
    });

    test('rejects invalid radio ids before SDK requests', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseRadioRemoteDataSource(api: api);

      final localPage = await dataSource.fetchPrograms(
        ' local:radio-1 ',
        offset: 0,
        limit: 20,
        asc: true,
      );
      final blankPage = await dataSource.fetchPrograms(
        ' ',
        offset: 0,
        limit: 20,
        asc: true,
      );

      expect(localPage.items, isEmpty);
      expect(localPage.itemCount, 0);
      expect(blankPage.items, isEmpty);
      expect(blankPage.itemCount, 0);
      expect(api.programRequests, isEmpty);
    });
  });
}

class _FakeNeteaseMusicApi implements NeteaseMusicApi {
  final programRequests = <({
    String radioId,
    int offset,
    int limit,
    bool asc,
  })>[];

  @override
  Future<DjProgramListWrap> djProgramList(
    String radioId, {
    int offset = 0,
    int limit = 30,
    bool asc = true,
  }) async {
    programRequests.add(
      (
        radioId: radioId,
        offset: offset,
        limit: limit,
        asc: asc,
      ),
    );
    return DjProgramListWrap()
      ..code = 200
      ..programs = const [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
