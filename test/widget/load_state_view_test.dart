import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/ui/widgets/common/feedback/load_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoadStateView renders data before stale refresh error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoadStateView<List<String>>(
          state: LoadState.error(
            StateError('offline'),
            data: const ['cached song'],
          ),
          builder: (items) => Text(items.single),
        ),
      ),
    );

    expect(find.text('cached song'), findsOneWidget);
    expect(find.text('加载失败'), findsNothing);
  });
}
