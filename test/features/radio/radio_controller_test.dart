import 'dart:async';

import 'package:bujuan/core/entities/radio_data.dart';
import 'package:bujuan/features/radio/radio_detail_controller.dart';
import 'package:bujuan/features/radio/radio_list_controller.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RadioListController', () {
    test('keeps cached radios when background refresh fails', () async {
      final refresh = Completer<DjRadioPage>();
      final error = Exception('offline');
      final repository = _FakeRadioRepository(
        cachedRadios: [_radio('cached-radio')],
        fetchSubscribedRadios: () => refresh.future,
      );
      final controller = RadioListController(
        userId: 'user-1',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      expect(controller.state.value.items.map((item) => item.id), ['cached-radio']);
      expect(controller.state.value.refreshing, isTrue);

      refresh.completeError(error, StackTrace.current);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.value.items.map((item) => item.id), ['cached-radio']);
      expect(controller.state.value.refreshing, isFalse);
      expect(controller.state.value.error, same(error));
      expect(controller.state.value.hasInitialError, isFalse);
    });

    test('uses initial error when no cached radios exist', () async {
      final error = Exception('offline');
      final repository = _FakeRadioRepository(
        fetchSubscribedRadios: () => Future<DjRadioPage>.error(error),
      );
      final controller = RadioListController(
        userId: 'user-1',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(controller.state.value.items, isEmpty);
      expect(controller.state.value.error, same(error));
      expect(controller.state.value.hasInitialError, isTrue);
    });
  });

  group('RadioDetailController', () {
    test('keeps cached programs when background refresh fails', () async {
      final refresh = Completer<DjProgramPage>();
      final error = Exception('offline');
      final repository = _FakeRadioRepository(
        cachedPrograms: [_program('cached-program')],
        fetchPrograms: () => refresh.future,
      );
      final controller = RadioDetailController(
        radioId: 'radio-1',
        userId: 'user-1',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      expect(controller.state.value.items.map((item) => item.id), ['cached-program']);
      expect(controller.state.value.refreshing, isTrue);

      refresh.completeError(error, StackTrace.current);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.value.items.map((item) => item.id), ['cached-program']);
      expect(controller.state.value.refreshing, isFalse);
      expect(controller.state.value.error, same(error));
      expect(controller.state.value.hasInitialError, isFalse);
    });

    test('uses initial error when no cached programs exist', () async {
      final error = Exception('offline');
      final repository = _FakeRadioRepository(
        fetchPrograms: () => Future<DjProgramPage>.error(error),
      );
      final controller = RadioDetailController(
        radioId: 'radio-1',
        userId: 'user-1',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(controller.state.value.items, isEmpty);
      expect(controller.state.value.error, same(error));
      expect(controller.state.value.hasInitialError, isTrue);
    });
  });
}

RadioSummaryData _radio(String id) {
  return RadioSummaryData(
    id: id,
    name: 'Radio $id',
    coverUrl: 'https://cover.test/$id.jpg',
    lastProgramName: 'Latest $id',
  );
}

RadioProgramData _program(String id) {
  return RadioProgramData(
    id: id,
    mainTrackId: 'track-$id',
    title: 'Program $id',
    coverUrl: 'https://cover.test/$id.jpg',
    artistName: 'Artist',
    albumTitle: 'Album',
    durationMs: 1000,
  );
}

class _FakeRadioRepository implements RadioRepository {
  _FakeRadioRepository({
    this.cachedRadios = const [],
    this.cachedPrograms = const [],
    Future<DjRadioPage> Function()? fetchSubscribedRadios,
    Future<DjProgramPage> Function()? fetchPrograms,
  })  : _fetchSubscribedRadios = fetchSubscribedRadios,
        _fetchPrograms = fetchPrograms;

  final List<RadioSummaryData> cachedRadios;
  final List<RadioProgramData> cachedPrograms;
  final Future<DjRadioPage> Function()? _fetchSubscribedRadios;
  final Future<DjProgramPage> Function()? _fetchPrograms;

  @override
  Future<List<RadioSummaryData>> loadCachedSubscribedRadios(String userId) async {
    return cachedRadios;
  }

  @override
  Future<List<RadioProgramData>> loadCachedPrograms(
    String userId,
    String radioId, {
    required bool asc,
  }) async {
    return cachedPrograms;
  }

  @override
  Future<DjRadioPage> fetchSubscribedRadios({
    required String userId,
    bool total = true,
    required int offset,
    required int limit,
  }) {
    return _fetchSubscribedRadios?.call() ??
        Future.value(
          const DjRadioPage(
            items: [],
            hasMore: false,
            nextOffset: 0,
          ),
        );
  }

  @override
  Future<DjProgramPage> fetchPrograms(
    String userId,
    String radioId, {
    required int offset,
    required int limit,
    required bool asc,
  }) {
    return _fetchPrograms?.call() ??
        Future.value(
          const DjProgramPage(
            items: [],
            hasMore: false,
            nextOffset: 0,
          ),
        );
  }
}
