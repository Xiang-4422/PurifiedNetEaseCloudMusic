import 'dart:async';

import 'package:bujuan/features/shell/mini_player_expand_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MiniPlayerExpandCoordinator', () {
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
          alreadyOpened: false,
          opened: false,
        ),
        'action=expand result=skipped attached=true alreadyOpened=false',
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
      final coordinator = MiniPlayerExpandCoordinator();
      final openCalls = <Completer<void>>[];

      Future<void> openPanel() {
        final completer = Completer<void>();
        openCalls.add(completer);
        return completer.future;
      }

      final first = coordinator.open(
        isAttached: () => true,
        isFullyOpened: () => false,
        openPanel: openPanel,
      );
      final second = coordinator.open(
        isAttached: () => true,
        isFullyOpened: () => false,
        openPanel: openPanel,
      );
      await Future<void>.delayed(Duration.zero);

      expect(openCalls, hasLength(1));

      openCalls.last.complete();
      await Future.wait([first, second]);

      final third = coordinator.open(
        isAttached: () => true,
        isFullyOpened: () => false,
        openPanel: openPanel,
      );
      await Future<void>.delayed(Duration.zero);

      expect(openCalls, hasLength(2));

      openCalls.last.complete();
      await third;
    });

    test('checks opened state after mini player expand action completes', () async {
      final coordinator = MiniPlayerExpandCoordinator();
      var opened = false;
      var openedChecks = 0;

      await coordinator.open(
        isAttached: () => true,
        isFullyOpened: () {
          openedChecks++;
          return opened;
        },
        openPanel: () async {
          expect(openedChecks, 1);
          opened = true;
        },
      );

      expect(openedChecks, 2);
    });
  });
}
