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

      final domainFlutterViolations = boundaryFiles
          .where((file) => _relativePath(file).startsWith('lib/domain/'))
          .where((file) => _contains(file, "package:flutter/"))
          .map(_relativePath)
          .toList();

      expect(
        domainFlutterViolations,
        isEmpty,
        reason: 'domain 必须保持纯 Dart，不能依赖 Flutter UI 包。',
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

    test('presentation does not import remote data sources directly', () {
      final violations = _dartFiles(libDirectory)
          .where((file) => _relativePath(file).contains('/presentation/'))
          .where((file) => _contains(file, "package:bujuan/data/netease"))
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            'presentation 只能通过 controller/application/repository 读取数据，不能直连 data/netease。',
      );
    });

    test('shared widgets stay presentation only', () {
      final widgetDirectory = Directory('${projectRoot.path}/lib/widget');
      final violations = _dartFiles(widgetDirectory)
          .where(
            (file) => _containsAny(file, const [
              "package:bujuan/features/",
              "package:bujuan/data/",
              "package:get/get.dart",
              "Get.find",
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            'lib/widget 只能保留通用展示组件，不能直接读取 feature controller/repository 或 data。',
      );
    });

    test('repositories stay UI and container free', () {
      final violations = _repositoryFiles(libDirectory)
          .where(
            (file) => _containsAny(file, const [
              "package:flutter/material.dart",
              "package:flutter/widgets.dart",
              "package:get/get.dart",
              'Get.find',
              'Get.put',
              'Get.lazyPut',
              'Rx<',
              '.obs',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'repository 只能做数据聚合和映射，不能依赖 Flutter UI 或 GetX 容器。',
      );
    });

    test('feature repository imports use the approved cross-feature boundary',
        () {
      final violations = <String>[];
      for (final file in _repositoryFiles(libDirectory)) {
        final path = _relativePath(file);
        final featureName = _featureName(path);
        final imports = _featureImports(file);
        for (final importedFeature in imports) {
          if (_isAllowedRepositoryFeatureImport(
            ownerFeature: featureName,
            importedFeature: importedFeature,
          )) {
            continue;
          }
          violations.add('$path -> features/$importedFeature');
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'feature repository 之间不能横向随意依赖；共享能力应上移到 domain/application 或显式白名单。',
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

Iterable<File> _repositoryFiles(Directory directory) {
  return _dartFiles(directory).where((file) {
    final path = _relativePath(file);
    return path.startsWith('lib/features/') &&
        path.endsWith('_repository.dart');
  });
}

bool _contains(File file, String pattern) {
  return file.readAsStringSync().contains(pattern);
}

bool _containsAny(File file, List<String> patterns) {
  final content = file.readAsStringSync();
  return patterns.any(content.contains);
}

bool _isAllowedMediaItemFile(String path) {
  return path.startsWith('lib/features/playback/application/') ||
      path == 'lib/features/playback/playback_service.dart' ||
      path.startsWith('lib/features/') && path.contains('/presentation/');
}

String _featureName(String path) {
  final parts = path.split('/');
  if (parts.length < 3 || parts[0] != 'lib' || parts[1] != 'features') {
    return '';
  }
  return parts[2];
}

List<String> _featureImports(File file) {
  final importPattern =
      RegExp(r"import 'package:bujuan/features/([^/]+)/[^']*';");
  return importPattern
      .allMatches(file.readAsStringSync())
      .map((match) => match.group(1) ?? '')
      .where((feature) => feature.isNotEmpty)
      .toList();
}

bool _isAllowedRepositoryFeatureImport({
  required String ownerFeature,
  required String importedFeature,
}) {
  if (ownerFeature == importedFeature) {
    return true;
  }
  return importedFeature == 'library';
}

String _relativePath(File file) {
  final root = Directory.current.path;
  return file.path
      .replaceFirst('$root/', '')
      .replaceAll(Platform.pathSeparator, '/');
}
