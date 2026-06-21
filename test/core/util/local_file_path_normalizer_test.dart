import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalFilePathNormalizer', () {
    test('normalizes supported local file references', () {
      expect(
        LocalFilePathNormalizer.normalize('/music/song.mp3?token=local'),
        '/music/song.mp3',
      );
      expect(
        LocalFilePathNormalizer.normalize(
          Uri(
            scheme: 'file',
            host: 'localhost',
            path: '/music/song with space.mp3',
            queryParameters: {'token': 'local'},
          ).toString(),
        ),
        '/music/song with space.mp3',
      );
      expect(
        LocalFilePathNormalizer.normalize(r'C:\Music\song.mp3?token=local'),
        r'C:\Music\song.mp3',
      );
    });

    test('rejects remote and unsafe uri references', () {
      expect(LocalFilePathNormalizer.normalize(null), isEmpty);
      expect(LocalFilePathNormalizer.normalize(''), isEmpty);
      expect(
        LocalFilePathNormalizer.normalize('https://audio.test/song.mp3'),
        isEmpty,
      );
      expect(
        LocalFilePathNormalizer.normalize('ftp://audio.test/song.mp3'),
        isEmpty,
      );
      expect(
        LocalFilePathNormalizer.normalize(
          Uri(
            scheme: 'file',
            host: 'media-server',
            path: '/music/song.mp3',
          ).toString(),
        ),
        isEmpty,
      );
    });
  });
}
