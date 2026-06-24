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
    test('normalizes track ids and skips blank track ids', () {
      final items = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(id: '  netease:1  '),
            resources: const TrackResourceBundle(),
          ),
          TrackWithResources(
            track: _track(id: '   '),
            resources: const TrackResourceBundle(),
          ),
        ],
        likedSongIds: const [],
      );

      expect(items.map((item) => item.id), ['netease:1']);
    });

    test('normalizes track ids from plain track list', () {
      final items = PlaybackQueueItemMapper.fromTrackList(
        [
          _track(id: '  netease:1  '),
          _track(id: '   '),
        ],
        likedSongIds: const [],
      );

      expect(items.map((item) => item.id), ['netease:1']);
    });

    test('marks liked tracks with prefixed and trimmed source ids', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(sourceId: ' netease:1 '),
            resources: const TrackResourceBundle(),
          ),
        ],
        likedSongIds: const [1],
      ).single;

      expect(item.isLiked, isTrue);
    });

    test('falls back to track id when liked track source id is blank', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(id: ' netease:1 ', sourceId: '   '),
            resources: const TrackResourceBundle(),
          ),
        ],
        likedSongIds: const [1],
      ).single;

      expect(item.isLiked, isTrue);
    });

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

    test('keeps local import playable without cached display marker', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(
              id: 'local:/Music/imported/song.mp3',
              sourceType: SourceType.local,
              sourceId: '/Music/imported/song.mp3',
            ),
            resources: TrackResourceBundle(
              audio: _audioResource(
                '/Music/imported/song.mp3',
                origin: TrackResourceOrigin.localImport,
              ),
            ),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.mediaType, MediaType.local);
      expect(item.playbackUrl, '/Music/imported/song.mp3');
      expect(item.isCached, isFalse);
    });

    test('keeps remote artwork separate from indexed local artwork', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(artworkUrl: 'https://p1.music.126.net/cover.jpg?param=64y64'),
            resources: TrackResourceBundle(
              artwork: _artworkResource('/cache/artwork/cover.jpg'),
            ),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.artworkUrl, 'https://p1.music.126.net/cover.jpg');
      expect(item.localArtworkPath, '/cache/artwork/cover.jpg');
    });

    test('normalizes indexed local resource file uris before building queue item', () {
      final audioUri = Uri(
        scheme: 'file',
        host: 'localhost',
        path: '/cache/audio/song with space.mp3',
        queryParameters: {'token': 'local'},
      ).toString();
      final artworkUri = Uri(
        scheme: 'file',
        host: 'localhost',
        path: '/cache/artwork/cover with space.jpg',
        queryParameters: {'token': 'local'},
      ).toString();
      final lyricsUri = Uri(
        scheme: 'file',
        host: 'localhost',
        path: '/cache/lyrics/song with space.lrc',
        queryParameters: {'token': 'local'},
      ).toString();

      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(artworkUrl: 'https://p1.music.126.net/cover.jpg?param=64y64'),
            resources: TrackResourceBundle(
              audio: _audioResource(audioUri),
              artwork: _artworkResource(artworkUri),
              lyrics: _lyricsResource(lyricsUri),
            ),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.playbackUrl, '/cache/audio/song with space.mp3');
      expect(item.localArtworkPath, '/cache/artwork/cover with space.jpg');
      expect(item.localLyricsPath, '/cache/lyrics/song with space.lrc');
      expect(item.artworkUrl, 'https://p1.music.126.net/cover.jpg');
    });

    test('does not use local track source id without indexed audio', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(
              id: 'local:/Music/imported/song.mp3',
              sourceType: SourceType.local,
              sourceId: '/Music/imported/song.mp3',
            ),
            resources: const TrackResourceBundle(),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.mediaType, MediaType.local);
      expect(item.playbackUrl, isNull);
      expect(item.isCached, isFalse);
    });

    test('does not write remote track playback url into queue item', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(remoteUrl: 'https://audio.test/song.mp3?auth=temp'),
            resources: const TrackResourceBundle(),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.playbackUrl, isNull);
      expect(item.isCached, isFalse);
    });

    test('keeps legacy local track playback url after normalization', () {
      final localFileUri = Uri(
        scheme: 'file',
        host: 'localhost',
        path: '/cache/audio/song with space.mp3',
        queryParameters: {'token': 'legacy'},
      ).toString();

      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(remoteUrl: localFileUri),
            resources: const TrackResourceBundle(),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.playbackUrl, '/cache/audio/song with space.mp3');
      expect(item.isCached, isFalse);
    });

    test('does not mark cached when indexed audio path is not local', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(),
            resources: TrackResourceBundle(
              audio: _audioResource('https://audio.test/song.mp3'),
            ),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.mediaType, MediaType.playlist);
      expect(item.playbackUrl, isNull);
      expect(item.isCached, isFalse);
    });

    test('does not mark cached for unsafe local file uri audio path', () {
      final unsafeFileUri = Uri(
        scheme: 'file',
        host: 'media-server',
        path: '/cache/audio/song.mp3',
      ).toString();

      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(),
            resources: TrackResourceBundle(
              audio: _audioResource(unsafeFileUri),
            ),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.mediaType, MediaType.playlist);
      expect(item.playbackUrl, isNull);
      expect(item.isCached, isFalse);
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

    test('drops known non-playback source metadata from queue item', () {
      final item = PlaybackQueueItemMapper.fromTrackWithResourcesList(
        [
          TrackWithResources(
            track: _track(
              metadata: const {
                'mv': 123,
                'fee': 8,
                'publishTime': 1700000000000,
                'cloudSongId': 456,
                'cloudFileName': 'cloud.mp3',
                'cloudAddTime': 1700000001000,
                'scanSource': 'directory',
                'scannedAt': 1700000002000,
                'custom': 'keep',
              },
            ),
            resources: const TrackResourceBundle(),
          ),
        ],
        likedSongIds: const [],
      ).single;

      expect(item.metadata, {'custom': 'keep'});
    });
  });
}

Track _track({
  String id = 'netease:1',
  SourceType sourceType = SourceType.netease,
  String sourceId = '1',
  String? artworkUrl,
  String? remoteUrl,
  String? albumId,
  List<String> artistIds = const [],
  TrackAvailability availability = TrackAvailability.unknown,
  Map<String, Object?> metadata = const {},
}) {
  return Track(
    id: id,
    sourceType: sourceType,
    sourceId: sourceId,
    title: 'Track',
    artworkUrl: artworkUrl,
    remoteUrl: remoteUrl,
    albumId: albumId,
    artistIds: artistIds,
    availability: availability,
    metadata: metadata,
  );
}

LocalResourceEntry _artworkResource(String path) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: 'netease:1',
    kind: LocalResourceKind.artwork,
    path: path,
    origin: TrackResourceOrigin.artworkCache,
    sizeBytes: 10,
    createdAt: now,
    lastAccessedAt: now,
  );
}

LocalResourceEntry _audioResource(
  String path, {
  TrackResourceOrigin origin = TrackResourceOrigin.playbackCache,
}) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: 'netease:1',
    kind: LocalResourceKind.audio,
    path: path,
    origin: origin,
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
