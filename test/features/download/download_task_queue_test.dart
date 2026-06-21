import 'dart:async';

import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/features/download/application/download_task_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownloadTaskQueue', () {
    test('removes failed download task without leaking cleanup errors', () async {
      final queue = DownloadTaskQueue();
      const trackId = 'failed-download';
      final operationError = StateError('download failed');
      final unhandledErrors = <Object>[];

      await runZonedGuarded(
        () async {
          final task = queue.scheduleDownload(
            trackId,
            () => Future<Track?>.error(operationError),
          );

          await expectLater(task, throwsA(same(operationError)));
          await Future<void>.delayed(Duration.zero);
        },
        (error, stackTrace) => unhandledErrors.add(error),
      );

      expect(queue.existingDownload(trackId), isNull);
      expect(unhandledErrors, isEmpty);
    });

    test('removes failed playback cache task without leaking cleanup errors', () async {
      final queue = DownloadTaskQueue();
      const trackId = 'failed-playback-cache';
      final operationError = StateError('cache failed');
      final unhandledErrors = <Object>[];

      await runZonedGuarded(
        () async {
          final task = queue.schedulePlaybackCache(
            trackId,
            () => Future<Track?>.error(operationError),
          );

          await expectLater(task, throwsA(same(operationError)));
          await Future<void>.delayed(Duration.zero);
        },
        (error, stackTrace) => unhandledErrors.add(error),
      );

      expect(queue.existingPlaybackCache(trackId), isNull);
      expect(unhandledErrors, isEmpty);
    });

    test('keeps existing download task until it completes', () async {
      final queue = DownloadTaskQueue();
      const trackId = 'pending-download';
      final completer = Completer<Track?>();

      final task = queue.scheduleDownload(trackId, () => completer.future);

      expect(queue.existingDownload(trackId), same(task));

      completer.complete(null);
      await task;
      await Future<void>.delayed(Duration.zero);

      expect(queue.existingDownload(trackId), isNull);
    });
  });
}
