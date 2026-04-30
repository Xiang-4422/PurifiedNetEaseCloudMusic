import 'package:bujuan/data/netease/api/models/play/bean.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SongLyricWrap', () {
    test('accepts missing optional lyric blocks', () {
      final wrap = SongLyricWrap.fromJson({
        'code': 200,
        'lrc': {'lyric': '[00:00.00]main'},
        'klyric': null,
        'tlyric': null,
      });

      expect(wrap.lrc?.lyric, '[00:00.00]main');
      expect(wrap.klyric, isNull);
      expect(wrap.tlyric, isNull);
    });
  });
}
