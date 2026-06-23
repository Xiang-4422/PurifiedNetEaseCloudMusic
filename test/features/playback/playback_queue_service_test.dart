import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_mode.dart';
import 'package:bujuan/core/entities/playback_order_mode.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_queue_service.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_restore_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackQueueService', () {
    test('replaces queue and syncs notification queue without switching source', () async {
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
      expect(playbackService.notificationQueue.map((item) => item.id), ['1', '2']);
      expect(playbackService.notificationIndex, -1);
      expect(playbackService.sourceSwitches, isEmpty);
    });

    test('normalizes queue item ids before replacing queue state', () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);

      await queueService.replaceQueue(
        [_item('   '), _item(' 1 '), _item('2')],
        1,
        playlistName: 'Queue',
      );

      expect(queueService.state.originalQueue.map((item) => item.id), ['1', '2']);
      expect(queueService.state.activeQueue.map((item) => item.id), ['1', '2']);
      expect(queueService.state.selectedItem.id, '1');
      expect(playbackService.notificationQueue.map((item) => item.id), ['1', '2']);
    });

    test('keeps selected item mapped after shuffle mode rebuilds active queue', () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);
      await queueService.setOrderMode(PlaybackOrderMode.shuffle);

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

    test('restore data restores selection and pending position only', () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);

      await queueService.restoreFromData(
        PlaybackRestoreData(
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
      expect(queueService.state.pendingRestorePosition, const Duration(seconds: 42));
      expect(playbackService.pendingRestorePosition, const Duration(seconds: 42));
      expect(playbackService.pendingRestoreMediaItemId, '2');
      expect(playbackService.sourceSwitches, isEmpty);
    });

    test('normalizes restored queue item ids before rebuilding queue facts', () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);

      await queueService.restoreFromData(
        PlaybackRestoreData(
          playbackMode: PlaybackMode.playlist,
          repeatMode: PlaybackRepeatMode.all,
          queue: [_item(' 1 '), _item('   '), _item(' 2 ')],
          index: 2,
          playlistName: 'Restored',
          playlistHeader: 'Header',
          position: const Duration(seconds: 42),
        ),
      );

      expect(queueService.state.originalQueue.map((item) => item.id), ['1', '2']);
      expect(queueService.state.selectedItem.id, '2');
      expect(playbackService.pendingRestoreMediaItemId, '2');
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
        queueService.state.activeQueue.firstWhere((item) => item.id == '2').title,
        'Updated',
      );
    });

    test('normalizes appended queue item ids and ignores blank or duplicate ids', () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);
      await queueService.replaceQueue(
        [_item('1')],
        0,
        playlistName: 'Queue',
      );

      await queueService.appendQueueItems(
        [_item(' 1 ', title: 'Duplicate'), _item('   '), _item(' 2 ')],
        currentSongId: ' 1 ',
      );

      expect(queueService.state.originalQueue.map((item) => item.id), ['1', '2']);
      expect(queueService.state.selectedItem.id, '1');
      expect(playbackService.notificationQueue.map((item) => item.id), ['1', '2']);
    });

    test('normalizes update and confirmed queue item ids', () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);
      await queueService.replaceQueue(
        [_item('1'), _item('2')],
        0,
        playlistName: 'Queue',
      );

      await queueService.updateQueueItem(_item(' 2 ', title: 'Updated'));
      await queueService.markConfirmed(item: _item(' 2 '), index: 0);

      expect(queueService.state.originalQueue.last.title, 'Updated');
      expect(queueService.state.confirmedIndex, 1);
      expect(queueService.state.confirmedItem.id, '2');
    });

    test('relocates confirmed item when caller passes stale index', () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);
      await queueService.replaceQueue(
        [_item('1'), _item('2')],
        0,
        playlistName: 'Queue',
      );

      await queueService.markConfirmed(item: _item('2'), index: 0);

      expect(queueService.state.confirmedIndex, 1);
      expect(queueService.state.confirmedItem.id, '2');
      expect(playbackService.notificationIndex, 1);
    });

    test('ignores stale confirmed item after queue replacement', () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);
      await queueService.replaceQueue(
        [_item('1'), _item('2')],
        0,
        playlistName: 'Old Queue',
      );
      await queueService.markConfirmed(item: _item('1'), index: 0);
      await queueService.replaceQueue(
        [_item('3'), _item('4')],
        0,
        playlistName: 'New Queue',
      );

      await queueService.markConfirmed(item: _item('1'), index: 0);

      expect(queueService.state.confirmedIndex, -1);
      expect(queueService.state.confirmedItem.id, isEmpty);
      expect(playbackService.notificationIndex, -1);
    });

    test('skips notification sync when notification signature is unchanged', () async {
      final playbackService = _FakePlaybackService();
      final queueService = _queueService(playbackService);

      await queueService.replaceQueue(
        [_item('1'), _item('2')],
        0,
        playlistName: 'Queue',
      );
      final callsAfterReplace = playbackService.notificationSyncCount;

      await queueService.selectIndex(0);

      expect(playbackService.notificationSyncCount, callsAfterReplace);
    });

    test('setPlaybackMode owns restore mode persistence', () async {
      final queueStore = _FakePlaybackQueueStore();
      final queueService = _queueService(
        _FakePlaybackService(),
        queueStore: queueStore,
      );

      await queueService.setPlaybackMode(PlaybackMode.roaming);

      expect(queueService.state.playbackMode, PlaybackMode.roaming);
      expect(queueStore.savedPlaybackModes, [PlaybackMode.roaming]);
    });
  });
}

PlaybackQueueService _queueService(
  _FakePlaybackService playbackService, {
  _FakePlaybackQueueStore? queueStore,
}) {
  return PlaybackQueueService(
    queueStore: queueStore ?? _FakePlaybackQueueStore(),
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
  int notificationIndex = -1;
  int notificationSyncCount = 0;
  final List<int> sourceSwitches = <int>[];
  Duration pendingRestorePosition = Duration.zero;
  String? pendingRestoreMediaItemId;

  @override
  Future<void> setNotificationQueue(
    List<PlaybackQueueItem> queue, {
    required int currentIndex,
    required String playlistName,
    required String playlistHeader,
  }) async {
    notificationSyncCount++;
    notificationQueue = queue;
    notificationIndex = currentIndex;
  }

  @override
  Future<void> setPendingRestorePosition(
    Duration position, {
    String? mediaItemId,
  }) async {
    pendingRestorePosition = position;
    pendingRestoreMediaItemId = mediaItemId;
  }

  @override
  bool isHighQualityEnabled() => false;

  @override
  Future<bool> replaceSourceForQueueItem({
    required List<PlaybackQueueItem> queue,
    required PlaybackQueueItem item,
    required int activeIndex,
    required PlaybackResolvedSource source,
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
  final List<PlaybackMode> savedPlaybackModes = <PlaybackMode>[];

  @override
  Future<void> saveQueueState({
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
  Future<void> savePlaybackMode(PlaybackMode playbackMode) async {
    savedPlaybackModes.add(playbackMode);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
