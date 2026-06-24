import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/features/playback/application/track_playback_queue_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrackPlaybackQueueBuilder', () {
    test('keeps track order and attaches local resources', () async {
      final repository = _FakeMusicDataRepository(
        resourcesByTrackId: {
          'netease:2': TrackResourceBundle(
            audio: _audioResource(
              trackId: 'netease:2',
              path: '/cache/audio/2.mp3',
            ),
          ),
        },
      );
      final builder = TrackPlaybackQueueBuilder(repository);

      final items = await builder.build(
        [_track('netease:1'), _track('netease:2')],
        likedSongIds: const [1],
      );

      expect(repository.requestedTrackIds, ['netease:1', 'netease:2']);
      expect(items.map((item) => item.id), ['netease:1', 'netease:2']);
      expect(items.first.mediaType, MediaType.playlist);
      expect(items.first.isLiked, isTrue);
      expect(items.last.mediaType, MediaType.local);
      expect(items.last.playbackUrl, '/cache/audio/2.mp3');
      expect(items.last.isCached, isTrue);
    });

    test('does not query resources for empty track list', () async {
      final repository = _FakeMusicDataRepository(resourcesByTrackId: const {});
      final builder = TrackPlaybackQueueBuilder(repository);

      final items = await builder.build(const [], likedSongIds: const []);

      expect(items, isEmpty);
      expect(repository.requestedTrackIds, isEmpty);
    });
  });
}

Track _track(String id) {
  return Track(
    id: id,
    sourceType: SourceType.netease,
    sourceId: id.split(':').last,
    title: 'Track $id',
    artistNames: const ['Artist'],
  );
}

LocalResourceEntry _audioResource({
  required String trackId,
  required String path,
}) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: trackId,
    kind: LocalResourceKind.audio,
    path: path,
    origin: TrackResourceOrigin.managedDownload,
    sizeBytes: 1,
    createdAt: now,
    lastAccessedAt: now,
  );
}

class _FakeMusicDataRepository implements MusicDataRepository {
  _FakeMusicDataRepository({
    required this.resourcesByTrackId,
  });

  final Map<String, TrackResourceBundle> resourcesByTrackId;
  final List<String> requestedTrackIds = [];

  @override
  Future<List<TrackWithResources>> getTracksWithResources(
    Iterable<String> trackIds,
  ) async {
    requestedTrackIds.addAll(trackIds);
    return [
      for (final trackId in trackIds)
        TrackWithResources(
          track: _track(trackId),
          resources: resourcesByTrackId[trackId] ?? const TrackResourceBundle(),
        ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
