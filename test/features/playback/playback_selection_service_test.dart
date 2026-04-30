import 'dart:async';

import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/application/playback_selection_navigator.dart';
import 'package:bujuan/features/playback/application/playback_selection_service.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:bujuan/features/playback/application/playback_switch_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/playback_selection_state.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackSelectionService', () {
    test('updates selection before playback source resolves', () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);
      final selectionService = PlaybackSelectionService(
        queueService: queueService,
        navigator: const PlaybackSelectionNavigator(),
        switchCoordinator: _switchCoordinator(playbackService, queueService),
      );
      final states = <PlaybackSelectionState>[];
      final subscription = selectionService.stream.listen(states.add);
      final queue = [_item('1'), _item('2')];

      final selectFuture = selectionService.selectQueue(
        queue,
        1,
        playListName: 'Queue',
        trigger: PlaybackSwitchTrigger.userSelect,
      );
      await Future<void>.delayed(Duration.zero);

      expect(selectionService.state.selectedItem.id, '2');
      expect(selectionService.state.sourceStatus,
          PlaybackSelectionSourceStatus.loading);
      expect(playbackService.replaceSourceCompleter.isCompleted, isFalse);

      playbackService.completeReplaceSource(true);
      await selectFuture;

      expect(selectionService.state.sourceStatus,
          PlaybackSelectionSourceStatus.ready);
      expect(playbackService.replacedIndexes, [1]);
      await subscription.cancel();
    });

    test('keeps selection and reports error when source switch fails',
        () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);
      final selectionService = PlaybackSelectionService(
        queueService: queueService,
        navigator: const PlaybackSelectionNavigator(),
        switchCoordinator: _switchCoordinator(playbackService, queueService),
      );

      final selectFuture = selectionService.selectQueue(
        [_item('1')],
        0,
        playListName: 'Queue',
        trigger: PlaybackSwitchTrigger.userSelect,
      );
      await Future<void>.delayed(Duration.zero);
      playbackService.completeReplaceSource(false);
      await selectFuture;

      expect(selectionService.state.selectedItem.id, '1');
      expect(selectionService.state.sourceStatus,
          PlaybackSelectionSourceStatus.error);
      expect(selectionService.state.sourceError, isNotEmpty);
    });

    test('only the latest rapid selection can become ready', () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);
      final selectionService = PlaybackSelectionService(
        queueService: queueService,
        navigator: const PlaybackSelectionNavigator(),
        switchCoordinator: _switchCoordinator(playbackService, queueService),
      );
      final queue = [_item('1'), _item('2'), _item('3')];

      unawaited(selectionService.selectQueue(
        queue,
        0,
        playListName: 'Queue',
        trigger: PlaybackSwitchTrigger.userSelect,
      ));
      await Future<void>.delayed(Duration.zero);
      unawaited(selectionService.selectIndex(
        1,
        trigger: PlaybackSwitchTrigger.userNext,
      ));
      await Future<void>.delayed(Duration.zero);
      final latest = selectionService.selectIndex(
        2,
        trigger: PlaybackSwitchTrigger.userNext,
      );

      playbackService.completeReplaceSource(true);
      await Future<void>.delayed(Duration.zero);
      playbackService.completeReplaceSource(true);
      await latest;

      expect(selectionService.state.selectedItem.id, '3');
      expect(selectionService.state.sourceStatus,
          PlaybackSelectionSourceStatus.ready);
      expect(playbackService.replacedIndexes, containsAllInOrder([0, 2]));
      expect(playbackService.replacedIndexes.last, 2);
    });

    test('maps selected item to active queue after queue service reorder',
        () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);
      await queueService.setRepeatMode(PlaybackRepeatMode.none);
      final selectionService = PlaybackSelectionService(
        queueService: queueService,
        navigator: const PlaybackSelectionNavigator(),
        switchCoordinator: _switchCoordinator(playbackService, queueService),
      );

      final selectFuture = selectionService.selectQueue(
        [_item('1'), _item('2'), _item('3')],
        1,
        playListName: 'Queue',
        trigger: PlaybackSwitchTrigger.userSelect,
      );
      await Future<void>.delayed(Duration.zero);

      expect(selectionService.state.selectedItem.id, '2');
      expect(selectionService.state.selectedIndex, isNonNegative);
      expect(
        selectionService.state.queue[selectionService.state.selectedIndex].id,
        '2',
      );

      playbackService.completeReplaceSource(true);
      await selectFuture;

      expect(playbackService.replacedIndexes,
          [selectionService.state.selectedIndex]);
    });

    test('submits playback source when selecting next track', () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);
      final selectionService = PlaybackSelectionService(
        queueService: queueService,
        navigator: const PlaybackSelectionNavigator(),
        switchCoordinator: _switchCoordinator(playbackService, queueService),
      );

      final first = selectionService.selectQueue(
        [_item('1'), _item('2'), _item('3')],
        0,
        playListName: 'Queue',
        trigger: PlaybackSwitchTrigger.userSelect,
      );
      await Future<void>.delayed(Duration.zero);
      playbackService.completeReplaceSource(true);
      await first;

      final next = selectionService.selectNext(
        trigger: PlaybackSwitchTrigger.userNext,
      );
      await Future<void>.delayed(Duration.zero);

      expect(selectionService.state.selectedItem.id, '2');
      expect(playbackService.replacedIndexes, [0, 1]);

      playbackService.completeReplaceSource(true);
      await next;

      expect(selectionService.state.sourceStatus,
          PlaybackSelectionSourceStatus.ready);
    });

    test(
        'queue completion advances from confirmed index, not previewed selection',
        () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);
      final selectionService = PlaybackSelectionService(
        queueService: queueService,
        navigator: const PlaybackSelectionNavigator(),
        switchCoordinator: _switchCoordinator(playbackService, queueService),
      );

      final first = selectionService.selectQueue(
        [_item('1'), _item('2'), _item('3')],
        0,
        playListName: 'Queue',
        trigger: PlaybackSwitchTrigger.userSelect,
      );
      await Future<void>.delayed(Duration.zero);
      playbackService.completeReplaceSource(true);
      await first;

      await selectionService.selectIndex(
        2,
        trigger: PlaybackSwitchTrigger.userSelect,
        playNow: false,
      );

      final completedNext = selectionService.selectNext(
        trigger: PlaybackSwitchTrigger.queueCompletion,
      );
      await Future<void>.delayed(Duration.zero);

      expect(selectionService.state.selectedItem.id, '2');
      expect(playbackService.replacedIndexes.last, 1);

      playbackService.completeReplaceSource(true);
      await completedNext;
    });
  });
}

