import 'dart:io';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/features/playback/application/playback_queue_cached_audio_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hasUsableCachedAudio', () {
    test('keeps cache marker only for existing non-local audio files', () async {
      final directory = await Directory.systemTemp.createTemp(
        'playback-cache-guard-',
      );
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final audioFile = File('${directory.path}/song with space.mp3');
      await audioFile.writeAsString('audio');

      expect(
        hasUsableCachedAudio(
          isCached: true,
          sourceType: SourceType.netease,
          mediaType: MediaType.neteaseCache,
          playbackUrl: audioFile.uri.replace(queryParameters: {'token': 'legacy'}).toString(),
        ),
        isTrue,
      );
      expect(
        hasUsableCachedAudio(
          isCached: true,
          sourceType: SourceType.netease,
          mediaType: MediaType.neteaseCache,
          playbackUrl: '${audioFile.path}.missing',
        ),
        isFalse,
      );
    });

    test('rejects local imports, remote urls, and non-cache media types', () async {
      final directory = await Directory.systemTemp.createTemp(
        'playback-cache-guard-',
      );
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final audioFile = File('${directory.path}/song.mp3');
      await audioFile.writeAsString('audio');

      expect(
        hasUsableCachedAudio(
          isCached: true,
          sourceType: SourceType.local,
          mediaType: MediaType.local,
          playbackUrl: audioFile.path,
        ),
        isFalse,
      );
      expect(
        hasUsableCachedAudio(
          isCached: true,
          sourceType: SourceType.netease,
          mediaType: MediaType.playlist,
          playbackUrl: audioFile.path,
        ),
        isFalse,
      );
      expect(
        hasUsableCachedAudio(
          isCached: true,
          sourceType: SourceType.netease,
          mediaType: MediaType.neteaseCache,
          playbackUrl: 'https://audio.test/song.mp3',
        ),
        isFalse,
      );
      expect(
        hasUsableCachedAudio(
          isCached: false,
          sourceType: SourceType.netease,
          mediaType: MediaType.neteaseCache,
          playbackUrl: audioFile.path,
        ),
        isFalse,
      );
    });
  });
}
