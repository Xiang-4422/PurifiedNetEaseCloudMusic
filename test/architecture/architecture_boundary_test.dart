import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final projectRoot = Directory.current;
  final libDirectory = Directory('${projectRoot.path}/lib');

  group('architecture boundary', () {
    test('root UI entry points stay isolated', () {
      expect(
        Directory('${projectRoot.path}/lib/pages').existsSync(),
        isFalse,
        reason: '页面入口统一放在 lib/ui/pages，不能恢复 lib/pages 双轨目录。',
      );
      expect(
        Directory('${projectRoot.path}/lib/widgets').existsSync(),
        isFalse,
        reason: 'UI 组件统一放在 lib/ui/widgets，不能恢复 lib/widgets 双轨目录。',
      );
      expect(
        Directory('${projectRoot.path}/lib/ui/pages').existsSync(),
        isTrue,
        reason: '页面入口必须统一放在 lib/ui/pages。',
      );
      expect(
        Directory('${projectRoot.path}/lib/ui/widgets').existsSync(),
        isTrue,
        reason: 'UI 组件必须统一放在 lib/ui/widgets。',
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

    test('project architecture mapping and app root stay explicit', () {
      expect(
        File('${projectRoot.path}/docs/项目架构.md').existsSync(),
        isTrue,
        reason: '项目必须维护一份说明当前 app/ui/features/data/core 职责边界的中文架构文档，避免后续机械搬目录。',
      );
      final mainFile = File('${projectRoot.path}/lib/main.dart');
      expect(
        File('${projectRoot.path}/lib/app.dart').existsSync(),
        isTrue,
        reason: '应用根组件必须保留在 lib/app.dart，对齐规范里的 app.dart 职责。',
      );
      expect(
        Directory('${projectRoot.path}/lib/domain').existsSync(),
        isFalse,
        reason: '共享模型统一归入 lib/core/entities，不能恢复根目录 lib/domain。',
      );
      final appFile = File('${projectRoot.path}/lib/app.dart');
      final appContent = appFile.readAsStringSync();
      expect(
        mainFile.readAsStringSync(),
        contains('runApp(const App())'),
        reason: 'main.dart 只负责启动顺序，根组件应从 App 进入。',
      );
      expect(
        appContent,
        contains('GetMaterialApp.router'),
        reason: 'lib/app.dart 必须直接承接 App 根组件，不能退化成只转发到另一个 root router。',
      );
      expect(
        File('${projectRoot.path}/lib/app/routing/app_root_router.dart').existsSync(),
        isFalse,
        reason: 'App 根壳层不能在 lib/app.dart 和 app_root_router.dart 之间双轨拆分。',
      );
    });

    test('refactor route documents local verification gate without Android build', () {
      final doc = File('${projectRoot.path}/docs/重构路线.md').readAsStringSync();
      final acceptanceSection = _markdownSection(doc, '## 10. 验收命令');

      expect(
        doc,
        isNot(contains('flutter build apk --debug')),
        reason: '这台开发机后续不默认执行 Android APK 构建，文档不能把它写回每次修改门槛。',
      );
      expect(
        doc,
        isNot(contains('adb -s <deviceId> install -r build/app/outputs/flutter-apk/app-debug.apk')),
        reason: '这台开发机后续不默认执行 adb 安装，文档不能把它写回每次修改门槛。',
      );
      expect(
        doc,
        contains('后续默认不执行 Android APK 构建和 adb 安装'),
        reason: '路线文档必须记录当前机器不再把编译安装作为默认验证。',
      );
      expect(
        acceptanceSection,
        allOf(
          contains('flutter analyze'),
          contains('flutter test'),
          contains('git diff --check'),
          contains('flutter test test/architecture'),
          contains('架构测试不能替代本机验证门槛'),
          isNot(contains('flutter build apk --debug')),
          isNot(contains('adb -s <deviceId> install -r build/app/outputs/flutter-apk/app-debug.apk')),
        ),
        reason: '验收命令章节必须反映当前本机验证门槛，不能重新要求每次 Android 构建和 adb 安装。',
      );
    });

    test('app directory only keeps composition and routing', () {
      const expectedAppDirectories = [
        'lib/app/bootstrap',
        'lib/app/routing',
      ];
      const removedAppDirectories = [
        'lib/app/layout',
        'lib/app/presentation_adapters',
        'lib/app/services',
        'lib/app/theme',
      ];
      const expectedUiDirectories = [
        'lib/ui/layout',
        'lib/ui/services',
        'lib/ui/theme',
      ];

      final missingExpectedAppDirectories = expectedAppDirectories.where((path) => !Directory('${projectRoot.path}/$path').existsSync()).toList();
      final existingRemovedAppDirectories = removedAppDirectories.where((path) => Directory('${projectRoot.path}/$path').existsSync()).toList();
      final missingExpectedUiDirectories = expectedUiDirectories.where((path) => !Directory('${projectRoot.path}/$path').existsSync()).toList();

      expect(
        missingExpectedAppDirectories,
        isEmpty,
        reason: 'lib/app 只保留启动装配和路由目录。',
      );
      expect(
        existingRemovedAppDirectories,
        isEmpty,
        reason: '主题、布局、Toast/Dialog 和播放展示协作对象不能继续留在 app 目录。',
      );
      expect(
        missingExpectedUiDirectories,
        isEmpty,
        reason: '通用 UI 主题、布局和展示服务统一归入 lib/ui。',
      );
    });

    test('data directories use music data and app storage boundaries', () {
      const expectedDataDirectories = [
        'lib/data/app_storage',
        'lib/data/music_data/sources/local',
        'lib/data/music_data/sources/netease',
      ];
      const removedDataPaths = [
        'lib/core/database',
        'lib/core/storage',
        'lib/data/local',
        'lib/data/netease',
        'lib/features/library',
      ];
      final missingExpected = expectedDataDirectories.where((path) => !Directory('${projectRoot.path}/$path').existsSync()).toList();
      final existingRemoved = removedDataPaths.where((path) => Directory('${projectRoot.path}/$path').existsSync()).toList();
      final musicDataRoot = Directory('${projectRoot.path}/lib/data/music_data');
      final unexpectedMusicDataRootEntries = musicDataRoot
          .listSync()
          .map((entity) => entity.uri.pathSegments.where((segment) => segment.isNotEmpty).last)
          .where((name) => !const {'music_data_repository.dart', 'music_remote_data_sources.dart', 'sources'}.contains(name))
          .toList();

      expect(
        missingExpected,
        isEmpty,
        reason: '数据层只保留 app_storage 与 music_data/sources/local|netease 两条主线。',
      );
      expect(
        existingRemoved,
        isEmpty,
        reason: 'database/storage/local/netease/library 旧目录不能继续和新 data 边界并存。',
      );
      expect(
        unexpectedMusicDataRootEntries,
        isEmpty,
        reason: 'music_data 根目录只放统一入口、远程中性契约和 sources 目录。',
      );
    });

    test('generated root directory stays removed', () {
      expect(
        Directory('${projectRoot.path}/lib/generated').existsSync(),
        isFalse,
        reason: '根目录 generated 语义不清；资源路径索引归 UI，网易云 JSON 解析归 netease api models 自身生成文件。',
      );

      final generatedImports = _dartFiles(libDirectory)
          .where(
            (file) => _containsAny(file, const [
              'package:bujuan/generated/',
              "import '../generated/",
            ]),
          )
          .map(_relativePath)
          .toList();
      expect(
        generatedImports,
        isEmpty,
        reason: '运行时代码不能继续依赖 lib/generated。',
      );
    });

    test('offline mode is removed from runtime code', () {
      final violations = _dartFiles(libDirectory)
          .where(
            (file) => _containsAny(file, const [
              'offlineModeSp',
              'isOfflineModeEnabled',
              'saveOfflineModeEnabled',
              'toggleOfflineMode',
              '离线模式',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: '离线模式已从产品和数据调度策略中移除，不能保留运行时代码入口。',
      );
    });

    test('feature controllers do not import storage or data source details', () {
      final controllerFiles = _dartFiles(Directory('${projectRoot.path}/lib/features')).where((file) => _relativePath(file).endsWith('_controller.dart'));
      final violations = controllerFiles
          .where(
            (file) => _containsAny(file, const [
              'package:bujuan/data/music_data/sources/',
              'package:bujuan/data/app_storage/cache_box.dart',
              'package:hive/',
              'package:hive_flutter/',
              '/dao/',
              '_data_source.dart',
              'remote_data_source.dart',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'Controller 只能依赖页面状态、feature repository 或统一数据入口，不能直接触碰 source、DAO、Hive/CacheBox。',
      );
    });

    test('remote services and repositories are constructed in composition root', () {
      final remoteFiles = [
        ..._dartFiles(Directory('${projectRoot.path}/lib/data/music_data/sources/netease/remote')),
        File('${projectRoot.path}/lib/data/music_data/sources/netease/netease_music_source.dart'),
      ];
      final remoteViolations = remoteFiles
          .where(
            (file) => _containsAny(file, const [
              'NeteaseMusicApi? api',
              '?? NeteaseMusicApi()',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        remoteViolations,
        isEmpty,
        reason: '网易云 service/remote data source 必须显式接收 NeteaseMusicApi，由 bootstrap/registrar 统一创建。',
      );

      final repositoryViolations = _repositoryFiles(libDirectory)
          .where(
            (file) => _containsAny(file, const [
              'RemoteDataSource? remoteDataSource',
              '?? Netease',
              'NeteaseMusicSource()',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        repositoryViolations,
        isEmpty,
        reason: 'feature repository 不能隐式创建 remote/data service；所有底层依赖必须由组合根显式传入。',
      );
    });

    test('controllers publish state instead of touching storage or UI effects directly', () {
      final controllerFiles = _dartFiles(libDirectory).where((file) {
        final path = _relativePath(file);
        return path.startsWith('lib/features/') && (path.endsWith('_controller.dart') || path.endsWith('_page_controller.dart') || path.endsWith('_scan_controller.dart'));
      });

      final violations = controllerFiles
          .where(
            (file) => _containsAny(file, const [
              'CacheBox.instance',
              'package:hive',
              'hive_flutter',
              'ToastService',
              'DialogService',
              'AutoRouter',
              'Navigator.of',
              'showDialog',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'Controller 只发布页面状态/一次性 effect，不能直接触碰 Hive/CacheBox/Toast/Dialog/路由跳转。',
      );
    });

    test('shell-only widgets stay under shell page widgets', () {
      final removedGlobalWidgetDirectories = [
        'lib/ui/widgets/playback',
        'lib/ui/widgets/search',
        'lib/ui/widgets/comment',
      ];
      final existingGlobalDirectories = removedGlobalWidgetDirectories
          .where(
            (path) => Directory('${projectRoot.path}/$path').existsSync(),
          )
          .toList();

      expect(
        existingGlobalDirectories,
        isEmpty,
        reason: '播放面板、顶部搜索和评论面板只服务 shell 页面，不能继续占用全局 widgets 目录。',
      );
      expect(
        Directory('${projectRoot.path}/lib/ui/pages/shell/widgets/playback').existsSync(),
        isTrue,
        reason: 'shell 专属播放面板组件必须归入 shell 页面局部 widgets。',
      );
      expect(
        Directory('${projectRoot.path}/lib/ui/pages/shell/widgets/search').existsSync(),
        isTrue,
        reason: 'shell 专属顶部搜索组件必须归入 shell 页面局部 widgets。',
      );
      expect(
        Directory('${projectRoot.path}/lib/ui/pages/shell/widgets/comment').existsSync(),
        isTrue,
        reason: 'shell 专属评论面板组件必须归入 shell 页面局部 widgets。',
      );
    });

    test('core entities and data stay pure Dart and do not import features', () {
      final boundaryFiles = _dartFiles(libDirectory).where((file) {
        final path = _relativePath(file);
        return path.startsWith('lib/core/') || path.startsWith('lib/data/');
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
        reason: 'core/data 不能依赖 GetX，未来迁移 Riverpod 时业务层不能被展示层容器绑死。',
      );

      final featureImportViolations = boundaryFiles.where((file) => _contains(file, "package:bujuan/features/")).map(_relativePath).toList();

      expect(
        featureImportViolations,
        isEmpty,
        reason: 'core/data 不能反向 import features。',
      );

      final entityFlutterViolations = boundaryFiles
          .where((file) => _relativePath(file).startsWith('lib/core/entities/'))
          .where(
            (file) => _containsAny(file, const [
              "package:flutter/",
              "package:audio_service/",
              "package:just_audio/",
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        entityFlutterViolations,
        isEmpty,
        reason: 'core/entities 必须保持纯 Dart，不能依赖 Flutter、audio_service 或 just_audio。',
      );
    });

    test('data and playback lyric parser stay Flutter free', () {
      final handWrittenDataFiles = _dartFiles(Directory('${projectRoot.path}/lib/data')).where((file) => !_isGeneratedDartFile(_relativePath(file)));
      final lyricParserFiles = _dartFiles(
        Directory('${projectRoot.path}/lib/features/playback/lyrics'),
      );

      final violations = [
        ...handWrittenDataFiles,
        ...lyricParserFiles,
      ].where((file) => _contains(file, 'package:flutter/')).map(_relativePath).toList();

      expect(
        violations,
        isEmpty,
        reason: 'data 和歌词解析模型必须保持纯 Dart；Flutter 绘制对象只能留在 presentation adapter。',
      );
    });

    test('core does not depend on netease data implementation', () {
      final violations = _dartFiles(Directory('${projectRoot.path}/lib/core')).where((file) => _contains(file, 'package:bujuan/data/music_data/sources/netease/')).map(_relativePath).toList();

      expect(
        violations,
        isEmpty,
        reason: 'core 是跨数据源基础层，不能反向依赖网易云实现；请求细节应留在 packages/netease_music_api。',
      );
    });

    test('core directory only keeps approved foundation boundaries', () {
      const allowedCoreDirectories = {
        'diagnostics',
        'entities',
        'platform',
        'state',
        'time',
        'util',
      };
      final coreDirectory = Directory('${projectRoot.path}/lib/core');
      final unexpectedDirectories = coreDirectory.listSync().whereType<Directory>().map((entity) => entity.uri.pathSegments.where((segment) => segment.isNotEmpty).last).where((name) => !allowedCoreDirectories.contains(name)).toList();

      expect(
        Directory('${projectRoot.path}/lib/core/playback').existsSync(),
        isFalse,
        reason: '播放队列转换和缓存编解码属于 playback application，不能恢复 core/playback。',
      );
      expect(
        Directory('${projectRoot.path}/lib/core/network').existsSync(),
        isFalse,
        reason: 'LoadState 和 OperationResult 是通用状态模型，统一放在 core/state。',
      );
      expect(
        unexpectedDirectories,
        isEmpty,
        reason: 'core 只保留真正跨层基础能力目录，避免重新变成杂物层。',
      );
    });

    test('local file uri parsing stays in shared path normalizer', () {
      const allowedPath = 'lib/core/util/local_file_path_normalizer.dart';
      final violations = <String>[];
      for (final file in _dartFiles(libDirectory)) {
        final path = _relativePath(file);
        if (path == allowedPath || _isGeneratedDartFile(path)) {
          continue;
        }
        final content = file.readAsStringSync();
        if (content.contains('.toFilePath(') || content.contains("scheme == 'file'") || content.contains("uri.scheme == 'file'") || content.contains('_looksLikeWindowsDrivePath')) {
          violations.add(path);
        }
      }

      expect(
        violations,
        isEmpty,
        reason: '本地路径、合法 file:// 和 Windows 盘符路径的判定必须收口到 LocalFilePathNormalizer，避免导入、播放、封面和缓存清理入口语义漂移。',
      );
    });

    test('netease remote data sources depend on api facade only', () {
      final remoteFiles = _dartFiles(Directory('${projectRoot.path}/lib/data/music_data/sources/netease/remote'));
      final violations = remoteFiles
          .where(
            (file) => _containsAny(file, const [
              'package:netease_music_api/src/client/',
              'DioMetaData',
              'DioProxy',
              'Https.',
              'NeteaseMusicApi().',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'remote data source 只能通过构造注入的 NeteaseMusicApi 门面访问接口，不能触碰底层 Dio client 或临时创建 SDK 单例。',
      );
    });

    test('main app imports netease api package through public facade', () {
      final violations = _dartFiles(libDirectory)
          .where(
            (file) => _contains(file, 'package:netease_music_api/src/'),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: '主项目代码只能 import package:netease_music_api/netease_music_api.dart，不能直接依赖 API package 的 src 内部实现。',
      );
    });

    test('netease SDK facade stays in bootstrap handoff files', () {
      final violations = <String>[];
      for (final file in _dartFiles(Directory('${projectRoot.path}/lib/app/bootstrap'))) {
        final path = _relativePath(file);
        final content = file.readAsStringSync();
        final touchesSdk = [
          'package:netease_music_api/',
          'NeteaseMusicApi',
          'ApiEnhancedRaw',
          'requestModule(',
        ].any(content.contains);

        if (!touchesSdk) {
          continue;
        }
        if (!_allowedNeteaseSdkBootstrapFiles.contains(path)) {
          violations.add(path);
        }
        if (path != 'lib/app/bootstrap/sdk_bootstrap.dart' && content.contains('NeteaseMusicApi()')) {
          violations.add('$path creates SDK instance');
        }
      }

      expect(
        violations,
        isEmpty,
        reason: '启动层只有 sdk_bootstrap、data_bootstrap、data_source_bootstrap 能携带网易云 SDK 门面；其他 bootstrap 文件只能处理自己的装配职责。',
      );
    });

    test('netease SDK access stays inside bootstrap and source boundary', () {
      final violations = _dartFiles(libDirectory)
          .where(
            (file) => _containsAny(file, const [
              'package:netease_music_api/',
              'NeteaseMusicApi',
              'ApiEnhancedRaw',
              'requestModule(',
            ]),
          )
          .map(_relativePath)
          .where((path) => !_isAllowedNeteaseSdkBoundary(path))
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'UI、controller、feature repository 和普通 data 层不能直接访问网易云 SDK；SDK 只允许在 app/bootstrap 创建，在 data/music_data/sources/netease 调用和映射。',
      );
    });

    test('bootstrap only initializes and injects netease SDK', () {
      final violations = <String>[];
      for (final file in _dartFiles(Directory('${projectRoot.path}/lib/app/bootstrap'))) {
        final content = file.readAsStringSync();
        final path = _relativePath(file);
        if (content.contains('requestModule(')) {
          violations.add('$path calls raw requestModule');
        }
        if (RegExp(r'\bneteaseApi\.\w+\s*\(').hasMatch(content)) {
          violations.add('$path calls neteaseApi business method');
        }
        if (RegExp(r'\bNeteaseMusicApi\(\)\.\w+\s*\(').hasMatch(content)) {
          violations.add('$path calls SDK singleton business method');
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'bootstrap 可以初始化 SDK 并注入 netease source，但不能在组合根直接发网易云业务请求。',
      );
    });

    test('netease endpoint and model files do not import public api barrel', () {
      final sdkFiles = [
        ..._dartFiles(
          Directory('${projectRoot.path}/packages/netease_music_api/lib/src/endpoints'),
        ),
        ..._dartFiles(
          Directory('${projectRoot.path}/packages/netease_music_api/lib/src/models'),
        ),
      ];
      final violations = sdkFiles.where((file) => _contains(file, 'netease_music_api.dart')).map(_relativePath).toList();

      expect(
        violations,
        isEmpty,
        reason: 'api/endpoints 和 api/models 不能反向 import 对外 barrel；内部应依赖 client 或具体 DTO 文件，避免 SDK 内部循环依赖。',
      );
    });

    test('MediaItem is restricted to playback adapter and presentation edges', () {
      final violations = _dartFiles(libDirectory).where((file) => _contains(file, 'MediaItem')).where((file) => !_isAllowedMediaItemFile(_relativePath(file))).map(_relativePath).toList();

      expect(
        violations,
        isEmpty,
        reason: 'MediaItem 只能留在 audio_service 播放适配层或展示边界，repository 和 remote data source 不能返回它。',
      );
    });

    test('playback queue item stays free of adapter and cache serialization concerns', () {
      final queueItemFile = File(
        '${projectRoot.path}/lib/core/entities/playback_queue_item.dart',
      );
      final content = queueItemFile.readAsStringSync();
      final violations = <String>[
        if (content.contains('MediaItem')) 'depends on MediaItem',
        if (content.contains('extras')) 'exposes adapter extras',
        if (content.contains('fromJson(')) 'owns cache JSON decoding',
        if (content.contains('toJson(')) 'owns cache JSON encoding',
        if (content.contains('artUri')) 'owns adapter artUri',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'PlaybackQueueItem 是应用播放队列实体，MediaItem extras 和缓存 JSON 格式必须留在 adapter/codec 边界。',
      );
    });

    test('playback queue cache normalizes queue item ids', () {
      final codecFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_queue_item_cache_codec.dart',
      );
      final content = codecFile.readAsStringSync();
      final violations = <String>[
        if (!content.contains('String _normalizedQueueItemId(String id)')) 'queue item cache codec does not define id normalization',
        if (!content.contains(".where((item) => _normalizedQueueItemId(item.id).isNotEmpty)")) 'queue item cache codec can still persist blank item ids',
        if (!content.contains("id: _normalizedQueueItemId(json['id'] as String? ?? '')")) 'queue item cache codec can restore raw item ids',
        if (!content.contains("'id': _normalizedQueueItemId(item.id)")) 'queue item cache codec can write raw item ids',
      ];

      expect(
        violations,
        isEmpty,
        reason: '播放恢复队列缓存必须在 codec 边界规范化队列项 id，并跳过空白 id；空白队列项不能被持久化为 session 事实。',
      );
    });

    test('playback queue mappers normalize queue item ids', () {
      final mapperFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_queue_item_mapper.dart',
      );
      final radioMapperFile = File(
        '${projectRoot.path}/lib/features/radio/radio_playback_queue_item_mapper.dart',
      );
      final mapper = mapperFile.readAsStringSync();
      final radioMapper = radioMapperFile.readAsStringSync();
      final violations = <String>[
        if (!mapper.contains('String _normalizedQueueItemId(String id)')) 'playback queue item mapper does not define id normalization',
        if (!mapper.contains('_normalizedQueueItemId(track.id).isNotEmpty')) 'playback queue item mapper does not filter blank track ids',
        if (!mapper.contains('final trackId = _normalizedQueueItemId(track.id);')) 'playback queue item mapper does not normalize ids before mapping',
        if (!mapper.contains('id: trackId')) 'playback queue item mapper can still write raw track ids',
        if (!radioMapper.contains('String _normalizedQueueItemId(String id)')) 'radio queue item mapper does not define id normalization',
        if (!radioMapper.contains('_normalizedQueueItemId(program.mainTrackId).isNotEmpty')) 'radio queue item mapper does not filter blank main track ids',
        if (!radioMapper.contains('final trackId = _normalizedQueueItemId(program.mainTrackId);')) 'radio queue item mapper does not normalize main track ids before mapping',
        if (!radioMapper.contains('id: trackId')) 'radio queue item mapper can still write raw main track ids',
      ];

      expect(
        violations,
        isEmpty,
        reason: '播放队列 mapper 是 UI、播放和恢复状态共用的入口，曲目 id 必须在进入 PlaybackQueueItem 前规范化并拒绝空白值。',
      );
    });

    test('media item adapter normalizes queue item ids', () {
      final adapterFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_queue_item_adapter.dart',
      );
      final content = adapterFile.readAsStringSync();
      final violations = <String>[
        if (!content.contains('String _normalizedQueueItemId(String id)')) 'media item adapter does not define id normalization',
        if (!content.contains('id: _normalizedQueueItemId(item.id)')) 'media item adapter can still write raw queue ids to MediaItem',
        if (!content.contains('final itemId = _normalizedQueueItemId(item.id);')) 'media item adapter does not normalize MediaItem ids before mapping back',
        if (!content.contains('sourceId: _stringOrNull(extras[\'sourceId\']) ?? itemId')) 'media item adapter does not fall back to normalized id for missing source id',
        if (!content.contains('.where((item) => _normalizedQueueItemId(item.id).isNotEmpty)')) 'media item adapter can still export blank item ids in batch',
        if (!content.contains('.where((item) => item.id.isNotEmpty)')) 'media item adapter can still import blank item ids in batch',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'MediaItem adapter 是 audio_service 和应用播放队列之间的边界，进出都必须规范化队列项 id，并过滤空白批量项。',
      );
    });

    test('playback queue service normalizes queue fact ids', () {
      final serviceFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_queue_service.dart',
      );
      final content = serviceFile.readAsStringSync();
      final violations = <String>[
        if (!content.contains('String _normalizedQueueItemId(String id)')) 'playback queue service does not define id normalization',
        if (!content.contains('final normalizedQueue = _normalizedQueueItems(queue);')) 'replaceQueue can still accept raw queue ids',
        if (!content.contains('final normalizedIncomingSongs = _normalizedQueueItems(incomingSongs);')) 'appendQueueItems can still accept raw queue ids',
        if (!content.contains('final restoredQueue = _normalizedQueueItems(restoreData.queue);')) 'restoreFromData can still restore raw queue ids',
        if (!content.contains('PlaybackQueueItem _normalizedQueueItem(PlaybackQueueItem item)')) 'playback queue service does not normalize queue items',
        if (!content.contains('return queue.map(_normalizedQueueItem).where((item) => item.id.isNotEmpty)')) 'playback queue service does not filter blank queue item ids',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'PlaybackQueueService 是 original queue、active queue 和 confirmed item 的事实源，写入和匹配前必须规范化队列项 id，并过滤空白 id。',
      );
    });

    test('media item adapter does not persist remote playback urls', () {
      final adapterFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_queue_item_adapter.dart',
      );
      final content = adapterFile.readAsStringSync();
      final violations = <String>[
        if (content.contains("'url': item.playbackUrl") || content.contains('"url": item.playbackUrl')) 'writes raw playbackUrl into MediaItem extras',
        if (!content.contains("'url': _restorablePlaybackUrl(item.playbackUrl) ?? ''")) 'does not sanitize MediaItem playback url extras',
      ];

      expect(
        violations,
        isEmpty,
        reason: '远程播放 URL 是短效资源，MediaItem extras 只允许保存可恢复的本地路径，不能把远程 URL 带回通知栏或恢复边界。',
      );
    });

    test('playback restore position requires matched current song', () {
      final coordinatorFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_restore_coordinator.dart',
      );
      final content = coordinatorFile.readAsStringSync();
      final violations = <String>[
        if (!content.contains('final currentSongMatched = index >= 0')) 'does not record whether restored current song matched queue',
        if (!content.contains('currentSongMatched && restoreState.position > Duration.zero')) 'restores position without checking matched current song',
        if (!content.contains('restoreState.position > Duration.zero')) 'does not sanitize non-positive restored position',
      ];

      expect(
        violations,
        isEmpty,
        reason: '恢复进度只属于持久化的当前歌曲；当前歌曲缺失或进度异常时只能恢复队列上下文，不能把旧进度 seek 到另一首歌。',
      );
    });

    test('playback state synchronizer resets position when confirmed media item changes', () {
      final synchronizerFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_state_synchronizer.dart',
      );
      final content = synchronizerFile.readAsStringSync();
      final violations = <String>[
        if (content.contains('playback.position.saveOnTrackChange')) 'saves previous track position as a separate background task',
        if (!content.contains('final trackChanged = _lastPositionTrackId.isNotEmpty && _lastPositionTrackId != queueItem.id')) 'does not detect media item track changes',
        if (!content.contains('_latestPosition = Duration.zero')) 'does not reset latest position on media item change',
        if (!content.contains('currentPosition: trackChanged ? Duration.zero : null')) 'does not reset runtime position on media item change',
        if (!content.contains('position: trackChanged ? Duration.zero : null')) 'does not reset restore position with current song save',
      ];

      expect(
        violations,
        isEmpty,
        reason: '切歌时当前歌曲和恢复进度必须作为同一语义更新；不能把上一首的进度通过独立后台任务写到新歌恢复状态上。',
      );
    });

    test('playback repository rejects negative restore positions', () {
      final repositoryFile = File(
        '${projectRoot.path}/lib/features/playback/playback_repository.dart',
      );
      final content = repositoryFile.readAsStringSync();
      final violations = <String>[
        if (!content.contains('Future<void> updateRestorePosition(Duration position)')) 'restore position boundary is missing',
        if (!content.contains('if (position < Duration.zero)')) 'restore position boundary does not reject negative positions',
      ];

      expect(
        violations,
        isEmpty,
        reason: '播放进度进入恢复持久化前必须过滤异常负值，避免损坏的运行态污染 restore/session 状态。',
      );
    });

    test('playback restore state normalizes current song ids', () {
      final stateFile = File(
        '${projectRoot.path}/lib/core/entities/playback_restore_state.dart',
      );
      final repositoryFile = File(
        '${projectRoot.path}/lib/features/playback/playback_repository.dart',
      );
      final dataSourceFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/data_sources/drift_playback_restore_data_source.dart',
      );
      final state = stateFile.readAsStringSync();
      final repository = repositoryFile.readAsStringSync();
      final dataSource = dataSourceFile.readAsStringSync();
      final violations = <String>[
        if (!state.contains('currentSongId.trim().isNotEmpty')) 'restore state can treat blank current song ids as valid data',
        if (!state.contains("currentSongId: (json['currentSongId'] as String? ?? '').trim()")) 'restore state json decode does not normalize current song ids',
        if (!repository.contains('currentSongId: normalizedCurrentSongId')) 'playback repository can still save raw restore current song ids',
        if (!repository.contains('final normalizedState = _normalizedRestoreState(localState);')) 'playback repository does not normalize restored current song ids before validation',
        if (!repository.contains('String? _normalizedOptionalTrackId(String? trackId)')) 'playback repository does not normalize nullable restore track ids',
        if (!dataSource.contains('currentSongId: row.currentSongId.trim()')) 'drift restore data source can return raw current song ids',
        if (!dataSource.contains('currentSongId: drift.Value(state.currentSongId.trim())')) 'drift restore data source can persist raw current song ids',
      ];

      expect(
        violations,
        isEmpty,
        reason: '播放恢复 currentSongId 是 restore/session 边界字段，写入和读取都必须规范化；纯空白 id 不能让旧恢复状态被误判为有效。',
      );
    });

    test('music data repository delegates playback url cache coordination', () {
      final repositoryFile = File(
        '${projectRoot.path}/lib/data/music_data/music_data_repository.dart',
      );
      final coordinatorFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/resources/playback_url_cache_coordinator.dart',
      );
      final repositoryContent = repositoryFile.readAsStringSync();
      final coordinatorContent = coordinatorFile.existsSync() ? coordinatorFile.readAsStringSync() : '';
      final violations = <String>[
        if (!coordinatorFile.existsSync()) 'playback url cache coordinator is missing',
        if (!repositoryContent.contains('PlaybackUrlCacheCoordinator')) 'repository does not delegate to PlaybackUrlCacheCoordinator',
        if (!repositoryContent.contains('String _normalizedTrackId(String trackId)')) 'repository does not normalize playback URL track ids before delegation',
        if (!repositoryContent.contains('final normalizedTrackId = _normalizedTrackId(trackId);')) 'repository playback URL entry points do not normalize track ids',
        if (repositoryContent.contains('Map<String, Future<String?>> _playbackUrlLoads')) 'repository still owns playback URL in-flight loads',
        if (repositoryContent.contains('Map<String, _CachedPlaybackUrl> _playbackUrlCache')) 'repository still owns playback URL cache entries',
        if (repositoryContent.contains('class _CachedPlaybackUrl')) 'repository still owns cached playback URL model',
        if (!coordinatorContent.contains('final Map<String, Future<String?>> _loads')) 'coordinator does not own in-flight load state',
        if (!coordinatorContent.contains('final Map<String, _CachedPlaybackUrl> _cache')) 'coordinator does not own cache state',
        if (!coordinatorContent.contains('final normalizedTrackId = _normalizedTrackId(trackId);')) 'coordinator does not normalize track ids before lookup',
        if (!coordinatorContent.contains('_cacheKey(normalizedTrackId, qualityLevel)')) 'coordinator cache key does not use normalized track id',
        if (!coordinatorContent.contains('_resolveLocalResourceUrlOrNull(normalizedTrackId)')) 'coordinator local lookup does not use normalized track id',
      ];

      expect(
        violations,
        isEmpty,
        reason: '播放 URL 短 TTL、并发合并、本地资源优先重查和 LRU 淘汰必须留在独立协调器，MusicDataRepository 只编排数据来源。',
      );
    });

    test('music data repository rejects blank track ids at data boundary', () {
      final repositoryFile = File(
        '${projectRoot.path}/lib/data/music_data/music_data_repository.dart',
      );
      final content = repositoryFile.readAsStringSync();
      final blankTrackGuardCount = '_isBlankTrackId'.allMatches(content).length;
      final violations = <String>[
        if (!content.contains('bool _isBlankTrackId(String trackId)')) 'blank track id helper is missing',
        if (!content.contains('String _normalizedTrackId(String trackId)')) 'normalized track id helper is missing',
        if (!content.contains('List<String> _candidateTrackIds(Iterable<String> trackIds)')) 'batch track id candidate helper is missing',
        if (!content.contains('final normalizedTrackId = _normalizedTrackId(trackId);')) 'single-track entry points do not normalize track ids',
        if (!content.contains('if (_isBlankTrackId(normalizedTrackId) || !seen.add(normalizedTrackId))')) 'batch track candidates are not normalized before de-duplication',
        if (RegExp(r'Future<List<Track>> getTracksByIds[\s\S]*?final ids = _candidateTrackIds\(trackIds\);').firstMatch(content) == null) 'batch track loading does not filter blank ids before local lookup',
        if (RegExp(r'Future<List<TrackWithResources>> getTracksWithResources[\s\S]*?final ids = _candidateTrackIds\(trackIds\);').firstMatch(content) == null) 'batch track resource loading does not filter blank ids before resource lookup',
        if (!content.contains('getTrackResourceBundles(\n      ids,\n    )')) 'batch track resource lookup does not preserve candidate id order',
        if (blankTrackGuardCount < 5) 'blank track id guard does not cover track, playback URL, artwork, lyrics and resource bundle entry points',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'MusicDataRepository 是 App 统一数据入口，空白曲目 id 不能继续进入本地库、本地资源索引或网易云远程源。',
      );
    });

    test('local resource index repository rejects blank track ids', () {
      final repositoryFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/resources/local_resource_index_repository.dart',
      );
      final content = repositoryFile.readAsStringSync();
      final blankTrackGuardCount = '_isBlankTrackId'.allMatches(content).length;
      final violations = <String>[
        if (!content.contains('String _normalizedTrackId(String trackId)')) 'local resource index repository does not normalize track ids',
        if (!content.contains('bool _isBlankTrackId(String trackId)')) 'local resource index repository does not define a blank track id guard',
        if (!content.contains('List<String> _candidateTrackIds(Iterable<String> trackIds)')) 'local resource index repository does not filter batch track ids',
        if (!content.contains('final candidateTrackIds = _candidateTrackIds(trackIds);')) 'batch resource lookup does not use filtered track ids',
        if (!content.contains('if (_isBlankTrackId(normalizedTrackId))')) 'single-track resource index entry points do not reject blank ids',
        if (blankTrackGuardCount < 7) 'blank track id guard does not cover resource reads, writes, touch and deletion paths',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'local_resource_entries 是本地资源事实表，资源索引仓库自身也必须拒绝空白曲目 id，不能只依赖上层下载或播放入口。',
      );
    });

    test('UI reads explicit queue item fields instead of metadata keys', () {
      final uiFiles = _dartFiles(Directory('${projectRoot.path}/lib/ui'));
      final violations = uiFiles
          .where(
            (file) => _containsAny(file, const [
              '.metadata[',
              "metadata['",
              'metadata["',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'UI 只能读取 PlaybackQueueItem 的显式字段，不能依赖 metadata 动态键。',
      );
    });

    test('bottom panel queue view receives playback state boundaries', () {
      final queueFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_queue_view.dart',
      );
      final panelFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart',
      );
      final queue = queueFile.readAsStringSync();
      final panel = panelFile.readAsStringSync();
      final violations = <String>[
        if (queue.contains('PlayerController.to')) '${_relativePath(queueFile)} reads player controller globally',
        if (queue.contains('SettingsController.to')) '${_relativePath(queueFile)} reads settings controller globally',
        if (!queue.contains('required this.playerController')) '${_relativePath(queueFile)} does not receive player controller',
        if (!queue.contains('required this.settingsController')) '${_relativePath(queueFile)} does not receive settings controller',
        if (!panel.contains('playerController: playerController')) '${_relativePath(panelFile)} does not inject player controller',
        if (!panel.contains('settingsController: settingsController')) '${_relativePath(panelFile)} does not inject settings controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '底部队列页只能展示播放队列和提交播放意图，播放状态与面板颜色必须由底部播放面板组合层注入。',
      );
    });

    test('bottom panel main view receives shell injected boundaries', () {
      final homeFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/app_home_page_view.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final panelFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart',
      );
      final home = homeFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final panel = panelFile.readAsStringSync();
      final violations = <String>[
        if (panel.contains('PlayerController.to')) '${_relativePath(panelFile)} reads player controller globally',
        if (panel.contains('SettingsController.to')) '${_relativePath(panelFile)} reads settings controller globally',
        if (panel.contains('Get.find<CommentControllerFactory>')) '${_relativePath(panelFile)} reads comment controller factory globally',
        if (!panel.contains('required this.playerController')) '${_relativePath(panelFile)} does not receive player controller',
        if (!panel.contains('required this.settingsController')) '${_relativePath(panelFile)} does not receive settings controller',
        if (!panel.contains('required this.commentControllerFactory')) '${_relativePath(panelFile)} does not receive comment controller factory',
        if (!home.contains('final appHomeControllers = Get.find<AppHomeControllerBundle>()')) '${_relativePath(homeFile)} does not resolve app home controller bundle at shell boundary',
        if (home.contains('Get.find<PlayerController>')) '${_relativePath(homeFile)} reads player controller globally',
        if (home.contains('Get.find<SettingsController>')) '${_relativePath(homeFile)} reads settings controller globally',
        if (home.contains('Get.find<CommentControllerFactory>')) '${_relativePath(homeFile)} reads comment controller factory globally',
        if (!home.contains('final playerController = appHomeControllers.playerController')) '${_relativePath(homeFile)} does not receive player controller from app home bundle',
        if (!home.contains('final settingsController = appHomeControllers.settingsController')) '${_relativePath(homeFile)} does not receive settings controller from app home bundle',
        if (!home.contains('final commentControllerFactory = appHomeControllers.commentControllerFactory')) '${_relativePath(homeFile)} does not receive comment controller factory from app home bundle',
        if (!bootstrap.contains('Get.put<AppHomeControllerBundle>')) 'feature bootstrap does not register app home controller bundle',
        if (!bootstrap.contains('commentControllerFactory: Get.find<CommentControllerFactory>()')) 'feature bootstrap does not inject comment factory into app home bundle',
        if (!bootstrap.contains('playerController: Get.find<PlayerController>()')) 'feature bootstrap does not inject player controller into app home bundle',
        if (!bootstrap.contains('settingsController: Get.find<SettingsController>()')) 'feature bootstrap does not inject settings controller into app home bundle',
        if (!home.contains('panel: BottomPanelView(')) '${_relativePath(homeFile)} does not compose bottom panel',
        if (!home.contains('playerController: playerController')) '${_relativePath(homeFile)} does not inject player controller into bottom panel',
        if (!home.contains('settingsController: settingsController')) '${_relativePath(homeFile)} does not inject settings controller into bottom panel',
        if (!home.contains('commentControllerFactory: commentControllerFactory')) '${_relativePath(homeFile)} does not inject comment controller factory into bottom panel',
      ];

      expect(
        violations,
        isEmpty,
        reason: '底部播放主面板只能组合播放页局部 widgets，播放、设置和评论工厂必须由首页壳层组合边界注入。',
      );
    });

    test('bottom panel comment page receives playback state boundaries', () {
      final commentFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_comment_page.dart',
      );
      final panelFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart',
      );
      final homeFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/app_home_page_view.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final comment = commentFile.readAsStringSync();
      final panel = panelFile.readAsStringSync();
      final home = homeFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (comment.contains('PlayerController.to')) '${_relativePath(commentFile)} reads player controller globally',
        if (comment.contains('SettingsController.to')) '${_relativePath(commentFile)} reads settings controller globally',
        if (comment.contains('Get.find<CommentControllerFactory>')) '${_relativePath(commentFile)} reads comment controller factory globally',
        if (!comment.contains('required this.playerController')) '${_relativePath(commentFile)} does not receive player controller',
        if (!comment.contains('required this.settingsController')) '${_relativePath(commentFile)} does not receive settings controller',
        if (!comment.contains('required this.commentControllerFactory')) '${_relativePath(commentFile)} does not receive comment controller factory',
        if (!panel.contains('BottomPanelCommentPage(')) '${_relativePath(panelFile)} does not compose comment pages',
        if (panel.contains('Get.find<CommentControllerFactory>')) '${_relativePath(panelFile)} reads comment controller factory globally',
        if (!panel.contains('required this.commentControllerFactory')) '${_relativePath(panelFile)} does not receive comment controller factory',
        if (!panel.contains('commentControllerFactory: commentControllerFactory')) '${_relativePath(panelFile)} does not inject comment controller factory',
        if (!home.contains('final appHomeControllers = Get.find<AppHomeControllerBundle>()')) '${_relativePath(homeFile)} does not resolve app home controller bundle at shell boundary',
        if (home.contains('Get.find<CommentControllerFactory>')) '${_relativePath(homeFile)} reads comment factory globally',
        if (!home.contains('final commentControllerFactory = appHomeControllers.commentControllerFactory')) '${_relativePath(homeFile)} does not receive comment factory from app home bundle',
        if (!bootstrap.contains('commentControllerFactory: Get.find<CommentControllerFactory>()')) 'feature bootstrap does not inject comment factory into app home bundle',
        if (!home.contains('commentControllerFactory: commentControllerFactory')) '${_relativePath(homeFile)} does not inject comment controller factory into bottom panel',
        if (!panel.contains('playerController: playerController')) '${_relativePath(panelFile)} does not inject player controller',
        if (!panel.contains('settingsController: settingsController')) '${_relativePath(panelFile)} does not inject settings controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '底部评论页只能根据当前歌曲展示评论，当前歌曲和面板颜色必须由底部播放面板组合层注入。',
      );
    });

    test('bottom panel header receives playback state boundaries', () {
      final headerFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_header.dart',
      );
      final panelFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart',
      );
      final header = headerFile.readAsStringSync();
      final panel = panelFile.readAsStringSync();
      final violations = <String>[
        if (header.contains('PlayerController.to')) '${_relativePath(headerFile)} reads player controller globally',
        if (header.contains('SettingsController.to')) '${_relativePath(headerFile)} reads settings controller globally',
        if (!header.contains('required this.playerController')) '${_relativePath(headerFile)} does not receive player controller',
        if (!header.contains('required this.settingsController')) '${_relativePath(headerFile)} does not receive settings controller',
        if (!panel.contains('BottomPanelHeader(')) '${_relativePath(panelFile)} does not compose header',
        if (!panel.contains('playerController: playerController')) '${_relativePath(panelFile)} does not inject player controller',
        if (!panel.contains('settingsController: settingsController')) '${_relativePath(panelFile)} does not inject settings controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '底部 header 只展示当前歌曲并切换封面/歌词状态，当前歌曲和面板颜色必须由底部播放面板组合层注入。',
      );
    });

    test('bottom panel mini player receives playback state boundaries', () {
      final miniPlayerFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_mini_player.dart',
      );
      final homeFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/app_home_page_view.dart',
      );
      final miniPlayer = miniPlayerFile.readAsStringSync();
      final home = homeFile.readAsStringSync();
      final violations = <String>[
        if (miniPlayer.contains('PlayerController.to')) '${_relativePath(miniPlayerFile)} reads player controller globally',
        if (miniPlayer.contains('SettingsController.to')) '${_relativePath(miniPlayerFile)} reads settings controller globally',
        if (!miniPlayer.contains('required this.playerController')) '${_relativePath(miniPlayerFile)} does not receive player controller',
        if (!miniPlayer.contains('required this.settingsController')) '${_relativePath(miniPlayerFile)} does not receive settings controller',
        if (!home.contains('BottomPanelHeaderView(')) '${_relativePath(homeFile)} does not compose mini player',
        if (!home.contains('playerController: playerController')) '${_relativePath(homeFile)} does not inject player controller',
        if (!home.contains('settingsController: settingsController')) '${_relativePath(homeFile)} does not inject settings controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '收起态 mini player 只能展示当前播放入口并提交播放意图，当前歌曲、进度和面板颜色必须由首页壳层注入。',
      );
    });

    test('bottom panel background receives visual state boundary', () {
      final backgroundFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_background_layers.dart',
      );
      final panelFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart',
      );
      final background = backgroundFile.readAsStringSync();
      final panel = panelFile.readAsStringSync();
      final violations = <String>[
        if (background.contains('SettingsController.to')) '${_relativePath(backgroundFile)} reads settings controller globally',
        if (!background.contains('required this.settingsController')) '${_relativePath(backgroundFile)} does not receive settings controller',
        if (!panel.contains('BottomPanelBackgroundLayer(')) '${_relativePath(panelFile)} does not compose background layer',
        if (!panel.contains('BottomPanelContentFadeMask(')) '${_relativePath(panelFile)} does not compose content fade mask',
        if (!panel.contains('settingsController: settingsController')) '${_relativePath(panelFile)} does not inject settings controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '底部背景和渐隐遮罩只消费播放面板视觉状态，专辑取色必须由底部播放面板组合层注入。',
      );
    });

    test('bottom panel page indicator receives playback state boundaries', () {
      final indicatorFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_page_indicator.dart',
      );
      final panelFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart',
      );
      final indicator = indicatorFile.readAsStringSync();
      final panel = panelFile.readAsStringSync();
      final violations = <String>[
        if (indicator.contains('PlayerController.to')) '${_relativePath(indicatorFile)} reads player controller globally',
        if (indicator.contains('SettingsController.to')) '${_relativePath(indicatorFile)} reads settings controller globally',
        if (!indicator.contains('required this.playerController')) '${_relativePath(indicatorFile)} does not receive player controller',
        if (!indicator.contains('required this.settingsController')) '${_relativePath(indicatorFile)} does not receive settings controller',
        if (!panel.contains('BottomPanelPageIndicator(')) '${_relativePath(panelFile)} does not compose page indicator',
        if (!panel.contains('playerController: playerController')) '${_relativePath(panelFile)} does not inject player controller',
        if (!panel.contains('settingsController: settingsController')) '${_relativePath(panelFile)} does not inject settings controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '底部页面指示器只能展示播放会话标题和 tab 状态，播放会话和面板颜色必须由底部播放面板组合层注入。',
      );
    });

    test('bottom panel now playing page receives playback interaction boundary', () {
      final nowPlayingFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_now_playing_page.dart',
      );
      final panelFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart',
      );
      final nowPlaying = nowPlayingFile.readAsStringSync();
      final panel = panelFile.readAsStringSync();
      final violations = <String>[
        if (nowPlaying.contains('PlayerController.to')) '${_relativePath(nowPlayingFile)} reads player controller globally',
        if (!nowPlaying.contains('required this.playerController')) '${_relativePath(nowPlayingFile)} does not receive player controller',
        if (!nowPlaying.contains('required this.settingsController')) '${_relativePath(nowPlayingFile)} does not receive settings controller',
        if (!panel.contains('BottomPanelNowPlayingPage(')) '${_relativePath(panelFile)} does not compose now playing page',
        if (!panel.contains('playerController: playerController')) '${_relativePath(panelFile)} does not inject player controller',
        if (!panel.contains('settingsController: settingsController')) '${_relativePath(panelFile)} does not inject settings controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '正在播放页只能处理歌词全屏和封面切换交互，播放交互边界必须由底部播放面板组合层注入。',
      );
    });

    test('bottom panel lyric view receives playback state boundaries', () {
      final lyricFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/lyric_view.dart',
      );
      final nowPlayingFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_now_playing_page.dart',
      );
      final lyric = lyricFile.readAsStringSync();
      final nowPlaying = nowPlayingFile.readAsStringSync();
      final violations = <String>[
        if (lyric.contains('PlayerController.to')) '${_relativePath(lyricFile)} reads player controller globally',
        if (lyric.contains('SettingsController.to')) '${_relativePath(lyricFile)} reads settings controller globally',
        if (!lyric.contains('required this.playerController')) '${_relativePath(lyricFile)} does not receive player controller',
        if (!lyric.contains('required this.settingsController')) '${_relativePath(lyricFile)} does not receive settings controller',
        if (!nowPlaying.contains('LyricView(')) '${_relativePath(nowPlayingFile)} does not compose lyric view',
        if (!nowPlaying.contains('playerController: playerController')) '${_relativePath(nowPlayingFile)} does not inject player controller',
        if (!nowPlaying.contains('settingsController: settingsController')) '${_relativePath(nowPlayingFile)} does not inject settings controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '歌词视图只能展示歌词并提交 seek 意图，歌词状态、播放进度和颜色必须由正在播放页注入。',
      );
    });

    test('bottom panel playback controls receive playback state boundaries', () {
      final controlsFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_playback_controls.dart',
      );
      final nowPlayingFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_now_playing_page.dart',
      );
      final controls = controlsFile.readAsStringSync();
      final nowPlaying = nowPlayingFile.readAsStringSync();
      final controlsStart = controls.indexOf('class BottomPanelPlaybackControls');
      final controlButtonStart = controls.indexOf('class _PlaybackControlButton');
      final backgroundStart = controls.indexOf('class _ButtonBackground');
      final controlsSection = controlsStart >= 0 && controlButtonStart > controlsStart ? controls.substring(controlsStart, controlButtonStart) : '';
      final backgroundSection = backgroundStart >= 0 ? controls.substring(backgroundStart) : '';
      final violations = <String>[
        if (controlsSection.isEmpty) '${_relativePath(controlsFile)} playback controls section is missing',
        if (controlsSection.contains('PlayerController.to')) '${_relativePath(controlsFile)} playback controls read player controller globally',
        if (controlsSection.contains('SettingsController.to')) '${_relativePath(controlsFile)} playback controls read settings controller globally',
        if (backgroundSection.contains('SettingsController.to')) '${_relativePath(controlsFile)} button background reads settings controller globally',
        if (!controlsSection.contains('required this.playerController')) '${_relativePath(controlsFile)} playback controls do not receive player controller',
        if (!controlsSection.contains('required this.settingsController')) '${_relativePath(controlsFile)} playback controls do not receive settings controller',
        if (!backgroundSection.contains('required this.settingsController')) '${_relativePath(controlsFile)} button background does not receive settings controller',
        if (!nowPlaying.contains('BottomPanelPlaybackControls(')) '${_relativePath(nowPlayingFile)} does not compose playback controls',
        if (!nowPlaying.contains('playerController: playerController')) '${_relativePath(nowPlayingFile)} does not inject player controller',
        if (!nowPlaying.contains('settingsController: settingsController')) '${_relativePath(nowPlayingFile)} does not inject settings controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '播放控制按钮组只能展示播放状态并提交播放意图，播放状态和按钮颜色必须由正在播放页注入。',
      );
    });

    test('bottom panel progress bar receives playback state boundaries', () {
      final controlsFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_playback_controls.dart',
      );
      final metadataFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_now_playing_metadata.dart',
      );
      final nowPlayingFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_now_playing_page.dart',
      );
      final controls = controlsFile.readAsStringSync();
      final metadata = metadataFile.readAsStringSync();
      final nowPlaying = nowPlayingFile.readAsStringSync();
      final progressStart = controls.indexOf('class BottomPanelProgressBar');
      final playbackControlsStart = controls.indexOf('class BottomPanelPlaybackControls');
      final progressSection = progressStart >= 0 && playbackControlsStart > progressStart ? controls.substring(progressStart, playbackControlsStart) : '';
      final violations = <String>[
        if (progressSection.isEmpty) '${_relativePath(controlsFile)} progress bar section is missing',
        if (progressSection.contains('PlayerController.to')) '${_relativePath(controlsFile)} progress bar reads player controller globally',
        if (progressSection.contains('SettingsController.to')) '${_relativePath(controlsFile)} progress bar reads settings controller globally',
        if (!progressSection.contains('required this.playerController')) '${_relativePath(controlsFile)} progress bar does not receive player controller',
        if (!progressSection.contains('required this.settingsController')) '${_relativePath(controlsFile)} progress bar does not receive settings controller',
        if (!metadata.contains('BottomPanelProgressBar(')) '${_relativePath(metadataFile)} does not compose progress bar',
        if (!metadata.contains('playerController: playerController')) '${_relativePath(metadataFile)} does not inject player controller',
        if (!metadata.contains('settingsController: settingsController')) '${_relativePath(metadataFile)} does not inject settings controller',
        if (!nowPlaying.contains('BottomPanelNowPlayingMetadata(')) '${_relativePath(nowPlayingFile)} does not compose metadata area',
        if (!nowPlaying.contains('playerController: playerController')) '${_relativePath(nowPlayingFile)} does not inject player controller',
        if (!nowPlaying.contains('settingsController: settingsController')) '${_relativePath(nowPlayingFile)} does not inject settings controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '大封面进度条只展示播放进度并提交 seek 意图，当前歌曲、进度和颜色必须由正在播放页元信息区注入。',
      );
    });

    test('bottom panel now playing metadata receives playback state boundaries', () {
      final metadataFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_now_playing_metadata.dart',
      );
      final nowPlayingFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_now_playing_page.dart',
      );
      final metadata = metadataFile.readAsStringSync();
      final nowPlaying = nowPlayingFile.readAsStringSync();
      final violations = <String>[
        if (metadata.contains('PlayerController.to')) '${_relativePath(metadataFile)} reads player controller globally',
        if (metadata.contains('SettingsController.to')) '${_relativePath(metadataFile)} reads settings controller globally',
        if (!metadata.contains('required this.playerController')) '${_relativePath(metadataFile)} does not receive player controller',
        if (!metadata.contains('required this.settingsController')) '${_relativePath(metadataFile)} does not receive settings controller',
        if (!metadata.contains('_AlbumInfoChip(')) '${_relativePath(metadataFile)} does not compose album chip',
        if (!metadata.contains('_ArtistInfoChip(')) '${_relativePath(metadataFile)} does not compose artist chip',
        if (!metadata.contains('_ArtistRouteChip(')) '${_relativePath(metadataFile)} does not compose artist route chip',
        if (!metadata.contains('playerController: playerController')) '${_relativePath(metadataFile)} does not inject player controller',
        if (!metadata.contains('settingsController: settingsController')) '${_relativePath(metadataFile)} does not inject settings controller',
        if (!nowPlaying.contains('BottomPanelNowPlayingMetadata(')) '${_relativePath(nowPlayingFile)} does not compose metadata area',
        if (!nowPlaying.contains('playerController: playerController')) '${_relativePath(nowPlayingFile)} does not inject player controller',
        if (!nowPlaying.contains('settingsController: settingsController')) '${_relativePath(nowPlayingFile)} does not inject settings controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '正在播放元信息区只展示专辑、歌手和进度入口，当前歌曲和面板颜色必须由正在播放页注入。',
      );
    });

    test('bottom panel artwork widgets receive playback state boundary', () {
      final widgetsFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_artwork_widgets.dart',
      );
      final layerFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_artwork_layer.dart',
      );
      final panelFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart',
      );
      final widgets = widgetsFile.readAsStringSync();
      final layer = layerFile.readAsStringSync();
      final panel = panelFile.readAsStringSync();
      final violations = <String>[
        if (widgets.contains('PlayerController.to')) '${_relativePath(widgetsFile)} reads player controller globally',
        if (!widgets.contains('required this.playerController')) '${_relativePath(widgetsFile)} does not receive player controller',
        if (!layer.contains('BottomPanelCurrentArtworkImage(')) '${_relativePath(layerFile)} does not compose current artwork image',
        if (!layer.contains('BottomPanelArtworkPageViewport(')) '${_relativePath(layerFile)} does not compose artwork page viewport',
        if (!layer.contains('playerController: playerController') && !layer.contains('playerController: widget.playerController')) '${_relativePath(layerFile)} does not inject player controller',
        if (!panel.contains('BottomPanelArtworkTransitionLayer(')) '${_relativePath(panelFile)} does not compose transition layer',
        if (!panel.contains('BottomPanelArtworkPageLayer(')) '${_relativePath(panelFile)} does not compose artwork page layer',
        if (!panel.contains('playerController: playerController')) '${_relativePath(panelFile)} does not inject player controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '封面组件只能展示当前封面和封面队列，当前歌曲、封面队列和歌词计时器操作必须由底部播放面板组合层注入。',
      );
    });

    test('playback metadata key access stays in queue boundary codecs', () {
      const allowedPaths = {
        'lib/features/playback/application/playback_queue_item_adapter.dart',
        'lib/features/playback/application/playback_queue_item_cache_codec.dart',
      };
      final playbackFiles = _dartFiles(Directory('${projectRoot.path}/lib/features/playback'));
      final violations = playbackFiles
          .where(
            (file) => _containsAny(file, const [
              '.metadata[',
              "metadata['",
              'metadata["',
            ]),
          )
          .map(_relativePath)
          .where((path) => !allowedPaths.contains(path))
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'PlaybackQueueItem.metadata 动态键只能在 adapter/cache codec 边界做兼容迁移，播放 mapper、service 和 controller 必须使用显式字段。',
      );
    });

    test('playback mode switch context stays typed', () {
      final contextFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_mode_switch_context.dart',
      );
      final commandFiles = [
        File('${projectRoot.path}/lib/features/playback/player_controller.dart'),
        File(
          '${projectRoot.path}/lib/features/playback/application/playback_mode_command_service.dart',
        ),
        File(
          '${projectRoot.path}/lib/features/playback/application/playback_ui_command_service.dart',
        ),
      ];
      final violations = <String>[
        if (!contextFile.existsSync()) 'playback mode switch context file is missing',
        if (contextFile.existsSync() && !contextFile.readAsStringSync().contains('class PlaybackHeartBeatModeContext')) 'heartbeat switch context type is missing',
        for (final file in commandFiles)
          if (_containsAny(file, const [
            'contextData',
            'dynamic context',
            "['startSongId']",
            '["startSongId"]',
            "['fromPlayAll']",
            '["fromPlayAll"]',
          ]))
            _relativePath(file),
      ];

      expect(
        violations,
        isEmpty,
        reason: '播放模式切换必须用显式心动模式上下文传递启动歌曲和入口来源，不能靠 dynamic Map 或字符串键穿透 UI 命令层。',
      );
    });

    test('playback selection layer stays independent from audio service', () {
      final selectionFiles = _dartFiles(
        Directory('${projectRoot.path}/lib/features/playback'),
      ).where((file) {
        final path = _relativePath(file);
        return path.contains('playback_selection') || path.endsWith('playback_switch_coordinator.dart') || path.endsWith('playback_switch_trigger.dart');
      });

      final violations = selectionFiles
          .where(
            (file) => _containsAny(file, const [
              'package:audio_service/',
              'MediaItem',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'UI selection 表示用户意图，不能依赖 audio_service MediaItem；底层 confirmed 状态才允许进入 audio_service 边界。',
      );
    });

    test('playback queue ownership does not flow back from audio adapter', () {
      final selectionFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_selection_service.dart',
      );
      final synchronizerFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_state_synchronizer.dart',
      );
      final handlerFile = File(
        '${projectRoot.path}/lib/features/playback/application/audio_service_handler.dart',
      );
      final violations = <String>[
        if (_containsAny(selectionFile, const [
          'PlaybackService',
          '_playbackService',
          'handler.queue',
          'mediaItemStream',
          'queueStream',
        ]))
          _relativePath(selectionFile),
        if (_containsAny(synchronizerFile, const [
          'syncQueueState',
          'syncFromQueueState(',
        ]))
          _relativePath(synchronizerFile),
        if (_containsAny(handlerFile, const [
          '.shuffle(',
          'reorderPlayList',
          'buildPlayableQueue',
          'nextIndex(',
          'previousIndex(',
        ]))
          _relativePath(handlerFile),
      ];

      expect(
        violations,
        isEmpty,
        reason: '队列顺序和 selection 只能由 PlaybackQueueService/SelectionService 决定，audio adapter 与 synchronizer 不能反向改写。',
      );
    });

    test('playback controller does not persist queue store directly', () {
      final controllerFile = File(
        '${projectRoot.path}/lib/features/playback/player_controller.dart',
      );
      final stateSyncFile = File(
        '${projectRoot.path}/lib/features/playback/player_state_sync.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final bootstrapContent = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (_containsAny(controllerFile, const [
          'PlaybackQueueStore',
          '_queueStore',
          'savePlaybackMode',
        ]))
          _relativePath(controllerFile),
        if (_containsAny(stateSyncFile, const [
          '_queueStore',
          'savePlaybackMode',
        ]))
          _relativePath(stateSyncFile),
        if (RegExp(r'PlayerController\([\s\S]*?queueStore:').hasMatch(bootstrapContent)) _relativePath(bootstrapFile),
      ];

      expect(
        violations,
        isEmpty,
        reason: 'PlayerController 只发布 UI 播放状态；播放模式持久化必须经 PlaybackQueueService/QueueStore 边界，避免 controller 重复写 restore state。',
      );
    });

    test('playback like control stays behind player controller boundary', () {
      final controlsFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_playback_controls.dart',
      );
      final controllerFile = File(
        '${projectRoot.path}/lib/features/playback/player_controller.dart',
      );
      final stateSyncFile = File(
        '${projectRoot.path}/lib/features/playback/player_state_sync.dart',
      );
      final controls = controlsFile.readAsStringSync();
      final controller = controllerFile.readAsStringSync();
      final stateSync = stateSyncFile.readAsStringSync();
      final violations = <String>[
        if (!controls.contains('playerController.isPlaybackItemLiked(currentSong)')) 'playback controls do not read liked state from injected player boundary',
        if (!controls.contains('playerController.toggleLikeFromPlayback(currentSong)')) 'playback controls do not use injected player like boundary',
        if (controls.contains('PlayerController.to')) '${_relativePath(controlsFile)} reads player controller globally',
        if (controls.contains('UserLibraryController.to.likedSongIds')) '${_relativePath(controlsFile)} reads user library liked ids directly',
        if (controls.contains('toggleLikeStatus(currentSong)')) '${_relativePath(controlsFile)} toggles user library directly',
        if (controls.contains('updatePlaybackQueueItem(')) '${_relativePath(controlsFile)} updates playback queue directly after like toggle',
        if (!controller.contains('_likeToggleInFlightByItem')) 'player controller does not coalesce like toggles',
        if (!stateSync.contains('bool isPlaybackItemLiked(PlaybackQueueItem item)')) 'player state sync does not expose liked state boundary',
        if (!stateSync.contains('Future<void> toggleLikeFromPlayback(PlaybackQueueItem item)')) 'player state sync does not expose like toggle boundary',
      ];

      expect(
        violations,
        isEmpty,
        reason: '播放页喜欢按钮必须经 PlayerController 播放边界读取状态、切换喜欢并同步队列，同一曲目的并发喜欢请求必须在控制器边界合并。',
      );
    });

    test('playback quality control stays behind player controller boundary', () {
      final controlsFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_playback_controls.dart',
      );
      final stateSyncFile = File(
        '${projectRoot.path}/lib/features/playback/player_state_sync.dart',
      );
      final preferencePortFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_preference_port.dart',
      );
      final controls = controlsFile.readAsStringSync();
      final stateSync = stateSyncFile.readAsStringSync();
      final preferencePort = preferencePortFile.readAsStringSync();
      final violations = <String>[
        if (!controls.contains('playerController.isHighQualityPlaybackPreferred()')) 'playback controls do not read quality preference from injected player boundary',
        if (!controls.contains('playerController.toggleHighQualityPlaybackPreference')) 'playback controls do not toggle quality preference through injected player boundary',
        if (controls.contains('PlayerController.to')) '${_relativePath(controlsFile)} reads player controller globally',
        if (controls.contains('SettingsController.to.isHighSoundQualityOpen')) '${_relativePath(controlsFile)} reads high quality setting directly',
        if (controls.contains('SettingsController.to.toggleHighSoundQualityOpen')) '${_relativePath(controlsFile)} toggles high quality setting directly',
        if (!stateSync.contains('bool isHighQualityPlaybackPreferred()')) 'player state sync does not expose quality preference read boundary',
        if (!stateSync.contains('Future<void> toggleHighQualityPlaybackPreference()')) 'player state sync does not expose quality preference toggle boundary',
        if (!preferencePort.contains('toggleHighQuality')) 'playback preference port cannot toggle high quality preference',
      ];

      expect(
        violations,
        isEmpty,
        reason: '播放页音质按钮必须经 PlayerController 播放边界读取和切换播放源偏好，不能在 Widget 内直接读写 SettingsController 的高音质设置。',
      );
    });

    test('cloud and radio pages keep liked ids behind page controllers', () {
      final cloudViewFile = File(
        '${projectRoot.path}/lib/ui/pages/cloud/cloud_drive_view.dart',
      );
      final cloudControllerFile = File(
        '${projectRoot.path}/lib/features/cloud/cloud_page_controller.dart',
      );
      final cloudFactoryFile = File(
        '${projectRoot.path}/lib/features/cloud/cloud_page_controller_factory.dart',
      );
      final radioListViewFile = File(
        '${projectRoot.path}/lib/ui/pages/radio/my_radio_view.dart',
      );
      final radioViewFile = File(
        '${projectRoot.path}/lib/ui/pages/radio/radio_details_view.dart',
      );
      final radioListControllerFile = File(
        '${projectRoot.path}/lib/features/radio/radio_list_controller.dart',
      );
      final radioControllerFile = File(
        '${projectRoot.path}/lib/features/radio/radio_detail_controller.dart',
      );
      final radioFactoryFile = File(
        '${projectRoot.path}/lib/features/radio/radio_controller_factory.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final cloudView = cloudViewFile.readAsStringSync();
      final cloudController = cloudControllerFile.readAsStringSync();
      final cloudFactory = cloudFactoryFile.readAsStringSync();
      final radioListView = radioListViewFile.readAsStringSync();
      final radioView = radioViewFile.readAsStringSync();
      final radioListController = radioListControllerFile.readAsStringSync();
      final radioController = radioControllerFile.readAsStringSync();
      final radioFactory = radioFactoryFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (cloudView.contains('UserLibraryController')) '${_relativePath(cloudViewFile)} reads user library directly',
        if (cloudView.contains('CloudRepository')) '${_relativePath(cloudViewFile)} names cloud repository directly',
        if (cloudView.contains('UserSessionController')) '${_relativePath(cloudViewFile)} reads current user directly',
        if (cloudView.contains('likedSongIds:')) '${_relativePath(cloudViewFile)} passes liked ids from UI',
        if (!cloudView.contains('Get.find<CloudPageControllerFactory>().create()')) '${_relativePath(cloudViewFile)} does not create controller through feature factory',
        if (cloudController.contains('UserLibraryController')) '${_relativePath(cloudControllerFile)} reads user library directly',
        if (!cloudController.contains('required List<int> Function() likedSongIds')) 'cloud controller does not require a lazy liked ids provider',
        if (!cloudController.contains('likedSongIds: _likedSongIds()')) 'cloud controller does not read liked ids at request time',
        if (!cloudController.contains('bool get _hasUserId => _userId.trim().isNotEmpty')) 'cloud controller does not trim-check current user before repository access',
        if (!cloudFactory.contains('CloudPageController create({int pageSize = 30})')) 'cloud controller factory does not create page-local controllers',
        if (!cloudFactory.contains('userId: _currentUserId()')) 'cloud controller factory does not snapshot current user at controller creation',
        if (!cloudFactory.contains('likedSongIds: _likedSongIds')) 'cloud controller factory does not inject liked ids provider',
        if (radioListView.contains('RadioRepository')) '${_relativePath(radioListViewFile)} names radio repository directly',
        if (radioListView.contains('UserSessionController')) '${_relativePath(radioListViewFile)} reads current user directly',
        if (!radioListView.contains('Get.find<RadioControllerFactory>().createList()')) '${_relativePath(radioListViewFile)} does not create list controller through feature factory',
        if (!radioListController.contains('bool get _hasUserId => _userId.trim().isNotEmpty')) 'radio list controller does not trim-check current user before repository access',
        if (radioView.contains('UserLibraryController')) '${_relativePath(radioViewFile)} reads user library directly',
        if (radioView.contains('RadioRepository')) '${_relativePath(radioViewFile)} names radio repository directly',
        if (radioView.contains('UserSessionController')) '${_relativePath(radioViewFile)} reads current user directly',
        if (!radioView.contains('Get.find<RadioControllerFactory>().createDetail(radioId: _radioId)')) '${_relativePath(radioViewFile)} does not create detail controller through feature factory',
        if (radioView.contains('RadioPlaybackQueueItemMapper.fromPrograms')) '${_relativePath(radioViewFile)} maps radio queue items in UI',
        if (!radioView.contains('final queueItems = _controller.queueItems')) '${_relativePath(radioViewFile)} does not read queue items from controller',
        if (radioController.contains('UserLibraryController')) '${_relativePath(radioControllerFile)} reads user library directly',
        if (!radioController.contains('List<PlaybackQueueItem> get queueItems')) 'radio detail controller does not expose queue items',
        if (!radioController.contains('required List<int> Function() likedSongIds')) 'radio detail controller does not require a lazy liked ids provider',
        if (!radioController.contains('likedSongIds: _likedSongIds()')) 'radio detail controller does not derive liked state from lazy provider',
        if (!radioController.contains('bool get _hasUserId => _userId.trim().isNotEmpty')) 'radio detail controller does not trim-check current user before repository access',
        if (!radioFactory.contains('RadioListController createList({int pageSize = 30})')) 'radio controller factory does not create list controllers',
        if (!radioFactory.contains('RadioDetailController createDetail({')) 'radio controller factory does not create detail controllers',
        if (!radioFactory.contains('userId: _currentUserId()')) 'radio controller factory does not snapshot current user at controller creation',
        if (!radioFactory.contains('likedSongIds: _likedSongIds')) 'radio controller factory does not inject liked ids provider',
        if (!bootstrap.contains('CloudPageControllerFactory(')) 'feature bootstrap does not register cloud controller factory',
        if (!bootstrap.contains('RadioControllerFactory(')) 'feature bootstrap does not register radio controller factory',
      ];

      expect(
        violations,
        isEmpty,
        reason: '云盘页和播客页不能在 Widget 内直接拼账号、repository 或喜欢列表；页面本地 controller 应由 feature factory 注入当前账号和喜欢列表 provider。',
      );
    });

    test('radio repository rejects blank account scope', () {
      final repositoryFile = File(
        '${projectRoot.path}/lib/features/radio/radio_repository.dart',
      );
      final repository = repositoryFile.readAsStringSync();
      final violations = <String>[
        if (!repository.contains('bool _isBlankUserId(String userId)')) '${_relativePath(repositoryFile)} does not define a blank user guard',
        if (!repository.contains('if (_isBlankUserId(userId))')) '${_relativePath(repositoryFile)} does not guard user-scoped radio entry points',
        if (!repository.contains('return const DjRadioPage(')) '${_relativePath(repositoryFile)} does not return an empty radio page for blank users',
        if (!repository.contains('return const DjProgramPage(')) '${_relativePath(repositoryFile)} does not return an empty radio program page for blank users',
      ];

      expect(
        violations,
        isEmpty,
        reason: '电台仓库是账号作用域缓存边界，空账号不能读取或写入用户电台缓存，也不能触发远程电台请求。',
      );
    });

    test('cloud repository rejects blank account scope', () {
      final repositoryFile = File(
        '${projectRoot.path}/lib/features/cloud/cloud_repository.dart',
      );
      final repository = repositoryFile.readAsStringSync();
      final violations = <String>[
        if (!repository.contains('bool _isBlankUserId(String userId)')) '${_relativePath(repositoryFile)} does not define a blank user guard',
        if (!repository.contains('if (_isBlankUserId(userId))')) '${_relativePath(repositoryFile)} does not guard user-scoped cloud entry points',
        if (!repository.contains('return const CloudSongPage(')) '${_relativePath(repositoryFile)} does not return an empty cloud page for blank users',
      ];

      expect(
        violations,
        isEmpty,
        reason: '云盘仓库是账号作用域缓存边界，空账号不能读取或写入用户云盘缓存，也不能触发远程云盘请求。',
      );
    });

    test('download page creates local song controllers through feature factory', () {
      final pageFile = File(
        '${projectRoot.path}/lib/ui/pages/download/download_task_page_view.dart',
      );
      final factoryFile = File(
        '${projectRoot.path}/lib/features/download/local_song_list_controller_factory.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final page = pageFile.readAsStringSync();
      final factory = factoryFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (page.contains('MusicDataRepository')) '${_relativePath(pageFile)} names music data repository directly',
        if (page.contains('DownloadRepository')) '${_relativePath(pageFile)} names download repository directly',
        if (!page.contains('Get.find<LocalSongListControllerFactory>().create(origins: origins)')) '${_relativePath(pageFile)} does not create local song controllers through feature factory',
        if (!factory.contains('LocalSongListController create({')) 'local song controller factory does not create page-local controllers',
        if (!factory.contains('musicDataRepository: _musicDataRepository')) 'local song controller factory does not inject music data repository',
        if (!factory.contains('downloadRepository: _downloadRepository')) 'local song controller factory does not inject download repository',
        if (!bootstrap.contains('LocalSongListControllerFactory(')) 'feature bootstrap does not register local song controller factory',
      ];

      expect(
        violations,
        isEmpty,
        reason: '下载页可以拥有 tab 和 controller 生命周期，但不能在 Widget 内直接拼装 MusicDataRepository 或 DownloadRepository。',
      );
    });

    test('download workflow rechecks cancellation before saving local resources', () {
      final workflowFile = File(
        '${projectRoot.path}/lib/features/download/download_repository_workflow.dart',
      );
      final workflow = workflowFile.readAsStringSync();
      final finalCancelCheck = workflow.indexOf('artworkPath: artworkPath');
      final saveResources = workflow.indexOf('final savedResources = await _resourceWriter.saveManagedDownloadResources');
      final violations = <String>[
        if (RegExp(r'return _clearCancelledDownloadedFiles\(').allMatches(workflow).length < 2) '${_relativePath(workflowFile)} does not recheck cancellation after side resource work',
        if (!workflow.contains('Future<Track?> _clearCancelledDownloadedFiles')) '${_relativePath(workflowFile)} does not centralize cancelled file cleanup',
        if (!workflow.contains('await _fileStore.deleteFileIfExists(artworkPath)')) '${_relativePath(workflowFile)} does not delete cancelled artwork file',
        if (!workflow.contains('await _fileStore.deleteFileIfExists(lyricsPath)')) '${_relativePath(workflowFile)} does not delete cancelled lyrics file',
        if (finalCancelCheck < 0 || saveResources < 0 || finalCancelCheck > saveResources) '${_relativePath(workflowFile)} saves resource facts before the final cancellation check',
      ];

      expect(
        violations,
        isEmpty,
        reason: '取消下载可能发生在音频落盘后、封面或歌词处理中；保存 local_resource_entries 前必须再次复核取消状态。',
      );
    });

    test('download workflow preserves local import resource priority', () {
      final workflowFile = File(
        '${projectRoot.path}/lib/features/download/download_repository_workflow.dart',
      );
      final workflow = workflowFile.readAsStringSync();
      final localImportBranch = workflow.indexOf('audioResource.origin == TrackResourceOrigin.localImport');
      final promotion = workflow.indexOf('_resourceWriter.promoteResourcesToManagedDownload');
      final violations = <String>[
        if (localImportBranch < 0) '${_relativePath(workflowFile)} does not branch on local import resources before download promotion',
        if (promotion < 0) '${_relativePath(workflowFile)} does not promote playback cache resources to managed download',
        if (localImportBranch > promotion) '${_relativePath(workflowFile)} can promote local import resources before preserving their origin',
      ];

      expect(
        violations,
        isEmpty,
        reason: '本地导入资源优先级高于正式下载，下载流程不能把 localImport 资源归属覆盖成 managedDownload。',
      );
    });

    test('download resource writer does not promote local import resources', () {
      final writerFile = File(
        '${projectRoot.path}/lib/features/download/application/download_resource_writer.dart',
      );
      final writer = writerFile.readAsStringSync();
      final promotionMethod = writer.indexOf('Future<bool> promoteResourcesToManagedDownload');
      final localImportBranch = writer.indexOf(
        'bundle.audio?.origin == TrackResourceOrigin.localImport',
        promotionMethod,
      );
      final saveManagedAudio = writer.indexOf(
        'origin: TrackResourceOrigin.managedDownload',
        promotionMethod,
      );
      final violations = <String>[
        if (promotionMethod < 0) '${_relativePath(writerFile)} does not expose managed download promotion',
        if (localImportBranch < 0) '${_relativePath(writerFile)} does not guard local import bundle promotion',
        if (saveManagedAudio < 0) '${_relativePath(writerFile)} no longer writes managed download resources',
        if (localImportBranch > saveManagedAudio) '${_relativePath(writerFile)} can save local import audio as managed download before checking origin',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'DownloadResourceWriter 是资源归属写入边界，不能把 localImport bundle 提升成 managedDownload。',
      );
    });

    test('download queue planner skips available local audio resources', () {
      final plannerFile = File(
        '${projectRoot.path}/lib/features/download/application/download_queue_planner.dart',
      );
      final planner = plannerFile.readAsStringSync();
      final violations = <String>[
        if (planner.contains('_isAvailableManagedDownload')) '${_relativePath(plannerFile)} only models managed download availability',
        if (!planner.contains('TrackResourceOrigin.localImport')) '${_relativePath(plannerFile)} does not treat local import audio as already available',
        if (!planner.contains('TrackResourceOrigin.managedDownload')) '${_relativePath(plannerFile)} does not treat managed download audio as already available',
        if (!planner.contains('File(path).existsSync()')) '${_relativePath(plannerFile)} skips indexed resources without checking the file exists',
        if (!planner.contains('track.sourceType == SourceType.local || _isAvailableLocalAudioResource(audioResource)')) '${_relativePath(plannerFile)} does not skip available local audio before queueing',
      ];

      expect(
        violations,
        isEmpty,
        reason: '批量下载规划必须先尊重本地音频事实；已有本地导入或正式下载文件时不应产生无意义排队。',
      );
    });

    test('download entry points reject blank track ids', () {
      final repositoryFile = File(
        '${projectRoot.path}/lib/features/download/download_repository.dart',
      );
      final taskStoreFile = File(
        '${projectRoot.path}/lib/features/download/application/download_task_state_store.dart',
      );
      final plannerFile = File(
        '${projectRoot.path}/lib/features/download/application/download_queue_planner.dart',
      );
      final repository = repositoryFile.readAsStringSync();
      final taskStore = taskStoreFile.readAsStringSync();
      final planner = plannerFile.readAsStringSync();
      final normalizedEntryCount = 'final normalizedTrackId = _normalizedTrackId(trackId);'.allMatches(repository).length;
      final violations = <String>[
        if (!repository.contains('bool _isBlankTrackId(String trackId)')) '${_relativePath(repositoryFile)} does not define a blank track guard',
        if (!repository.contains('String _normalizedTrackId(String trackId)')) '${_relativePath(repositoryFile)} does not define a normalized track id helper',
        if (normalizedEntryCount < 6) '${_relativePath(repositoryFile)} does not normalize all public task entry points',
        if (!taskStore.contains('trackId: normalizedTrackId')) '${_relativePath(taskStoreFile)} can still write raw track ids into download_tasks',
        if (!planner.contains('final candidateIds = _candidateTrackIds(trackIds);')) '${_relativePath(plannerFile)} does not normalize batch candidates before lookup',
        if (!planner.contains('_normalizedTrackId(task.trackId)')) '${_relativePath(plannerFile)} does not normalize active task ids before matching',
      ];

      expect(
        violations,
        isEmpty,
        reason: '下载任务入口必须先规范化曲目 id，再拒绝空白曲目 id；异常 id 不能创建重复 download_tasks，也不能绕过批量资源或 active task 查询。',
      );
    });

    test('setting sections receive settings controller boundary', () {
      final pageFile = File(
        '${projectRoot.path}/lib/ui/pages/settings/setting_page.dart',
      );
      final sectionsFile = File(
        '${projectRoot.path}/lib/ui/pages/settings/widgets/settings_sections.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final page = pageFile.readAsStringSync();
      final sections = sectionsFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (!page.contains('final SettingsPageControllerBundle _controllers = Get.find<SettingsPageControllerBundle>()')) '${_relativePath(pageFile)} does not resolve settings page controller bundle at page boundary',
        if (page.contains('Get.find<SettingsController>')) '${_relativePath(pageFile)} reads settings controller globally',
        if (!page.contains('final _settingsController = _controllers.settingsController')) '${_relativePath(pageFile)} does not receive settings controller from settings page bundle',
        if (!bootstrap.contains('Get.put<SettingsPageControllerBundle>')) 'feature bootstrap does not register settings page controller bundle',
        if (!bootstrap.contains('settingsController: Get.find<SettingsController>()')) 'feature bootstrap does not inject settings controller into settings page bundle',
        if (!page.contains('settingsController: _settingsController')) '${_relativePath(pageFile)} does not inject settings controller into sections',
        if (!sections.contains('required this.settingsController')) '${_relativePath(sectionsFile)} does not receive settings controller',
        if (sections.contains('SettingsController.to')) '${_relativePath(sectionsFile)} reads settings controller globally',
        if (!sections.contains('settingsController.isHighSoundQualityOpen.value')) '${_relativePath(sectionsFile)} does not read quality preference through injected controller',
        if (!sections.contains('settingsController.toggleHighSoundQualityOpen()')) '${_relativePath(sectionsFile)} does not toggle quality preference through injected controller',
        if (!sections.contains('settingsController.isGradientBackground.value')) '${_relativePath(sectionsFile)} does not read gradient preference through injected controller',
        if (!sections.contains('settingsController.toggleGradientBackground()')) '${_relativePath(sectionsFile)} does not toggle gradient preference through injected controller',
        if (!sections.contains('settingsController.isRoundAlbumOpen.value')) '${_relativePath(sectionsFile)} does not read round album preference through injected controller',
        if (!sections.contains('settingsController.toggleRoundAlbumOpen()')) '${_relativePath(sectionsFile)} does not toggle round album preference through injected controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '设置页分组只能展示设置项并提交开关意图，设置状态边界必须由设置页主文件注入。',
      );
    });

    test('cache analysis page receives service through feature controller factory', () {
      final pageFile = File(
        '${projectRoot.path}/lib/ui/pages/settings/cache_analysis_page.dart',
      );
      final controllerFile = File(
        '${projectRoot.path}/lib/features/settings/cache_analysis_controller.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final page = pageFile.readAsStringSync();
      final controller = controllerFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (page.contains('Get.find<CacheAnalysisService>')) '${_relativePath(pageFile)} reads cache service directly',
        if (page.contains('CacheAnalysisService')) '${_relativePath(pageFile)} names cache service directly',
        if (!page.contains('Get.find<CacheAnalysisControllerFactory>().create()')) '${_relativePath(pageFile)} does not create controller through feature factory',
        if (!controller.contains('class CacheAnalysisControllerFactory')) '${_relativePath(controllerFile)} does not define cache analysis controller factory',
        if (!controller.contains('required CacheAnalysisService service')) '${_relativePath(controllerFile)} does not receive cache analysis service through constructor',
        if (!bootstrap.contains('CacheAnalysisControllerFactory(')) 'feature bootstrap does not register cache analysis controller factory',
      ];

      expect(
        violations,
        isEmpty,
        reason: '缓存分析页可以处理确认弹窗和 Toast，但分析/清理服务必须由 feature controller factory 注入。',
      );
    });

    test('coverflow debug page receives playback boundary from settings page', () {
      final pageFile = File(
        '${projectRoot.path}/lib/ui/pages/settings/setting_page.dart',
      );
      final sectionsFile = File(
        '${projectRoot.path}/lib/ui/pages/settings/widgets/settings_sections.dart',
      );
      final demoFile = File(
        '${projectRoot.path}/lib/ui/pages/debug/coverflow_demo_page_view.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final page = pageFile.readAsStringSync();
      final sections = sectionsFile.readAsStringSync();
      final demo = demoFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (!page.contains('final SettingsPageControllerBundle _controllers = Get.find<SettingsPageControllerBundle>()')) '${_relativePath(pageFile)} does not resolve settings page controller bundle at page boundary',
        if (page.contains('Get.find<PlayerController>')) '${_relativePath(pageFile)} reads playback controller globally',
        if (!page.contains('final _playerController = _controllers.playerController')) '${_relativePath(pageFile)} does not receive playback controller from settings page bundle',
        if (!bootstrap.contains('playerController: Get.find<PlayerController>()')) 'feature bootstrap does not inject playback controller into settings page bundle',
        if (!page.contains('playerController: _playerController')) '${_relativePath(pageFile)} does not inject playback controller into setting sections',
        if (!sections.contains('required this.playerController')) '${_relativePath(sectionsFile)} does not receive playback controller',
        if (!sections.contains('playerController: playerController')) '${_relativePath(sectionsFile)} does not pass playback controller into CoverFlow demo',
        if (!demo.contains('required this.playerController')) '${_relativePath(demoFile)} does not receive playback controller',
        if (!demo.contains('widget.playerController')) '${_relativePath(demoFile)} does not read playback controller from widget boundary',
        if (demo.contains('PlayerController.to')) '${_relativePath(demoFile)} reads playback controller globally',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'CoverFlow 调试页只能消费设置页边界注入的播放队列，不能在实验性 UI 内部读取全局容器。',
      );
    });

    test('user profile page creates controller through feature factory', () {
      final pageFile = File(
        '${projectRoot.path}/lib/ui/pages/user/user_setting_view.dart',
      );
      final factoryFile = File(
        '${projectRoot.path}/lib/features/user/user_profile_controller_factory.dart',
      );
      final controllerFile = File(
        '${projectRoot.path}/lib/features/user/user_profile_controller.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final page = pageFile.readAsStringSync();
      final factory = factoryFile.readAsStringSync();
      final controller = controllerFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (page.contains('UserRepository')) '${_relativePath(pageFile)} names user repository directly',
        if (page.contains('UserSessionController')) '${_relativePath(pageFile)} reads current user directly',
        if (page.contains('AuthController')) '${_relativePath(pageFile)} reads auth controller directly',
        if (!page.contains('Get.find<UserProfileControllerFactory>().create()')) '${_relativePath(pageFile)} does not create profile controller through feature factory',
        if (!page.contains('_controller.logoutCurrentUser()')) '${_relativePath(pageFile)} does not submit logout through profile controller',
        if (!factory.contains('UserProfileController create()')) 'user profile controller factory does not create page-local controllers',
        if (!factory.contains('userId: _currentUserId()')) 'user profile controller factory does not snapshot current user at controller creation',
        if (!factory.contains('repository: _repository')) 'user profile controller factory does not inject user repository',
        if (!factory.contains('required Future<void> Function() logoutCurrentUser')) 'user profile controller factory does not receive logout boundary',
        if (!factory.contains('logoutCurrentUser: _logoutCurrentUser')) 'user profile controller factory does not inject logout boundary',
        if (!controller.contains('userId = _normalizedUserId(userId)')) 'user profile controller does not normalize the injected user id',
        if (!controller.contains('static bool _isSignedInUserId(String userId)')) 'user profile controller does not centralize signed-in account checks',
        if (!bootstrap.contains('UserProfileControllerFactory(')) 'feature bootstrap does not register user profile controller factory',
        if (!bootstrap.contains('currentUserId: () => Get.find<UserSessionController>().userInfo.value.userId')) 'feature bootstrap does not inject current user provider',
        if (!bootstrap.contains('logoutCurrentUser: () => Get.find<AuthController>().logoutCurrentUser()')) 'feature bootstrap does not inject auth logout boundary',
      ];

      expect(
        violations,
        isEmpty,
        reason: '用户资料页可以拥有页面 controller 生命周期，但不能在 Widget 内直接拼装 UserRepository、当前账号上下文或 AuthController。',
      );
    });

    test('playlist page creates controller through feature factory', () {
      final pageFile = File(
        '${projectRoot.path}/lib/ui/pages/playlist/playlist_page_view.dart',
      );
      final factoryFile = File(
        '${projectRoot.path}/lib/features/playlist/playlist_page_controller_factory.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final page = pageFile.readAsStringSync();
      final factory = factoryFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (page.contains('PlaylistRepository')) '${_relativePath(pageFile)} names playlist repository directly',
        if (page.contains('UserLibraryController')) '${_relativePath(pageFile)} reads user library directly',
        if (page.contains('UserSessionController')) '${_relativePath(pageFile)} reads current user directly',
        if (page.contains('likedSongIds:')) '${_relativePath(pageFile)} passes liked ids from UI',
        if (page.contains('currentUserId:')) '${_relativePath(pageFile)} passes current user from UI',
        if (page.contains('PlaylistArtworkColorService()')) '${_relativePath(pageFile)} creates artwork color service directly',
        if (!page.contains('final controllerFactory = Get.find<PlaylistPageControllerFactory>()')) '${_relativePath(pageFile)} does not resolve playlist factory at page boundary',
        if (!page.contains('_controller = controllerFactory.create()')) '${_relativePath(pageFile)} does not create playlist controller through feature factory',
        if (!page.contains('_artworkColorService = controllerFactory.createArtworkColorService()')) '${_relativePath(pageFile)} does not receive artwork color service through feature factory',
        if (!factory.contains('PlaylistPageController create()')) 'playlist page controller factory does not create page controllers',
        if (!factory.contains('PlaylistArtworkColorService createArtworkColorService()')) 'playlist page controller factory does not expose artwork color service',
        if (!factory.contains('required PlaylistArtworkColorService artworkColorService')) 'playlist page controller factory does not receive artwork color service',
        if (!factory.contains('likedSongIds: _likedSongIds')) 'playlist page controller factory does not inject liked ids provider',
        if (!factory.contains('currentUserId: _currentUserId')) 'playlist page controller factory does not inject current user provider',
        if (!factory.contains('repository: _repository')) 'playlist page controller factory does not inject playlist repository',
        if (!bootstrap.contains('Get.put<PlaylistArtworkColorService>')) 'feature bootstrap does not register playlist artwork color service',
        if (!bootstrap.contains('PlaylistPageControllerFactory(')) 'feature bootstrap does not register playlist page controller factory',
      ];

      expect(
        violations,
        isEmpty,
        reason: '歌单页可以拥有加载、播放和取色 UI 状态，但不能在 Widget 内直接拼装 PlaylistRepository、喜欢列表、当前账号上下文或本地图片缓存服务。',
      );
    });

    test('playlist repository trims current user before subscription cache access', () {
      final repositoryFile = File('${projectRoot.path}/lib/features/playlist/playlist_repository.dart');
      final repository = repositoryFile.readAsStringSync();
      final violations = <String>[
        if (!repository.contains('String? _normalizedCurrentUserId(String? currentUserId)')) '${_relativePath(repositoryFile)} does not define a current user normalizer',
        if (!repository.contains('currentUserId?.trim()')) '${_relativePath(repositoryFile)} does not trim current user ids',
        if (!repository.contains('if (scopedUserId != null)')) '${_relativePath(repositoryFile)} does not guard subscription writes with normalized user ids',
        if (!repository.contains('loadPlaylistSubscriptionState(')) '${_relativePath(repositoryFile)} does not load subscription state through the user scoped boundary',
        if (!repository.contains('_isCurrentUserPlaylist(index.creatorUserId, currentUserId)')) '${_relativePath(repositoryFile)} does not use normalized current user for ownership checks',
      ];

      expect(
        violations,
        isEmpty,
        reason: '歌单订阅状态是账号作用域数据，PlaylistRepository 必须先 trim 当前账号，空白账号不能读写订阅缓存或被判断成“我的歌单”。',
      );
    });

    test('image cache repository is injected through bootstrap boundaries', () {
      final repositoryBootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/repository_bootstrap.dart',
      );
      final presentationBootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/presentation_bootstrap.dart',
      );
      final featureBootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final localImageCacheServiceFile = File(
        '${projectRoot.path}/lib/ui/services/local_image_cache_service.dart',
      );
      final playbackArtworkPresenterFile = File(
        '${projectRoot.path}/lib/features/playback/playback_artwork_presenter.dart',
      );
      final playlistArtworkColorServiceFile = File(
        '${projectRoot.path}/lib/features/playlist/playlist_artwork_color_service.dart',
      );
      final repositoryBootstrap = repositoryBootstrapFile.readAsStringSync();
      final presentationBootstrap = presentationBootstrapFile.readAsStringSync();
      final featureBootstrap = featureBootstrapFile.readAsStringSync();
      final localImageCacheService = localImageCacheServiceFile.readAsStringSync();
      final playbackArtworkPresenter = playbackArtworkPresenterFile.readAsStringSync();
      final playlistArtworkColorService = playlistArtworkColorServiceFile.readAsStringSync();
      final violations = <String>[
        if (!repositoryBootstrap.contains('final localImageCacheRepository = LocalImageCacheRepository(dio: sharedDio)')) 'repository bootstrap does not create local image cache repository with shared Dio',
        if (!repositoryBootstrap.contains('Get.put<LocalImageCacheRepository>')) 'repository bootstrap does not register local image cache repository',
        if (!presentationBootstrap.contains('LocalImageCacheService.configure(')) 'presentation bootstrap does not configure UI image cache service',
        if (!presentationBootstrap.contains('imageCacheRepository: Get.find<LocalImageCacheRepository>()')) 'presentation bootstrap does not inject image cache repository into playback artwork presenter',
        if (!featureBootstrap.contains('imageCacheRepository: Get.find<LocalImageCacheRepository>()')) 'feature bootstrap does not inject image cache repository into playlist artwork color service',
        if (localImageCacheService.contains('LocalImageCacheRepository()')) '${_relativePath(localImageCacheServiceFile)} creates image cache repository directly',
        if (playbackArtworkPresenter.contains('LocalImageCacheRepository()')) '${_relativePath(playbackArtworkPresenterFile)} creates image cache repository directly',
        if (playlistArtworkColorService.contains('LocalImageCacheRepository()')) '${_relativePath(playlistArtworkColorServiceFile)} creates image cache repository directly',
        if (!playbackArtworkPresenter.contains('required LocalImageCacheRepository imageCacheRepository')) 'playback artwork presenter does not require injected image cache repository',
        if (!playlistArtworkColorService.contains('required LocalImageCacheRepository imageCacheRepository')) 'playlist artwork color service does not require injected image cache repository',
      ];

      expect(
        violations,
        isEmpty,
        reason: '本地图片展示缓存属于 AppStorage 视觉缓存边界，仓库生命周期必须由 repository bootstrap 收口，播放和歌单展示服务只能接收注入实例。',
      );
    });

    test('playlist page opens playback panel through shell boundary', () {
      final pageFile = File(
        '${projectRoot.path}/lib/ui/pages/playlist/playlist_page_view.dart',
      );
      final page = pageFile.readAsStringSync();
      final violations = <String>[
        if (!page.contains('final ShellController _shellController = Get.find<ShellController>()')) '${_relativePath(pageFile)} does not resolve shell controller at page boundary',
        if (!page.contains('void _openPlaybackPanel()')) '${_relativePath(pageFile)} does not centralize playback panel opening',
        if (!page.contains('_shellController.jumpBottomPanelToPage(0)')) '${_relativePath(pageFile)} does not jump bottom panel through injected shell controller',
        if (!page.contains('_shellController.openBottomPanel()')) '${_relativePath(pageFile)} does not open bottom panel through injected shell controller',
        if (page.contains('ShellController.to')) '${_relativePath(pageFile)} reads shell controller globally',
      ];

      expect(
        violations,
        isEmpty,
        reason: '歌单页可以在播放歌曲时打开底部播放面板，但 shell 面板操作必须从页面边界注入，不能在播放动作里读取全局 shell。',
      );
    });

    test('comment widgets create controllers through feature factory', () {
      final commentWidgetFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/comment/comment_widget.dart',
      );
      final commentItemFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/comment/comment_item_view.dart',
      );
      final floorSheetFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/comment/floor_comment_sheet.dart',
      );
      final factoryFile = File(
        '${projectRoot.path}/lib/features/comment/comment_controller_factory.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final commentWidget = commentWidgetFile.readAsStringSync();
      final commentItem = commentItemFile.readAsStringSync();
      final floorSheet = floorSheetFile.readAsStringSync();
      final factory = factoryFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (commentWidget.contains('CommentRepository')) '${_relativePath(commentWidgetFile)} names comment repository directly',
        if (commentItem.contains('CommentRepository')) '${_relativePath(commentItemFile)} names comment repository directly',
        if (floorSheet.contains('CommentRepository')) '${_relativePath(floorSheetFile)} names comment repository directly',
        if (commentWidget.contains('Get.find<CommentControllerFactory>')) '${_relativePath(commentWidgetFile)} reads comment controller factory globally',
        if (commentItem.contains('Get.find<CommentControllerFactory>')) '${_relativePath(commentItemFile)} reads comment controller factory globally',
        if (floorSheet.contains('Get.find<CommentControllerFactory>')) '${_relativePath(floorSheetFile)} reads comment controller factory globally',
        if (!commentWidget.contains('required this.controllerFactory')) '${_relativePath(commentWidgetFile)} does not receive comment controller factory',
        if (!commentWidget.contains('widget.controllerFactory.createList(')) '${_relativePath(commentWidgetFile)} does not create list controller through injected feature factory',
        if (!commentWidget.contains('controllerFactory: widget.controllerFactory')) '${_relativePath(commentWidgetFile)} does not inject comment factory into comment items',
        if (!commentItem.contains('required this.controllerFactory')) '${_relativePath(commentItemFile)} does not receive comment controller factory',
        if (!commentItem.contains('widget.controllerFactory.createFloor(')) '${_relativePath(commentItemFile)} does not create floor controller through injected feature factory',
        if (!commentItem.contains('widget.controllerFactory.createItem(')) '${_relativePath(commentItemFile)} does not create item controller through injected feature factory',
        if (!commentItem.contains('controllerFactory: widget.controllerFactory')) '${_relativePath(commentItemFile)} does not inject comment factory into nested replies',
        if (!floorSheet.contains('required this.controllerFactory')) '${_relativePath(floorSheetFile)} does not receive comment controller factory',
        if (!floorSheet.contains('widget.controllerFactory.createFloor(')) '${_relativePath(floorSheetFile)} does not create floor controller through injected feature factory',
        if (!floorSheet.contains('widget.controllerFactory.createReplySheet(')) '${_relativePath(floorSheetFile)} does not create reply sheet controller through injected feature factory',
        if (!factory.contains('CommentListController createList({')) 'comment controller factory does not create list controllers',
        if (!factory.contains('FloorCommentController createFloor({')) 'comment controller factory does not create floor controllers',
        if (!factory.contains('CommentItemController createItem({')) 'comment controller factory does not create item controllers',
        if (!factory.contains('ReplySheetController createReplySheet({')) 'comment controller factory does not create reply sheet controllers',
        if (!factory.contains('repository: _repository')) 'comment controller factory does not inject comment repository',
        if (!bootstrap.contains('CommentControllerFactory(')) 'feature bootstrap does not register comment controller factory',
      ];

      expect(
        violations,
        isEmpty,
        reason: '评论列表、评论项和楼层回复组件可以拥有页面 controller 生命周期，但不能在 Widget 内直接拼装 CommentRepository。',
      );
    });

    test('UI does not assemble repositories or account scoped request context', () {
      final violations = <String>[];
      final repositoryLookupPattern = RegExp(r'Get\.find<[^>]*Repository>');
      final uiFiles = [
        ..._dartFiles(Directory('${projectRoot.path}/lib/ui/pages')),
        ..._dartFiles(Directory('${projectRoot.path}/lib/ui/widgets')),
      ];
      for (final file in uiFiles) {
        final content = file.readAsStringSync();
        final path = _relativePath(file);
        if (repositoryLookupPattern.hasMatch(content)) {
          violations.add('$path looks up a repository from UI');
        }
        if (content.contains('UserSessionController')) {
          violations.add('$path reads current user from UI');
        }
        if (content.contains('Get.find<UserLibraryController>')) {
          violations.add('$path reads user library from UI');
        }
        if (content.contains('likedSongIds:')) {
          violations.add('$path passes liked song ids from UI');
        }
        if (content.contains('currentUserId:')) {
          violations.add('$path passes current user id from UI');
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'UI 只能表达用户意图和展示状态，repository、当前账号和喜欢歌曲上下文必须由 controller、feature factory 或 bootstrap 注入。',
      );
    });

    test('top search panel keeps search context behind controller boundary', () {
      final topPanelFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/widgets/search/top_panel_view.dart',
      );
      final homeFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/app_home_page_view.dart',
      );
      final controllerFile = File(
        '${projectRoot.path}/lib/features/search/search_panel_controller.dart',
      );
      final repositoryFile = File(
        '${projectRoot.path}/lib/features/search/search_repository.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final topPanel = topPanelFile.readAsStringSync();
      final home = homeFile.readAsStringSync();
      final controller = controllerFile.readAsStringSync();
      final repository = repositoryFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (topPanel.contains('UserLibraryController')) '${_relativePath(topPanelFile)} reads user library directly',
        if (topPanel.contains('UserSessionController')) '${_relativePath(topPanelFile)} reads user session directly',
        if (topPanel.contains('likedSongIds:')) '${_relativePath(topPanelFile)} passes liked ids from UI',
        if (topPanel.contains('currentUserId:')) '${_relativePath(topPanelFile)} passes current user from UI',
        if (topPanel.contains('ShellController.to')) '${_relativePath(topPanelFile)} reads shell controller globally',
        if (topPanel.contains('Get.find<SearchPanelController>')) '${_relativePath(topPanelFile)} reads search controller globally',
        if (topPanel.contains('Get.find<PlayerController>')) '${_relativePath(topPanelFile)} reads player controller globally',
        if (!topPanel.contains('required this.shellController')) '${_relativePath(topPanelFile)} does not receive shell controller',
        if (!topPanel.contains('required this.searchController')) '${_relativePath(topPanelFile)} does not receive search controller',
        if (!topPanel.contains('required this.playerController')) '${_relativePath(topPanelFile)} does not receive player controller',
        if (!topPanel.contains('widget.searchController.search(keyword)')) '${_relativePath(topPanelFile)} does not search through controller keyword boundary',
        if (!home.contains('TopPanelView(')) '${_relativePath(homeFile)} does not compose top panel',
        if (!home.contains('shellController: controller')) '${_relativePath(homeFile)} does not inject shell controller',
        if (!home.contains('searchController: searchController')) '${_relativePath(homeFile)} does not inject search controller',
        if (!home.contains('playerController: playerController')) '${_relativePath(homeFile)} does not inject player controller',
        if (!controller.contains('required List<int> Function() likedSongIds')) 'search controller does not require liked ids provider',
        if (!controller.contains('required String Function() currentUserId')) 'search controller does not require current user provider',
        if (controller.contains('List<int> Function()? likedSongIds')) 'search controller allows missing liked ids provider',
        if (controller.contains('String Function()? currentUserId')) 'search controller allows missing current user provider',
        if (controller.contains('_emptyLikedSongIds')) 'search controller keeps an empty liked ids fallback',
        if (controller.contains('_emptyCurrentUserId')) 'search controller keeps an empty current user fallback',
        if (controller.contains('required List<int> likedSongIds')) 'search method still requires liked ids per call',
        if (controller.contains('required String currentUserId')) 'search method still requires current user per call',
        if (!controller.contains('_normalizedCurrentUserId(_currentUserIdProvider())')) 'search controller does not normalize injected current user before building search context',
        if (!repository.contains('String? _normalizedCurrentUserId(String currentUserId)')) 'search repository does not define a current user normalizer',
        if (!repository.contains('final scopedUserId = _normalizedCurrentUserId(currentUserId)')) 'search repository does not normalize current user before user playlist cache access',
        if (repository.contains('currentUserId.isEmpty')) 'search repository still checks raw current user emptiness',
        if (!bootstrap.contains('likedSongIds: () => Get.find<UserLibraryController>().likedSongIds.toList()')) 'feature bootstrap does not inject liked ids provider',
        if (!bootstrap.contains('currentUserId: () => Get.find<UserSessionController>().userInfo.value.userId')) 'feature bootstrap does not inject current user provider',
      ];

      expect(
        violations,
        isEmpty,
        reason: '顶部搜索 Widget 只提交关键词；账号和喜欢歌曲上下文必须由 SearchPanelController 的注入 provider 读取，避免 UI 拼搜索请求上下文。',
      );
    });

    test('shell body passes home shell boundary to local widgets', () {
      final homeFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/app_home_page_view.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final bodyFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/app_body_page_view.dart',
      );
      final home = homeFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final body = bodyFile.readAsStringSync();
      final drawerStart = body.indexOf('class DrawerMainScreenView');
      final menuStart = body.indexOf('class MenuView');
      final drawerSection = drawerStart >= 0 && menuStart > drawerStart ? body.substring(drawerStart, menuStart) : '';
      final menuSection = menuStart >= 0 ? body.substring(menuStart) : '';
      final violations = <String>[
        if (drawerSection.isEmpty) '${_relativePath(bodyFile)} drawer main screen section is missing',
        if (body.contains('HomeShellController.to')) '${_relativePath(bodyFile)} reads home shell globally',
        if (drawerSection.contains('HomeShellController.to')) '${_relativePath(bodyFile)} drawer main screen reads home shell globally',
        if (menuSection.contains('HomeShellController.to')) '${_relativePath(bodyFile)} menu view reads home shell globally',
        if (!body.contains('final homeShellController = HomeShellScope.of(context)')) '${_relativePath(bodyFile)} does not read home shell from local scope',
        if (!home.contains('final appHomeControllers = Get.find<AppHomeControllerBundle>()')) '${_relativePath(homeFile)} does not resolve app home controller bundle at shell boundary',
        if (home.contains('Get.find<HomeShellController>')) '${_relativePath(homeFile)} reads home shell controller globally',
        if (!home.contains('final homeShellController = appHomeControllers.homeShellController')) '${_relativePath(homeFile)} does not receive home shell controller from app home bundle',
        if (!bootstrap.contains('homeShellController: Get.find<HomeShellController>()')) 'feature bootstrap does not inject home shell controller into app home bundle',
        if (!home.contains('HomeShellScope(')) '${_relativePath(homeFile)} does not provide home shell scope',
        if (!home.contains('homeShellController: homeShellController')) '${_relativePath(homeFile)} does not inject home shell into scope',
        if (!body.contains('MenuView(homeShellController: homeShellController)')) '${_relativePath(bodyFile)} does not inject home shell into menu',
        if (!body.contains('DrawerMainScreenView(')) '${_relativePath(bodyFile)} does not compose drawer main screen',
        if (!body.contains('homeShellController: homeShellController')) '${_relativePath(bodyFile)} does not inject home shell into main screen',
        if (!drawerSection.contains('required this.homeShellController')) '${_relativePath(bodyFile)} drawer main screen does not receive home shell controller',
        if (!menuSection.contains('required this.homeShellController')) '${_relativePath(bodyFile)} menu view does not receive home shell controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '首页壳层负责读取 HomeShellController 并通过局部 scope 传给路由子树，主体页、抽屉主屏幕和菜单不能各自读取全局容器。',
      );
    });

    test('personal page receives home controllers from shell body', () {
      final bodyFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/app_body_page_view.dart',
      );
      final pageFile = File(
        '${projectRoot.path}/lib/ui/pages/user/personal_page.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final body = bodyFile.readAsStringSync();
      final page = pageFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (page.contains('RecommendationController.to')) '${_relativePath(pageFile)} reads recommendation controller globally',
        if (page.contains('UserLibraryController.to')) '${_relativePath(pageFile)} reads user library controller globally',
        if (page.contains('RecentPlaybackController.to')) '${_relativePath(pageFile)} reads recent playback controller globally',
        if (page.contains('Get.find<PlayerController>')) '${_relativePath(pageFile)} reads player controller globally',
        if (body.contains('Get.find<UserLibraryController>')) '${_relativePath(bodyFile)} reads user library controller directly',
        if (!page.contains('required this.recommendationController')) '${_relativePath(pageFile)} does not receive recommendation controller',
        if (!page.contains('required this.userLibraryController')) '${_relativePath(pageFile)} does not receive user library controller',
        if (!page.contains('required this.recentPlaybackController')) '${_relativePath(pageFile)} does not receive recent playback controller',
        if (!page.contains('required this.playerController')) '${_relativePath(pageFile)} does not receive player controller',
        if (!page.contains('required this.shellController')) '${_relativePath(pageFile)} does not receive shell controller',
        if (!body.contains('final personalHomeControllers = Get.find<PersonalHomeControllerBundle>()')) '${_relativePath(bodyFile)} does not resolve personal home controller bundle at shell body boundary',
        if (!body.contains('personalHomeControllers: personalHomeControllers')) '${_relativePath(bodyFile)} does not inject personal home controller bundle',
        if (!bootstrap.contains('Get.put<PersonalHomeControllerBundle>')) 'feature bootstrap does not register personal home controller bundle',
        if (!bootstrap.contains('userLibraryController: Get.find<UserLibraryController>()')) 'feature bootstrap does not inject user library controller into personal home bundle',
        if (!body.contains('PersonalPageView(')) '${_relativePath(bodyFile)} does not compose personal page',
        if (!body.contains('recommendationController: personalHomeControllers.recommendationController')) '${_relativePath(bodyFile)} does not inject recommendation controller',
        if (!body.contains('userLibraryController: personalHomeControllers.userLibraryController')) '${_relativePath(bodyFile)} does not inject user library controller',
        if (!body.contains('recentPlaybackController: personalHomeControllers.recentPlaybackController')) '${_relativePath(bodyFile)} does not inject recent playback controller',
        if (!body.contains('playerController: personalHomeControllers.playerController')) '${_relativePath(bodyFile)} does not inject player controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '个人首页主文件只负责布局模式分发，推荐、资料库、播放和最近播放控制器必须由首页主体组合层注入。',
      );
    });

    test('explore page keeps playlist playback resolution behind controller', () {
      final pageFile = File(
        '${projectRoot.path}/lib/ui/pages/explore/explore_page.dart',
      );
      final controllerFile = File(
        '${projectRoot.path}/lib/features/explore/explore_page_controller.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final page = pageFile.readAsStringSync();
      final controller = controllerFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final helperStart = page.indexOf('Future<void> _playPlaylistSummary');
      final pageClassStart = page.indexOf('class ExplorePageView');
      final helperSection = helperStart >= 0 && pageClassStart > helperStart ? page.substring(helperStart, pageClassStart) : '';
      final playerLookupCount = 'Get.find<PlayerController>'.allMatches(page).length;
      final violations = <String>[
        if (page.contains('UserLibraryController')) '${_relativePath(pageFile)} reads liked ids directly',
        if (page.contains('PlaylistRepository')) '${_relativePath(pageFile)} resolves playlist data directly',
        if (page.contains('fetchPlaylistIndex(')) '${_relativePath(pageFile)} fetches playlist index directly',
        if (page.contains('fetchPlaylistSongs(')) '${_relativePath(pageFile)} fetches playlist songs directly',
        if (helperSection.isEmpty) '${_relativePath(pageFile)} playlist playback helper is missing',
        if (helperSection.contains('Get.find<PlayerController>')) '${_relativePath(pageFile)} playlist playback helper reads player controller globally',
        if (playerLookupCount != 1) '${_relativePath(pageFile)} should resolve player controller once at page boundary, found $playerLookupCount',
        if (!helperSection.contains('PlayerController playerController')) '${_relativePath(pageFile)} playlist playback helper does not receive player controller',
        if (!page.contains('final playerController = Get.find<PlayerController>()')) '${_relativePath(pageFile)} does not resolve player controller at page boundary',
        if (!page.contains('onPlay: playerController.playPlaylist')) '${_relativePath(pageFile)} does not pass player controller boundary to ranking list',
        if (controller.contains("package:bujuan/features/shell/home_shell_controller.dart")) 'explore controller imports shell controller',
        if (controller.contains('HomeShellController.to')) 'explore controller reads global shell controller',
        if (!controller.contains('required ExplorePageVisibility pageVisibility')) 'explore controller does not accept visibility boundary',
        if (!bootstrap.contains('pageVisibility: ExplorePageVisibility(')) 'feature bootstrap does not inject explore visibility boundary',
        if (!bootstrap.contains('shellController.isExplorePageIndex')) 'feature bootstrap does not bind explore visibility to shell page kind',
        if (!page.contains('controller.resolvePlaylistPlayback(playlist)')) '${_relativePath(pageFile)} does not resolve playlist playback through controller',
        if (!controller.contains('Future<ExplorePlaylistPlaybackPlan> resolvePlaylistPlayback')) 'explore controller does not expose playlist playback resolution',
        if (!controller.contains('final likedSongIds = List<int>.of(_likedSongIds())')) 'explore controller does not resolve playback with liked ids provider',
        if (!controller.contains('playlistIndex: index')) 'explore controller does not reuse fetched playlist index for playback songs',
      ];

      expect(
        violations,
        isEmpty,
        reason: '探索页 Widget 只发起播放意图，歌单摘要到播放队列的解析必须留在 ExplorePageController，避免 UI 直接读用户喜欢列表和 PlaylistRepository。',
      );
    });

    test('frequent playlist section keeps playback resolution behind home controller', () {
      final sectionFile = File(
        '${projectRoot.path}/lib/ui/pages/user/widgets/frequent_playlist_section.dart',
      );
      final controllerFile = File(
        '${projectRoot.path}/lib/features/user/recommendation_controller.dart',
      );
      final bootstrapFile = File('${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart');
      final section = sectionFile.readAsStringSync();
      final controller = controllerFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (section.contains('PlaylistRepository')) '${_relativePath(sectionFile)} resolves playlist data directly',
        if (section.contains('likedSongIds.toList')) '${_relativePath(sectionFile)} reads liked ids directly',
        if (section.contains('Get.find<PlayerController>')) '${_relativePath(sectionFile)} reads player controller from container',
        if (section.contains('fetchPlaylistIndex(')) '${_relativePath(sectionFile)} fetches playlist index directly',
        if (section.contains('fetchPlaylistSongs(')) '${_relativePath(sectionFile)} fetches playlist songs directly',
        if (!section.contains('recommendationController.resolveFrequentPlaylistPlayback')) '${_relativePath(sectionFile)} does not resolve playlist playback through home controller',
        if (controller.contains('UserLibraryController')) 'recommendation controller reads user library controller directly',
        if (controller.contains("package:bujuan/features/user/user_session_controller.dart")) 'recommendation controller imports user session controller',
        if (controller.contains('UserSessionController')) 'recommendation controller names user session controller directly',
        if (!controller.contains('Future<UserHomePlaylistPlaybackPlan> resolveFrequentPlaylistPlayback')) 'recommendation controller does not expose frequent playlist playback resolution',
        if (!controller.contains('required PlaylistRepository playlistRepository')) 'recommendation controller does not receive playlist repository explicitly',
        if (!controller.contains('required RecommendationLibraryAccess libraryAccess')) 'recommendation controller does not receive library access boundary',
        if (!controller.contains('required RecommendationSessionAccess sessionAccess')) 'recommendation controller does not receive session access boundary',
        if (!controller.contains('String _normalizedUserId(String userId)')) 'recommendation controller does not normalize session user ids',
        if (!controller.contains('bool _isSignedInUserId(String userId)')) 'recommendation controller does not centralize signed-in account checks',
        if (!controller.contains('_currentUserId() == userId')) 'recommendation controller does not compare scoped loads against normalized current user',
        if (!bootstrap.contains('sessionAccess: RecommendationSessionAccess(')) 'feature bootstrap does not inject recommendation session access boundary',
        if (!bootstrap.contains('watchSession: (onChanged)')) 'feature bootstrap does not bind recommendation session watcher',
        if (!controller.contains('currentUserId: userId')) 'recommendation controller does not pass current user when resolving frequent playlist',
        if (!controller.contains('playlistIndex: index')) 'recommendation controller does not reuse fetched playlist index for playback songs',
      ];

      expect(
        violations,
        isEmpty,
        reason: '常用歌单 Widget 只发起播放意图，歌单摘要到播放队列的解析必须留在 RecommendationController，避免 UI 直接读喜欢列表和 PlaylistRepository。',
      );
    });

    test('today recommendation page reads songs through page controller boundary', () {
      final pageFile = File(
        '${projectRoot.path}/lib/ui/pages/user/today_page_view.dart',
      );
      final page = pageFile.readAsStringSync();
      final violations = <String>[
        if (page.contains('RecommendationController.to')) '${_relativePath(pageFile)} reads recommendation controller globally',
        if (page.contains('PlaylistRepository')) '${_relativePath(pageFile)} names playlist repository directly',
        if (page.contains('UserLibraryController')) '${_relativePath(pageFile)} reads user library directly',
        if (!page.contains('class TodayPageView extends GetView<RecommendationController>')) '${_relativePath(pageFile)} does not use page controller boundary',
        if (!page.contains('final songs = controller.todayRecommendSongs')) '${_relativePath(pageFile)} does not read songs through page controller boundary',
      ];

      expect(
        violations,
        isEmpty,
        reason: '今日推荐页只能展示 RecommendationController 暴露的推荐队列并提交播放意图，不能直接读取资料库或 repository。',
      );
    });

    test('recommended playlists page reads lists through page controller boundary', () {
      final pageFile = File(
        '${projectRoot.path}/lib/ui/pages/user/recommended_playlists_page.dart',
      );
      final page = pageFile.readAsStringSync();
      final violations = <String>[
        if (page.contains('RecommendationController.to')) '${_relativePath(pageFile)} reads recommendation controller globally',
        if (page.contains('PlaylistRepository')) '${_relativePath(pageFile)} names playlist repository directly',
        if (page.contains('UserLibraryController')) '${_relativePath(pageFile)} reads user library directly',
        if (!page.contains('class RecommendedPlaylistsPageView extends GetView<RecommendationController>')) '${_relativePath(pageFile)} does not use page controller boundary',
        if (!page.contains('RecommendedPlaylistListSliver(controller: controller)')) '${_relativePath(pageFile)} does not pass page controller to playlist sliver',
        if (!page.contains('controller.updateRecoPlayLists(getMore: true)')) '${_relativePath(pageFile)} does not load more through page controller boundary',
      ];

      expect(
        violations,
        isEmpty,
        reason: '推荐歌单页只能展示 RecommendationController 暴露的推荐歌单并提交加载意图，不能直接读取资料库或 repository。',
      );
    });

    test('library shortcut bar keeps liked playlist behind injected provider', () {
      final shortcutFile = File(
        '${projectRoot.path}/lib/ui/pages/user/widgets/library_shortcut_bar.dart',
      );
      final sectionFile = File(
        '${projectRoot.path}/lib/ui/pages/user/widgets/library_shortcut_section.dart',
      );
      final shortcut = shortcutFile.readAsStringSync();
      final section = sectionFile.readAsStringSync();
      final violations = <String>[
        if (shortcut.contains('UserLibraryController')) '${_relativePath(shortcutFile)} reads user library directly',
        if (!shortcut.contains('final PlaylistSummaryData Function() likedPlaylist')) '${_relativePath(shortcutFile)} does not receive liked playlist provider',
        if (!shortcut.contains('final WidgetBuilder userPlaylistsPageBuilder')) '${_relativePath(shortcutFile)} does not receive user playlist page builder',
        if (!shortcut.contains('final playlist = likedPlaylist();')) '${_relativePath(shortcutFile)} does not read liked playlist from provider',
        if (!section.contains('required this.libraryController')) '${_relativePath(sectionFile)} does not receive library controller from parent',
        if (!section.contains('likedPlaylist: () => libraryController.userLikedSongPlayList.value')) '${_relativePath(sectionFile)} does not inject liked playlist provider',
        if (!section.contains('userPlaylistsPageBuilder:')) '${_relativePath(sectionFile)} does not inject user playlist page builder',
      ];

      expect(
        violations,
        isEmpty,
        reason: '资料库快捷入口不能在按钮栏内部读取全局用户库；我喜欢歌单入口必须由资料库区通过 provider 注入。',
      );
    });

    test('album and artist detail pages create controllers through feature factories', () {
      final albumPageFile = File(
        '${projectRoot.path}/lib/ui/pages/album/album_page_view.dart',
      );
      final artistPageFile = File(
        '${projectRoot.path}/lib/ui/pages/artist/artist_page_view.dart',
      );
      final albumControllerFile = File(
        '${projectRoot.path}/lib/features/album/album_page_controller.dart',
      );
      final albumFactoryFile = File(
        '${projectRoot.path}/lib/features/album/album_page_controller_factory.dart',
      );
      final artistControllerFile = File(
        '${projectRoot.path}/lib/features/artist/artist_page_controller.dart',
      );
      final artistFactoryFile = File(
        '${projectRoot.path}/lib/features/artist/artist_page_controller_factory.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final albumPage = albumPageFile.readAsStringSync();
      final artistPage = artistPageFile.readAsStringSync();
      final albumController = albumControllerFile.readAsStringSync();
      final albumFactory = albumFactoryFile.readAsStringSync();
      final artistController = artistControllerFile.readAsStringSync();
      final artistFactory = artistFactoryFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (albumPage.contains('AlbumRepository')) '${_relativePath(albumPageFile)} names album repository directly',
        if (artistPage.contains('ArtistRepository')) '${_relativePath(artistPageFile)} names artist repository directly',
        if (albumPage.contains('Get.find<AlbumPageController>()')) '${_relativePath(albumPageFile)} reads album controller singleton directly',
        if (artistPage.contains('Get.find<ArtistPageController>()')) '${_relativePath(artistPageFile)} reads artist controller singleton directly',
        if (!albumPage.contains('Get.find<AlbumPageControllerFactory>().create()')) '${_relativePath(albumPageFile)} does not create album page controller through feature factory',
        if (!artistPage.contains('Get.find<ArtistPageControllerFactory>().create()')) '${_relativePath(artistPageFile)} does not create artist page controller through feature factory',
        if (albumPage.contains('_controller.loadLocalDetail(')) '${_relativePath(albumPageFile)} directly runs album local detail loading',
        if (artistPage.contains('_controller.loadLocalDetail(')) '${_relativePath(artistPageFile)} directly runs artist local detail loading',
        if (!albumPage.contains('_controller.loadInitialDetail(albumId)')) '${_relativePath(albumPageFile)} does not load album initial detail through controller boundary',
        if (!artistPage.contains('_controller.loadInitialDetail(artistId)')) '${_relativePath(artistPageFile)} does not load artist initial detail through controller boundary',
        if (!albumPage.contains('generation != _detailRefreshGeneration')) '${_relativePath(albumPageFile)} does not ignore stale album refresh results',
        if (!artistPage.contains('generation != _detailRefreshGeneration')) '${_relativePath(artistPageFile)} does not ignore stale artist refresh results',
        if (!albumController.contains('class AlbumInitialDetailData')) '${_relativePath(albumControllerFile)} does not define album initial detail boundary',
        if (!artistController.contains('class ArtistInitialDetailData')) '${_relativePath(artistControllerFile)} does not define artist initial detail boundary',
        if (albumController.contains('UserLibraryController')) '${_relativePath(albumControllerFile)} reads user library directly',
        if (artistController.contains('UserLibraryController')) '${_relativePath(artistControllerFile)} reads user library directly',
        if (!albumController.contains('required List<int> Function() likedSongIds')) 'album page controller does not require liked ids provider',
        if (!artistController.contains('required List<int> Function() likedSongIds')) 'artist page controller does not require liked ids provider',
        if (!albumFactory.contains('AlbumPageController create()')) 'album page controller factory does not create page controllers',
        if (!artistFactory.contains('ArtistPageController create()')) 'artist page controller factory does not create page controllers',
        if (!albumFactory.contains('repository: _repository')) 'album page controller factory does not inject album repository',
        if (!artistFactory.contains('repository: _repository')) 'artist page controller factory does not inject artist repository',
        if (!albumFactory.contains('likedSongIds: _likedSongIds')) 'album page controller factory does not inject liked ids provider',
        if (!artistFactory.contains('likedSongIds: _likedSongIds')) 'artist page controller factory does not inject liked ids provider',
        if (!bootstrap.contains('AlbumPageControllerFactory(')) 'feature bootstrap does not register album page controller factory',
        if (!bootstrap.contains('ArtistPageControllerFactory(')) 'feature bootstrap does not register artist page controller factory',
      ];

      expect(
        violations,
        isEmpty,
        reason: '专辑页和歌手页只能通过 feature factory 创建页面 controller；repository 和喜欢歌曲上下文必须由 feature bootstrap 注入，避免 Widget 或控制器回到全局用户库读取。',
      );
    });

    test('recent playback stays backed by confirmed history', () {
      final controllerFile = File(
        '${projectRoot.path}/lib/features/playback/recent_playback_controller.dart',
      );
      final repositoryFile = File(
        '${projectRoot.path}/lib/features/playback/playback_repository.dart',
      );
      final dataSourceFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/data_sources/drift_playback_history_data_source.dart',
      );
      final queueStoreFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_queue_store.dart',
      );
      final stripFile = File(
        '${projectRoot.path}/lib/ui/pages/user/widgets/recent_playback_strip.dart',
      );
      final controller = controllerFile.readAsStringSync();
      final repository = repositoryFile.readAsStringSync();
      final dataSource = dataSourceFile.readAsStringSync();
      final queueStore = queueStoreFile.readAsStringSync();
      final strip = stripFile.readAsStringSync();
      final violations = <String>[
        if (!controller.contains('loadRecentPlayedTracks(limit: limit)')) 'recent controller does not read playback history',
        if (!controller.contains('recentPlaybackUpdates.listen')) 'recent controller does not listen to history update notifications',
        if (!repository.contains('String _normalizedTrackId(String trackId)')) 'playback repository does not normalize recent history track ids',
        if (!repository.contains('final normalizedTrackId = _normalizedTrackId(trackId);')) 'playback repository records raw recent history track ids',
        if (!repository.contains('if (_isBlankTrackId(normalizedTrackId))')) 'playback repository does not reject blank recent history track ids',
        if (!dataSource.contains('final normalizedTrackId = trackId.trim();')) 'drift playback history data source does not normalize track ids',
        if (!dataSource.contains('trackId: drift.Value(normalizedTrackId)')) 'drift playback history data source can write raw track ids',
        if (_containsAny(controllerFile, const [
          'PlayerController',
          'PlaybackQueueService',
          'activeQueue',
          'confirmedItem',
          'currentSongState',
        ]))
          '${_relativePath(controllerFile)} derives history from current playback state',
        if (!queueStore.contains('await _repository.recordPlayedTrack(currentSongId);')) 'queue store does not record confirmed current song',
        if (!strip.contains('final recentTracks = controller.recentTracks.toList')) 'recent playback strip does not render controller history',
        if (_containsAny(stripFile, const [
          'activeQueue',
          'confirmedItem',
          'runtimeState.value.queue',
          'selectionState',
        ]))
          '${_relativePath(stripFile)} derives recent list from current playback queue',
      ];

      expect(
        violations,
        isEmpty,
        reason: '最近播放只能由底层确认播放写入的本地历史驱动；UI 当前歌曲状态只允许用于高亮，不能冒充历史数据源。',
      );
    });

    test('audio service handler stays playback adapter only', () {
      final handlerFile = File(
        '${projectRoot.path}/lib/features/playback/application/audio_service_handler.dart',
      );
      final violations = <String>[
        if (_containsAny(handlerFile, const [
          'PlaybackSourceResolver',
          'playback_source_resolver.dart',
          'PlaybackRepository',
          'fetchPlaybackUrl',
          'resolveRemote(',
        ]))
          _relativePath(handlerFile),
      ];

      expect(
        violations,
        isEmpty,
        reason: 'AudioServiceHandler 只能做 audio_service/just_audio adapter，播放源解析和 fallback 必须留在 switch/source resolver 层。',
      );
    });

    test('audio service transport controls route back to selection command', () {
      final handlerFile = File(
        '${projectRoot.path}/lib/features/playback/application/audio_service_handler.dart',
      );
      final content = handlerFile.readAsStringSync();

      expect(
        content,
        allOf(
          contains('_handleSkipToNext?.call()'),
          contains('_handleSkipToPrevious?.call()'),
          isNot(contains('await playIndex(audioSourceIndex: newIndex')),
        ),
        reason: '通知栏 next/previous 必须回到 selection 命令入口，不能在 handler 内部自行计算并切源。',
      );
    });

    test('UI does not import data sources directly', () {
      final uiDirectories = [
        Directory('${projectRoot.path}/lib/ui/pages'),
        Directory('${projectRoot.path}/lib/ui/widgets'),
      ];
      final violations = uiDirectories
          .expand(_dartFiles)
          .where(
            (file) => _containsAny(file, const [
              'package:bujuan/data/music_data/sources/netease/remote/',
              'package:bujuan/data/music_data/sources/local/',
              '/dao/',
              '_data_source.dart',
              'drift_',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'UI 可以依赖 feature repository/controller，但不能直连 remote/data source/DAO/Drift 细节。',
      );
    });

    test('feature repositories use neutral remote data source contracts', () {
      final repositoryViolations = _repositoryFiles(
        Directory('${projectRoot.path}/lib/features'),
      )
          .where(
            (file) => _contains(
              file,
              'package:bujuan/data/music_data/sources/netease/remote/',
            ),
          )
          .map(_relativePath)
          .toList();
      final contractFile = File(
        '${projectRoot.path}/lib/data/music_data/music_remote_data_sources.dart',
      );
      final contractContent = contractFile.existsSync() ? contractFile.readAsStringSync() : '';
      final missingContracts = <String>[
        for (final name in const [
          'AuthRemoteDataSource',
          'UserRemoteDataSource',
          'PlaylistRemoteDataSource',
          'AlbumRemoteDataSource',
          'ArtistRemoteDataSource',
          'CloudRemoteDataSource',
          'RadioRemoteDataSource',
          'SearchRemoteDataSource',
          'CommentRemoteDataSource',
          'ExploreRemoteDataSource',
        ])
          if (!contractContent.contains('abstract interface class $name')) name,
      ];
      final implementationViolations = _dartFiles(
        Directory('${projectRoot.path}/lib/data/music_data/sources/netease/remote'),
      ).where((file) => !_contains(file, ' implements ')).map(_relativePath).toList();

      expect(
        repositoryViolations,
        isEmpty,
        reason: 'feature repository 只能依赖 data/music_data 的中性远程数据契约，不能直接命名网易云 remote 实现。',
      );
      expect(
        missingContracts,
        isEmpty,
        reason: '所有被 feature repository 使用的远程能力必须先在中性契约中声明。',
      );
      expect(
        implementationViolations,
        isEmpty,
        reason: '网易云 remote 实现必须显式实现中性远程数据契约，避免 feature 层重新绑定具体平台类。',
      );
    });

    test('features do not keep presentation dart files', () {
      final violations = _dartFiles(Directory('${projectRoot.path}/lib/features')).where((file) => _relativePath(file).contains('/presentation/')).map(_relativePath).toList();

      expect(
        violations,
        isEmpty,
        reason: 'UI 页面和组件应统一移动到 lib/ui/pages 与 lib/ui/widgets，features 只保留功能代码。',
      );
    });

    test('application factories do not read GetX container directly', () {
      final violations = _dartFiles(libDirectory)
          .where((file) {
            final path = _relativePath(file);
            return path.startsWith('lib/features/') && (path.contains('/application/') || path.endsWith('_page_controller.dart') || path.endsWith('_scan_controller.dart'));
          })
          .where((file) => _contains(file, 'Get.find<'))
          .map(_relativePath)
          .where((path) => !_isTemporaryGetFindFactoryException(path))
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'application/page controller 应使用构造函数注入，Get.find 只能留在 binding/route/controller/presentation 装配边界。',
      );
    });

    test('feature application layer does not import UI', () {
      final violations = _dartFiles(libDirectory)
          .where((file) {
            final path = _relativePath(file);
            return path.startsWith('lib/features/') && path.contains('/application/');
          })
          .where(
            (file) => _containsAny(file, const [
              'package:bujuan/ui/',
              '/presentation/',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'application 层不能反向 import UI，展示组合必须留在 lib/ui 或 route 装配边界。',
      );
    });

    test('repositories do not import controllers', () {
      final violations = _repositoryFiles(libDirectory)
          .where(
            (file) => _containsAny(file, const [
              '_controller.dart',
              'Controller',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'repository 不能依赖 controller；页面流程应放在 controller/application service。',
      );
    });

    test('controllers do not import data sources directly', () {
      final violations = _dartFiles(libDirectory)
          .where((file) {
            final path = _relativePath(file);
            return path.startsWith('lib/features/') && (path.endsWith('_controller.dart') || path.endsWith('_page_controller.dart') || path.endsWith('_scan_controller.dart'));
          })
          .where(
            (file) => _containsAny(file, const [
              'package:bujuan/data/music_data/sources/',
              'package:bujuan/data/app_storage/',
              '_data_source.dart',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'controller 不能直连 data source，应通过 application service 或 repository。',
      );
    });

    test('playlist shared widgets stay controller free', () {
      final playlistWidgetFile = File('${projectRoot.path}/lib/ui/widgets/playlist/playlist_widgets.dart');
      final violations = <String>[
        if (_contains(playlistWidgetFile, 'PlayerController')) _relativePath(playlistWidgetFile),
      ];

      expect(
        violations,
        isEmpty,
        reason: 'playlist 共享展示组件不能直接依赖播放 controller，播放行为应由回调或业务 wrapper 注入。',
      );
    });

    test('common widgets stay presentation only', () {
      final widgetDirectory = Directory('${projectRoot.path}/lib/ui/widgets/common');
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
        reason: 'lib/ui/widgets/common 只能保留通用展示组件，不能直接读取 feature controller/repository 或 data。',
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
              'ToastService',
              'DialogService',
              'BuildContext',
              'Widget',
              'Navigator',
              'showDialog',
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

    test('feature repository imports use the approved cross-feature boundary', () {
      final violations = <String>[];
      for (final file in _repositoryFiles(libDirectory)) {
        final path = _relativePath(file);
        final featureName = _featureName(path);
        final imports = _featureImports(file);
        for (final importedFeature in imports) {
          if (importedFeature == 'playback' &&
              _contains(
                file,
                "package:bujuan/features/playback/application/playback_queue_item_mapper.dart",
              )) {
            continue;
          }
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
        reason: 'feature repository 之间不能横向随意依赖；共享能力应上移到 core/entities、application service 或显式白名单。',
      );
    });

    test('business cache stores do not read CacheBox directly', () {
      final cacheStores = _dartFiles(libDirectory).where((file) {
        final path = _relativePath(file);
        return path.endsWith('/search_cache_store.dart') ||
            path.endsWith('/comment_cache_store.dart') ||
            path.endsWith('/explore_cache_store.dart') ||
            path.endsWith('/radio_cache_store.dart') ||
            path.endsWith('/cloud_cache_store.dart') ||
            path.endsWith('/user_profile_cache_store.dart');
      });

      final violations = cacheStores.where((file) => _contains(file, 'CacheBox.instance')).map(_relativePath).toList();

      expect(
        violations,
        isEmpty,
        reason: '业务列表缓存应使用 Drift-backed AppCacheDataSource，Hive 只保留登录态、设置和轻量视觉缓存。',
      );
    });

    test('short app cache keys stay with AppCacheDataSource boundary', () {
      const cacheStorePaths = [
        'lib/features/search/search_cache_store.dart',
        'lib/features/explore/explore_cache_store.dart',
        'lib/features/comment/comment_cache_store.dart',
      ];
      final appStorageKeys = File('${projectRoot.path}/lib/data/app_storage/app_cache_keys.dart').readAsStringSync();
      final appCacheDataSource = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/data_sources/app_cache_data_source.dart',
      ).readAsStringSync();
      final violations = <String>[
        if (appStorageKeys.contains('SEARCH_HOT_KEYWORDS')) 'search hot keywords key stays in app_storage',
        if (appStorageKeys.contains('EXPLORE_PLAYLIST_CATALOGUE')) 'explore catalogue key stays in app_storage',
        if (appStorageKeys.contains('COMMENT_LIST')) 'comment list key stays in app_storage',
        if (appStorageKeys.contains('FLOOR_COMMENT')) 'floor comment key stays in app_storage',
        if (!appCacheDataSource.contains('appCacheSearchHotKeywordsKey')) 'missing search app cache key',
        if (!appCacheDataSource.contains('appCacheExplorePlaylistCatalogueKey')) 'missing explore app cache key',
        if (!appCacheDataSource.contains('appCacheCommentListPrefix')) 'missing comment app cache prefix',
        if (!appCacheDataSource.contains('appCacheFloorCommentPrefix')) 'missing floor comment app cache prefix',
      ];
      for (final path in cacheStorePaths) {
        final content = File('${projectRoot.path}/$path').readAsStringSync();
        if (content.contains("data/app_storage/app_cache_keys.dart")) {
          violations.add('$path imports app_storage cache keys');
        }
      }

      expect(
        violations,
        isEmpty,
        reason: '搜索、探索和评论短期缓存使用 Drift app_cache_entries，缓存 key 应归属 AppCacheDataSource 边界，不能继续混在 Hive/app_storage key 里。',
      );
    });

    test('legacy business fact keys stay out of Hive app cache keys', () {
      final keysFile = File('${projectRoot.path}/lib/data/app_storage/app_cache_keys.dart');
      final content = keysFile.readAsStringSync();
      const forbiddenKeys = {
        'gradientBackgroundSp': '<legacy_storage_variable>',
        'highSong': '<legacy_storage_variable>',
        'isLoginSP': '<legacy_storage_variable>',
        'roundAlbumSp': '<legacy_storage_variable>',
        'userSessionSp': '<legacy_storage_variable>',
        'leftImageSp': 'LEFT_IMAGE',
        'topLyricSp': 'TOP_LYRIC',
        'noFirstOpen': 'NO_FIRST_OPEN',
        'unblockSp': 'UNBLOCK',
        'unblockVipSp': 'UNBLOCK_VIP',
        'userInfoSp': '<legacy_user_info_variable>',
        'recoPlayListsSp': 'RECO_PLAY_LISTS',
        'userPlayListsSp': 'USER_PLAY_LISTS',
        'likedSongIdsSp': 'LIKED_SONG_IDS',
        'todayRecommendSongsSp': 'TODAY_RECO_SONGS',
        'fmSongsSp': 'FM_SONGS',
        'randomLikedSongAlbumUrlSp': 'RANDOM_LIKED_ALBUM_URL',
        'randomLikedSongIdSp': 'RANDOM_LIKED_SONG_ID',
        'userLikedSongPlayListSp': 'USER_LIKED_SONG_PL',
        'userStartupLastRefreshSp': 'USER_STARTUP_LAST_REFRESH',
        'downloadTasksSp': 'DOWNLOAD_TASKS',
        'localResourceIndexSp': 'LOCAL_RESOURCE_INDEX',
        'playbackRestoreStateSp': 'PLAYBACK_RESTORE_STATE',
      };
      final violations = <String>[
        for (final entry in forbiddenKeys.entries)
          if (content.contains(entry.key) || content.contains(entry.value)) '${entry.key}/${entry.value}',
      ];

      expect(
        violations,
        isEmpty,
        reason: '喜欢歌曲、用户歌单、推荐歌曲、下载任务、本地资源索引和播放恢复等业务事实必须留在 Drift/资源索引，不能以遗留 Hive key 回流。',
      );
    });

    test('Hive app storage keys keep semantic names and bounded scope', () {
      final keysFile = File('${projectRoot.path}/lib/data/app_storage/app_cache_keys.dart');
      final content = keysFile.readAsStringSync();
      final declarations = RegExp(
        r"const String (\w+) = '([^']+)';",
      ).allMatches(content).map((match) => MapEntry(match.group(1)!, match.group(2)!)).toList();
      const expectedKeys = {
        'gradientBackgroundKey': 'SOLID_BACK_GROUND',
        'highSoundQualityKey': 'HIGH_SONG',
        'loginFlagKey': 'IS_LOGIN',
        'roundAlbumKey': 'ROUND_ALBUM',
        'userSessionKey': 'USER_INFO',
      };

      expect(
        Map.fromEntries(declarations),
        expectedKeys,
        reason: 'Hive app_storage 只能保留登录态、用户 session、设置项和轻量视觉缓存；常量名必须表达语义，不能恢复 Sp 或业务事实缓存命名。',
      );
    });

    test('CacheBox direct access stays inside key-value adapter', () {
      const allowedFiles = {
        'lib/data/app_storage/hive_key_value_store.dart',
      };
      final violations = _dartFiles(libDirectory).where((file) => _contains(file, 'CacheBox.instance')).map(_relativePath).where((path) => !allowedFiles.contains(path)).toList();

      expect(
        violations,
        isEmpty,
        reason: 'CacheBox.instance 只能留在 HiveKeyValueStore，其他代码必须通过 AppKeyValueStore 或更窄的领域存储边界访问。',
      );
    });

    test('image color cache uses key-value boundary instead of CacheBox directly', () {
      final cacheStoreFile = File(
        '${projectRoot.path}/lib/data/app_storage/image_color_cache_store.dart',
      );
      final content = cacheStoreFile.readAsStringSync();
      final violations = <String>[
        if (content.contains('CacheBox.instance')) 'reads CacheBox directly',
        if (!content.contains('AppKeyValueStore')) 'missing key-value boundary',
      ];

      expect(
        violations,
        isEmpty,
        reason: '图片主色缓存属于轻量视觉缓存，但仍应通过窄 key-value 边界访问 Hive，避免 CacheBox 全局入口继续扩散。',
      );
    });

    test('app preferences use key-value boundary instead of CacheBox directly', () {
      final preferencesFile = File(
        '${projectRoot.path}/lib/data/app_storage/app_preferences.dart',
      );
      final content = preferencesFile.readAsStringSync();
      final violations = <String>[
        if (content.contains('CacheBox.instance')) 'reads CacheBox directly',
        if (!content.contains('AppKeyValueStore')) 'missing key-value boundary',
      ];

      expect(
        violations,
        isEmpty,
        reason: '设置项可以保存在 Hive，但 AppPreferences 应通过窄 key-value 边界访问，避免 CacheBox 全局入口扩散。',
      );
    });

    test('auth and user session stores use key-value boundary instead of CacheBox directly', () {
      const storePaths = [
        'lib/features/auth/auth_state_store.dart',
        'lib/features/user/user_session_store.dart',
      ];
      final violations = <String>[];
      for (final path in storePaths) {
        final file = File('${projectRoot.path}/$path');
        final content = file.readAsStringSync();
        if (content.contains('CacheBox.instance')) {
          violations.add('$path reads CacheBox directly');
        }
        if (!content.contains('AppKeyValueStore')) {
          violations.add('$path missing key-value boundary');
        }
      }

      expect(
        violations,
        isEmpty,
        reason: '登录标记和用户 session 可以落在 Hive，但必须通过窄 key-value 边界访问，避免账号状态存储继续扩散 CacheBox。',
      );
    });

    test('auth flow branches on cached session instead of login flag', () {
      final repository = File('${projectRoot.path}/lib/features/auth/auth_repository.dart').readAsStringSync();
      final controller = File('${projectRoot.path}/lib/features/auth/auth_controller.dart').readAsStringSync();
      final sessionController = File('${projectRoot.path}/lib/features/user/user_session_controller.dart').readAsStringSync();
      final featureBootstrap = File('${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart').readAsStringSync();
      final violations = <String>[
        if (repository.contains('hasCachedLogin')) 'auth repository exposes login flag as cached login',
        if (!repository.contains('hasCachedSession => _stateStore.hasCachedSession')) 'auth repository does not expose cached session',
        if (controller.contains('hasCachedLogin')) 'auth controller branches on login flag',
        if (!controller.contains('hasCachedSession')) 'auth controller does not branch on cached session',
        if (controller.contains("package:bujuan/features/user/user_session_controller.dart")) 'auth controller imports user session controller',
        if (controller.contains('UserSessionController.to')) 'auth controller reads global user session controller',
        if (!controller.contains('required AuthSessionAccess sessionAccess')) 'auth controller does not use narrow session access',
        if (!sessionController.contains('required bool Function() canRestoreCachedSession')) 'user session controller does not require cached-session restore guard',
        if (!sessionController.contains('if (!_canRestoreCachedSession())')) 'user session controller restores cache without guard',
        if (!featureBootstrap.contains('canRestoreCachedSession: () => Get.find<AuthRepository>().hasCachedSession')) 'feature bootstrap does not inject auth cached-session guard',
        if (!featureBootstrap.contains('AuthSessionAccess(')) 'feature bootstrap does not bind auth session access',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'App 当前用户必须由可解析 session 和登录标记共同驱动，不能只凭 SDK cookie、孤立登录标记或孤立 session 恢复账号状态。',
      );
    });

    test('user session persistence stays serialized and generation guarded', () {
      final sessionController = File('${projectRoot.path}/lib/features/user/user_session_controller.dart').readAsStringSync();
      final violations = <String>[
        if (!sessionController.contains('Future<void> _sessionPersistenceQueue')) 'user session controller does not serialize session persistence',
        if (!sessionController.contains('int _sessionPersistenceGeneration')) 'user session controller does not track session persistence generation',
        if (!sessionController.contains('final generation = ++_sessionPersistenceGeneration')) 'user session persistence does not create a generation per write',
        if (!sessionController.contains('_sessionPersistenceQueue = operation.catchError')) 'session persistence failures can break the write queue',
        if (!sessionController.contains('generation != _sessionPersistenceGeneration')) 'stale session persistence writes are not ignored',
        if (!sessionController.contains('await _queueSessionPersistence(const UserSessionData.empty())')) 'session clearing does not wait for the serialized persistence queue',
      ];

      expect(
        violations,
        isEmpty,
        reason: '用户 session 保存、注销清理和新账号写入必须串行且带代次保护，旧异步写入不能覆盖当前账号归属。',
      );
    });

    test('auth account and qr flows stay generation guarded', () {
      final authController = File('${projectRoot.path}/lib/features/auth/auth_controller.dart').readAsStringSync();
      final violations = <String>[
        if (!authController.contains('int _accountLoadGeneration')) 'auth controller does not track account load generation',
        if (!authController.contains('int _qrFlowGeneration')) 'auth controller does not track qr flow generation',
        if (!authController.contains('final accountLoadGeneration = _startAccountLoad()')) 'auth controller does not scope account loading by generation',
        if (!authController.contains('final qrFlowGeneration = _startQrFlow()')) 'auth controller does not scope qr refresh by generation',
        if (!authController.contains('_invalidateAccountLoad()')) 'auth controller does not invalidate account loading on flow changes',
        if (!authController.contains('_stopQrPolling()')) 'auth controller does not stop qr polling on logout or dispose',
        if (!authController.contains('!_isCurrentAccountLoad(accountLoadGeneration)')) 'auth controller does not guard stale account loads',
        if (!authController.contains('!_isCurrentQrFlow(qrFlowGeneration)')) 'auth controller does not guard stale qr flow responses',
        if (!authController.contains('_sessionAccess.currentSession().userId != validatingUserId')) 'background account validation does not recheck the active user',
      ];

      expect(
        violations,
        isEmpty,
        reason: '缓存恢复、二维码轮询和后台校验都可能跨账号返回，AuthController 必须用流程代次和当前用户复核来阻断旧结果落状态。',
      );
    });

    test('manual logout routes through auth effect boundary', () {
      final authController = File('${projectRoot.path}/lib/features/auth/auth_controller.dart').readAsStringSync();
      final profileController = File('${projectRoot.path}/lib/features/user/user_profile_controller.dart').readAsStringSync();
      final profileFactory = File('${projectRoot.path}/lib/features/user/user_profile_controller_factory.dart').readAsStringSync();
      final featureBootstrap = File('${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart').readAsStringSync();
      final userProfilePage = File('${projectRoot.path}/lib/ui/pages/user/user_setting_view.dart').readAsStringSync();
      final violations = <String>[
        if (!authController.contains('Future<void> logoutCurrentUser()')) 'auth controller does not own manual logout flow',
        if (!authController.contains("AuthUiEffect.loginExpired('已退出登录')")) 'manual logout does not emit login-page effect',
        if (!profileController.contains('Future<void> logoutCurrentUser()')) 'profile controller does not expose logout boundary',
        if (!profileFactory.contains('logoutCurrentUser: _logoutCurrentUser')) 'profile factory does not inject logout boundary',
        if (!featureBootstrap.contains('logoutCurrentUser: () => Get.find<AuthController>().logoutCurrentUser()')) 'feature bootstrap does not route logout to auth boundary',
        if (!userProfilePage.contains('_controller.logoutCurrentUser()')) 'user profile page does not use profile logout boundary',
        if (userProfilePage.contains('Get.find<AuthController>')) 'user profile page reads auth controller directly',
        if (userProfilePage.contains('AutoRouter.of(context)')) 'user profile page manipulates router after logout',
        if (userProfilePage.contains('UserSessionController.to.clearUser()')) 'user profile page clears session directly',
      ];

      expect(
        violations,
        isEmpty,
        reason: '主动注销需要复用 AuthController 的登录页副作用，避免 UI 绕过路由边界或只清 session 后留在已登录壳层。',
      );
    });

    test('user library reads session through narrow access boundary', () {
      final controllerFile = File('${projectRoot.path}/lib/features/user/user_library_controller.dart');
      final bootstrapFile = File('${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart');
      final controller = controllerFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (controller.contains("package:bujuan/features/user/user_session_controller.dart")) 'user library controller imports user session controller',
        if (controller.contains('UserSessionController')) 'user library controller names user session controller directly',
        if (!controller.contains('required UserLibrarySessionAccess sessionAccess')) 'user library controller does not receive session access boundary',
        if (!controller.contains('required this.watchSession')) 'user library session boundary does not expose session watcher',
        if (!controller.contains('String _normalizedUserId(String userId)')) 'user library controller does not normalize session user ids',
        if (!controller.contains('bool _isSignedInUserId(String userId)')) 'user library controller does not centralize signed-in account checks',
        if (!controller.contains('_currentUserId() == userId')) 'user library controller does not compare scoped loads against normalized current user',
        if (!bootstrap.contains('sessionAccess: UserLibrarySessionAccess(')) 'feature bootstrap does not inject user library session access boundary',
        if (!bootstrap.contains('watchSession: (onChanged)')) 'feature bootstrap does not bind user library session watcher',
      ];

      expect(
        violations,
        isEmpty,
        reason: '用户资料库可以按账号作用域刷新本地数据，但只能通过窄 session 边界读取和监听当前用户，不能直接依赖全局用户 session 控制器。',
      );
    });

    test('user repository rejects blank account scope', () {
      final repositoryFile = File('${projectRoot.path}/lib/features/user/user_repository.dart');
      final repository = repositoryFile.readAsStringSync();
      final violations = <String>[
        if (!repository.contains('bool _isBlankUserId(String userId)')) '${_relativePath(repositoryFile)} does not define a blank user guard',
        if (!repository.contains('if (_isBlankUserId(userId))')) '${_relativePath(repositoryFile)} does not guard user-scoped repository entry points',
        if (!repository.contains('return _emptyUserProfile')) '${_relativePath(repositoryFile)} does not return an empty profile for blank users',
        if (!repository.contains('likedSongIds: const <int>[]')) '${_relativePath(repositoryFile)} does not return an empty library snapshot for blank users',
        if (!repository.contains('return const OperationResult(success: false)')) '${_relativePath(repositoryFile)} does not reject like mutations for blank users',
      ];

      expect(
        violations,
        isEmpty,
        reason: '用户资料库仓库是账号作用域缓存边界，空账号不能读取或写入资料、喜欢歌曲、歌单、推荐或 FM 缓存，也不能触发对应远程请求。',
      );
    });

    test('feature repositories use narrow user scoped data capabilities', () {
      final violations = _repositoryFiles(libDirectory).where((file) => _contains(file, 'UserScopedDataSource')).map(_relativePath).toList();

      expect(
        violations,
        isEmpty,
        reason: 'feature repository 只能依赖用户资料、曲目列表、歌单列表、订阅、电台或同步标记等窄接口，不能重新吃下整个 UserScopedDataSource。',
      );
    });

    test('drift user scoped aggregate stays delegation only', () {
      final aggregateFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/data_sources/drift_user_scoped_data_source.dart',
      );
      final violations = _containsAny(aggregateFile, const [
        'BujuanDriftDatabase',
        '.select(',
        '.delete(',
        '.batch(',
        '.transaction(',
      ])
          ? [_relativePath(aggregateFile)]
          : const <String>[];

      expect(
        violations,
        isEmpty,
        reason: 'DriftUserScopedDataSource 只做兼容聚合委托；真实表访问应留在窄 Drift data source 或 DAO。',
      );
    });

    test('user scoped drift data sources delegate table access to dao', () {
      const dataSourcePaths = [
        'lib/data/music_data/sources/local/database/data_sources/drift_playlist_subscription_data_source.dart',
        'lib/data/music_data/sources/local/database/data_sources/drift_user_playlist_list_data_source.dart',
        'lib/data/music_data/sources/local/database/data_sources/drift_user_profile_data_source.dart',
        'lib/data/music_data/sources/local/database/data_sources/drift_user_radio_data_source.dart',
        'lib/data/music_data/sources/local/database/data_sources/drift_user_sync_marker_data_source.dart',
        'lib/data/music_data/sources/local/database/data_sources/drift_user_track_list_data_source.dart',
      ];
      final violations = dataSourcePaths
          .map((path) => File('${projectRoot.path}/$path'))
          .where(
            (file) => _containsAny(file, const [
              'BujuanDriftDatabase',
              '.select(',
              '.delete(',
              '.batch(',
              '.transaction(',
              'drift_database.dart',
              'user_dao.dart',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: '用户作用域窄 data source 只做接口适配，Drift 表访问应下沉到 dao。',
      );
    });

    test('core entities and data do not import legacy common UI constants', () {
      final violations = _dartFiles(libDirectory)
          .where((file) {
            final path = _relativePath(file);
            return path.startsWith('lib/core/') || path.startsWith('lib/data/');
          })
          .where(
            (file) => _containsAny(file, const [
              'common/constants/other.dart',
              'common/constants/colors.dart',
              'common/constants/text_styles.dart',
              'common/constants/platform_utils.dart',
              'common/constants/log.dart',
              'common/constants/app_constants.dart',
              'common/constants/enmu.dart',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'core/data 不能继续依赖 common/constants 中的 UI 或历史混合常量。',
      );
    });

    test('feature application layer stays pure Dart', () {
      final applicationFiles = _dartFiles(libDirectory).where((file) {
        final path = _relativePath(file);
        return path.startsWith('lib/features/') && path.contains('/application/');
      });

      final violations = applicationFiles
          .where(
            (file) => _containsAny(file, const [
              'package:flutter/',
              'package:get/get.dart',
              'BuildContext',
              'Widget',
              'Color ',
              'Get.find',
              '.obs',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'feature application 层必须保持纯 Dart；需要 Widget/BuildContext/Color 的组合放到 app presentation adapter。',
      );
    });

    test('app routing does not read local storage details directly', () {
      final routingFiles = _dartFiles(Directory('${projectRoot.path}/lib/app/routing'));
      final violations = routingFiles
          .where(
            (file) => _containsAny(file, const [
              'CacheBox.instance',
              'common/constants/key.dart',
              'package:hive/',
              'package:hive_flutter/',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'app routing 只能消费启动态解析结果，不能直接读取 Hive/CacheBox 或登录态 key。',
      );
    });

    test('presentation adapter imports stay isolated in the composition root', () {
      final bootstrapFiles = _dartFiles(Directory('${projectRoot.path}/lib/app/bootstrap'));
      const allowedFiles = {
        'lib/app/bootstrap/presentation_bootstrap.dart',
      };
      final violations = bootstrapFiles
          .where((file) {
            final path = _relativePath(file);
            return !allowedFiles.contains(path);
          })
          .where(
            (file) => _containsAny(file, const [
              'package:bujuan/ui/',
              '/presentation/',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: '展示层 adapter 只能在 presentation bootstrap 里被装配，不能扩散到普通启动辅助文件。',
      );
    });

    test('legacy mixed constants stay removed', () {
      const removedFiles = [
        'lib/app/theme/other.dart',
        'lib/core/logging/log.dart',
        'lib/core/platform/legacy_platform_utils.dart',
      ];
      final existing = removedFiles.where((path) => File('${projectRoot.path}/$path').existsSync()).toList();

      final importViolations = _dartFiles(libDirectory)
          .where(
            (file) => _containsAny(file, const [
              'app/theme/other.dart',
              'core/logging/log.dart',
              'core/platform/legacy_platform_utils.dart',
            ]),
          )
          .map(_relativePath)
          .toList();

      expect(
        existing,
        isEmpty,
        reason: '混合职责常量入口已经拆到 app/core 下，旧文件不能复活。',
      );
      expect(
        importViolations,
        isEmpty,
        reason: '业务代码必须依赖 app/core 下的明确服务，不能 import 旧混合常量入口。',
      );
    });

    test('old UI port application files stay removed', () {
      const removedFiles = [
        'lib/features/comment/application/comment_content_port.dart',
        'lib/features/settings/application/settings_navigation_port.dart',
        'lib/features/playback/application/playback_theme_port.dart',
        'lib/features/playback/application/playback_artwork_presenter.dart',
      ];
      final existing = removedFiles.where((path) => File('${projectRoot.path}/$path').existsSync()).toList();

      expect(
        existing,
        isEmpty,
        reason: '依赖 Widget/BuildContext/Color 的 port/presenter 不能回到纯 application 层。',
      );
    });

    test('composition root stays split by bootstrap responsibility', () {
      final registrarDirectory = Directory('${projectRoot.path}/lib/app/bootstrap/registrars');
      const expectedFiles = [
        'lib/app/bootstrap/app_bootstrap.dart',
        'lib/app/bootstrap/bootstrap_ui.dart',
        'lib/app/bootstrap/route_bootstrap.dart',
        'lib/app/bootstrap/sdk_bootstrap.dart',
        'lib/app/bootstrap/storage_bootstrap.dart',
        'lib/app/bootstrap/data_source_bootstrap.dart',
        'lib/app/bootstrap/repository_bootstrap.dart',
        'lib/app/bootstrap/data_bootstrap.dart',
        'lib/app/bootstrap/playback_bootstrap.dart',
        'lib/app/bootstrap/presentation_bootstrap.dart',
        'lib/app/bootstrap/feature_bootstrap.dart',
      ];
      const expectedEntrypoints = {
        'lib/app/bootstrap/app_bootstrap.dart': [
          'Future<void> bootstrapApplication()',
          'class AppBinding extends Bindings',
        ],
        'lib/app/bootstrap/bootstrap_ui.dart': [
          'Future<void> initializeBootstrapUi()',
        ],
        'lib/app/bootstrap/route_bootstrap.dart': [
          'class AppRouteBootstrapResult',
          'AppRouteBootstrapResult initializeRouteInfrastructure()',
          'List<PageRouteInfo> buildInitialRoutes()',
        ],
        'lib/app/bootstrap/sdk_bootstrap.dart': [
          'Future<NeteaseMusicApi> initializeSdk({required bool debug})',
        ],
        'lib/app/bootstrap/storage_bootstrap.dart': [
          'class AppStorageBootstrapResult',
          'Future<AppStorageBootstrapResult> initializeStorageInfrastructure()',
        ],
        'lib/app/bootstrap/data_source_bootstrap.dart': [
          'class AppDataSourceBootstrapResult',
          'AppDataSourceBootstrapResult initializeDataSourceInfrastructure({',
          'required NeteaseMusicApi neteaseApi,',
        ],
        'lib/app/bootstrap/repository_bootstrap.dart': [
          'class AppRepositoryBootstrapResult',
          'AppRepositoryBootstrapResult initializeRepositoryInfrastructure({',
          'void registerRepositoryInfrastructure(AppRepositoryBootstrapResult repositories)',
        ],
        'lib/app/bootstrap/data_bootstrap.dart': [
          'Future<void> initializeDataInfrastructure({',
          'required NeteaseMusicApi neteaseApi,',
        ],
        'lib/app/bootstrap/playback_bootstrap.dart': [
          'void registerPlaybackDependencies()',
        ],
        'lib/app/bootstrap/presentation_bootstrap.dart': [
          'void registerPresentationAdapters()',
        ],
        'lib/app/bootstrap/feature_bootstrap.dart': [
          'void registerUserControllers()',
          'void registerFeatureApplications()',
          'void registerFeatureControllers()',
        ],
      };
      final missingFiles = expectedFiles.where((path) => !File('${projectRoot.path}/$path').existsSync()).toList();
      final missingEntrypoints = <String>[];
      for (final entry in expectedEntrypoints.entries) {
        final file = File('${projectRoot.path}/${entry.key}');
        final content = file.existsSync() ? file.readAsStringSync() : '';
        missingEntrypoints.addAll(
          entry.value.where((symbol) => !content.contains(symbol)).map((symbol) => '${entry.key}: $symbol'),
        );
      }
      final appRoot = File('${projectRoot.path}/lib/app.dart').readAsStringSync();
      final appRootImportViolations = RegExp(r"^import '([^']+)';", multiLine: true)
          .allMatches(appRoot)
          .map((match) => match.group(1)!)
          .where(
            (uri) =>
                !uri.startsWith('package:bujuan/app/bootstrap/') && !uri.startsWith('package:bujuan/ui/theme/') && !uri.startsWith('package:bujuan/ui/widgets/') && uri != 'package:flutter/material.dart' && uri != 'package:get/get.dart',
          )
          .toList();
      final appBootstrap = File('${projectRoot.path}/lib/app/bootstrap/app_bootstrap.dart').readAsStringSync();
      final dataBootstrap = File('${projectRoot.path}/lib/app/bootstrap/data_bootstrap.dart').readAsStringSync();
      final dataSourceBootstrap = File('${projectRoot.path}/lib/app/bootstrap/data_source_bootstrap.dart').readAsStringSync();
      final routeBootstrap = File('${projectRoot.path}/lib/app/bootstrap/route_bootstrap.dart').readAsStringSync();
      final repositoryBootstrap = File('${projectRoot.path}/lib/app/bootstrap/repository_bootstrap.dart').readAsStringSync();
      final sdkBootstrap = File('${projectRoot.path}/lib/app/bootstrap/sdk_bootstrap.dart').readAsStringSync();
      final dataNeteaseBootstrap = File('${projectRoot.path}/lib/data/music_data/sources/netease/netease_remote_bootstrap.dart');
      final appBootstrapImportViolations = RegExp(r"^import '([^']+)';", multiLine: true)
          .allMatches(appBootstrap)
          .map((match) => match.group(1)!)
          .where(
            (uri) => !uri.startsWith('package:bujuan/app/bootstrap/') && uri != 'package:flutter/foundation.dart' && uri != 'package:flutter/widgets.dart' && uri != 'package:get/get.dart',
          )
          .toList();
      final routeOwnershipViolations = <String>[
        if (!appRoot.contains('static final AppRouteBootstrapResult _routes = initializeRouteInfrastructure();')) 'app root does not initialize route bootstrap result',
        if (!appRoot.contains('routeInformationParser: _routes.router.defaultRouteParser()')) 'app root does not delegate route parser to route bootstrap',
        if (!appRoot.contains('navigatorObservers: _routes.buildNavigatorObservers')) 'app root does not delegate route observers to route bootstrap',
        if (appRoot.contains('RootRouter(')) 'app root creates RootRouter directly',
        if (appRoot.contains('AppRouterObserver(')) 'app root creates route observer directly',
        if (appRoot.contains('AuthStateStore')) 'app root reads auth state store directly',
        if (!routeBootstrap.contains('RootRouter()')) 'route_bootstrap does not create RootRouter',
        if (!routeBootstrap.contains('hasCachedSession')) 'route_bootstrap does not own initial route session check',
        if (!routeBootstrap.contains('replaceNamed(Routes.login)')) 'route_bootstrap does not own login-expired navigation target',
      ];
      final sdkOwnershipViolations = <String>[
        if (!appBootstrap.contains('final neteaseApi = await initializeSdk(')) 'app_bootstrap does not receive SDK instance from sdk_bootstrap',
        if (!appBootstrap.contains('initializeDataInfrastructure(neteaseApi: neteaseApi)')) 'app_bootstrap does not pass SDK instance into data bootstrap',
        if (appBootstrap.contains('package:netease_music_api/')) 'app_bootstrap imports SDK package directly',
        if (appBootstrap.contains('NeteaseMusicApi')) 'app_bootstrap names SDK facade type directly',
        if (!sdkBootstrap.contains('await NeteaseMusicApi.init(debug: debug);')) 'sdk_bootstrap does not initialize SDK session directly',
        if (!sdkBootstrap.contains('return NeteaseMusicApi();')) 'sdk_bootstrap does not create SDK instance',
        if (sdkBootstrap.contains('netease_remote_bootstrap')) 'sdk_bootstrap initializes SDK through data source boundary',
        if (dataNeteaseBootstrap.existsSync()) 'data netease source still owns SDK initialization bootstrap',
        if (dataBootstrap.contains('NeteaseMusicApi()')) 'data_bootstrap creates SDK instance directly',
        if (!dataBootstrap.contains('neteaseApi: neteaseApi')) 'data_bootstrap does not pass SDK facade into data source bootstrap',
      ];
      final storageOwnershipViolations = <String>[
        if (!dataBootstrap.contains('final storage = await initializeStorageInfrastructure();')) 'data_bootstrap does not receive storage resources from storage_bootstrap',
        if (dataBootstrap.contains('Hive.initFlutter')) 'data_bootstrap initializes Hive directly',
        if (dataBootstrap.contains('CacheBox.init')) 'data_bootstrap initializes CacheBox directly',
        if (dataBootstrap.contains('DriftAppDatabase(')) 'data_bootstrap creates Drift database directly',
      ];
      final dataSourceOwnershipViolations = <String>[
        if (!dataBootstrap.contains('final dataSources = initializeDataSourceInfrastructure(')) 'data_bootstrap does not receive data sources from data_source_bootstrap',
        if (dataBootstrap.contains('appDatabase.local')) 'data_bootstrap reads local data sources directly',
        if (dataBootstrap.contains('appDatabase.user')) 'data_bootstrap reads user scoped data sources directly',
        if (dataBootstrap.contains('appDatabase.appCacheDataSource')) 'data_bootstrap reads cache data source directly',
        if (dataBootstrap.contains('SearchCacheStore(')) 'data_bootstrap creates search cache store directly',
        if (dataBootstrap.contains('ExploreCacheStore(')) 'data_bootstrap creates explore cache store directly',
        if (dataBootstrap.contains('LocalMusicSource(')) 'data_bootstrap creates local music source directly',
        if (!dataSourceBootstrap.contains('NeteaseMusicSource(api: neteaseApi)')) 'data_source_bootstrap does not create netease music source with injected SDK',
        if (!dataSourceBootstrap.contains('NeteaseAuthRemoteDataSource(api: neteaseApi)')) 'data_source_bootstrap does not create netease remote data sources',
      ];
      final repositoryOwnershipViolations = <String>[
        if (!dataBootstrap.contains('final repositories = initializeRepositoryInfrastructure(')) 'data_bootstrap does not receive repositories from repository_bootstrap',
        if (!dataBootstrap.contains('registerRepositoryInfrastructure(repositories);')) 'data_bootstrap does not delegate repository registration',
        if (dataBootstrap.contains('Get.put<MusicDataRepository>')) 'data_bootstrap registers music data repository directly',
        if (dataBootstrap.contains('NeteaseAuthRemoteDataSource(')) 'data_bootstrap creates auth remote data source directly',
        if (dataBootstrap.contains('NeteaseMusicSource(api:')) 'data_bootstrap creates netease music source directly',
        if (repositoryBootstrap.contains('NeteaseMusicSource(api:')) 'repository_bootstrap creates netease music source directly',
        if (repositoryBootstrap.contains('NeteaseAuthRemoteDataSource(')) 'repository_bootstrap creates netease remote data source directly',
        if (dataBootstrap.contains('LocalResourceIndexRepository(')) 'data_bootstrap creates local resource repository directly',
        if (dataBootstrap.contains('LocalArtworkCacheRepository(')) 'data_bootstrap creates artwork cache repository directly',
        if (dataBootstrap.contains('DownloadRepository(')) 'data_bootstrap creates download repository directly',
      ];

      expect(
        registrarDirectory.existsSync(),
        isFalse,
        reason: 'bootstrap 可以按职责拆文件，但不要恢复 registrar 目录层级。',
      );
      expect(
        missingFiles,
        isEmpty,
        reason: 'bootstrap 应按 UI、route、SDK、storage、数据源、repository、数据装配、播放、展示适配器、feature/controller 职责拆分。',
      );
      expect(
        missingEntrypoints,
        isEmpty,
        reason: '每个 bootstrap 文件必须保留清晰入口，避免装配职责重新混到单个大文件。',
      );
      expect(
        appRootImportViolations,
        isEmpty,
        reason: 'App 根组件只能依赖 bootstrap、主题、UI widgets、Flutter 和 GetX，不能直接导入 feature、data 或展示服务细节。',
      );
      expect(
        appBootstrapImportViolations,
        isEmpty,
        reason: 'app_bootstrap 只能导入子 bootstrap、Flutter binding 和 GetX，不能直接导入 data、features、ui 或 SDK 业务文件。',
      );
      expect(
        routeOwnershipViolations,
        isEmpty,
        reason: 'route bootstrap 必须收口根路由、初始路由和登录失效导航，App 根组件只承接 GetMaterialApp.router。',
      );
      expect(
        sdkOwnershipViolations,
        isEmpty,
        reason: 'SDK 实例创建必须由 sdk_bootstrap 收口，data_bootstrap 只接收并注入已经创建好的 API 门面。',
      );
      expect(
        storageOwnershipViolations,
        isEmpty,
        reason: 'storage bootstrap 必须收口 Drift/Hive 初始化，data_bootstrap 只消费已初始化的存储资源。',
      );
      expect(
        dataSourceOwnershipViolations,
        isEmpty,
        reason: 'data source bootstrap 必须收口本地和网易云数据源、音乐来源门面、轻量 cache store 构建，data_bootstrap 只消费结果对象。',
      );
      expect(
        repositoryOwnershipViolations,
        isEmpty,
        reason: 'repository bootstrap 必须只收口核心 repository 和 feature repository 构建，data_bootstrap 只保留启动顺序。',
      );
    });

    test('shell controller only reads approved global controllers', () {
      final shellController = File(
        '${projectRoot.path}/lib/features/shell/shell_controller.dart',
      );
      final violations = <String>[
        if (_containsAny(shellController, const [
          'features/settings/settings_controller.dart',
          '/data/music_data/sources/local/',
          '/data/music_data/sources/netease/',
        ]))
          _relativePath(shellController),
      ];

      expect(
        violations,
        isEmpty,
        reason: 'ShellController 可以读取全局播放/用户控制器，但不能越过 controller 触碰设置控制器或底层数据源。',
      );
    });

    test('demo pages stay in debug feature', () {
      expect(
        File(
          '${projectRoot.path}/lib/ui/pages/playback/coverflow_demo_page_view.dart',
        ).existsSync(),
        isFalse,
        reason: '实验性 demo 页面不能混在正式 playback 页面目录。',
      );
      expect(
        File(
          '${projectRoot.path}/lib/ui/pages/debug/coverflow_demo_page_view.dart',
        ).existsSync(),
        isTrue,
        reason: '实验性 demo 页面应归类到 debug UI 页面目录。',
      );
    });

    test('thin forwarding application and port layers stay removed', () {
      const removedFiles = [
        'lib/features/playlist/application/playlist_detail_service.dart',
        'lib/features/playlist/application/playlist_playback_action.dart',
        'lib/features/playlist/application/playlist_playback_use_case.dart',
        'lib/features/search/application/search_application_service.dart',
        'lib/features/explore/explore_application_service.dart',
        'lib/features/user/application/user_home_application_service.dart',
        'lib/features/download/application/queue_download_use_case.dart',
        'lib/features/download/application/remove_download_use_case.dart',
        'lib/features/download/application/recover_downloads_use_case.dart',
        'lib/features/playback/application/playback_action_port.dart',
        'lib/app/bootstrap/feature_controller_factory.dart',
        'lib/app/presentation_adapters/comment_content_port.dart',
        'lib/app/presentation_adapters/playback_theme_port.dart',
        'lib/app/presentation_adapters/settings_navigation_port.dart',
        'lib/app/presentation_adapters/shell_playback_port.dart',
        'lib/app/presentation_adapters/shell_user_port.dart',
      ];
      final existing = removedFiles.where((path) => File('${projectRoot.path}/$path').existsSync()).toList();

      expect(
        existing,
        isEmpty,
        reason: '不要恢复只有转发价值的 service/usecase/port/factory；普通页面应直接走 controller/repository/PlayerController。',
      );
    });

    test('drift dao layer exists', () {
      const expectedFiles = [
        'lib/data/music_data/sources/local/database/dao/track_dao.dart',
        'lib/data/music_data/sources/local/database/dao/playlist_dao.dart',
        'lib/data/music_data/sources/local/database/dao/user_profile_dao.dart',
        'lib/data/music_data/sources/local/database/dao/user_track_list_dao.dart',
        'lib/data/music_data/sources/local/database/dao/user_playlist_subscription_dao.dart',
        'lib/data/music_data/sources/local/database/dao/user_sync_marker_dao.dart',
        'lib/data/music_data/sources/local/database/dao/radio_dao.dart',
        'lib/data/music_data/sources/local/database/dao/download_task_dao.dart',
        'lib/data/music_data/sources/local/database/dao/resource_dao.dart',
        'lib/data/music_data/sources/local/database/dao/cache_dao.dart',
      ];
      final missing = expectedFiles.where((path) => !File('${projectRoot.path}/$path').existsSync()).toList();

      expect(
        missing,
        isEmpty,
        reason: 'Drift 手写数据访问必须有 DAO 分类入口，data source 只能保留 facade/组合职责。',
      );
    });

    test('local music source keeps database and resource details nested', () {
      final localRoot = Directory('${projectRoot.path}/lib/data/music_data/sources/local');
      final rootDartFiles = localRoot.listSync().whereType<File>().where((file) => file.path.endsWith('.dart')).map(_relativePath).toList();
      final unexpectedRootFiles = rootDartFiles
          .where(
            (path) => path != 'lib/data/music_data/sources/local/local_music_source.dart',
          )
          .toList();
      final unexpectedRootDirectories =
          localRoot.listSync().whereType<Directory>().map((entity) => entity.uri.pathSegments.where((segment) => segment.isNotEmpty).last).where((name) => !const {'database', 'resources'}.contains(name)).toList();
      final flatLocalDetails = _dartFiles(localRoot)
          .where((file) {
            final path = _relativePath(file);
            return path.startsWith('lib/data/music_data/sources/local/') &&
                !path.startsWith('lib/data/music_data/sources/local/database/') &&
                !path.startsWith('lib/data/music_data/sources/local/resources/') &&
                path != 'lib/data/music_data/sources/local/local_music_source.dart';
          })
          .map(_relativePath)
          .toList();
      final bootstrap = File('${projectRoot.path}/lib/app/bootstrap/app_bootstrap.dart');
      final bootstrapViolations = _containsAny(bootstrap, const [
        'package:bujuan/data/music_data/sources/local/database/dao/',
        'package:bujuan/data/music_data/sources/local/database/data_sources/drift_',
      ]);

      expect(
        unexpectedRootFiles,
        isEmpty,
        reason: 'local 根层只暴露本地音乐来源门面，数据库和资源细节必须下沉。',
      );
      expect(
        unexpectedRootDirectories,
        isEmpty,
        reason: 'local 根层只允许 database 与 resources 两条实现边界。',
      );
      expect(
        flatLocalDetails,
        isEmpty,
        reason: 'drift_*、*_data_source.dart、*_record.dart 不能继续平铺在 local 根层。',
      );
      expect(
        bootstrapViolations,
        isFalse,
        reason: '组合根可以装配 AppDatabase 和资源仓库，但不能直接 import DAO 或 Drift data source 实现。',
      );
    });

    test('drift dao layer owns real data access methods', () {
      const expectedMethods = {
        'lib/data/music_data/sources/local/database/dao/cache_dao.dart': ['load(', 'save(', 'delete('],
        'lib/data/music_data/sources/local/database/dao/download_task_dao.dart': [
          'getTask(',
          'saveTask(',
          'watchTasks(',
        ],
        'lib/data/music_data/sources/local/database/dao/resource_dao.dart': [
          'getResource(',
          'saveResource(',
          'listAudioResources(',
        ],
        'lib/data/music_data/sources/local/database/dao/track_dao.dart': [
          'getTrack(',
          'saveTracks(',
          'getLyrics(',
        ],
        'lib/data/music_data/sources/local/database/dao/playlist_dao.dart': [
          'getPlaylist(',
          'savePlaylists(',
          'loadTrackRefsByPlaylistIds(',
        ],
        'lib/data/music_data/sources/local/database/dao/user_profile_dao.dart': [
          'loadProfile(',
          'saveProfile(',
        ],
        'lib/data/music_data/sources/local/database/dao/user_track_list_dao.dart': [
          'loadTrackIds(',
          'replaceTrackList(',
          'appendTrackList(',
        ],
        'lib/data/music_data/sources/local/database/dao/user_playlist_subscription_dao.dart': [
          'loadPlaylistSubscriptionState(',
          'savePlaylistSubscriptionState(',
        ],
        'lib/data/music_data/sources/local/database/dao/user_sync_marker_dao.dart': [
          'loadSyncMarker(',
          'markSyncMarkerUpdated(',
        ],
        'lib/data/music_data/sources/local/database/dao/radio_dao.dart': [
          'loadSubscribedRadios(',
          'replaceSubscribedRadios(',
          'loadPrograms(',
          'replacePrograms(',
        ],
      };
      final violations = <String>[];
      for (final entry in expectedMethods.entries) {
        final file = File('${projectRoot.path}/${entry.key}');
        if (!file.existsSync()) {
          violations.add('${entry.key} missing');
          continue;
        }
        final content = file.readAsStringSync();
        for (final method in entry.value) {
          if (!content.contains(method)) {
            violations.add('${entry.key} missing $method');
          }
        }
        if (content.contains('BujuanDriftDatabase get database')) {
          violations.add('${entry.key} exposes raw database');
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'DAO 不能只是 database 占位壳，必须承接实际 Drift 读写方法且不向上暴露 raw database。',
      );
    });

    test('drift table definitions stay split by schema domain', () {
      final databaseFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/drift_database.dart',
      );
      final databaseContent = databaseFile.readAsStringSync();
      const expectedSchemaParts = {
        'schema/drift_playback_tables.dart': [
          'class PlaybackRestoreEntries extends Table',
        ],
        'schema/drift_local_resource_tables.dart': [
          'class LocalResourceEntries extends Table',
        ],
        'schema/drift_download_tables.dart': [
          'class DownloadTasks extends Table',
        ],
        'schema/drift_cache_tables.dart': [
          'class AppCacheEntries extends Table',
        ],
        'schema/drift_library_tables.dart': [
          'class Tracks extends Table',
          'class Albums extends Table',
          'class Artists extends Table',
        ],
        'schema/drift_playlist_tables.dart': [
          'class Playlists extends Table',
          'class PlaylistTrackRefs extends Table',
        ],
        'schema/drift_user_tables.dart': [
          'class UserProfiles extends Table',
          'class UserSyncMarkers extends Table',
        ],
      };
      final violations = <String>[
        if (databaseContent.contains(' extends Table')) 'drift_database.dart defines tables',
        if (File('${projectRoot.path}/lib/data/music_data/sources/local/database/schema/drift_tables.dart').existsSync()) 'legacy drift_tables.dart exists',
      ];
      for (final entry in expectedSchemaParts.entries) {
        final partPath = entry.key;
        final partFile = File(
          '${projectRoot.path}/lib/data/music_data/sources/local/database/$partPath',
        );
        if (!databaseContent.contains("part '$partPath';")) {
          violations.add('missing $partPath part');
        }
        if (!partFile.existsSync()) {
          violations.add('$partPath missing');
          continue;
        }
        final partContent = partFile.readAsStringSync();
        if (!partContent.contains("part of '../drift_database.dart';")) {
          violations.add('$partPath missing part-of');
        }
        for (final expectedTable in entry.value) {
          if (!partContent.contains(expectedTable)) {
            violations.add('$partPath missing $expectedTable');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Drift 表定义必须按 playback、local_resource、download、cache、library、playlist、user 业务域拆分。',
      );
    });

    test('drift schema maintenance sql stays in schema part', () {
      final databaseFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/drift_database.dart',
      );
      final maintenancePartFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/schema/drift_schema_maintenance.dart',
      );
      final databaseContent = databaseFile.readAsStringSync();
      final maintenanceContent = maintenancePartFile.readAsStringSync();
      final violations = <String>[
        if (!databaseContent.contains("part 'schema/drift_schema_maintenance.dart';")) 'missing maintenance part',
        if (databaseContent.contains('CREATE INDEX')) 'drift_database.dart creates indexes',
        if (databaseContent.contains('DROP TABLE')) 'drift_database.dart drops tables',
        if (!maintenanceContent.contains("part of '../drift_database.dart';")) 'maintenance part missing part-of',
        if (!maintenanceContent.contains('dropAllTablesForMigration(')) 'maintenance part missing migration drops',
        if (!maintenanceContent.contains('createQueryIndexes(')) 'maintenance part missing index creation',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'Drift 迁移和索引 SQL 必须放在 schema/drift_schema_maintenance.dart，主数据库文件只做组合入口。',
      );
    });

    test('large architecture files are reported as soft risks', () {
      const watchedFiles = {
        'lib/features/playback/player_controller.dart': 450,
        'lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart': 900,
        'lib/features/download/download_repository.dart': 360,
        'lib/data/music_data/sources/local/database/data_sources/drift_local_library_data_source.dart': 360,
        'lib/data/music_data/sources/local/database/data_sources/drift_user_scoped_data_source.dart': 500,
      };
      final risks = <String>[];
      for (final entry in watchedFiles.entries) {
        final file = File('${projectRoot.path}/${entry.key}');
        if (!file.existsSync()) {
          continue;
        }
        final lineCount = file.readAsLinesSync().length;
        if (lineCount > entry.value) {
          risks.add('${entry.key}: $lineCount > ${entry.value}');
        }
      }
      if (risks.isNotEmpty) {
        // 软报告：历史大文件不直接阻断测试，但输出会提醒后续提交不要继续堆职责。
        // ignore: avoid_print
        print('Architecture size risks: ${risks.join(', ')}');
      }
      expect(risks, isA<List<String>>());
    });
  });
}

Iterable<File> _dartFiles(Directory directory) {
  if (!directory.existsSync()) {
    return const [];
  }
  return directory.listSync(recursive: true).whereType<File>().where((file) => file.path.endsWith('.dart'));
}

Iterable<File> _repositoryFiles(Directory directory) {
  return _dartFiles(directory).where((file) {
    final path = _relativePath(file);
    return path.startsWith('lib/features/') && path.endsWith('_repository.dart');
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
  return path == 'lib/features/playback/playback_service.dart' ||
      path == 'lib/features/playback/application/audio_service_handler.dart' ||
      path == 'lib/features/playback/application/audio_service_queue_synchronizer.dart' ||
      path == 'lib/features/playback/application/playback_queue_item_adapter.dart' ||
      _isTemporaryMediaItemBoundaryException(path);
}

bool _isAllowedNeteaseSdkBoundary(String path) {
  return _allowedNeteaseSdkBootstrapFiles.contains(path) || path.startsWith('lib/data/music_data/sources/netease/');
}

const _allowedNeteaseSdkBootstrapFiles = {
  'lib/app/bootstrap/sdk_bootstrap.dart',
  'lib/app/bootstrap/data_bootstrap.dart',
  'lib/app/bootstrap/data_source_bootstrap.dart',
};

String _featureName(String path) {
  final parts = path.split('/');
  if (parts.length < 3 || parts[0] != 'lib' || parts[1] != 'features') {
    return '';
  }
  return parts[2];
}

List<String> _featureImports(File file) {
  final importPattern = RegExp(r"import 'package:bujuan/features/([^/]+)/[^']*';");
  return importPattern.allMatches(file.readAsStringSync()).map((match) => match.group(1) ?? '').where((feature) => feature.isNotEmpty).toList();
}

bool _isTemporaryGetFindFactoryException(String path) {
  return false;
}

bool _isTemporaryMediaItemBoundaryException(String path) {
  return false;
}

bool _isGeneratedDartFile(String path) {
  return path.endsWith('.g.dart') || path.endsWith('.freezed.dart') || path.contains('/generated/');
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
  return file.path.replaceFirst('$root/', '').replaceAll(Platform.pathSeparator, '/');
}

String _markdownSection(String content, String header) {
  final start = content.indexOf(header);
  if (start < 0) {
    return '';
  }
  final rest = content.substring(start);
  final next = rest.indexOf('\n## ', header.length);
  return next < 0 ? rest : rest.substring(0, next);
}
