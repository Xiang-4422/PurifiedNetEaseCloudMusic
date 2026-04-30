import 'package:bujuan/core/playback/playback_queue_item_mapper.dart';
import 'package:bujuan/domain/entities/local_resource_entry.dart';
import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_resource_bundle.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
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
  });
}

Track _track() {
  return const Track(
    id: 'netease:1',
    sourceType: SourceType.netease,
    sourceId: '1',
    title: 'Track',
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
