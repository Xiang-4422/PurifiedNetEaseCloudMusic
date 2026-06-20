import 'package:bujuan/features/playback/application/playback_queue_item_mapper.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackQueueItemMapper', () {
    test('maps normal downloaded audio files as local file playback', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(),
            resources: TrackResourceBundle(
              audio: _audioResource('/cache/audio/song.mp3'),
            ),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.mediaType, MediaType.local);
      expect(item.playbackUrl, '/cache/audio/song.mp3');
    });

    test('keeps encrypted uc cache files on netease cache stream', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(),
            resources: TrackResourceBundle(
              audio: _audioResource('/cache/audio/song.mp3.uc!'),
            ),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.mediaType, MediaType.neteaseCache);
      expect(item.playbackUrl, '/cache/audio/song.mp3.uc!');
    });

    test('maps album id as explicit queue item field instead of metadata key', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(
              metadata: const {
                'albumId': 20,
              },
            ),
            resources: const TrackResourceBundle(),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.albumId, '20');
      expect(item.metadata.containsKey('albumId'), isFalse);
    });

    test('maps source type as explicit queue item field instead of metadata key', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(
              sourceType: SourceType.local,
              metadata: const {
                'sourceType': 'legacy',
              },
            ),
            resources: const TrackResourceBundle(),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.sourceType, SourceType.local);
      expect(item.metadata.containsKey('sourceType'), isFalse);
    });
  });
}

Track _track({
  SourceType sourceType = SourceType.netease,
  Map<String, Object?> metadata = const {},
}) {
  return Track(
    id: 'netease:1',
    sourceType: sourceType,
    sourceId: '1',
    title: 'Track',
    metadata: metadata,
  );
}

LocalResourceEntry _audioResource(String path) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: 'netease:1',
    kind: LocalResourceKind.audio,
    path: path,
    origin: TrackResourceOrigin.playbackCache,
    sizeBytes: 10,
    createdAt: now,
    lastAccessedAt: now,
  );
}
