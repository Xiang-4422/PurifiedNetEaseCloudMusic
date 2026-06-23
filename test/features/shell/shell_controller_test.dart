import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShellController helpers', () {
    test('builds mini player expand feedback metric details', () {
      expect(
        miniPlayerExpandFeedbackMetricDetails(
          attached: true,
          alreadyOpened: false,
          opened: true,
        ),
        'action=expand result=success attached=true alreadyOpened=false',
      );
      expect(
        miniPlayerExpandFeedbackMetricDetails(
          attached: false,
          alreadyOpened: false,
          opened: false,
        ),
        'action=expand result=skipped attached=false alreadyOpened=false',
      );
      expect(
        miniPlayerExpandFeedbackMetricDetails(
          attached: true,
          alreadyOpened: true,
          opened: true,
        ),
        'action=expand result=already_open attached=true alreadyOpened=true',
      );
      expect(
        miniPlayerExpandFeedbackMetricDetails(
          attached: true,
          alreadyOpened: false,
          opened: false,
          error: StateError('open failed'),
        ),
        'action=expand result=error attached=true alreadyOpened=false error=StateError',
      );
    });
  });
}
