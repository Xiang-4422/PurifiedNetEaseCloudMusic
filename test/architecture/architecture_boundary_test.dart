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
        domainFlutterViolations,
        isEmpty,
        reason: 'domain 必须保持纯 Dart，不能依赖 Flutter、audio_service 或 just_audio。',
      );
    });

    test('data and lyric parser stay Flutter free', () {
      final handWrittenDataFiles =
          _dartFiles(Directory('${projectRoot.path}/lib/data'))
              .where((file) => !_isGeneratedDartFile(_relativePath(file)));
      final lyricParserFiles = _dartFiles(
        Directory('${projectRoot.path}/lib/common/lyric_parser'),
      );

      final violations = [
        ...handWrittenDataFiles,
        ...lyricParserFiles,
      ]
          .where((file) => _contains(file, 'package:flutter/'))
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'data 和歌词解析模型必须保持纯 Dart；Flutter 绘制对象只能留在 presentation adapter。',
      );
    });

    test('core does not depend on netease data implementation', () {
      final violations = _dartFiles(Directory('${projectRoot.path}/lib/core'))
          .where((file) => _contains(file, 'package:bujuan/data/netease/'))
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'core 是跨数据源基础层，不能反向依赖网易云实现；请求细节应留在 data/netease/api/client。',
      );
    });

    test('netease remote data sources depend on api facade only', () {
      final remoteFiles =
          _dartFiles(Directory('${projectRoot.path}/lib/data/netease/remote'));
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
        reason:
            'remote data source 只能通过构造注入的 NeteaseMusicApi 门面访问接口，不能触碰底层 Dio client 或临时创建 SDK 单例。',
      );
    });

    test('netease endpoint and model files do not import public api barrel',
        () {
      final sdkFiles = [
        ..._dartFiles(
          Directory('${projectRoot.path}/lib/data/netease/api/endpoints'),
        ),
        ..._dartFiles(
          Directory('${projectRoot.path}/lib/data/netease/api/models'),
        ),
      ];
      final violations = sdkFiles
          .where((file) => _contains(file, 'netease_music_api.dart'))
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            'api/endpoints 和 api/models 不能反向 import 对外 barrel；内部应依赖 client 或具体 DTO 文件，避免 SDK 内部循环依赖。',
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

    test('playback selection layer stays independent from audio service', () {
      final selectionFiles = _dartFiles(
        Directory('${projectRoot.path}/lib/features/playback'),
      ).where((file) {
        final path = _relativePath(file);
        return path.contains('playback_selection') ||
            path.endsWith('playback_switch_coordinator.dart') ||
            path.endsWith('playback_switch_trigger.dart');
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
        reason:
            'UI selection 表示用户意图，不能依赖 audio_service MediaItem；底层 confirmed 状态才允许进入 audio_service 边界。',
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
          'syncQueueSnapshot',
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
        reason:
            '队列顺序和 selection 只能由 PlaybackQueueService/SelectionService 决定，audio adapter 与 synchronizer 不能反向改写。',
      );
    });

    test('audio service transport controls route back to selection command',
        () {
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

    test('presentation does not import repositories directly', () {
      final violations = _dartFiles(libDirectory)
          .where((file) => _relativePath(file).contains('/presentation/'))
          .where((file) => _contains(file, '_repository.dart'))
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            'presentation 只能依赖 controller/application service，不能直接持有 repository。',
      );
    });

    test('presentation does not import other feature presentation directly',
        () {
      final violations = <String>[];
      for (final file in _dartFiles(libDirectory)) {
        final path = _relativePath(file);
        if (!path.contains('/presentation/')) {
          continue;
        }
        final ownerFeature = _featureName(path);
        for (final import in _featurePresentationImports(file)) {
          if (_isAllowedPresentationFeatureImport(
            ownerFeature: ownerFeature,
            importedFeature: import,
          )) {
            continue;
          }
          violations.add('$path -> features/$import/presentation');
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'presentation 不能横向直连其他 feature 页面，跨页面跳转应走 route 或明确 wrapper。',
      );
    });

    test('application factories do not read GetX container directly', () {
      final violations = _dartFiles(libDirectory)
          .where((file) {
            final path = _relativePath(file);
            return path.startsWith('lib/features/') &&
                (path.contains('/application/') ||
                    path.endsWith('_page_controller.dart') ||
                    path.endsWith('_scan_controller.dart'));
          })
          .where((file) => _contains(file, 'Get.find<'))
          .map(_relativePath)
          .where((path) => !_isTemporaryGetFindFactoryException(path))
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            'application/page controller 应使用构造函数注入，Get.find 只能留在 binding/route/controller/presentation 装配边界。',
      );
    });

    test('feature application layer does not import presentation', () {
      final violations = _dartFiles(libDirectory)
          .where((file) {
            final path = _relativePath(file);
            return path.startsWith('lib/features/') &&
                path.contains('/application/');
          })
          .where((file) => _contains(file, '/presentation/'))
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            'application 层不能反向 import presentation，展示组合必须留在 route/binding/presentation 边界。',
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
        reason:
            'repository 不能依赖 controller；页面流程应放在 controller/application service。',
      );
    });

    test('controllers do not import data sources directly', () {
      final violations = _dartFiles(libDirectory)
          .where((file) {
            final path = _relativePath(file);
            return path.startsWith('lib/features/') &&
                (path.endsWith('_controller.dart') ||
                    path.endsWith('_page_controller.dart') ||
                    path.endsWith('_scan_controller.dart'));
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
        reason:
            'controller 不能直连 data source，应通过 application service 或 repository。',
      );
    });

    test('non playback presentation does not import PlayerController', () {
      final violations = _dartFiles(libDirectory)
          .where((file) {
            final path = _relativePath(file);
            return path.startsWith('lib/features/') &&
                path.contains('/presentation/') &&
                !path.startsWith('lib/features/playback/presentation/') &&
                !path.startsWith('lib/features/debug/presentation/');
          })
          .where((file) =>
              _contains(file, 'features/playback/player_controller.dart'))
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            '非 playback presentation 应通过 PlaybackActionPort 使用播放能力，不能直接依赖 PlayerController。',
      );
    });

    test('playlist shared widgets stay controller free', () {
      final playlistWidgetFile = File(
          '${projectRoot.path}/lib/features/playlist/playlist_widgets.dart');
      final violations = <String>[
        if (_contains(playlistWidgetFile, 'PlayerController'))
          _relativePath(playlistWidgetFile),
      ];

      expect(
        violations,
        isEmpty,
        reason: 'playlist 共享展示组件不能直接依赖播放 controller，播放行为应由回调或业务 wrapper 注入。',
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

    test('core data domain do not import legacy common UI constants', () {
      final violations = _dartFiles(libDirectory)
          .where((file) {
            final path = _relativePath(file);
            return path.startsWith('lib/core/') ||
                path.startsWith('lib/data/') ||
                path.startsWith('lib/domain/');
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
        reason: 'core/data/domain 不能继续依赖 common/constants 中的 UI 或历史混合常量。',
      );
    });

    test('feature application layer stays pure Dart', () {
      final applicationFiles = _dartFiles(libDirectory).where((file) {
        final path = _relativePath(file);
        return path.startsWith('lib/features/') &&
            path.contains('/application/');
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
        reason:
            'feature application 层必须保持纯 Dart；需要 Widget/BuildContext/Color 的组合放到 app presentation adapter。',
      );
    });

    test('app routing does not read local storage details directly', () {
      final routingFiles =
          _dartFiles(Directory('${projectRoot.path}/lib/app/routing'));
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

    test('presentation adapter imports stay isolated in bootstrap', () {
      final bootstrapFiles =
          _dartFiles(Directory('${projectRoot.path}/lib/app/bootstrap'));
      final violations = bootstrapFiles
          .where((file) {
            final path = _relativePath(file);
            return path !=
                'lib/app/bootstrap/registrars/presentation_adapter_registrar.dart';
          })
          .where((file) => _contains(file, '/presentation/'))
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            'AppBinding 和普通 registrar 不能直接构造 presentation，只有 presentation adapter registrar 可以承接 Widget/route adapter。',
      );
    });

    test('legacy mixed constants stay removed', () {
      const removedFiles = [
        'lib/common/constants/other.dart',
        'lib/common/constants/log.dart',
        'lib/common/constants/platform_utils.dart',
      ];
      final existing = removedFiles
          .where((path) => File('${projectRoot.path}/$path').existsSync())
          .toList();

      final importViolations = _dartFiles(libDirectory)
          .where(
            (file) => _containsAny(file, const [
              'common/constants/other.dart',
              'common/constants/log.dart',
              'common/constants/platform_utils.dart',
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
      final existing = removedFiles
          .where((path) => File('${projectRoot.path}/$path').existsSync())
          .toList();

      expect(
        existing,
        isEmpty,
        reason:
            '依赖 Widget/BuildContext/Color 的 port/presenter 不能回到纯 application 层。',
      );
    });

    test('composition root is split into focused registrars', () {
      const expectedRegistrars = [
        'infrastructure_registrar.dart',
        'repository_registrar.dart',
        'playback_registrar.dart',
        'user_registrar.dart',
        'feature_controller_registrar.dart',
        'presentation_adapter_registrar.dart',
      ];
      final missing = expectedRegistrars
          .where(
            (name) => !File(
              '${projectRoot.path}/lib/app/bootstrap/registrars/$name',
            ).existsSync(),
          )
          .toList();

      expect(
        missing,
        isEmpty,
        reason: 'AppBinding 必须保持轻量入口，具体注册职责拆到 registrar，避免组合根重新膨胀。',
      );
    });

    test('shell controller uses composition ports for cross-feature state', () {
      final shellController = File(
        '${projectRoot.path}/lib/features/shell/shell_controller.dart',
      );
      final violations = <String>[
        if (_containsAny(shellController, const [
          'features/playback/player_controller.dart',
          'features/settings/settings_controller.dart',
          'features/user/user_session_controller.dart',
        ]))
          _relativePath(shellController),
      ];

      expect(
        violations,
        isEmpty,
        reason:
            'ShellController 只协调壳层 UI；播放、设置、用户状态应通过 app presentation adapter port 接入。',
      );
    });

    test('demo pages stay in debug feature', () {
      expect(
        File(
          '${projectRoot.path}/lib/features/playback/presentation/coverflow_demo_page_view.dart',
        ).existsSync(),
        isFalse,
        reason: '实验性 demo 页面不能继续混在正式 playback presentation 目录。',
      );
      expect(
        File(
          '${projectRoot.path}/lib/features/debug/presentation/coverflow_demo_page_view.dart',
        ).existsSync(),
        isTrue,
        reason: '实验性 demo 页面应归类到 debug feature。',
      );
    });

    test('application service and download usecase layer exists', () {
      const expectedFiles = [
        'lib/features/playlist/application/playlist_detail_service.dart',
        'lib/features/search/application/search_application_service.dart',
        'lib/features/user/application/user_home_application_service.dart',
        'lib/features/download/application/queue_download_use_case.dart',
        'lib/features/download/application/remove_download_use_case.dart',
        'lib/features/download/application/recover_downloads_use_case.dart',
      ];
      final missing = expectedFiles
          .where((path) => !File('${projectRoot.path}/$path').existsSync())
          .toList();

      expect(
        missing,
        isEmpty,
        reason:
            '页面流程必须有明确 application service/usecase 落点，不能继续只堆在 repository 或 controller。',
      );
    });

    test('application services are actual controller dependencies', () {
      const expectedUsage = {
        'lib/features/search/search_panel_controller.dart':
            'SearchApplicationService',
        'lib/features/playlist/playlist_page_controller.dart':
            'PlaylistDetailService',
        'lib/features/user/recommendation_controller.dart':
            'UserHomeApplicationService',
        'lib/app/bootstrap/feature_controller_factory.dart':
            'SearchApplicationService',
        'lib/app/bootstrap/registrars/user_registrar.dart':
            'UserHomeApplicationService',
      };
      final violations = expectedUsage.entries
          .where((entry) {
            final file = File('${projectRoot.path}/${entry.key}');
            return !file.existsSync() || !_contains(file, entry.value);
          })
          .map((entry) => '${entry.key} missing ${entry.value}')
          .toList();

      expect(
        violations,
        isEmpty,
        reason:
            'application service/usecase 不能只是空入口，页面 controller 和 registrar 必须实际依赖它。',
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
      final missing = expectedFiles
          .where((path) => !File('${projectRoot.path}/$path').existsSync())
          .toList();

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
        'lib/features/playback/presentation/bottom_panel_view.dart': 900,
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
  return path == 'lib/features/playback/playback_service.dart' ||
      path == 'lib/features/playback/application/audio_service_handler.dart' ||
      path ==
          'lib/features/playback/application/audio_service_queue_synchronizer.dart' ||
      path ==
          'lib/features/playback/application/playback_queue_item_adapter.dart' ||
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
  final importPattern =
      RegExp(r"import 'package:bujuan/features/([^/]+)/[^']*';");
  return importPattern
      .allMatches(file.readAsStringSync())
      .map((match) => match.group(1) ?? '')
      .where((feature) => feature.isNotEmpty)
      .toList();
}

List<String> _featurePresentationImports(File file) {
  final importPattern =
      RegExp(r"import 'package:bujuan/features/([^/]+)/presentation/[^']*';");
  return importPattern
      .allMatches(file.readAsStringSync())
      .map((match) => match.group(1) ?? '')
      .where((feature) => feature.isNotEmpty)
      .toList();
}

bool _isAllowedPresentationFeatureImport({
  required String ownerFeature,
  required String importedFeature,
}) {
  if (ownerFeature == importedFeature) {
    return true;
  }
  const temporaryRouteEntrypoints = {
    'shell:explore',
    'shell:settings',
    'shell:user',
    'shell:playback',
    'shell:search',
  };
  return temporaryRouteEntrypoints.contains('$ownerFeature:$importedFeature');
}

bool _isTemporaryGetFindFactoryException(String path) {
  return false;
}

bool _isTemporaryMediaItemBoundaryException(String path) {
  const exceptions = {
    'lib/features/playback/application/playback_source_resolver.dart',
  };
  return exceptions.contains(path);
}

bool _isGeneratedDartFile(String path) {
  return path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart') ||
      path.contains('/generated/');
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
