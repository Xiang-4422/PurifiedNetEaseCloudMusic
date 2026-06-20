import 'package:bujuan/features/playback/lyrics/lyrics_reader_model.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/lyric_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LyricLineText', () {
    test('builds placeholder and translated lyric text', () {
      final emptyLine = LyricsLineModel()..mainText = '   ';
      final translatedLine = LyricsLineModel()
        ..mainText = '  main lyric  '
        ..extText = '  translated lyric  ';

      expect(lyricLineDisplayText(emptyLine), '···');
      expect(lyricLineDisplayText(translatedLine), 'main lyric\ntranslated lyric');
    });

    test('resolves seek position from lyric line start time', () {
      final missingTime = LyricsLineModel()..mainText = 'no time';
      final negativeTime = LyricsLineModel()
        ..mainText = 'negative'
        ..startTime = -120;
      final normalTime = LyricsLineModel()
        ..mainText = 'normal'
        ..startTime = 1234;

      expect(lyricLineSeekPosition(missingTime), isNull);
      expect(lyricLineSeekPosition(negativeTime), Duration.zero);
      expect(lyricLineSeekPosition(normalTime), const Duration(milliseconds: 1234));
    });

    test('splits timed lyric spans by current playback position', () {
      final line = LyricsLineModel()
        ..mainText = '你好世界'
        ..spanList = [
          LyricSpanInfo()
            ..raw = '你'
            ..start = 1000,
          LyricSpanInfo()
            ..raw = '好'
            ..start = 1300,
          LyricSpanInfo()
            ..raw = '世'
            ..start = 1600,
          LyricSpanInfo()
            ..raw = '界'
            ..start = 1900,
        ];

      final before = lyricLineProgressText(
        line,
        const Duration(milliseconds: 999),
      );
      final middle = lyricLineProgressText(
        line,
        const Duration(milliseconds: 1600),
      );
      final after = lyricLineProgressText(
        line,
        const Duration(milliseconds: 2200),
      );

      expect(before.playedText, isEmpty);
      expect(before.upcomingText, '你好世界');
      expect(middle.playedText, '你好世');
      expect(middle.upcomingText, '界');
      expect(after.playedText, '你好世界');
      expect(after.upcomingText, isEmpty);
    });

    testWidgets('renders active timed lyric line with played and upcoming spans', (tester) async {
      final line = LyricsLineModel()
        ..mainText = '你好'
        ..extText = 'Hello'
        ..spanList = [
          LyricSpanInfo()
            ..raw = '你'
            ..start = 1000,
          LyricSpanInfo()
            ..raw = '好'
            ..start = 1300,
        ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LyricLineText(
              line: line,
              isActive: true,
              currentPosition: const Duration(milliseconds: 1100),
              color: Colors.white,
              baseStyle: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      final span = text.textSpan! as TextSpan;
      final children = span.children!.cast<TextSpan>().toList();

      expect(children.map((child) => child.text), ['你', '好', '\nHello']);
      expect(children[0].style?.color, Colors.white.withValues(alpha: 1));
      expect(children[1].style?.color, Colors.white.withValues(alpha: 0.42));
      expect(children[2].style?.color, Colors.white.withValues(alpha: 0.68));
      expect(text.softWrap, isTrue);
      expect(text.overflow, TextOverflow.visible);
    });

    testWidgets('keeps long lyric lines wrappable inside constrained width', (tester) async {
      final line = LyricsLineModel()
        ..mainText = 'this is a very long lyric line that should wrap instead of forcing the player panel wider'
        ..extText = 'translated line also wraps';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 120,
                child: LyricLineText(
                  line: line,
                  isActive: true,
                  color: Colors.white,
                  baseStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text(lyricLineDisplayText(line)));

      expect(text.softWrap, isTrue);
      expect(text.maxLines, isNull);
      expect(text.overflow, TextOverflow.visible);
      expect(tester.takeException(), isNull);
    });
  });
}
