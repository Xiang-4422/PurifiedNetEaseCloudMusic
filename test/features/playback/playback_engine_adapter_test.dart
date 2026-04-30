import 'dart:io';
import 'dart:typed_data';

import 'package:bujuan/features/playback/application/playback_engine_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NeteaseCacheStreamSource', () {
    test('decrypts only the requested byte range', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'netease_cache_stream_source_test_',
      );
      addTearDown(() async {
        if (await tempDirectory.exists()) {
          await tempDirectory.delete(recursive: true);
        }
      });
      final sourceBytes = Uint8List.fromList(
        List<int>.generate(12, (index) => index + 1),
      );
      final encryptedBytes = Uint8List.fromList(
        sourceBytes.map((byte) => byte ^ 0xa3).toList(growable: false),
      );
      final cacheFile = File('${tempDirectory.path}/song.mp3.uc!');
      await cacheFile.writeAsBytes(encryptedBytes);

      final source = NeteaseCacheStreamSource(cacheFile.path, 'mp3');
      final response = await source.request(3, 8);
      final decrypted = await response.stream.expand((chunk) => chunk).toList();

      expect(response.sourceLength, encryptedBytes.length);
      expect(response.contentLength, 5);
      expect(response.offset, 3);
      expect(response.contentType, 'audio/mpeg');
      expect(decrypted, sourceBytes.sublist(3, 8));
    });
  });
}
