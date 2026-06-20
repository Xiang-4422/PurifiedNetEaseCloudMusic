import 'package:bujuan/features/playback/player_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerController helpers', () {
    test('builds mini player feedback metric details for success', () {
      expect(
        miniPlayerFeedbackMetricDetails(
          wasPlaying: false,
          succeeded: true,
        ),
        'action=play result=success',
      );
      expect(
        miniPlayerFeedbackMetricDetails(
          wasPlaying: true,
          succeeded: true,
        ),
        'action=pause result=success',
      );
    });

    test('builds mini player feedback metric details for failures', () {
      expect(
        miniPlayerFeedbackMetricDetails(
          wasPlaying: false,
          succeeded: false,
          error: StateError('play failed'),
        ),
        'action=play result=error error=StateError',
      );
      expect(
        miniPlayerFeedbackMetricDetails(
          wasPlaying: true,
          succeeded: false,
        ),
        'action=pause result=error',
      );
    });
  });
}
