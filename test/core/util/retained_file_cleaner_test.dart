import 'dart:io';

import 'package:bujuan/core/util/retained_file_cleaner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RetainedFileCleaner', () {
    late Directory tempDirectory;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp('retained-file-cleaner-');
    });

    tearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('clears unretained files while keeping normalized retained paths', () async {
      final cacheDirectory = Directory('${tempDirectory.path}/cache')..createSync(recursive: true);
      final nestedDirectory = Directory('${cacheDirectory.path}/nested')..createSync(recursive: true);
      final retainedFile = await _writeFile(cacheDirectory, 'retained.mp3');
      final orphanFile = await _writeFile(cacheDirectory, 'orphan.mp3');
      final nestedOrphan = await _writeFile(nestedDirectory, 'orphan.lrc');

      await RetainedFileCleaner.clearDirectory(
        cacheDirectory,
        retainedPaths: {
          retainedFile.uri.replace(queryParameters: {'token': 'legacy'}).toString(),
        },
      );

      expect(retainedFile.existsSync(), isTrue);
      expect(orphanFile.existsSync(), isFalse);
      expect(nestedOrphan.existsSync(), isFalse);
      expect(cacheDirectory.existsSync(), isTrue);
      expect(nestedDirectory.existsSync(), isFalse);
    });

    test('recreates missing root directory', () async {
      final cacheDirectory = Directory('${tempDirectory.path}/missing-cache');

      await RetainedFileCleaner.clearDirectory(
        cacheDirectory,
        retainedPaths: const {},
      );

      expect(cacheDirectory.existsSync(), isTrue);
    });
  });
}

Future<File> _writeFile(Directory directory, String name) async {
  final file = File('${directory.path}/$name');
  await file.writeAsBytes([1, 2, 3]);
  return file;
}
