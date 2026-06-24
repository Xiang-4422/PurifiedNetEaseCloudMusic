import 'dart:io';

import 'package:bujuan/core/util/playback_source_reference.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackSourceReference', () {
    test('normalizes valid remote playback urls', () {
      expect(
        PlaybackSourceReference.remoteHttpUrl('  HTTPS://audio.test/song.mp3?token=abc  '),
        'HTTPS://audio.test/song.mp3?token=abc',
      );
      expect(
        PlaybackSourceReference.remoteHttpUrl('https:///missing-host.mp3'),
        isEmpty,
      );
      expect(
        PlaybackSourceReference.remoteHttpUrl('ftp://audio.test/song.mp3'),
        isEmpty,
      );
      expect(
        PlaybackSourceReference.remoteHttpUrl('   '),
        isEmpty,
      );
    });

    test('rejects expired remote playback urls', () {
      final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);
      final freshExpiry = now.add(const Duration(seconds: 30)).millisecondsSinceEpoch ~/ 1000;
      final staleExpiry = now.subtract(const Duration(seconds: 1)).millisecondsSinceEpoch ~/ 1000;

      expect(
        PlaybackSourceReference.freshRemoteHttpUrl(
          'https://audio.test/song.mp3?authTime=$freshExpiry',
          now: now,
        ),
        isNotEmpty,
      );
      expect(
        PlaybackSourceReference.freshRemoteHttpUrl(
          'https://audio.test/song.mp3?authTime=$staleExpiry',
          now: now,
        ),
        isEmpty,
      );
    });

    test('normalizes local references and existing local files', () async {
      final directory = await Directory.systemTemp.createTemp('playback-source-reference-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final audioFile = File('${directory.path}/song with space.mp3');
      await audioFile.writeAsString('audio');
      final fileUri = audioFile.uri.replace(queryParameters: {'token': 'local'}).toString();

      expect(PlaybackSourceReference.localPath(fileUri), audioFile.path);
      expect(PlaybackSourceReference.existingLocalPath(fileUri), audioFile.path);
      expect(
        PlaybackSourceReference.existingLocalPath('${directory.path}/missing.mp3'),
        isEmpty,
      );
    });

    test('normalizes data-layer playback references without requiring local existence', () {
      expect(
        PlaybackSourceReference.playbackReference('  https://audio.test/song.mp3?token=abc  '),
        'https://audio.test/song.mp3?token=abc',
      );
      expect(
        PlaybackSourceReference.playbackReference('  /music/downloaded.mp3?token=local  '),
        '/music/downloaded.mp3',
      );
      expect(
        PlaybackSourceReference.playbackReference(
          Uri(scheme: 'file', host: 'media-server', path: '/music/song.mp3').toString(),
        ),
        isEmpty,
      );
    });
  });
}
