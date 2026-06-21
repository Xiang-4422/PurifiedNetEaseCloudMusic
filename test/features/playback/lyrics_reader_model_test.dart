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

  group('LyricsLineModel.defaultSpanList', () {
    test('does not create negative default span duration', () {
      final missingEnd = LyricsLineModel()
        ..mainText = 'missing'
        ..startTime = 1000;
      final reversedEnd = LyricsLineModel()
        ..mainText = 'reversed'
        ..startTime = 2000
        ..endTime = 1000;

      expect(missingEnd.defaultSpanList.single.duration, 0);
      expect(reversedEnd.defaultSpanList.single.duration, 0);
    });

    test('uses positive line duration when start and end are available', () {
      final line = LyricsLineModel()
        ..mainText = 'line'
        ..startTime = 1000
        ..endTime = 2500;

      final span = line.defaultSpanList.single;

      expect(span.start, 1000);
      expect(span.duration, 1500);
      expect(span.raw, 'line');
      expect(span.length, 4);
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
