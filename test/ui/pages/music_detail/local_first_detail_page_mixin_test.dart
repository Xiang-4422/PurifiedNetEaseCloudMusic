import 'dart:async';

import 'package:bujuan/features/music_detail/local_first_detail_controller.dart';
import 'package:bujuan/ui/pages/music_detail/local_first_detail_page_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalFirstDetailPageMixin', () {
    testWidgets('keeps local detail visible when background refresh fails', (tester) async {
      final remoteRefresh = Completer<String>();

      await tester.pumpWidget(
        MaterialApp(
          home: _DetailHarness(
            loadInitialDetail: () async {
              return const LocalFirstDetailInitialData<String>(
                localDetail: 'local',
              );
            },
            fetchDetail: () => remoteRefresh.future,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('local|loading=false|failed=false|loaded=true'), findsOneWidget);

      remoteRefresh.completeError(StateError('network'));
      await tester.pump();
      await tester.pump();

      expect(find.text('local|loading=false|failed=false|loaded=true'), findsOneWidget);
    });

    testWidgets('shows first-load failure when no local detail exists', (tester) async {
      final remoteRefresh = Completer<String>();

      await tester.pumpWidget(
        MaterialApp(
          home: _DetailHarness(
            loadInitialDetail: () async {
              return const LocalFirstDetailInitialData<String>(
                localDetail: null,
              );
            },
            fetchDetail: () => remoteRefresh.future,
          ),
        ),
      );
      await tester.pump();

      remoteRefresh.completeError(StateError('network'));
      await tester.pump();
      await tester.pump();

      expect(find.text('null|loading=false|failed=true|loaded=false'), findsOneWidget);
    });
  });
}

class _DetailHarness extends StatefulWidget {
  const _DetailHarness({
    required this.loadInitialDetail,
    required this.fetchDetail,
  });

  final Future<LocalFirstDetailInitialData<String>> Function() loadInitialDetail;
  final Future<String> Function() fetchDetail;

  @override
  State<_DetailHarness> createState() => _DetailHarnessState();
}

class _DetailHarnessState extends State<_DetailHarness> with LocalFirstDetailPageMixin<_DetailHarness> {
  String? detail;

  @override
  void initState() {
    super.initState();
    unawaited(
      loadInitialLocalFirstDetail<String>(
        loadInitialDetail: widget.loadInitialDetail,
        applyDetail: (value) => detail = value,
        refreshDetail: _refreshDetail,
      ),
    );
  }

  Future<void> _refreshDetail({required bool showLoadingState}) {
    return refreshLocalFirstDetail<String>(
      showLoadingState: showLoadingState,
      fetchDetail: widget.fetchDetail,
      applyDetail: (value) => detail = value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text('$detail|loading=$detailLoading|failed=$detailLoadFailed|loaded=$hasLoadedDetail'),
    );
  }
}
