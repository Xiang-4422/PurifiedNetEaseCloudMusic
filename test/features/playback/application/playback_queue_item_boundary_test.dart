import 'dart:convert';

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
        },
      );

      final item = PlaybackQueueItemAdapter.fromMediaItem(mediaItem);

      expect(item.sourceId, '1');
      expect(item.artistNames, ['Artist']);
      expect(item.playbackUrl, 'https://example.com/song.mp3');
      expect(item.albumId, '20');
      expect(item.sourceType, SourceType.netease);
      expect(item.localLyricsPath, '/cache/lyrics.lrc');
      expect(item.availability, TrackAvailability.playable);
      expect(item.metadata, isEmpty);
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
      expect(mediaItem.extras?['albumId'], '20');
      expect(mediaItem.extras?['sourceType'], 'netease');
      expect(mediaItem.extras?['localLyricsPath'], '/cache/lyrics.lrc');
      expect(mediaItem.extras?['availability'], 'playable');
      expect(mediaItem.extras?['type'], 'playlist');
      expect(mediaItem.extras?['url'], 'https://example.com/song.mp3');
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
  });
}

PlaybackQueueItem _queueItem({
  String? albumId,
  SourceType sourceType = SourceType.netease,
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
    localArtworkPath: '/cache/art.jpg',
    mediaType: MediaType.playlist,
    playbackUrl: 'https://example.com/song.mp3',
    lyricKey: 'netease:1',
    localLyricsPath: localLyricsPath,
    availability: availability,
    isLiked: true,
    isCached: true,
    metadata: metadata,
  );
}
