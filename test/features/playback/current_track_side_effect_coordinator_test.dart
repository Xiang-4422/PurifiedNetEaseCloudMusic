import 'dart:async';

import 'package:bujuan/features/playback/application/current_track_side_effect_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrentTrackSideEffectCoordinator', () {
    test('reports task failure without leaking callback errors', () async {
      final taskError = StateError('side effect failed');
      final reported = Completer<void>();
      final reportedChannels = <String>[];
      final reportedTrackIds = <String>[];
      final reportedErrors = <Object>[];
      final unhandledErrors = <Object>[];
      final coordinator = CurrentTrackSideEffectCoordinator(
        onError: (channel, trackId, error, stackTrace) {
          reportedChannels.add(channel);
          reportedTrackIds.add(trackId);
          reportedErrors.add(error);
          reported.complete();
          throw StateError('diagnostic callback failed');
        },
      );

      await runZonedGuarded(
        () async {
          coordinator.schedule(
            channel: 'artwork',
            delay: Duration.zero,
            trackId: 'track-1',
            isStillCurrent: (_) => true,
            run: () => Future<void>.error(taskError),
          );
          await reported.future;
          await Future<void>.delayed(Duration.zero);
        },
        (error, stackTrace) => unhandledErrors.add(error),
      );

      expect(reportedChannels, ['artwork']);
      expect(reportedTrackIds, ['track-1']);
      expect(reportedErrors.single, same(taskError));
      expect(unhandledErrors, isEmpty);
    });

    test('replaces a pending task on the same channel', () async {
      final coordinator = CurrentTrackSideEffectCoordinator();
      final completedTasks = <String>[];

      coordinator.schedule(
        channel: 'lyrics',
        delay: const Duration(milliseconds: 20),
        trackId: 'old',
        isStillCurrent: (_) => true,
        run: () async => completedTasks.add('old'),
      );
      coordinator.schedule(
        channel: 'lyrics',
        delay: Duration.zero,
        trackId: 'new',
        isStillCurrent: (_) => true,
        run: () async => completedTasks.add('new'),
      );

      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(completedTasks, ['new']);
    });
  });
}
