import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('comment list exposes retry on initial error', () {
    final source = File(
      'lib/ui/pages/shell/widgets/comment/comment_widget.dart',
    ).readAsStringSync();

    expect(source, contains('ErrorView('));
    expect(source, contains('onRetry: () => unawaited(_controller.loadInitial())'));
    expect(source, isNot(contains('return const ErrorView();')));
  });

  test('floor comment sheet exposes forced retry on initial error', () {
    final source = File(
      'lib/ui/pages/shell/widgets/comment/floor_comment_sheet.dart',
    ).readAsStringSync();

    expect(source, contains('ErrorView('));
    expect(source, contains('onRetry: () => unawaited(_controller.loadInitial(force: true))'));
    expect(source, isNot(contains('return const ErrorView();')));
  });
}
