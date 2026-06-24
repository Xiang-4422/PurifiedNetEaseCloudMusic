import 'package:bujuan/ui/widgets/common/interaction/swipeable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Swipeable', () {
    testWidgets('dispatches horizontal swipe callbacks by drag direction', (tester) async {
      var leftSwipeCount = 0;
      var rightSwipeCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 240,
                height: 80,
                child: Swipeable(
                  threshold: 64,
                  background: const SizedBox.expand(),
                  onSwipeLeft: () => leftSwipeCount++,
                  onSwipeRight: () => rightSwipeCount++,
                  child: const ColoredBox(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(Swipeable), const Offset(-200, 0));
      await tester.pumpAndSettle();

      expect(leftSwipeCount, 1);
      expect(rightSwipeCount, 0);

      await tester.drag(find.byType(Swipeable), const Offset(200, 0));
      await tester.pumpAndSettle();

      expect(leftSwipeCount, 1);
      expect(rightSwipeCount, 1);
    });
  });
}
