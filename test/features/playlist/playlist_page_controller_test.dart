import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playlist/playlist_page_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaylistDetailData', () {
    test('treats local detail as incomplete when snapshot has more track ids',
        () {
      final snapshot = PlaylistSnapshotData(
        id: '1',
        name: 'playlist',
        trackIds: List.generate(100, (index) => 'netease:$index'),
        creatorUserId: null,
      );
      final detail = _detail(
        songCount: 30,
        expectedTrackCount:
            PlaylistDetailData.resolveExpectedTrackCount(snapshot, null),
      );

      expect(detail.expectedTrackCount, 100);
      expect(detail.isComplete, isFalse);
    });

    test('treats local detail as complete when it reaches snapshot track ids',
        () {
      final snapshot = PlaylistSnapshotData(
        id: '1',
        name: 'playlist',
        trackIds: List.generate(100, (index) => 'netease:$index'),
        creatorUserId: null,
      );
      final detail = _detail(
        songCount: 100,
        expectedTrackCount:
            PlaylistDetailData.resolveExpectedTrackCount(snapshot, null),
      );

      expect(detail.isComplete, isTrue);
    });

    test('uses fallback track count when snapshot track ids are unavailable',
        () {
      const snapshot = PlaylistSnapshotData(
        id: '1',
        name: 'playlist',
        trackIds: [],
        creatorUserId: null,
        trackCount: 100,
      );
      final detail = _detail(
        songCount: 30,
        expectedTrackCount:
            PlaylistDetailData.resolveExpectedTrackCount(snapshot, null),
      );

      expect(detail.expectedTrackCount, 100);
      expect(detail.isComplete, isFalse);
    });

    test('allows cached detail when no expected track count is known', () {
      final detail = _detail(songCount: 30);

      expect(detail.expectedTrackCount, isNull);
      expect(detail.isComplete, isTrue);
    });
  });

  group('PlaylistPageController', () {
    test('resolves partial local cache for first screen display', () {
      final detail = _detail(songCount: 30, expectedTrackCount: 100);

      expect(
        PlaylistPageController.resolveLocalDetailDisplayState(detail),
        PlaylistLocalDetailState.partial,
      );
    });

    test('resolves remote replacement as complete after refresh succeeds', () {
      final detail = _detail(
        songCount: 100,
        expectedTrackCount: 100,
        source: PlaylistDetailSource.remote,
      );

      expect(
        PlaylistPageController.resolveLocalDetailDisplayState(detail),
        PlaylistLocalDetailState.complete,
      );
    });

    test('resolves empty local detail for initial loading or empty failure',
        () {
      expect(
        PlaylistPageController.resolveLocalDetailDisplayState(null),
        PlaylistLocalDetailState.empty,
      );
      expect(
        PlaylistPageController.resolveLocalDetailDisplayState(
          _detail(songCount: 0, expectedTrackCount: 100),
        ),
        PlaylistLocalDetailState.empty,
      );
    });
  });
}

PlaylistDetailData _detail({
  required int songCount,
  int? expectedTrackCount,
  PlaylistDetailSource source = PlaylistDetailSource.local,
}) {
  return PlaylistDetailData(
    songs: List.generate(songCount, (index) => _queueItem(index)),
    isSubscribed: false,
    isMyPlayList: false,
    expectedTrackCount: expectedTrackCount,
    source: source,
  );
}

PlaybackQueueItem _queueItem(int index) {
  return PlaybackQueueItem(
    id: 'netease:$index',
    sourceId: '$index',
    title: 'Song $index',
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
