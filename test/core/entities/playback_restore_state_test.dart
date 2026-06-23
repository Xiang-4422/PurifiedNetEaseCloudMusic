import 'package:bujuan/core/entities/playback_restore_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackRestoreState', () {
    test('does not treat blank current song id as restore data', () {
      const state = PlaybackRestoreState(currentSongId: '   ');

      expect(state.hasRestoreData, isFalse);
    });

    test('normalizes current song id from json', () {
      final state = PlaybackRestoreState.fromJson({
        'currentSongId': '  netease:1  ',
      });

      expect(state.currentSongId, 'netease:1');
      expect(state.hasRestoreData, isTrue);
    });
  });
}
