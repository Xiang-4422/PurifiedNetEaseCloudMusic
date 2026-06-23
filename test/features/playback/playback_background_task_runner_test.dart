import 'dart:async';

import 'package:bujuan/features/playback/application/playback_background_task_runner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackBackgroundTaskRunner', () {
    test('reports async task failure without leaking callback errors', () async {
      final taskError = StateError('save failed');
      final reported = Completer<void>();
      final reportedTasks = <String>[];
      final reportedTrackIds = <String?>[];
      final reportedErrors = <Object>[];
      final unhandledErrors = <Object>[];
      final runner = PlaybackBackgroundTaskRunner(
        onError: (taskName, trackId, error, stackTrace) {
          reportedTasks.add(taskName);
          reportedTrackIds.add(trackId);
          reportedErrors.add(error);
          reported.complete();
          throw StateError('diagnostic callback failed');
        },
      );

      await runZonedGuarded(
        () async {
          runner.run(
            taskName: 'playback.position.save',
            trackId: 'track-1',
            task: () => Future<void>.error(taskError),
          );
          await reported.future;
          await Future<void>.delayed(Duration.zero);
        },
        (error, stackTrace) => unhandledErrors.add(error),
      );

      expect(reportedTasks, ['playback.position.save']);
      expect(reportedTrackIds, ['track-1']);
      expect(reportedErrors.single, same(taskError));
      expect(unhandledErrors, isEmpty);
    });

    test('reports sync task failure without leaking it', () async {
      final taskError = StateError('stream sync failed');
      final reported = Completer<void>();
      final reportedErrors = <Object>[];
      final unhandledErrors = <Object>[];
      final runner = PlaybackBackgroundTaskRunner(
        onError: (taskName, trackId, error, stackTrace) {
          reportedErrors.add(error);
          reported.complete();
        },
      );

      await runZonedGuarded(
        () async {
          runner.run(
            taskName: 'playback.state.sync',
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
