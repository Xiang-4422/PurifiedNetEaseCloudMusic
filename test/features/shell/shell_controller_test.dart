import 'dart:async';

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
          coalesced: true,
        ),
        'action=expand result=coalesced attached=true alreadyOpened=false coalesced=true',
      );
      expect(
        miniPlayerExpandFeedbackMetricDetails(
          attached: true,
          alreadyOpened: false,
          opened: false,
          coalesced: true,
          error: StateError('open failed'),
        ),
        'action=expand result=error attached=true alreadyOpened=false coalesced=true error=StateError',
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

    test('coalesces concurrent mini player expand commands', () async {
      final controller = _TestShellController();

      final first = controller.openBottomPanelFromMiniPlayer();
      final second = controller.openBottomPanelFromMiniPlayer();
      await Future<void>.delayed(Duration.zero);

      expect(controller.openCount, 1);

      controller.completeLatestOpen();
      await Future.wait([first, second]);

      final third = controller.openBottomPanelFromMiniPlayer();
      await Future<void>.delayed(Duration.zero);

      expect(controller.openCount, 2);

      controller.completeLatestOpen();
      await third;
    });
  });
}

class _TestShellController extends ShellController {
  final List<Completer<void>> _openCompleters = <Completer<void>>[];

  int get openCount => _openCompleters.length;

  @override
  Future<void> openBottomPanel() {
    final completer = Completer<void>();
    _openCompleters.add(completer);
    return completer.future;
  }

  void completeLatestOpen() {
    _openCompleters.last.complete();
  }
}
