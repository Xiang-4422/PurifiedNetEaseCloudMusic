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

    test('keeps indexed audio resource before explicit remote media type', () {
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
        mediaType: MediaType.fm,
      ).single;

      expect(item.mediaType, MediaType.local);
      expect(item.playbackUrl, '/cache/audio/song.mp3');
      expect(item.isCached, isTrue);
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

    test('maps artist ids as explicit queue item field instead of metadata key', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(
              metadata: const {
                'artistIds': [10, '11'],
              },
            ),
            resources: const TrackResourceBundle(),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.artistIds, ['10', '11']);
      expect(item.metadata.containsKey('artistIds'), isFalse);
    });

    test('prefers explicit track album and artist ids over legacy metadata', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(
              albumId: 'explicit-album',
              artistIds: const ['explicit-artist'],
              metadata: const {
                'albumId': 'legacy-album',
                'artistIds': ['legacy-artist'],
              },
            ),
            resources: const TrackResourceBundle(),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.albumId, 'explicit-album');
      expect(item.artistIds, ['explicit-artist']);
      expect(item.metadata.containsKey('albumId'), isFalse);
      expect(item.metadata.containsKey('artistIds'), isFalse);
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

    test('maps lyrics path and availability as explicit queue item fields', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(
              availability: TrackAvailability.playable,
              metadata: const {
                'localLyricsPath': '/legacy/lyrics.lrc',
                'availability': 'unavailable',
              },
            ),
            resources: TrackResourceBundle(
              lyrics: _lyricsResource('/cache/lyrics/song.lrc'),
            ),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.localLyricsPath, '/cache/lyrics/song.lrc');
      expect(item.availability, TrackAvailability.playable);
      expect(item.metadata.containsKey('localLyricsPath'), isFalse);
      expect(item.metadata.containsKey('availability'), isFalse);
    });
  });
}

Track _track({
  SourceType sourceType = SourceType.netease,
  String? albumId,
  List<String> artistIds = const [],
  TrackAvailability availability = TrackAvailability.unknown,
  Map<String, Object?> metadata = const {},
}) {
  return Track(
    id: 'netease:1',
    sourceType: sourceType,
    sourceId: '1',
    title: 'Track',
    albumId: albumId,
    artistIds: artistIds,
    availability: availability,
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

LocalResourceEntry _lyricsResource(String path) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: 'netease:1',
    kind: LocalResourceKind.lyrics,
    path: path,
    origin: TrackResourceOrigin.playbackCache,
    sizeBytes: 10,
    createdAt: now,
    lastAccessedAt: now,
  );
}
