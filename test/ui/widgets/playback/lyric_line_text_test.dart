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
