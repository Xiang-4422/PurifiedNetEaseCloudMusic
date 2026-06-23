import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playback_restore_state.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/application/playback_restore_coordinator.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackRestoreCoordinator', () {
    test('drops restored queue when queue cache decoding fails', () async {
      final coordinator = PlaybackRestoreCoordinator(
        repository: _FakePlaybackRepository(
          const PlaybackRestoreState(
            queue: ['broken'],
            currentSongId: 'netease:1',
            playlistName: 'Restored',
            playlistHeader: 'Header',
            position: Duration(seconds: 42),
          ),
        ),
        queueStore: _ThrowingPlaybackQueueStore(),
      );

      final restoreData = await coordinator.loadRestoreData();

      expect(restoreData.queue, isEmpty);
      expect(restoreData.index, -1);
      expect(restoreData.position, Duration.zero);
      expect(restoreData.playlistName, isEmpty);
      expect(restoreData.playlistHeader, isEmpty);
    });

    test('filters empty restored queue items and drops position when current song is missing', () async {
      final coordinator = PlaybackRestoreCoordinator(
        repository: _FakePlaybackRepository(
          const PlaybackRestoreState(
            queue: ['cached-empty', 'cached-valid'],
            currentSongId: 'missing',
            position: Duration(seconds: 12),
          ),
        ),
        queueStore: _FakePlaybackQueueStore([
          const PlaybackQueueItem.empty(),
          _item('netease:1'),
        ]),
      );

      final restoreData = await coordinator.loadRestoreData();

      expect(restoreData.queue.map((item) => item.id), ['netease:1']);
      expect(restoreData.index, 0);
      expect(restoreData.position, Duration.zero);
    });

    test('keeps restored position only when current song is matched', () async {
      final coordinator = PlaybackRestoreCoordinator(
        repository: _FakePlaybackRepository(
          const PlaybackRestoreState(
            queue: ['cached-1', 'cached-2'],
            currentSongId: 'netease:2',
            position: Duration(seconds: 42),
          ),
        ),
        queueStore: _FakePlaybackQueueStore([
          _item('netease:1'),
          _item('netease:2'),
        ]),
      );

      final restoreData = await coordinator.loadRestoreData();

      expect(restoreData.queue.map((item) => item.id), ['netease:1', 'netease:2']);
      expect(restoreData.index, 1);
      expect(restoreData.position, const Duration(seconds: 42));
    });

    test('drops negative restored position even when current song is matched', () async {
      final coordinator = PlaybackRestoreCoordinator(
        repository: _FakePlaybackRepository(
          const PlaybackRestoreState(
            queue: ['cached-1'],
            currentSongId: 'netease:1',
            position: Duration(seconds: -3),
          ),
        ),
        queueStore: _FakePlaybackQueueStore([
          _item('netease:1'),
        ]),
      );

      final restoreData = await coordinator.loadRestoreData();

      expect(restoreData.index, 0);
      expect(restoreData.position, Duration.zero);
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

class _FakePlaybackRepository implements PlaybackRepository {
  _FakePlaybackRepository(this.restoreState);

  final PlaybackRestoreState restoreState;

  @override
  Future<PlaybackRestoreState> getRestoreState() async {
    return restoreState;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackQueueStore implements PlaybackQueueStore {
  _FakePlaybackQueueStore(this.items);

  final List<PlaybackQueueItem> items;

  @override
  Future<List<PlaybackQueueItem>> decodeQueue(List<String> queueState) async {
    return items;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ThrowingPlaybackQueueStore implements PlaybackQueueStore {
  @override
  Future<List<PlaybackQueueItem>> decodeQueue(List<String> queueState) {
    throw const FormatException('broken queue cache');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
