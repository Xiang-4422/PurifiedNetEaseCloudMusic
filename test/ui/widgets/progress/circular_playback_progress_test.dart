import 'package:bujuan/ui/widgets/common/progress/circular_playback_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('playback progress helpers', () {
    test('normalizes raw progress values', () {
      expect(normalizePlaybackProgress(0.25), 0.25);
      expect(normalizePlaybackProgress(-0.5), 0);
      expect(normalizePlaybackProgress(1.5), 1);
      expect(normalizePlaybackProgress(double.nan), 0);
      expect(normalizePlaybackProgress(double.infinity), 0);
    });

    test('builds safe progress fraction from position and total duration', () {
      expect(
        playbackProgressFraction(
          position: const Duration(seconds: 30),
          total: const Duration(minutes: 2),
        ),
        0.25,
      );
      expect(
        playbackProgressFraction(
          position: const Duration(seconds: -5),
          total: const Duration(minutes: 2),
        ),
        0,
      );
      expect(
        playbackProgressFraction(
          position: const Duration(minutes: 3),
          total: const Duration(minutes: 2),
        ),
        1,
      );
      expect(
        playbackProgressFraction(
          position: const Duration(seconds: 30),
          total: null,
        ),
        0,
      );
      expect(
        playbackProgressFraction(
          position: const Duration(seconds: 30),
          total: Duration.zero,
        ),
        0,
      );
    });
  });
}
