import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final projectRoot = Directory.current;
  final libDirectory = Directory('${projectRoot.path}/lib');

  group('architecture boundary', () {
    test('global compatibility entry points stay removed', () {
      expect(
        Directory('${projectRoot.path}/lib/pages').existsSync(),
        isFalse,
        reason: '页面入口必须按 feature 内聚，不能恢复 lib/pages 双轨目录。',
      );

      final violations = _dartFiles(libDirectory)
          .where(
            (file) => _containsAny(file, const [
              'GetIt',
              'get_it',
              'AppController',
              'MediaItemBean',
              '迁移期兼容',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: '兼容层入口已经删除，不能再引入旧容器或旧播放队列模型。',
      );
    });

    test('core data domain stay pure Dart and do not import features', () {
      final boundaryFiles = _dartFiles(libDirectory).where((file) {
        final path = _relativePath(file);
        return path.startsWith('lib/core/') ||
            path.startsWith('lib/data/') ||
            path.startsWith('lib/domain/');
      }).toList();

      final getxViolations = boundaryFiles
          .where(
            (file) => _containsAny(file, const [
              "package:get/get.dart",
              'GetxController',
              'Get.find',
              'Get.put',
              'Get.lazyPut',
              'Rx<',
              'RxBool',
              'RxInt',
              'RxDouble',
              'RxString',
              'RxList',
              'RxMap',
              '.obs',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        getxViolations,
        isEmpty,
        reason: 'core/data/domain 不能依赖 GetX，未来迁移 Riverpod 时业务层不能被展示层容器绑死。',
      );

      final featureImportViolations = boundaryFiles
          .where((file) => _contains(file, "package:bujuan/features/"))
          .map(_relativePath)
          .toList();

      expect(
        featureImportViolations,
        isEmpty,
        reason: 'core/data/domain 不能反向 import features。',
      );
    });

    test('MediaItem is restricted to playback adapter and presentation edges',
        () {
      final violations = _dartFiles(libDirectory)
          .where((file) => _contains(file, 'MediaItem'))
          .where((file) => !_isAllowedMediaItemFile(_relativePath(file)))
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            'MediaItem 只能留在 audio_service 播放适配层或展示边界，repository 和 remote data source 不能返回它。',
      );
    });

    test('business cache stores do not read CacheBox directly', () {
      final cacheStores = _dartFiles(libDirectory).where((file) {
        final path = _relativePath(file);
        return path.endsWith('/search_cache_store.dart') ||
            path.endsWith('/explore_cache_store.dart') ||
            path.endsWith('/radio_cache_store.dart') ||
            path.endsWith('/playlist_cache_store.dart') ||
            path.endsWith('/cloud_cache_store.dart') ||
            path.endsWith('/user_profile_cache_store.dart');
      });

      final violations = cacheStores
          .where((file) => _contains(file, 'CacheBox.instance'))
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            '业务列表缓存应使用 Drift-backed AppCacheDataSource，Hive 只保留登录态、设置和轻量视觉缓存。',
      );
    });
  });
}

Iterable<File> _dartFiles(Directory directory) {
  if (!directory.existsSync()) {
    return const [];
  }
  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

bool _contains(File file, String pattern) {
  return file.readAsStringSync().contains(pattern);
}

bool _containsAny(File file, List<String> patterns) {
  final content = file.readAsStringSync();
  return patterns.any(content.contains);
}

bool _isAllowedMediaItemFile(String path) {
  return path.startsWith('lib/features/playback/') ||
      path.startsWith('lib/features/') && path.contains('/presentation/') ||
      path == 'lib/core/playback/media_item_cache_codec.dart';
}

String _relativePath(File file) {
  final root = Directory.current.path;
  return file.path
      .replaceFirst('$root/', '')
      .replaceAll(Platform.pathSeparator, '/');
}
