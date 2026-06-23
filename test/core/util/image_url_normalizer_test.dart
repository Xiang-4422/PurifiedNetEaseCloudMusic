import 'package:bujuan/core/util/image_url_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageUrlNormalizer', () {
    test('detects http scheme case-insensitively', () {
      expect(
        ImageUrlNormalizer.isRemoteHttpUrl('HTTPS://img.test/cover.jpg'),
        isTrue,
      );
      expect(
        ImageUrlNormalizer.isRemoteHttpUrl('HtTp://img.test/cover.jpg'),
        isTrue,
      );
      expect(
        ImageUrlNormalizer.isRemoteHttpUrl('ftp://img.test/cover.jpg'),
        isFalse,
      );
      expect(
        ImageUrlNormalizer.isRemoteHttpUrl('/cache/cover.jpg'),
        isFalse,
      );
    });

    test('removes netease image size param from mixed-case http url', () {
      final normalized = ImageUrlNormalizer.normalize(
        'HTTPS://img.test/cover.jpg?param=200y200&token=keep',
      );

      expect(normalized.toLowerCase(), contains('https://img.test/cover.jpg'));
      expect(normalized, contains('token=keep'));
      expect(normalized, isNot(contains('param=')));
    });

    test('removes size param when it is the only query parameter', () {
      expect(
        ImageUrlNormalizer.normalize('https://img.test/cover.jpg?param=200y200'),
        'https://img.test/cover.jpg',
      );
    });
  });
}
