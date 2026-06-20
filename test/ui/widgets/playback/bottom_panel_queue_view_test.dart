import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_queue_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bottom panel queue helpers', () {
    test('builds artist display text with fallback', () {
      expect(
        playbackQueueArtistDisplayText(
          _queueItem(artistNames: const ['Artist A', 'Artist B']),
        ),
        'Artist A / Artist B',
      );
      expect(
        playbackQueueArtistDisplayText(_queueItem()),
        '未知歌手',
      );
      expect(
        playbackQueueArtistDisplayText(
          _queueItem(artistNames: const ['   ']),
        ),
        '未知歌手',
      );
    });

    test('builds title color from current queue state', () {
      const panelColor = Color(0xFF223344);
      expect(
        playbackQueueTitleColor(isCurrent: false, panelColor: panelColor),
        panelColor,
      );
      expect(
        playbackQueueTitleColor(isCurrent: true, panelColor: panelColor),
        Colors.red,
      );
    });
  });
}

PlaybackQueueItem _queueItem({
  List<String> artistNames = const [],
}) {
  return PlaybackQueueItem(
    id: 'queue-item',
    sourceId: '1',
    title: 'Track',
    albumTitle: null,
    artistNames: artistNames,
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
