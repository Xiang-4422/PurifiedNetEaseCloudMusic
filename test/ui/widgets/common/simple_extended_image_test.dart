import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SimpleExtendedImage', () {
    testWidgets('keeps default placeholder dimensions when image path is empty', (tester) async {
      const imageKey = Key('empty-image');

      await tester.pumpWidget(
        _wrap(
          const SimpleExtendedImage(
            '',
            key: imageKey,
            width: 96,
            height: 72,
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(imageKey)), const Size(96, 72));
      expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
    });

    testWidgets('keeps replacement dimensions when image path is empty', (tester) async {
      const imageKey = Key('replacement-image');
      const replacementKey = Key('replacement');

      await tester.pumpWidget(
        _wrap(
          const SimpleExtendedImage(
            '',
            key: imageKey,
            width: 84,
            height: 84,
            replacement: ColoredBox(
              key: replacementKey,
              color: Colors.red,
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(imageKey)), const Size(84, 84));
      expect(tester.getSize(find.byKey(replacementKey)), const Size(84, 84));
      expect(find.byIcon(Icons.music_note_rounded), findsNothing);
    });
  });
}

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}
