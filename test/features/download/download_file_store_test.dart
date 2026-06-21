import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bujuan/features/download/application/download_file_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DownloadFileStore', () {
    late Directory tempDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp('download-file-store-');
    });

    tearDown(() async {
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
