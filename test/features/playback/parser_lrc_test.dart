import 'package:bujuan/features/playback/lyrics/parser_lrc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParserLrc', () {
    test('converts centisecond and millisecond time tags to milliseconds', () {
      final parser = ParserLrc('');

      expect(parser.timeTagToTS('[00:03.47]'), 3470);
      expect(parser.timeTagToTS('[00:03.470]'), 3470);
      expect(parser.timeTagToTS('[00:03.4]'), 3400);
      expect(parser.timeTagToTS('[01:02.345]'), 62345);
    });

    test('expands multiple time tags on the same lyric line and sorts them', () {
      final lines = ParserLrc('[00:02.00][00:01.50]Replay\n[00:03.000]Next').parseLines();

      expect(lines.map((line) => line.startTime), [1500, 2000, 3000]);
      expect(lines.map((line) => line.mainText), ['Replay', 'Replay', 'Next']);
    });

    test('stores parsed text as extension text for translated lyrics', () {
      final lines = ParserLrc('[00:01.00]Hello').parseLines(isMain: false);

      expect(lines.single.mainText, isNull);
      expect(lines.single.extText, 'Hello');
      expect(lines.single.startTime, 1000);
    });
  });
}
