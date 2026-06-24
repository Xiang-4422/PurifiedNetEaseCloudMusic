import 'package:bujuan/core/util/playback_url_expiry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackUrlExpiry', () {
    test('parses common playback url expiry query parameters', () {
      final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      final futureSeconds = now.add(const Duration(seconds: 30)).millisecondsSinceEpoch ~/ 1000;
      final futureMilliseconds = now.add(const Duration(minutes: 2)).millisecondsSinceEpoch;

      expect(
        PlaybackUrlExpiry.isExpired(
          'https://audio.test/song.mp3?authTime=$futureSeconds',
          now: now,
        ),
        isFalse,
      );
      expect(
        PlaybackUrlExpiry.isExpired(
          'https://audio.test/song.mp3?expires=$futureMilliseconds',
          now: now.add(const Duration(minutes: 3)),
        ),
        isTrue,
      );
    });

    test('uses the earliest recognized expiry parameter', () {
      final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      final earlier = now.subtract(const Duration(seconds: 1)).millisecondsSinceEpoch ~/ 1000;
      final later = now.add(const Duration(minutes: 2)).millisecondsSinceEpoch ~/ 1000;

      expect(
        PlaybackUrlExpiry.isExpired(
          'https://audio.test/song.mp3?exp=$later&expire=$earlier',
          now: now,
        ),
        isTrue,
      );
    });

    test('ignores local paths, invalid urls and non-numeric expiry values', () {
      final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);

      expect(PlaybackUrlExpiry.isExpired('/music/song.mp3?expires=1', now: now), isFalse);
      expect(PlaybackUrlExpiry.isExpired('https:///song.mp3?expires=1', now: now), isFalse);
      expect(PlaybackUrlExpiry.isExpired('https://audio.test/song.mp3?expires=soon', now: now), isFalse);
    });
  });
}
