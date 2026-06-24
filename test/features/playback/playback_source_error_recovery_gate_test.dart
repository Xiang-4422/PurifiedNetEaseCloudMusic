import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/application/playback_source_error_recovery_gate.dart';
import 'package:bujuan/features/playback/playback_selection_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackSourceErrorRecoveryGate', () {
    test('blocks invalid or loading selections', () {
      final gate = PlaybackSourceErrorRecoveryGate();

      expect(
        gate.shouldStartRecovery(
          currentItemId: '',
          selection: _selection('1'),
        ),
        isFalse,
      );
      expect(
        gate.shouldStartRecovery(
          currentItemId: '1',
          selection: const PlaybackSelectionState(),
        ),
        isFalse,
      );
      expect(
        gate.shouldStartRecovery(
          currentItemId: '1',
          selection: _selection('2'),
        ),
        isFalse,
      );
      expect(
        gate.shouldStartRecovery(
          currentItemId: '1',
          selection: _selection(
            '1',
            sourceStatus: PlaybackSelectionSourceStatus.loading,
          ),
        ),
        isFalse,
      );
    });

    test('deduplicates the same selection until source becomes ready', () {
      final gate = PlaybackSourceErrorRecoveryGate();
      final selection = _selection('1', version: 3);

      expect(
        gate.shouldStartRecovery(
          currentItemId: '1',
          selection: selection,
        ),
        isTrue,
      );
      expect(
        gate.shouldStartRecovery(
          currentItemId: '1',
          selection: selection,
        ),
        isFalse,
      );

      gate.completeRecovery();
      expect(
        gate.shouldStartRecovery(
          currentItemId: '1',
          selection: selection,
        ),
        isFalse,
      );

      gate.markSourceReady();
      expect(
        gate.shouldStartRecovery(
          currentItemId: '1',
          selection: selection,
        ),
        isTrue,
      );
    });

    test('allows a newer selection version to recover after prior failure', () {
      final gate = PlaybackSourceErrorRecoveryGate();

      expect(
        gate.shouldStartRecovery(
          currentItemId: '1',
          selection: _selection('1', version: 1),
        ),
        isTrue,
      );
      gate.completeRecovery();

      expect(
        gate.shouldStartRecovery(
          currentItemId: '1',
          selection: _selection('1', version: 2),
        ),
        isTrue,
      );
    });
  });
}

PlaybackSelectionState _selection(
  String id, {
  int version = 1,
  PlaybackSelectionSourceStatus sourceStatus = PlaybackSelectionSourceStatus.ready,
}) {
  return PlaybackSelectionState(
    queue: [_item(id)],
    selectedItem: _item(id),
    selectedIndex: 0,
    selectionVersion: version,
    sourceStatus: sourceStatus,
  );
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
