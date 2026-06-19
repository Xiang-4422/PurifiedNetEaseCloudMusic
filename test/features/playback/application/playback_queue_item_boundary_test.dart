import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
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
        },
      );

      final item = PlaybackQueueItemAdapter.fromMediaItem(mediaItem);

      expect(item.sourceId, '1');
      expect(item.artistNames, ['Artist']);
      expect(item.playbackUrl, 'https://example.com/song.mp3');
      expect(item.metadata, {
        'albumId': '20',
        'sourceType': 'netease',
      });
    });

    test('adapter owns MediaItem extras without requiring queue item extras getter', () {
      final mediaItem = PlaybackQueueItemAdapter.toMediaItem(
        _queueItem(
          metadata: const {
            'albumId': '20',
            'sourceType': 'netease',
          },
        ),
      );

      expect(mediaItem.album, 'Album');
      expect(mediaItem.artist, 'Artist');
      expect(mediaItem.artUri?.toFilePath(), '/cache/art.jpg');
      expect(mediaItem.extras?['albumId'], '20');
      expect(mediaItem.extras?['type'], 'playlist');
      expect(mediaItem.extras?['url'], 'https://example.com/song.mp3');
    });

    test('cache codec owns queue item JSON persistence format', () async {
      final encoded = await encodePlaybackQueueItemCacheList([
        _queueItem(
          metadata: const {
            'albumId': '20',
          },
        ),
      ]);
      final raw = jsonDecode(encoded.single) as Map<String, dynamic>;

      expect(raw['mediaType'], 'playlist');
      expect(raw['metadata'], {'albumId': '20'});

      final decoded = await decodePlaybackQueueItemCacheList(encoded);

      expect(decoded.single.id, 'netease:1');
      expect(decoded.single.duration, const Duration(seconds: 3));
      expect(decoded.single.metadata, {'albumId': '20'});
    });
  });
}

PlaybackQueueItem _queueItem({
  Map<String, dynamic> metadata = const {},
}) {
  return PlaybackQueueItem(
    id: 'netease:1',
    sourceId: '1',
    title: 'Track',
    albumTitle: 'Album',
    artistNames: const ['Artist'],
    artistIds: const ['10'],
    duration: const Duration(seconds: 3),
    artworkUrl: 'https://example.com/art.jpg',
    localArtworkPath: '/cache/art.jpg',
    mediaType: MediaType.playlist,
    playbackUrl: 'https://example.com/song.mp3',
    lyricKey: 'netease:1',
    isLiked: true,
    isCached: true,
    metadata: metadata,
  );
}
