import 'dart:async';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playback/recent_playback_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecentPlaybackController', () {
    test('loads recent local history as playable queue items', () async {
      final repository = _FakePlaybackRepository(
        results: [
          Future.value([
            _track('netease:1', sourceId: '1'),
            _track('netease:2', sourceId: '2'),
          ]),
        ],
      );
      final controller = RecentPlaybackController(
        repository: repository,
        likedSongIds: () => [1],
      );
      addTearDown(controller.onClose);

      await controller.loadRecent(limit: 2);

      expect(repository.requestedLimits, [2]);
      expect(controller.recentTracks.map((item) => item.id), ['netease:1', 'netease:2']);
      expect(controller.recentTracks.first.isLiked, isTrue);
      expect(controller.recentTracks.last.isLiked, isFalse);
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.isLoading.value, isFalse);
    });

    test('ignores stale recent history loads', () async {
      final oldLoad = Completer<List<TrackWithResources>>();
      final newLoad = Completer<List<TrackWithResources>>();
      final controller = RecentPlaybackController(
        repository: _FakePlaybackRepository(
          results: [oldLoad.future, newLoad.future],
        ),
        likedSongIds: () => const [],
      );
      addTearDown(controller.onClose);

      final oldFuture = controller.loadRecent(limit: 4);
      await Future<void>.delayed(Duration.zero);
      final newFuture = controller.loadRecent(limit: 4);
      await Future<void>.delayed(Duration.zero);

      newLoad.complete([_track('netease:new')]);
      await newFuture;
      expect(controller.recentTracks.map((item) => item.id), ['netease:new']);

      oldLoad.complete([_track('netease:old')]);
      await oldFuture;
      expect(controller.recentTracks.map((item) => item.id), ['netease:new']);
    });

    test('keeps visible recent tracks when refresh fails', () async {
      final controller = RecentPlaybackController(
        repository: _FakePlaybackRepository(
          results: [Future<List<TrackWithResources>>.error(Exception('offline'))],
        ),
        likedSongIds: () => const [],
      );
      addTearDown(controller.onClose);
      controller.recentTracks.add(_queueItem('visible'));

      await controller.loadRecent();

      expect(controller.recentTracks.map((item) => item.id), ['visible']);
      expect(controller.errorMessage.value, contains('offline'));
      expect(controller.isLoading.value, isFalse);
    });

    test('refreshes after local playback history update notification', () async {
      final updates = StreamController<void>();
      final controller = RecentPlaybackController(
        repository: _FakePlaybackRepository(
          results: [
            Future.value([_track('netease:old')]),
            Future.value([_track('netease:new')]),
          ],
          recentPlaybackUpdates: updates.stream,
        ),
        likedSongIds: () => const [],
      );
      addTearDown(() async {
        controller.onClose();
        await updates.close();
      });

      controller.onInit();
      await Future<void>.delayed(Duration.zero);

      expect(controller.recentTracks.map((item) => item.id), ['netease:old']);

      updates.add(null);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(controller.recentTracks.map((item) => item.id), ['netease:new']);
    });
  });
}

class _FakePlaybackRepository implements PlaybackRepository {
  _FakePlaybackRepository({
    required this.results,
    this.recentPlaybackUpdates = const Stream<void>.empty(),
  });

  final List<Future<List<TrackWithResources>>> results;
  @override
  final Stream<void> recentPlaybackUpdates;
  final List<int> requestedLimits = <int>[];

  @override
  Future<List<TrackWithResources>> loadRecentPlayedTracks({int limit = 20}) {
    requestedLimits.add(limit);
    return results.removeAt(0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TrackWithResources _track(
  String id, {
  String? sourceId,
}) {
  return TrackWithResources(
    track: Track(
      id: id,
      sourceType: SourceType.netease,
      sourceId: sourceId ?? id,
      title: 'Track $id',
      artistNames: const ['Artist'],
    ),
    resources: const TrackResourceBundle(),
  );
}

PlaybackQueueItem _queueItem(String id) {
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
