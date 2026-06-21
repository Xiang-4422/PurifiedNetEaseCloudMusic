import 'package:bujuan/features/playback/lyrics/parser_qrc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParserQrc', () {
    test('sorts lyric lines by start time', () {
      final lines = ParserQrc(
        '[2500,800](2500,400)世(2900,400)界\n'
        '[1000,1200](1000,300)你(1300,300)好',
      ).parseLines();

      expect(lines.map((line) => line.startTime), [1000, 2500]);
      expect(lines.map((line) => line.mainText), ['你好', '世界']);
    });

    test('keeps word-level spans for sorted lines', () {
      final lines = ParserQrc(
        '[2500,800](2500,400)世(2900,400)界\n'
        '[1000,1200](1000,300)你(1300,300)好',
      ).parseLines();

      final first = lines.first;
      expect(first.spanList?.map((span) => span.raw), ['你', '好']);
      expect(first.spanList?.map((span) => span.index), [0, 1]);
      expect(first.spanList?.map((span) => span.start), [1000, 1300]);
      expect(first.spanList?.map((span) => span.duration), [300, 300]);
    });

    test('stores parsed text as extension text for translated lyrics', () {
      final lines = ParserQrc('[1000,1200](1000,300)你(1300,300)好').parseLines(
        isMain: false,
      );

      expect(lines.single.mainText, isNull);
      expect(lines.single.extText, '你好');
      expect(lines.single.spanList, isNull);
    });
  });
}
