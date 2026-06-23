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

    test('falls back to remote radios when cached radios load fails', () async {
      final repository = _FakeRadioRepository(
        cachedRadiosFuture: Future<List<RadioSummaryData>>.error(Exception('cache failed')),
        fetchSubscribedRadios: () => Future.value(
          DjRadioPage(
            items: [_radio('remote-radio')],
            hasMore: false,
            nextOffset: 1,
          ),
        ),
      );
      final controller = RadioListController(
        userId: 'user-1',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(repository.requestedRadioOffsets, [0]);
      expect(controller.state.value.items.map((item) => item.id), ['remote-radio']);
      expect(controller.state.value.initialLoading, isFalse);
      expect(controller.state.value.error, isNull);
    });

    test('ignores stale load more result after refresh completes', () async {
      final loadMore = Completer<DjRadioPage>();
      final refresh = Completer<DjRadioPage>();
      var firstPageLoaded = false;
      final repository = _FakeRadioRepository(
        fetchSubscribedRadiosWithArgs: ({required userId, required offset, required limit}) {
          if (offset == 0 && !firstPageLoaded) {
            firstPageLoaded = true;
            return Future.value(
              DjRadioPage(
                items: [_radio('old-radio')],
                hasMore: true,
                nextOffset: 1,
              ),
            );
          }
          if (offset == 0) {
            return refresh.future;
          }
          return loadMore.future;
        },
      );
      final controller = RadioListController(
        userId: 'user-1',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      expect(controller.state.value.items.map((item) => item.id), ['old-radio']);

      final loadMoreFuture = controller.loadMore();
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.value.loadingMore, isTrue);

      final refreshFuture = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      refresh.complete(
        DjRadioPage(
          items: [_radio('fresh-radio')],
          hasMore: true,
          nextOffset: 1,
        ),
      );
      await refreshFuture;

      expect(controller.state.value.items.map((item) => item.id), ['fresh-radio']);

      loadMore.complete(
        DjRadioPage(
          items: [_radio('stale-radio')],
          hasMore: false,
          nextOffset: 2,
        ),
      );
      await loadMoreFuture;

      expect(controller.state.value.items.map((item) => item.id), ['fresh-radio']);
      expect(controller.state.value.loadingMore, isFalse);
      expect(controller.state.value.refreshing, isFalse);
    });

    test('ignores refresh completion after dispose', () async {
      final refresh = Completer<DjRadioPage>();
      final repository = _FakeRadioRepository(
        fetchSubscribedRadios: () => refresh.future,
      );
      final controller = RadioListController(
        userId: 'user-1',
        repository: repository,
      );

      final refreshFuture = controller.refresh();
      await _flushAsync();

      controller.dispose();
      refresh.complete(
        DjRadioPage(
          items: [_radio('late-radio')],
          hasMore: false,
          nextOffset: 1,
        ),
      );

      await expectLater(refreshFuture, completes);
    });

    test('ignores load more completion after dispose', () async {
      final loadMore = Completer<DjRadioPage>();
      final repository = _FakeRadioRepository(
        fetchSubscribedRadiosWithArgs: ({required userId, required offset, required limit}) {
          if (offset == 0) {
            return Future.value(
              DjRadioPage(
                items: [_radio('cached-page-radio')],
                hasMore: true,
                nextOffset: 1,
              ),
            );
          }
          return loadMore.future;
        },
      );
      final controller = RadioListController(
        userId: 'user-1',
        repository: repository,
      );

      await controller.loadInitial();
      final loadMoreFuture = controller.loadMore();
      await _flushAsync();

      controller.dispose();
      loadMore.complete(
        DjRadioPage(
          items: [_radio('late-radio')],
          hasMore: false,
          nextOffset: 2,
        ),
      );

      await expectLater(loadMoreFuture, completes);
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

    test('falls back to remote programs when cached programs load fails', () async {
      final repository = _FakeRadioRepository(
        cachedProgramsFuture: Future<List<RadioProgramData>>.error(Exception('cache failed')),
        fetchPrograms: () => Future.value(
          DjProgramPage(
            items: [_program('remote-program')],
            hasMore: false,
            nextOffset: 1,
          ),
        ),
      );
      final controller = RadioDetailController(
        radioId: 'radio-1',
        userId: 'user-1',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(repository.requestedProgramOffsets, [0]);
      expect(controller.state.value.items.map((item) => item.id), ['remote-program']);
      expect(controller.state.value.initialLoading, isFalse);
      expect(controller.state.value.error, isNull);
    });

    test('ignores stale load more result after refresh completes', () async {
      final loadMore = Completer<DjProgramPage>();
      final refresh = Completer<DjProgramPage>();
      var firstPageLoaded = false;
      final repository = _FakeRadioRepository(
        fetchProgramsWithArgs: ({required userId, required radioId, required offset, required limit, required asc}) {
          if (offset == 0 && !firstPageLoaded) {
            firstPageLoaded = true;
            return Future.value(
              DjProgramPage(
                items: [_program('old-program')],
                hasMore: true,
                nextOffset: 1,
              ),
            );
          }
          if (offset == 0) {
            return refresh.future;
          }
          return loadMore.future;
        },
      );
      final controller = RadioDetailController(
        radioId: 'radio-1',
        userId: 'user-1',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      expect(controller.state.value.items.map((item) => item.id), ['old-program']);

      final loadMoreFuture = controller.loadMore();
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.value.loadingMore, isTrue);

      final refreshFuture = controller.refresh();
      await Future<void>.delayed(Duration.zero);
      refresh.complete(
        DjProgramPage(
          items: [_program('fresh-program')],
          hasMore: true,
          nextOffset: 1,
        ),
      );
      await refreshFuture;

      expect(controller.state.value.items.map((item) => item.id), ['fresh-program']);

      loadMore.complete(
        DjProgramPage(
          items: [_program('stale-program')],
          hasMore: false,
          nextOffset: 2,
        ),
      );
      await loadMoreFuture;

      expect(controller.state.value.items.map((item) => item.id), ['fresh-program']);
      expect(controller.state.value.loadingMore, isFalse);
      expect(controller.state.value.refreshing, isFalse);
    });

    test('ignores refresh completion after dispose', () async {
      final refresh = Completer<DjProgramPage>();
      final repository = _FakeRadioRepository(
        fetchPrograms: () => refresh.future,
      );
      final controller = RadioDetailController(
        radioId: 'radio-1',
        userId: 'user-1',
        repository: repository,
      );

      final refreshFuture = controller.refresh();
      await _flushAsync();

      controller.dispose();
      refresh.complete(
        DjProgramPage(
          items: [_program('late-program')],
          hasMore: false,
          nextOffset: 1,
        ),
      );

      await expectLater(refreshFuture, completes);
    });

    test('ignores load more completion after dispose', () async {
      final loadMore = Completer<DjProgramPage>();
      final repository = _FakeRadioRepository(
        fetchProgramsWithArgs: ({required userId, required radioId, required offset, required limit, required asc}) {
          if (offset == 0) {
            return Future.value(
              DjProgramPage(
                items: [_program('cached-page-program')],
                hasMore: true,
                nextOffset: 1,
              ),
            );
          }
          return loadMore.future;
        },
      );
      final controller = RadioDetailController(
        radioId: 'radio-1',
        userId: 'user-1',
        repository: repository,
      );

      await controller.loadInitial();
      final loadMoreFuture = controller.loadMore();
      await _flushAsync();

      controller.dispose();
      loadMore.complete(
        DjProgramPage(
          items: [_program('late-program')],
          hasMore: false,
          nextOffset: 2,
        ),
      );

      await expectLater(loadMoreFuture, completes);
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

Future<void> _flushAsync() async {
  for (var i = 0; i < 4; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _FakeRadioRepository implements RadioRepository {
  _FakeRadioRepository({
    this.cachedRadios = const [],
    this.cachedPrograms = const [],
    this.cachedRadiosFuture,
    this.cachedProgramsFuture,
    Future<DjRadioPage> Function()? fetchSubscribedRadios,
    Future<DjProgramPage> Function()? fetchPrograms,
    Future<DjRadioPage> Function({
      required String userId,
      required int offset,
      required int limit,
    })? fetchSubscribedRadiosWithArgs,
    Future<DjProgramPage> Function({
      required String userId,
      required String radioId,
      required int offset,
      required int limit,
      required bool asc,
    })? fetchProgramsWithArgs,
  })  : _fetchSubscribedRadios = fetchSubscribedRadios,
        _fetchPrograms = fetchPrograms,
        _fetchSubscribedRadiosWithArgs = fetchSubscribedRadiosWithArgs,
        _fetchProgramsWithArgs = fetchProgramsWithArgs;

  final List<RadioSummaryData> cachedRadios;
  final List<RadioProgramData> cachedPrograms;
  final Future<List<RadioSummaryData>>? cachedRadiosFuture;
  final Future<List<RadioProgramData>>? cachedProgramsFuture;
  final Future<DjRadioPage> Function()? _fetchSubscribedRadios;
  final Future<DjProgramPage> Function()? _fetchPrograms;
  final Future<DjRadioPage> Function({
    required String userId,
    required int offset,
    required int limit,
  })? _fetchSubscribedRadiosWithArgs;
  final Future<DjProgramPage> Function({
    required String userId,
    required String radioId,
    required int offset,
    required int limit,
    required bool asc,
  })? _fetchProgramsWithArgs;
  final List<int> requestedRadioOffsets = <int>[];
  final List<int> requestedProgramOffsets = <int>[];

  @override
  Future<List<RadioSummaryData>> loadCachedSubscribedRadios(String userId) async {
    final future = cachedRadiosFuture;
    if (future != null) {
      return future;
    }
    return cachedRadios;
  }

  @override
  Future<List<RadioProgramData>> loadCachedPrograms(
    String userId,
    String radioId, {
    required bool asc,
  }) async {
    final future = cachedProgramsFuture;
    if (future != null) {
      return future;
    }
    return cachedPrograms;
  }

  @override
  Future<DjRadioPage> fetchSubscribedRadios({
    required String userId,
    bool total = true,
    required int offset,
    required int limit,
  }) {
    requestedRadioOffsets.add(offset);
    final fetchWithArgs = _fetchSubscribedRadiosWithArgs;
    if (fetchWithArgs != null) {
      return fetchWithArgs(
        userId: userId,
        offset: offset,
        limit: limit,
      );
    }
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
    requestedProgramOffsets.add(offset);
    final fetchWithArgs = _fetchProgramsWithArgs;
    if (fetchWithArgs != null) {
      return fetchWithArgs(
        userId: userId,
        radioId: radioId,
        offset: offset,
        limit: limit,
        asc: asc,
      );
    }
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
