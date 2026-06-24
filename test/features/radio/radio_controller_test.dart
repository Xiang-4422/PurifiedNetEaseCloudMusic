import 'dart:async';

import 'package:bujuan/core/state/load_state.dart';
import 'package:bujuan/core/entities/radio_data.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/user_scoped_data_source.dart';
import 'package:bujuan/features/radio/radio_detail_controller.dart';
import 'package:bujuan/features/radio/radio_list_controller.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RadioListController', () {
    test('skips repository access for blank user id', () async {
      final repository = _FakeRadioRepository();
      final controller = RadioListController(
        userId: '   ',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(controller.state.value.items, isEmpty);
      expect(controller.state.value.hasMore, isFalse);
      expect(repository.requestedCachedRadioUserIds, isEmpty);
      expect(repository.requestedRadioOffsets, isEmpty);

      expect(await controller.refresh(), isTrue);
      expect(await controller.loadMore(), isTrue);

      expect(controller.state.value.items, isEmpty);
      expect(controller.state.value.hasMore, isFalse);
      expect(repository.requestedCachedRadioUserIds, isEmpty);
      expect(repository.requestedRadioOffsets, isEmpty);
    });

    test('normalizes account scoped user id before repository access', () async {
      final repository = _FakeRadioRepository(
        fetchSubscribedRadiosWithArgs: ({required userId, required offset, required limit}) {
          return Future.value(
            DjRadioPage(
              items: [_radio('remote-radio-$offset')],
              hasMore: true,
              nextOffset: offset + 1,
            ),
          );
        },
      );
      final controller = RadioListController(
        userId: ' user-1 ',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      await controller.refresh();
      await controller.loadMore();

      expect(repository.requestedCachedRadioUserIds, ['user-1']);
      expect(repository.requestedRadioUserIds, ['user-1', 'user-1', 'user-1']);
    });

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

    test('ignores stale cached radios after newer refresh completes', () async {
      final cachedLoad = Completer<List<RadioSummaryData>>();
      final refresh = Completer<DjRadioPage>();
      final repository = _FakeRadioRepository(
        cachedRadiosFuture: cachedLoad.future,
        fetchSubscribedRadios: () => refresh.future,
      );
      final controller = RadioListController(
        userId: 'user-1',
        repository: repository,
      );
      addTearDown(controller.dispose);

      final initialLoad = controller.loadInitial();
      await _flushAsync();

      final refreshFuture = controller.refresh();
      await _flushAsync();
      refresh.complete(
        DjRadioPage(
          items: [_radio('fresh-radio')],
          hasMore: true,
          nextOffset: 1,
        ),
      );
      await refreshFuture;

      expect(controller.state.value.items.map((item) => item.id), ['fresh-radio']);

      cachedLoad.complete([_radio('stale-cached-radio')]);
      await initialLoad;

      expect(controller.state.value.items.map((item) => item.id), ['fresh-radio']);
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
    test('skips repository access for blank user id', () async {
      final repository = _FakeRadioRepository();
      final controller = RadioDetailController(
        radioId: 'radio-1',
        userId: '   ',
        repository: repository,
        likedSongIds: () => const [],
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(controller.state.value.items, isEmpty);
      expect(controller.state.value.hasMore, isFalse);
      expect(repository.requestedCachedProgramUserIds, isEmpty);
      expect(repository.requestedProgramOffsets, isEmpty);

      expect(await controller.refresh(), isTrue);
      expect(await controller.loadMore(), isTrue);

      expect(controller.state.value.items, isEmpty);
      expect(controller.state.value.hasMore, isFalse);
      expect(repository.requestedCachedProgramUserIds, isEmpty);
      expect(repository.requestedProgramOffsets, isEmpty);
    });

    test('normalizes account scoped user id before repository access', () async {
      final repository = _FakeRadioRepository(
        fetchProgramsWithArgs: ({required userId, required radioId, required offset, required limit, required asc}) {
          return Future.value(
            DjProgramPage(
              items: [_program('remote-program-$offset')],
              hasMore: true,
              nextOffset: offset + 1,
            ),
          );
        },
      );
      final controller = RadioDetailController(
        radioId: 'radio-1',
        userId: ' user-1 ',
        repository: repository,
        likedSongIds: () => const [],
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      await controller.refresh();
      await controller.loadMore();

      expect(repository.requestedCachedProgramUserIds, ['user-1']);
      expect(repository.requestedProgramUserIds, ['user-1', 'user-1', 'user-1']);
    });

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
        likedSongIds: () => const [],
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
        likedSongIds: () => const [],
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
        likedSongIds: () => const [],
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(repository.requestedProgramOffsets, [0]);
      expect(controller.state.value.items.map((item) => item.id), ['remote-program']);
      expect(controller.state.value.initialLoading, isFalse);
      expect(controller.state.value.error, isNull);
    });

    test('builds playback queue items with latest liked song ids', () {
      var likedSongIds = <int>[101];
      final controller = RadioDetailController(
        radioId: 'radio-1',
        userId: 'user-1',
        repository: _FakeRadioRepository(),
        likedSongIds: () => likedSongIds,
      );
      addTearDown(controller.dispose);
      controller.state.value = PagedState.data(
        [_program('program-1', mainTrackId: '101')],
        hasMore: false,
      );

      expect(controller.queueItems.single.isLiked, isTrue);

      likedSongIds = <int>[];

      expect(controller.queueItems.single.isLiked, isFalse);
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
        likedSongIds: () => const [],
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

    test('ignores stale cached programs after newer refresh completes', () async {
      final cachedLoad = Completer<List<RadioProgramData>>();
      final refresh = Completer<DjProgramPage>();
      final repository = _FakeRadioRepository(
        cachedProgramsFuture: cachedLoad.future,
        fetchPrograms: () => refresh.future,
      );
      final controller = RadioDetailController(
        radioId: 'radio-1',
        userId: 'user-1',
        repository: repository,
        likedSongIds: () => const [],
      );
      addTearDown(controller.dispose);

      final initialLoad = controller.loadInitial();
      await _flushAsync();

      final refreshFuture = controller.refresh();
      await _flushAsync();
      refresh.complete(
        DjProgramPage(
          items: [_program('fresh-program')],
          hasMore: true,
          nextOffset: 1,
        ),
      );
      await refreshFuture;

      expect(controller.state.value.items.map((item) => item.id), ['fresh-program']);

      cachedLoad.complete([_program('stale-cached-program')]);
      await initialLoad;

      expect(controller.state.value.items.map((item) => item.id), ['fresh-program']);
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
        likedSongIds: () => const [],
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
        likedSongIds: () => const [],
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

  group('RadioRepository', () {
    test('returns empty data without touching data sources for blank user id', () async {
      final repository = RadioRepository(
        userRadioDataSource: _FailingUserRadioDataSource(),
        remoteDataSource: _FailingRadioRemoteDataSource(),
      );

      expect(await repository.loadCachedSubscribedRadios('   '), isEmpty);
      expect(
        await repository.loadCachedPrograms(
          '   ',
          'radio-1',
          asc: true,
        ),
        isEmpty,
      );

      final radios = await repository.fetchSubscribedRadios(
        userId: '   ',
        offset: 0,
        limit: 30,
      );
      expect(radios.items, isEmpty);
      expect(radios.hasMore, isFalse);
      expect(radios.nextOffset, 0);

      final programs = await repository.fetchPrograms(
        '   ',
        'radio-1',
        offset: 0,
        limit: 30,
        asc: true,
      );
      expect(programs.items, isEmpty);
      expect(programs.hasMore, isFalse);
      expect(programs.nextOffset, 0);
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

RadioProgramData _program(String id, {String? mainTrackId}) {
  return RadioProgramData(
    id: id,
    mainTrackId: mainTrackId ?? 'track-$id',
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
  final List<String> requestedCachedRadioUserIds = <String>[];
  final List<String> requestedCachedProgramUserIds = <String>[];
  final List<String> requestedRadioUserIds = <String>[];
  final List<String> requestedProgramUserIds = <String>[];

  @override
  Future<List<RadioSummaryData>> loadCachedSubscribedRadios(String userId) async {
    requestedCachedRadioUserIds.add(userId);
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
    requestedCachedProgramUserIds.add(userId);
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
    requestedRadioUserIds.add(userId);
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
    requestedProgramUserIds.add(userId);
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

class _FailingUserRadioDataSource implements UserRadioDataSource {
  Never _fail() => throw StateError('blank user id should not touch user radio data source');

  @override
  Future<List<RadioSummaryData>> loadSubscribedRadios(String userId) => _fail();

  @override
  Future<void> replaceSubscribedRadios(
    String userId,
    List<RadioSummaryData> items,
  ) =>
      _fail();

  @override
  Future<void> appendSubscribedRadios(
    String userId,
    List<RadioSummaryData> items, {
    required int startOrder,
  }) =>
      _fail();

  @override
  Future<List<RadioProgramData>> loadPrograms(
    String userId,
    String radioId, {
    required bool asc,
  }) =>
      _fail();

  @override
  Future<void> replacePrograms(
    String userId,
    String radioId, {
    required bool asc,
    required List<RadioProgramData> items,
  }) =>
      _fail();

  @override
  Future<void> appendPrograms(
    String userId,
    String radioId, {
    required bool asc,
    required List<RadioProgramData> items,
    required int startOrder,
  }) =>
      _fail();
}

class _FailingRadioRemoteDataSource implements RadioRemoteDataSource {
  Never _fail() => throw StateError('blank user id should not touch radio remote data source');

  @override
  Future<RadioSummaryRemotePage> fetchSubscribedRadios({
    bool total = true,
    required int offset,
    required int limit,
  }) =>
      _fail();

  @override
  Future<RadioProgramRemotePage> fetchPrograms(
    String radioId, {
    required int offset,
    required int limit,
    required bool asc,
  }) =>
      _fail();
}
