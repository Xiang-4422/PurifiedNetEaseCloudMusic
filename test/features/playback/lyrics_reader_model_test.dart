import 'package:bujuan/features/playback/lyrics/lyrics_reader_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LyricsReaderModel.getCurrentLine', () {
    test('returns -1 for empty lyrics and positions before first line', () {
      final model = LyricsReaderModel();

      expect(model.getCurrentLine(0), -1);

      model.lyrics = _lines();

      expect(model.getCurrentLine(999), -1);
    });

    test('uses line start times when end times are missing', () {
      final model = LyricsReaderModel()..lyrics = _lines();

      expect(model.getCurrentLine(1000), 0);
      expect(model.getCurrentLine(3999), 0);
      expect(model.getCurrentLine(4000), 1);
      expect(model.getCurrentLine(8999), 1);
      expect(model.getCurrentLine(9000), 2);
      expect(model.getCurrentLine(12000), 2);
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
