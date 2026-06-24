import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/playback_queue_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_selection_service.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/playback_queue_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackQueueCoordinator', () {
    test('normalizes current song id before selecting appended roaming next item', () async {
      final queueService = _FakePlaybackQueueService(
        appendedState: PlaybackQueueState(
          activeQueue: [_item('1'), _item('2'), _item('3')],
        ),
      );
      final selectionService = _FakePlaybackSelectionService();
      final coordinator = PlaybackQueueCoordinator(
        queueService: queueService,
        selectionService: selectionService,
      );

      await coordinator.appendRoamingSongs(
        currentQueue: [_item(' 2 ')],
        incomingSongs: [_item('3')],
        currentSongId: ' 2 ',
        shouldAutoPlayNext: true,
        fallbackIndex: 0,
      );

      expect(queueService.appendedCurrentSongIds, ['2']);
      expect(selectionService.selectedIndexes, [2]);
      expect(selectionService.triggers, [PlaybackSwitchTrigger.modeAutoAdvance]);
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

class _FakePlaybackQueueService implements PlaybackQueueService {
  _FakePlaybackQueueService({
    required this.appendedState,
  });

  final PlaybackQueueState appendedState;
  final List<String> appendedCurrentSongIds = <String>[];

  @override
  Future<PlaybackQueueState> appendQueueItems(
    List<PlaybackQueueItem> incomingSongs, {
    required String currentSongId,
    int maxQueueLength = 200,
    int retainQueueLength = 150,
  }) async {
    appendedCurrentSongIds.add(currentSongId);
    return appendedState;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackSelectionService implements PlaybackSelectionService {
  final List<int> selectedIndexes = <int>[];
  final List<PlaybackSwitchTrigger> triggers = <PlaybackSwitchTrigger>[];

  @override
  Future<void> selectIndex(
    int index, {
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
  }) async {
    selectedIndexes.add(index);
    triggers.add(trigger);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
