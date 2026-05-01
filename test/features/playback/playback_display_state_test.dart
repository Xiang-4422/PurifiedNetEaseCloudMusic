import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/playback_confirmed_state.dart';
import 'package:bujuan/features/playback/playback_display_state.dart';
import 'package:bujuan/features/playback/playback_runtime_state.dart';
import 'package:bujuan/features/playback/playback_selection_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Playback display and confirmed states', () {
    test('display state is derived from selection state', () {
      final selection = PlaybackSelectionState(
        queue: [_item('1'), _item('2')],
        selectedItem: _item('2'),
        selectedIndex: 1,
        selectionVersion: 3,
        sourceStatus: PlaybackSelectionSourceStatus.loading,
      );

      final display = PlaybackDisplayState.fromSelection(selection);

      expect(display.currentSong.id, '2');
      expect(display.currentIndex, 1);
      expect(display.sourceStatus, PlaybackSelectionSourceStatus.loading);
      expect(display.hasCurrentSong, isTrue);
    });

    test('confirmed state is derived from runtime state and playing flag', () {
      final runtime = PlaybackRuntimeState(
        queue: [_item('1')],
        currentSong: _item('1'),
        currentIndex: 0,
        currentPosition: const Duration(seconds: 12),
      );

      final confirmed = PlaybackConfirmedState.fromRuntime(
        runtime,
        isPlaying: true,
      );

      expect(confirmed.currentSong.id, '1');
      expect(confirmed.currentIndex, 0);
      expect(confirmed.currentPosition, const Duration(seconds: 12));
      expect(confirmed.isPlaying, isTrue);
    });
  });
}

PlaybackQueueItem _item(String id) {
  return PlaybackQueueItem(
    id: id,
    sourceId: id,
    title: 'Track $id',
    albumTitle: null,
    artistNames: const [],
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
