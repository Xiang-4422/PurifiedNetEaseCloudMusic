import 'dart:async';

import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/playback_selection_navigator.dart';
import 'package:bujuan/features/playback/application/playback_selection_service.dart';
import 'package:bujuan/features/playback/application/playback_switch_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/playback_selection_state.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackSelectionService', () {
    test('updates selection before playback source resolves', () async {
      final playbackService = _FakePlaybackService();
      final selectionService = PlaybackSelectionService(
        playbackService: playbackService,
        navigator: const PlaybackSelectionNavigator(),
        switchCoordinator: PlaybackSwitchCoordinator(
          playbackService: playbackService,
        ),
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
      expect(playbackService.playIndexCompleter.isCompleted, isFalse);

      playbackService.completePlayIndex(true);
      await selectFuture;

      expect(selectionService.state.sourceStatus,
          PlaybackSelectionSourceStatus.ready);
      expect(playbackService.playedIndexes, [1]);
      await subscription.cancel();
    });

    test('keeps selection and reports error when source switch fails',
        () async {
      final playbackService = _FakePlaybackService();
      final selectionService = PlaybackSelectionService(
        playbackService: playbackService,
        navigator: const PlaybackSelectionNavigator(),
        switchCoordinator: PlaybackSwitchCoordinator(
          playbackService: playbackService,
        ),
      );

      final selectFuture = selectionService.selectQueue(
        [_item('1')],
        0,
        playListName: 'Queue',
        trigger: PlaybackSwitchTrigger.userSelect,
      );
      await Future<void>.delayed(Duration.zero);
      playbackService.completePlayIndex(false);
      await selectFuture;

      expect(selectionService.state.selectedItem.id, '1');
      expect(selectionService.state.sourceStatus,
          PlaybackSelectionSourceStatus.error);
      expect(selectionService.state.sourceError, isNotEmpty);
    });

    test('only the latest rapid selection can become ready', () async {
      final playbackService = _FakePlaybackService();
      final selectionService = PlaybackSelectionService(
        playbackService: playbackService,
        navigator: const PlaybackSelectionNavigator(),
        switchCoordinator: PlaybackSwitchCoordinator(
          playbackService: playbackService,
        ),
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

      playbackService.completePlayIndex(true);
      await Future<void>.delayed(Duration.zero);
      playbackService.completePlayIndex(true);
      await latest;

      expect(selectionService.state.selectedItem.id, '3');
      expect(selectionService.state.sourceStatus,
          PlaybackSelectionSourceStatus.ready);
      expect(playbackService.playedIndexes, [0, 2]);
      expect(playbackService.playedIndexes.last, 2);
    });
  });
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
  final List<int> playedIndexes = <int>[];
  final List<Completer<bool>> _playIndexCompleters = <Completer<bool>>[];

  Completer<bool> get playIndexCompleter => _playIndexCompleters.last;

  @override
  Future<void> changePlayList(
    List<PlaybackQueueItem> playList, {
    int index = 0,
    bool needStore = true,
    required String playListName,
    String playListNameHeader = '',
    required bool changePlayerSource,
    required bool playNow,
  }) async {}

  @override
  Future<bool> playIndex({
    required int audioSourceIndex,
    required bool playNow,
  }) {
    playedIndexes.add(audioSourceIndex);
    final completer = Completer<bool>();
    _playIndexCompleters.add(completer);
    return completer.future;
  }

  void completePlayIndex(bool success) {
    _playIndexCompleters.last.complete(success);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
