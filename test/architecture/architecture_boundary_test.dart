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
        File('${projectRoot.path}/docs/project_architecture_mapping.md').existsSync(),
        isTrue,
        reason: '项目必须维护一份把中小项目规范映射到当前 app/ui/features/data/core 的说明，避免后续机械搬目录。',
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

    test('remote services and repositories are constructed in composition root', () {
      final remoteFiles = [
        ..._dartFiles(Directory('${projectRoot.path}/lib/data/netease/remote')),
        File('${projectRoot.path}/lib/data/netease/netease_music_source.dart'),
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
      final violations = _dartFiles(Directory('${projectRoot.path}/lib/core')).where((file) => _contains(file, 'package:bujuan/data/netease/')).map(_relativePath).toList();

      expect(
        violations,
        isEmpty,
        reason: 'core 是跨数据源基础层，不能反向依赖网易云实现；请求细节应留在 data/netease/api/client。',
      );
    });

    test('netease remote data sources depend on api facade only', () {
      final remoteFiles = _dartFiles(Directory('${projectRoot.path}/lib/data/netease/remote'));
      final violations = remoteFiles
          .where(
            (file) => _containsAny(file, const [
              'package:bujuan/data/netease/api/client/',
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

    test('netease endpoint and model files do not import public api barrel', () {
      final sdkFiles = [
        ..._dartFiles(
          Directory('${projectRoot.path}/lib/data/netease/api/endpoints'),
        ),
        ..._dartFiles(
          Directory('${projectRoot.path}/lib/data/netease/api/models'),
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
              'package:bujuan/data/netease/remote/',
              'package:bujuan/data/local/',
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
              'package:bujuan/data/',
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
        'lib/app/bootstrap/app_bootstrap.dart',
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
        reason: '展示层 adapter 只能在 composition root 里被装配，不能扩散到普通 bootstrap 辅助文件。',
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

    test('composition root stays consolidated but sectioned', () {
      final registrarDirectory = Directory('${projectRoot.path}/lib/app/bootstrap/registrars');
      final bootstrapFile = File('${projectRoot.path}/lib/app/bootstrap/app_bootstrap.dart');
      final content = bootstrapFile.readAsStringSync();
      const expectedSections = [
        'Future<void> bootstrapApplication()',
        'class AppBinding extends Bindings',
        'Future<void> _initAppInfrastructure()',
        'void _registerInfrastructure({',
        'void _registerRepositories({',
        'void _registerUserControllers()',
        'void _registerPlayback()',
        'void _registerPresentationAdapters()',
        'void _registerFeatureApplications()',
        'void _registerFeatureControllers()',
      ];
      final missingSections = expectedSections.where((section) => !content.contains(section)).toList();

      expect(
        registrarDirectory.existsSync(),
        isFalse,
        reason: 'bootstrap 目录保持一个组合根文件，避免 registrar 文件层级重新膨胀。',
      );
      expect(
        missingSections,
        isEmpty,
        reason: '单文件组合根仍要用清晰私有 section 分隔初始化、仓库、播放、展示适配器和控制器职责。',
      );
    });

    test('shell controller only reads approved global controllers', () {
      final shellController = File(
        '${projectRoot.path}/lib/features/shell/shell_controller.dart',
      );
      final violations = <String>[
        if (_containsAny(shellController, const [
          'features/settings/settings_controller.dart',
          '/data/local/',
          '/data/netease/',
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
        'lib/data/local/dao/track_dao.dart',
        'lib/data/local/dao/playlist_dao.dart',
        'lib/data/local/dao/user_dao.dart',
        'lib/data/local/dao/download_task_dao.dart',
        'lib/data/local/dao/resource_dao.dart',
        'lib/data/local/dao/cache_dao.dart',
      ];
      final missing = expectedFiles.where((path) => !File('${projectRoot.path}/$path').existsSync()).toList();

      expect(
        missing,
        isEmpty,
        reason: 'Drift 手写数据访问必须有 DAO 分类入口，data source 只能保留 facade/组合职责。',
      );
    });

    test('drift dao layer owns real data access methods', () {
      const expectedMethods = {
        'lib/data/local/dao/cache_dao.dart': ['load(', 'save(', 'delete('],
        'lib/data/local/dao/download_task_dao.dart': [
          'getTask(',
          'saveTask(',
          'watchTasks(',
        ],
        'lib/data/local/dao/resource_dao.dart': [
          'getResource(',
          'saveResource(',
          'listAudioResources(',
        ],
        'lib/data/local/dao/track_dao.dart': [
          'getTrack(',
          'saveTracks(',
          'getLyrics(',
        ],
        'lib/data/local/dao/playlist_dao.dart': [
          'getPlaylist(',
          'savePlaylists(',
          'loadTrackRefsByPlaylistIds(',
        ],
        'lib/data/local/dao/user_dao.dart': [
          'loadProfile(',
          'saveProfile(',
          'loadTrackIds(',
          'replaceTrackList(',
          'loadPlaylistSubscriptionState(',
          'loadSyncMarker(',
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

    test('large architecture files are reported as soft risks', () {
      const watchedFiles = {
        'lib/features/playback/player_controller.dart': 450,
        'lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart': 900,
        'lib/features/download/download_repository.dart': 360,
        'lib/data/local/drift_local_library_data_source.dart': 360,
        'lib/data/local/drift_user_scoped_data_source.dart': 500,
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
