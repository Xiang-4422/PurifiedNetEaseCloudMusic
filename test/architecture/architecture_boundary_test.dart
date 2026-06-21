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
      final unexpectedMusicDataRootEntries =
          musicDataRoot.listSync().map((entity) => entity.uri.pathSegments.where((segment) => segment.isNotEmpty).last).where((name) => !const {'music_data_repository.dart', 'sources'}.contains(name)).toList();

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
        reason: 'music_data 根目录只放统一入口 music_data_repository.dart 和 sources 目录。',
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
        if (repositoryContent.contains('Map<String, Future<String?>> _playbackUrlLoads')) 'repository still owns playback URL in-flight loads',
        if (repositoryContent.contains('Map<String, _CachedPlaybackUrl> _playbackUrlCache')) 'repository still owns playback URL cache entries',
        if (repositoryContent.contains('class _CachedPlaybackUrl')) 'repository still owns cached playback URL model',
        if (!coordinatorContent.contains('final Map<String, Future<String?>> _loads')) 'coordinator does not own in-flight load state',
        if (!coordinatorContent.contains('final Map<String, _CachedPlaybackUrl> _cache')) 'coordinator does not own cache state',
      ];

      expect(
        violations,
        isEmpty,
        reason: '播放 URL 短 TTL、并发合并、本地资源优先重查和 LRU 淘汰必须留在独立协调器，MusicDataRepository 只编排数据来源。',
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

    test('playback metadata key access stays in queue boundary codecs', () {
      const allowedPaths = {
        'lib/features/playback/application/playback_queue_item_adapter.dart',
        'lib/features/playback/application/playback_queue_item_cache_codec.dart',
        'lib/features/playback/application/playback_queue_item_mapper.dart',
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
        reason: 'PlaybackQueueItem.metadata 动态键只能在 mapper/adapter/cache codec 边界做兼容迁移，播放服务和 controller 必须使用显式字段。',
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

    test('legacy business fact keys stay out of Hive app cache keys', () {
      final keysFile = File('${projectRoot.path}/lib/data/app_storage/app_cache_keys.dart');
      final content = keysFile.readAsStringSync();
      const forbiddenKeys = {
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
      final violations = <String>[
        if (repository.contains('hasCachedLogin')) 'auth repository exposes login flag as cached login',
        if (!repository.contains('hasCachedSession => _stateStore.hasCachedSession')) 'auth repository does not expose cached session',
        if (controller.contains('hasCachedLogin')) 'auth controller branches on login flag',
        if (!controller.contains('hasCachedSession')) 'auth controller does not branch on cached session',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'App 当前用户必须由可解析 session 驱动，不能只凭 SDK cookie 或孤立登录标记恢复账号状态。',
      );
    });

    test('manual logout routes through auth effect boundary', () {
      final authController = File('${projectRoot.path}/lib/features/auth/auth_controller.dart').readAsStringSync();
      final userProfilePage = File('${projectRoot.path}/lib/ui/pages/user/user_setting_view.dart').readAsStringSync();
      final violations = <String>[
        if (!authController.contains('Future<void> logoutCurrentUser()')) 'auth controller does not own manual logout flow',
        if (!authController.contains("AuthUiEffect.loginExpired('已退出登录')")) 'manual logout does not emit login-page effect',
        if (!userProfilePage.contains('logoutCurrentUser()')) 'user profile page does not use auth logout flow',
        if (userProfilePage.contains('AutoRouter.of(context)')) 'user profile page manipulates router after logout',
        if (userProfilePage.contains('UserSessionController.to.clearUser()')) 'user profile page clears session directly',
      ];

      expect(
        violations,
        isEmpty,
        reason: '主动注销需要复用 AuthController 的登录页副作用，避免 UI 绕过路由边界或只清 session 后留在已登录壳层。',
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
        'UserDao',
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
      final appBootstrap = File('${projectRoot.path}/lib/app/bootstrap/app_bootstrap.dart').readAsStringSync();
      final dataBootstrap = File('${projectRoot.path}/lib/app/bootstrap/data_bootstrap.dart').readAsStringSync();
      final routeBootstrap = File('${projectRoot.path}/lib/app/bootstrap/route_bootstrap.dart').readAsStringSync();
      final repositoryBootstrap = File('${projectRoot.path}/lib/app/bootstrap/repository_bootstrap.dart').readAsStringSync();
      final sdkBootstrap = File('${projectRoot.path}/lib/app/bootstrap/sdk_bootstrap.dart').readAsStringSync();
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
        if (!sdkBootstrap.contains('return NeteaseMusicApi();')) 'sdk_bootstrap does not create SDK instance',
        if (dataBootstrap.contains('NeteaseMusicApi()')) 'data_bootstrap creates SDK instance directly',
      ];
      final storageOwnershipViolations = <String>[
        if (!dataBootstrap.contains('final storage = await initializeStorageInfrastructure();')) 'data_bootstrap does not receive storage resources from storage_bootstrap',
        if (dataBootstrap.contains('Hive.initFlutter')) 'data_bootstrap initializes Hive directly',
        if (dataBootstrap.contains('CacheBox.init')) 'data_bootstrap initializes CacheBox directly',
        if (dataBootstrap.contains('DriftAppDatabase(')) 'data_bootstrap creates Drift database directly',
      ];
      final dataSourceOwnershipViolations = <String>[
        if (!dataBootstrap.contains('final dataSources = initializeDataSourceInfrastructure(appDatabase: appDatabase);')) 'data_bootstrap does not receive data sources from data_source_bootstrap',
        if (dataBootstrap.contains('appDatabase.local')) 'data_bootstrap reads local data sources directly',
        if (dataBootstrap.contains('appDatabase.user')) 'data_bootstrap reads user scoped data sources directly',
        if (dataBootstrap.contains('appDatabase.appCacheDataSource')) 'data_bootstrap reads cache data source directly',
        if (dataBootstrap.contains('SearchCacheStore(')) 'data_bootstrap creates search cache store directly',
        if (dataBootstrap.contains('ExploreCacheStore(')) 'data_bootstrap creates explore cache store directly',
        if (dataBootstrap.contains('LocalMusicSource(')) 'data_bootstrap creates local music source directly',
      ];
      final repositoryOwnershipViolations = <String>[
        if (!dataBootstrap.contains('final repositories = initializeRepositoryInfrastructure(')) 'data_bootstrap does not receive repositories from repository_bootstrap',
        if (!dataBootstrap.contains('registerRepositoryInfrastructure(repositories);')) 'data_bootstrap does not delegate repository registration',
        if (!repositoryBootstrap.contains('NeteaseMusicSource(api: neteaseApi)')) 'repository_bootstrap does not construct netease music source with injected SDK',
        if (dataBootstrap.contains('Get.put<MusicDataRepository>')) 'data_bootstrap registers music data repository directly',
        if (dataBootstrap.contains('NeteaseAuthRemoteDataSource(')) 'data_bootstrap creates auth remote data source directly',
        if (dataBootstrap.contains('NeteaseMusicSource(api:')) 'data_bootstrap creates netease music source directly',
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
        reason: 'data source bootstrap 必须收口本地数据源和轻量 cache store 构建，data_bootstrap 只消费结果对象。',
      );
      expect(
        repositoryOwnershipViolations,
        isEmpty,
        reason: 'repository bootstrap 必须收口核心 repository、feature repository 和远程 data source 构建，data_bootstrap 只保留启动顺序。',
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
        'lib/data/music_data/sources/local/database/dao/user_dao.dart',
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
        'lib/data/music_data/sources/local/database/dao/user_dao.dart': [
          'loadProfile(',
          'saveProfile(',
          'loadTrackIds(',
          'replaceTrackList(',
          'loadPlaylistSubscriptionState(',
          'loadSyncMarker(',
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
  return path.startsWith('lib/app/bootstrap/') || path.startsWith('lib/data/music_data/sources/netease/');
}

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
