import 'dart:async';

import 'package:bujuan/features/shell/shell_background_task_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShellBackgroundTaskRunner', () {
    test('reports async task failure without leaking callback errors', () async {
      final taskError = StateError('animation failed');
      final reported = Completer<void>();
      final reportedTasks = <String>[];
      final reportedErrors = <Object>[];
      final unhandledErrors = <Object>[];
      final runner = ShellBackgroundTaskRunner(
        onError: (taskName, error, stackTrace) {
          reportedTasks.add(taskName);
          reportedErrors.add(error);
          reported.complete();
          throw StateError('diagnostic callback failed');
        },
      );

      await runZonedGuarded(
        () async {
          runner.run(
            taskName: 'shell.albumSync.run',
            task: () => Future<void>.error(taskError),
          );
          await reported.future;
          await Future<void>.delayed(Duration.zero);
        },
        (error, stackTrace) => unhandledErrors.add(error),
      );

      expect(reportedTasks, ['shell.albumSync.run']);
      expect(reportedErrors.single, same(taskError));
      expect(unhandledErrors, isEmpty);
    });

    test('reports sync task failure without leaking it', () async {
      final taskError = StateError('page listener failed');
      final reported = Completer<void>();
      final reportedErrors = <Object>[];
      final unhandledErrors = <Object>[];
      final runner = ShellBackgroundTaskRunner(
        onError: (taskName, error, stackTrace) {
          reportedErrors.add(error);
          reported.complete();
        },
      );

      await runZonedGuarded(
        () async {
          runner.run(
            taskName: 'shell.bottomPanel.pageChanged',
            task: () => throw taskError,
          );
          await reported.future;
          await Future<void>.delayed(Duration.zero);
        },
        (error, stackTrace) => unhandledErrors.add(error),
      );

      expect(reportedErrors.single, same(taskError));
      expect(unhandledErrors, isEmpty);
    });
  });
}
