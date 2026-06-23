import 'dart:convert';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart' show TrackAvailability;
import 'package:bujuan/features/playback/application/playback_queue_item_adapter.dart';
import 'package:bujuan/features/playback/application/playback_queue_item_cache_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackQueueItem boundary', () {
    test('adapter strips MediaItem-only keys when mapping back to queue item metadata', () {
      const mediaItem = MediaItem(
        id: 'netease:1',
        title: 'Track',
        album: 'Album',
        artist: 'Artist',
        duration: Duration(seconds: 3),
        extras: {
          'type': 'playlist',
          'image': 'https://example.com/art.jpg',
          'url': 'https://example.com/song.mp3',
          'liked': true,
          'artist': 'Artist',
          'artistNames': ['Artist'],
          'artistIds': ['10'],
          'albumTitle': 'Album',
          'sourceId': '1',
          'localArtworkPath': '/cache/art.jpg',
          'lyricKey': 'netease:1',
          'cache': true,
          'albumId': '20',
          'sourceType': 'netease',
          'localLyricsPath': '/cache/lyrics.lrc',
          'availability': 'playable',
          'mv': 123,
          'fee': 8,
          'publishTime': 1700000000000,
          'cloudSongId': 456,
          'cloudFileName': 'cloud.mp3',
          'cloudAddTime': 1700000001000,
          'scanSource': 'directory',
          'scannedAt': 1700000002000,
        },
      );

      final item = PlaybackQueueItemAdapter.fromMediaItem(mediaItem);

      expect(item.sourceId, '1');
      expect(item.artistNames, ['Artist']);
      expect(item.playbackUrl, isNull);
      expect(item.albumId, '20');
      expect(item.sourceType, SourceType.netease);
      expect(item.localLyricsPath, '/cache/lyrics.lrc');
      expect(item.availability, TrackAvailability.playable);
      expect(item.isCached, isFalse);
      expect(item.metadata, isEmpty);
    });

    test('adapter restores cache flag only for existing non-local audio', () {
      final tempDirectory = Directory.systemTemp.createTempSync(
        'playback-media-cache-',
      );
      addTearDown(() {
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });
      final audioFile = File('${tempDirectory.path}/song.mp3')..writeAsBytesSync([1, 2, 3]);
      final mediaItem = MediaItem(
        id: 'netease:1',
        title: 'Track',
        extras: {
          'type': 'local',
          'url': audioFile.path,
          'cache': true,
          'sourceType': 'netease',
        },
      );

      final item = PlaybackQueueItemAdapter.fromMediaItem(mediaItem);

      expect(item.isCached, isTrue);

      final localItem = PlaybackQueueItemAdapter.fromMediaItem(
        MediaItem(
          id: 'local:${audioFile.path}',
          title: 'Local',
          extras: {
            'type': 'local',
            'url': audioFile.path,
            'cache': true,
            'sourceType': 'local',
          },
        ),
      );

      expect(localItem.isCached, isFalse);
    });

    test('adapter restores only local playback urls from MediaItem extras', () {
      final fileUri = Uri(
        scheme: 'file',
        host: 'localhost',
        path: '/cache/audio/song with space.mp3',
        queryParameters: {'token': 'local'},
      ).toString();
      final localItem = PlaybackQueueItemAdapter.fromMediaItem(
        MediaItem(
          id: 'netease:1',
          title: 'Track',
          extras: {
            'type': 'local',
            'url': fileUri,
            'sourceType': 'netease',
          },
        ),
      );
      final remoteItem = PlaybackQueueItemAdapter.fromMediaItem(
        const MediaItem(
          id: 'netease:2',
          title: 'Remote',
          extras: {
            'type': 'playlist',
            'url': 'https://example.com/song.mp3?expires=1',
            'sourceType': 'netease',
          },
        ),
      );

      expect(localItem.playbackUrl, '/cache/audio/song with space.mp3');
      expect(remoteItem.playbackUrl, isNull);
    });

    test('adapter writes cache extra only for existing non-local audio', () {
      final tempDirectory = Directory.systemTemp.createTempSync(
        'playback-media-extra-cache-',
      );
      addTearDown(() {
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });
      final audioFile = File('${tempDirectory.path}/song.mp3')..writeAsBytesSync([1, 2, 3]);

      final cachedMediaItem = PlaybackQueueItemAdapter.toMediaItem(
        _queueItem(
          mediaType: MediaType.local,
          playbackUrl: audioFile.path,
        ),
      );
      final missingMediaItem = PlaybackQueueItemAdapter.toMediaItem(
        _queueItem(
          mediaType: MediaType.local,
          playbackUrl: '${tempDirectory.path}/missing.mp3',
        ),
      );
      final localImportMediaItem = PlaybackQueueItemAdapter.toMediaItem(
        _queueItem(
          sourceType: SourceType.local,
          mediaType: MediaType.local,
          playbackUrl: audioFile.path,
        ),
      );

      expect(cachedMediaItem.extras?['cache'], isTrue);
      expect(missingMediaItem.extras?['cache'], isFalse);
      expect(localImportMediaItem.extras?['cache'], isFalse);
    });

    test('adapter owns MediaItem extras without requiring queue item extras getter', () {
      final mediaItem = PlaybackQueueItemAdapter.toMediaItem(
        _queueItem(
          albumId: '20',
          localLyricsPath: '/cache/lyrics.lrc',
          availability: TrackAvailability.playable,
          metadata: const {
            'sourceType': 'netease',
            'artistIds': ['legacy'],
            'localLyricsPath': '/legacy/lyrics.lrc',
            'availability': 'unavailable',
          },
        ),
      );

      expect(mediaItem.album, 'Album');
      expect(mediaItem.artist, 'Artist');
      expect(mediaItem.artUri?.toFilePath(), '/cache/art.jpg');
      expect(mediaItem.extras?['image'], '/cache/art.jpg');
      expect(mediaItem.extras?['albumId'], '20');
      expect(mediaItem.extras?['sourceType'], 'netease');
      expect(mediaItem.extras?['localLyricsPath'], '/cache/lyrics.lrc');
      expect(mediaItem.extras?['availability'], 'playable');
      expect(mediaItem.extras?['type'], 'playlist');
      expect(mediaItem.extras?['url'], 'https://example.com/song.mp3');
    });

    test('adapter normalizes local artwork file uri before building MediaItem artUri', () {
      final localArtworkUri = Uri(
        scheme: 'file',
        host: 'localhost',
        path: '/cache/art with space.jpg',
        queryParameters: {'token': 'local'},
      ).toString();

      final mediaItem = PlaybackQueueItemAdapter.toMediaItem(
        _queueItem(localArtworkPath: localArtworkUri),
      );

      expect(mediaItem.artUri?.toFilePath(), '/cache/art with space.jpg');
      expect(mediaItem.extras?['image'], '/cache/art with space.jpg');
    });

    test('adapter does not expose remote artwork url as local MediaItem artUri', () {
      final mediaItem = PlaybackQueueItemAdapter.toMediaItem(
        _queueItem(localArtworkPath: 'https://image.test/art.jpg'),
      );

      expect(mediaItem.artUri, isNull);
      expect(mediaItem.extras?['image'], 'https://example.com/art.jpg');
      expect(mediaItem.extras?['localArtworkPath'], 'https://image.test/art.jpg');
    });

    test('adapter writes explicit fields only and does not promote legacy metadata', () {
      final mediaItem = PlaybackQueueItemAdapter.toMediaItem(
        _queueItem(
          metadata: const {
            'albumId': 'legacy-album',
            'localLyricsPath': '/legacy/lyrics.lrc',
            'availability': 'playable',
          },
        ),
      );

      expect(mediaItem.extras?['albumId'], '');
      expect(mediaItem.extras?['localLyricsPath'], '');
      expect(mediaItem.extras?['availability'], 'unknown');
    });

    test('cache codec owns queue item JSON persistence format', () async {
      final encoded = await encodePlaybackQueueItemCacheList([
        _queueItem(
          albumId: '20',
          localLyricsPath: '/cache/lyrics.lrc',
          availability: TrackAvailability.playable,
          metadata: const {
            'sourceType': 'netease',
            'localLyricsPath': '/legacy/lyrics.lrc',
            'availability': 'unavailable',
          },
        ),
      ]);
      final raw = jsonDecode(encoded.single) as Map<String, dynamic>;

      expect(raw['mediaType'], 'playlist');
      expect(raw['albumId'], '20');
      expect(raw['sourceType'], 'netease');
      expect(raw['artistIds'], ['10']);
      expect(raw['localLyricsPath'], '/cache/lyrics.lrc');
      expect(raw['availability'], 'playable');
      expect(raw['metadata'], isEmpty);

      final decoded = await decodePlaybackQueueItemCacheList(encoded);

      expect(decoded.single.id, 'netease:1');
      expect(decoded.single.albumId, '20');
      expect(decoded.single.sourceType, SourceType.netease);
      expect(decoded.single.localLyricsPath, '/cache/lyrics.lrc');
      expect(decoded.single.availability, TrackAvailability.playable);
      expect(decoded.single.duration, const Duration(seconds: 3));
      expect(decoded.single.metadata, isEmpty);
    });

    test('cache codec writes explicit fields only and drops legacy metadata fields', () async {
      final encoded = await encodePlaybackQueueItemCacheList([
        _queueItem(
          metadata: const {
            'albumId': 'legacy-album',
            'localLyricsPath': '/legacy/lyrics.lrc',
            'availability': 'playable',
            'mv': 123,
            'fee': 8,
            'custom': 'keep',
          },
        ),
      ]);
      final raw = jsonDecode(encoded.single) as Map<String, dynamic>;

      expect(raw['albumId'], isNull);
      expect(raw['localLyricsPath'], isNull);
      expect(raw['availability'], 'unknown');
      expect(raw['isCached'], isFalse);
      expect(raw['metadata'], {'custom': 'keep'});
    });

    test('cache codec restores cache flag only when local audio still exists', () async {
      final tempDirectory = Directory.systemTemp.createTempSync(
        'playback-cache-codec-',
      );
      addTearDown(() {
        if (tempDirectory.existsSync()) {
          tempDirectory.deleteSync(recursive: true);
        }
      });
      final audioFile = File('${tempDirectory.path}/song.mp3')..writeAsBytesSync([1, 2, 3]);
      final encoded = await encodePlaybackQueueItemCacheList([
        _queueItem(
          mediaType: MediaType.local,
          playbackUrl: audioFile.path,
        ),
      ]);
      final raw = jsonDecode(encoded.single) as Map<String, dynamic>;

      expect(raw['isCached'], isTrue);

      final decoded = await decodePlaybackQueueItemCacheList(encoded);

      expect(decoded.single.isCached, isTrue);

      final missingLegacy = jsonEncode({
        'id': 'netease:1',
        'sourceId': '1',
        'title': 'Missing',
        'mediaType': 'local',
        'playbackUrl': '${tempDirectory.path}/missing.mp3',
        'sourceType': 'netease',
        'isCached': true,
      });
      final decodedMissing = await decodePlaybackQueueItemCacheList([
        missingLegacy,
      ]);

      expect(decodedMissing.single.isCached, isFalse);
    });

    test('cache codec drops remote playback urls from restore cache', () async {
      final encoded = await encodePlaybackQueueItemCacheList([
        _queueItem(playbackUrl: 'https://example.com/song.mp3?expires=1'),
      ]);
      final raw = jsonDecode(encoded.single) as Map<String, dynamic>;

      expect(raw['playbackUrl'], isNull);

      final decoded = await decodePlaybackQueueItemCacheList(encoded);
      expect(decoded.single.playbackUrl, isNull);

      final legacy = jsonEncode({
        'id': 'netease:1',
        'sourceId': '1',
        'title': 'Remote',
        'mediaType': 'playlist',
        'playbackUrl': 'https://example.com/legacy.mp3?expires=1',
      });
      final decodedLegacy = await decodePlaybackQueueItemCacheList([legacy]);

      expect(decodedLegacy.single.playbackUrl, isNull);

      final ftpLegacy = jsonEncode({
        'id': 'netease:1',
        'sourceId': '1',
        'title': 'Remote',
        'mediaType': 'playlist',
        'playbackUrl': 'ftp://example.com/song.mp3',
      });
      final decodedFtpLegacy = await decodePlaybackQueueItemCacheList([ftpLegacy]);

      expect(decodedFtpLegacy.single.playbackUrl, isNull);
    });

    test('cache codec preserves local playback urls for restore cache', () async {
      final encoded = await encodePlaybackQueueItemCacheList([
        _queueItem(
          mediaType: MediaType.local,
          playbackUrl: '/cache/audio/song.mp3',
        ),
      ]);
      final raw = jsonDecode(encoded.single) as Map<String, dynamic>;

      expect(raw['playbackUrl'], '/cache/audio/song.mp3');

      final decoded = await decodePlaybackQueueItemCacheList(encoded);
      expect(decoded.single.playbackUrl, '/cache/audio/song.mp3');
    });

    test('cache codec normalizes local file uri playback urls for restore cache', () async {
      final fileUri = Uri(
        scheme: 'file',
        host: 'localhost',
        path: '/cache/audio/song with space.mp3',
        queryParameters: {'token': 'local'},
      ).toString();
      final encoded = await encodePlaybackQueueItemCacheList([
        _queueItem(
          mediaType: MediaType.local,
          playbackUrl: fileUri,
        ),
      ]);
      final raw = jsonDecode(encoded.single) as Map<String, dynamic>;

      expect(raw['playbackUrl'], '/cache/audio/song with space.mp3');

      final decoded = await decodePlaybackQueueItemCacheList(encoded);
      expect(decoded.single.playbackUrl, '/cache/audio/song with space.mp3');
    });

    test('cache codec migrates legacy metadata source type into explicit field', () async {
      final encoded = jsonEncode({
        'id': 'local:/music/a.mp3',
        'sourceId': '/music/a.mp3',
        'title': 'Local',
        'mediaType': 'local',
        'metadata': {
          'sourceType': 'local',
          'albumId': '30',
          'artistIds': [10, '11'],
          'localLyricsPath': '/music/a.lrc',
          'availability': 'localOnly',
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
      });

      final decoded = await decodePlaybackQueueItemCacheList([encoded]);

      expect(decoded.single.sourceType, SourceType.local);
      expect(decoded.single.albumId, '30');
      expect(decoded.single.artistIds, ['10', '11']);
      expect(decoded.single.localLyricsPath, '/music/a.lrc');
      expect(decoded.single.availability, TrackAvailability.localOnly);
      expect(decoded.single.metadata, {'custom': 'keep'});
    });

    test('cache codec skips corrupt cached queue entries', () async {
      final encoded = await encodePlaybackQueueItemCacheList([_queueItem()]);
      final emptyId = jsonEncode({
        'id': '',
        'sourceId': 'empty',
        'title': 'Empty',
      });

      final decoded = await decodePlaybackQueueItemCacheList([
        '{broken json',
        emptyId,
        encoded.single,
        '[]',
      ]);

      expect(decoded.map((item) => item.id), ['netease:1']);
    });
  });
}

PlaybackQueueItem _queueItem({
  String? albumId,
  SourceType sourceType = SourceType.netease,
  MediaType mediaType = MediaType.playlist,
  String? playbackUrl = 'https://example.com/song.mp3',
  String? localArtworkPath = '/cache/art.jpg',
  String? localLyricsPath,
  TrackAvailability availability = TrackAvailability.unknown,
  Map<String, dynamic> metadata = const {},
}) {
  return PlaybackQueueItem(
    id: 'netease:1',
    sourceId: '1',
    sourceType: sourceType,
    title: 'Track',
    albumTitle: 'Album',
    albumId: albumId,
    artistNames: const ['Artist'],
    artistIds: const ['10'],
    duration: const Duration(seconds: 3),
    artworkUrl: 'https://example.com/art.jpg',
    localArtworkPath: localArtworkPath,
    mediaType: mediaType,
    playbackUrl: playbackUrl,
    lyricKey: 'netease:1',
    localLyricsPath: localLyricsPath,
    availability: availability,
    isLiked: true,
    isCached: true,
    metadata: metadata,
  );
}
