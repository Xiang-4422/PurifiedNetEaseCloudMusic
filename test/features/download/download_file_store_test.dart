import 'dart:async';
import 'dart:io';

import 'package:bujuan/features/download/application/download_file_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DownloadFileStore', () {
    late Directory tempDirectory;
    late Directory supportDirectory;
    const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp('download-file-store-');
      supportDirectory = Directory('${tempDirectory.path}/support')..createSync(recursive: true);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        pathProviderChannel,
        (call) async {
          switch (call.method) {
            case 'getApplicationSupportDirectory':
              return supportDirectory.path;
          }
          return null;
        },
      );
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        pathProviderChannel,
        null,
      );
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('removes temporary audio file when streaming download fails', () async {
      final dio = Dio()..httpClientAdapter = _FailingStreamDownloadAdapter();
      final fileStore = DownloadFileStore(dio: dio);
      final outputPath = '${tempDirectory.path}/track.mp3';
      final temporaryPath = '$outputPath.download';

      await expectLater(
        fileStore.downloadBinaryFile(
          'https://audio.test/track.mp3',
          outputPath,
          onProgress: (_) async {},
        ),
        throwsA(isA<Object>()),
      );

      expect(File(outputPath).existsSync(), isFalse);
      expect(
        File(temporaryPath).existsSync(),
        isFalse,
        reason: '失败的流式下载不能留下 .download 临时文件。',
      );
    });

    test('cleans orphan temporary files from download and playback cache roots', () async {
      final fileStore = DownloadFileStore();
      final downloadAudioDirectory = Directory('${supportDirectory.path}/zmusic/downloads/audio')..createSync(recursive: true);
      final cacheAudioDirectory = Directory('${supportDirectory.path}/zmusic/cache/audio')..createSync(recursive: true);
      final downloadTemporaryFile = await File('${downloadAudioDirectory.path}/track.mp3.download').writeAsBytes([1, 2, 3]);
      final cacheTemporaryFile = await File('${cacheAudioDirectory.path}/track.mp3.download').writeAsBytes([1, 2, 3]);
      final retainedDownloadFile = await File('${downloadAudioDirectory.path}/track.mp3').writeAsBytes([1, 2, 3]);
      final retainedCacheFile = await File('${cacheAudioDirectory.path}/track.mp3').writeAsBytes([1, 2, 3]);

      await fileStore.cleanupOrphanTemporaryFiles();

      expect(downloadTemporaryFile.existsSync(), isFalse);
      expect(cacheTemporaryFile.existsSync(), isFalse);
      expect(retainedDownloadFile.existsSync(), isTrue);
      expect(retainedCacheFile.existsSync(), isTrue);
    });

    test('normalizes legacy file uri paths before deleting temporary files', () async {
      final fileStore = DownloadFileStore();
      final temporaryFile = await File('${tempDirectory.path}/track.mp3.download').writeAsBytes([1, 2, 3]);
      final legacyFileUri = Uri(
        scheme: 'file',
        host: 'localhost',
        path: temporaryFile.path,
        queryParameters: {'token': 'legacy'},
      ).toString();

      await fileStore.deleteTemporaryDownloadIfExists(legacyFileUri);

      expect(temporaryFile.existsSync(), isFalse);
    });

    test('ignores unsafe file uri paths while deleting files', () async {
      final fileStore = DownloadFileStore();
      final retainedFile = await File('${tempDirectory.path}/track.mp3.download').writeAsBytes([1, 2, 3]);
      final unsafeFileUri = Uri(
        scheme: 'file',
        host: 'media-server',
        path: retainedFile.path,
      ).toString();

      await fileStore.deleteTemporaryDownloadIfExists(unsafeFileUri);

      expect(retainedFile.existsSync(), isTrue);
    });

    test('clears playback cache files while keeping retained resource paths', () async {
      final fileStore = DownloadFileStore();
      final cacheAudioDirectory = Directory('${supportDirectory.path}/zmusic/cache/audio')..createSync(recursive: true);
      final nestedCacheDirectory = Directory('${supportDirectory.path}/zmusic/cache/lyrics/nested')..createSync(recursive: true);
      final retainedAudio = await File('${cacheAudioDirectory.path}/retained.mp3').writeAsBytes([1, 2, 3]);
      final orphanAudio = await File('${cacheAudioDirectory.path}/orphan.mp3').writeAsBytes([1, 2, 3]);
      final orphanLyrics = await File('${nestedCacheDirectory.path}/orphan.lrc').writeAsBytes([1, 2, 3]);

      await fileStore.clearPlaybackCacheFiles(
        retainedPaths: {
          retainedAudio.uri.replace(queryParameters: {'token': 'legacy'}).toString(),
        },
      );

      expect(retainedAudio.existsSync(), isTrue);
      expect(orphanAudio.existsSync(), isFalse);
      expect(orphanLyrics.existsSync(), isFalse);
      expect(cacheAudioDirectory.existsSync(), isTrue);
      expect(nestedCacheDirectory.existsSync(), isFalse);
    });
  });
}

class _FailingStreamDownloadAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final controller = StreamController<Uint8List>();
    scheduleMicrotask(() {
      controller.add(Uint8List.fromList([1, 2, 3]));
      controller.addError(StateError('network interrupted'));
      unawaited(controller.close());
    });
    return ResponseBody(
      controller.stream,
      200,
      headers: {
        Headers.contentLengthHeader: ['6'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
