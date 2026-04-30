import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_restore_coordinator.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackQueueService', () {
    test('replaces queue and syncs notification queue without switching source',
        () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);

      await queueService.replaceQueue(
        [_item('1'), _item('2')],
        1,
        playlistName: 'Queue',
        playlistHeader: 'Header',
      );

      expect(queueService.state.selectedItem.id, '2');
      expect(queueService.state.selectedIndex, 1);
      expect(
          playbackService.notificationQueue.map((item) => item.id), ['1', '2']);
      expect(playbackService.sourceSwitches, isEmpty);
    });

    test('keeps selected item mapped after shuffle mode rebuilds active queue',
        () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);
      await queueService.setRepeatMode(PlaybackRepeatMode.none);

      await queueService.replaceQueue(
        [_item('1'), _item('2'), _item('3')],
        1,
        playlistName: 'Queue',
      );

      expect(queueService.state.selectedItem.id, '2');
      expect(
        queueService.state.activeQueue[queueService.state.selectedIndex].id,
        '2',
      );
    });

    test('restore snapshot restores selection and pending position only',
        () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);

      await queueService.restoreSnapshot(
        PlaybackRestoreSnapshot(
          playbackMode: PlaybackMode.playlist,
          repeatMode: PlaybackRepeatMode.all,
          queue: [_item('1'), _item('2')],
          index: 1,
          playlistName: 'Restored',
          playlistHeader: 'Header',
          position: const Duration(seconds: 42),
        ),
      );

      expect(queueService.state.selectedItem.id, '2');
      expect(queueService.state.pendingRestorePosition,
          const Duration(seconds: 42));
      expect(
          playbackService.pendingRestorePosition, const Duration(seconds: 42));
      expect(playbackService.sourceSwitches, isEmpty);
    });

    test('updates queue item in both original and active queues', () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);
      await queueService.replaceQueue(
        [_item('1'), _item('2')],
        0,
        playlistName: 'Queue',
      );

      await queueService.updateQueueItem(_item('2', title: 'Updated'));

      expect(
        queueService.state.originalQueue.last.title,
        'Updated',
      );
      expect(
        queueService.state.activeQueue
            .firstWhere((item) => item.id == '2')
            .title,
        'Updated',
      );
    });
  });
}

PlaybackQueueService _queueService(_FakePlaybackService playbackService) {
  return PlaybackQueueService(
    queueStore: _FakePlaybackQueueStore(),
    playbackService: playbackService,
  );
}

PlaybackQueueItem _item(String id, {String? title}) {
  return PlaybackQueueItem(
    id: id,
    sourceId: id,
    title: title ?? 'Track $id',
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
  List<PlaybackQueueItem> notificationQueue = const <PlaybackQueueItem>[];
  final List<int> sourceSwitches = <int>[];
  Duration pendingRestorePosition = Duration.zero;

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
  Future<void> setPendingRestorePosition(Duration position) async {
    pendingRestorePosition = position;
  }

  @override
  Future<bool> setSourceForQueueItem({
    required List<PlaybackQueueItem> queue,
    required PlaybackQueueItem item,
    required int activeIndex,
    required bool playNow,
  }) async {
    notificationQueue = queue;
    sourceSwitches.add(activeIndex);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