PlaybackQueueService _queueService(_FakePlaybackService playbackService) {
  return PlaybackQueueService(
    queueStore: _FakePlaybackQueueStore(),
    playbackService: playbackService,
  );
}

PlaybackSwitchCoordinator _switchCoordinator(
  _FakePlaybackService playbackService,
  PlaybackQueueService queueService,
) {
  return PlaybackSwitchCoordinator(
    playbackService: playbackService,
    queueService: queueService,
    sourceResolver: _FakePlaybackSourceResolver(),
  );
}

PlaybackQueueItem _item(String id) {
  return PlaybackQueueItem(
    id: id,
    sourceId: id,
    title: 'Track $id',
    albumTitle: null,
    artistNames: const [],
    artistIds: const [],
    duration: null,
    artworkUrl: null,
    localArtworkPath: null,
    mediaType: MediaType.playlist,
    playbackUrl: null,
    lyricKey: null,
    isLiked: false,
    isCached: false,
  );
}

class _FakePlaybackService implements PlaybackService {
  final List<int> replacedIndexes = <int>[];
  final List<Completer<bool>> _replaceSourceCompleters = <Completer<bool>>[];
  List<PlaybackQueueItem> notificationQueue = const <PlaybackQueueItem>[];

  Completer<bool> get replaceSourceCompleter => _replaceSourceCompleters.last;

  @override
  List<PlaybackQueueItem> get activeQueue => notificationQueue;

  @override
  bool isHighQualityEnabled() => false;

  @override
  Future<void> setNotificationQueue(
    List<PlaybackQueueItem> queue, {
    required int currentIndex,
    required String playlistName,
    required String playlistHeader,
  }) async {
    notificationQueue = queue;
  }

  @override
  Future<bool> replaceSourceForQueueItem({
    required List<PlaybackQueueItem> queue,
    required PlaybackQueueItem item,
    required int activeIndex,
    required PlaybackResolvedSource source,
    required bool playNow,
  }) {
    notificationQueue = queue;
    replacedIndexes.add(activeIndex);
    final completer = Completer<bool>();
    _replaceSourceCompleters.add(completer);
    return completer.future;
  }

  void completeReplaceSource(bool success) {
    _replaceSourceCompleters.last.complete(success);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackSourceResolver implements PlaybackSourceResolver {
  @override
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: 'url-${item.id}',
    );
  }

  @override
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) {
    return resolve(item, preferHighQuality: preferHighQuality);
  }
}

class _FakePlaybackQueueStore implements PlaybackQueueStore {
  @override
  Future<void> saveQueueSnapshot({
    required List<PlaybackQueueItem> originalSongs,
    required String playlistName,
    required String playlistHeader,
  }) async {}

  @override
  Future<void> savePlaylistMeta({
    required String playlistName,
    required String playlistHeader,
  }) async {}

  @override
  Future<void> saveRepeatMode(PlaybackRepeatMode repeatMode) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
