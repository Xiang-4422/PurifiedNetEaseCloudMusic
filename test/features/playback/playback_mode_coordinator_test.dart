import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_mode_coordinator.dart';
import 'package:bujuan/features/playback/application/playback_selection_service.dart';
import 'package:bujuan/features/playback/application/playback_switch_trigger.dart';
import 'package:bujuan/features/playback/application/playback_user_content_port.dart';
import 'package:bujuan/features/playback/playback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackModeCoordinator', () {
    test('normalizes liked queue item ids before selecting current song', () async {
      final selectionService = _FakePlaybackSelectionService();
      final coordinator = PlaybackModeCoordinator(
        playbackService: _FakePlaybackService(),
        userContentPort: _userContentPort(
          likedSongIds: () => const [2],
          likedSongs: () => [
            _item('netease:1', sourceId: '1'),
            _item(' netease:2 ', sourceId: '2'),
          ],
        ),
        selectionService: selectionService,
      );

      await coordinator.playLikedSongs(
        currentSong: _item('netease:2', sourceId: ' 2 '),
      );

      expect(selectionService.ensureSelectQueueCount, 1);
      expect(selectionService.selectedIndex, 1);
      expect(selectionService.selectedQueue.map((item) => item.id), [
        'netease:1',
        'netease:2',
      ]);
      expect(selectionService.playListName, '喜欢的音乐');
      expect(selectionService.trigger, PlaybackSwitchTrigger.userSelect);
      expect(selectionService.playNow, isFalse);
    });
  });
}

PlaybackUserContentPort _userContentPort({
  List<int> Function()? likedSongIds,
  List<PlaybackQueueItem> Function()? likedSongs,
}) {
  return PlaybackUserContentPort(
    toggleLikeStatus: (_) async => null,
    likedSongIds: likedSongIds ?? () => const <int>[],
    ensureLikedSongsLoaded: () async {},
    likedSongs: likedSongs ?? () => const <PlaybackQueueItem>[],
    loadFmSongs: () async => const <PlaybackQueueItem>[],
    loadHeartBeatSongs: (_, __, ___) async => const <PlaybackQueueItem>[],
    randomLikedSongId: () => '',
  );
}

PlaybackQueueItem _item(
  String id, {
  required String sourceId,
}) {
  return PlaybackQueueItem(
    id: id,
    sourceId: sourceId,
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

class _FakePlaybackSelectionService implements PlaybackSelectionService {
  var ensureSelectQueueCount = 0;
  var selectedQueue = const <PlaybackQueueItem>[];
  var selectedIndex = -1;
  var playListName = '';
  PlaybackSwitchTrigger? trigger;
  bool? playNow;

  @override
  Future<void> selectQueue(
    List<PlaybackQueueItem> queue,
    int index, {
    required String playListName,
    String playListNameHeader = '',
    required PlaybackSwitchTrigger trigger,
    bool playNow = true,
    bool needStore = true,
  }) async {
    ensureSelectQueueCount++;
    selectedQueue = queue;
    selectedIndex = index;
    this.playListName = playListName;
    this.trigger = trigger;
    this.playNow = playNow;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlaybackService implements PlaybackService {
  @override
  Future<void> changeRepeatMode({
    PlaybackRepeatMode? newRepeatMode,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
