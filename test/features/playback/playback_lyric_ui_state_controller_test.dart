import 'package:bujuan/features/playback/lyrics/lyrics_reader_model.dart';
import 'package:bujuan/features/playback/application/playback_lyric_ui_state_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackLyricUiStateController.resolveCurrentLyricIndex', () {
    late PlaybackLyricUiStateController controller;

    setUp(() {
      controller = PlaybackLyricUiStateController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('returns -1 for empty lyrics and positions before first line', () {
      expect(
        controller.resolveCurrentLyricIndex(
          lines: const [],
          position: Duration.zero,
        ),
        -1,
      );
      expect(
        controller.resolveCurrentLyricIndex(
          lines: _lines(),
          position: const Duration(milliseconds: 999),
        ),
        -1,
      );
    });

    test('finds exact hits, positions between lines, and tail positions', () {
      final lines = _lines();

      expect(
        controller.resolveCurrentLyricIndex(
          lines: lines,
          position: const Duration(milliseconds: 1000),
        ),
        0,
      );
      expect(
        controller.resolveCurrentLyricIndex(
          lines: lines,
          position: const Duration(milliseconds: 4500),
        ),
        1,
      );
      expect(
        controller.resolveCurrentLyricIndex(
          lines: lines,
          position: const Duration(milliseconds: 9000),
        ),
        2,
      );
      expect(
        controller.resolveCurrentLyricIndex(
          lines: lines,
          position: const Duration(milliseconds: 12000),
        ),
        2,
      );
    });
  });
}

List<LyricsLineModel> _lines() {
  return [
    LyricsLineModel()
      ..mainText = 'first'
      ..startTime = 1000,
    LyricsLineModel()
      ..mainText = 'second'
      ..startTime = 4000,
    LyricsLineModel()
      ..mainText = 'third'
      ..startTime = 9000,
  ];
}
