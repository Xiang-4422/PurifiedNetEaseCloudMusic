import 'package:bujuan/core/entities/radio_data.dart';
import 'package:bujuan/features/radio/radio_playback_queue_item_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RadioPlaybackQueueItemMapper', () {
    test('normalizes program track ids and skips blank track ids', () {
      final items = RadioPlaybackQueueItemMapper.fromPrograms(
        const [
          RadioProgramData(
            id: 'program-1',
            mainTrackId: '  123  ',
            title: 'Track 123',
            coverUrl: '',
            artistName: 'Artist',
            albumTitle: 'Album',
            durationMs: 3000,
          ),
          RadioProgramData(
            id: 'program-blank',
            mainTrackId: '   ',
            title: 'Blank',
            coverUrl: '',
            artistName: '',
            albumTitle: '',
            durationMs: 1000,
          ),
        ],
        likedSongIds: const [123],
      );

      expect(items, hasLength(1));
      expect(items.single.id, '123');
      expect(items.single.sourceId, '123');
      expect(items.single.lyricKey, '123');
      expect(items.single.isLiked, isTrue);
      expect(items.single.metadata, isEmpty);
    });
  });
}
