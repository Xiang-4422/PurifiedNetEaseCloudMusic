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

    test('music resource id normalizes inputs before prefix conversion', () {
      final resourceIdFile = File(
        '${projectRoot.path}/lib/core/entities/music_resource_id.dart',
      );
      final content = resourceIdFile.readAsStringSync();
      final violations = <String>[
        if (!content.contains('static String _normalizedId(String id)')) '${_relativePath(resourceIdFile)} does not define a shared id normalizer',
        if (!content.contains('return id.trim();')) '${_relativePath(resourceIdFile)} does not trim resource ids centrally',
        if (!content.contains('final normalizedId = _normalizedId(id);')) '${_relativePath(resourceIdFile)} public helpers can still branch on raw ids',
        if (!content.contains(r"return '$neteasePrefix$normalizedId';")) '${_relativePath(resourceIdFile)} can still build netease entity ids from raw input',
        if (!content.contains('normalizedId.startsWith(neteasePrefix)')) '${_relativePath(resourceIdFile)} does not check netease prefix after normalization',
        if (!content.contains('normalizedId.startsWith(localPrefix)')) '${_relativePath(resourceIdFile)} does not check local prefix after normalization',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'MusicResourceId 是曲目、歌单和本地资源 id 的基础转换边界，公开方法必须先归一空白再判断或拼接前缀。',
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

    test('netease track mapper normalizes remote song ids', () {
      final mapperFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/mappers/netease_track_mapper.dart',
      );
      final mapper = mapperFile.readAsStringSync();
      final violations = <String>[
        if (!mapper.contains('String _normalizedSongId(String id)')) '${_relativePath(mapperFile)} does not define song id normalization',
        if (!mapper.contains('return id.trim();')) '${_relativePath(mapperFile)} does not trim remote song ids',
        if (!mapper.contains('final songId = _normalizedSongId(song.id);')) '${_relativePath(mapperFile)} still maps remote songs without normalized ids',
        if (!mapper.contains('id: entityId')) '${_relativePath(mapperFile)} can still write raw netease track entity ids',
        if (!mapper.contains('sourceId: songId')) '${_relativePath(mapperFile)} can still write raw netease source ids',
        if (!mapper.contains('lyricKey: entityId')) '${_relativePath(mapperFile)} can still write raw netease lyric keys',
        if (!mapper.contains('albumId: _normalizedOptionalId(song.album?.id)')) '${_relativePath(mapperFile)} can still write raw old song album ids',
        if (!mapper.contains('artistIds: _normalizedIds((song.artists ?? []).map((artist) => artist.id))')) '${_relativePath(mapperFile)} can still write raw old song artist ids',
        if (!mapper.contains('albumId: _normalizedOptionalId(song.al?.id)')) '${_relativePath(mapperFile)} can still write raw new song album ids',
        if (!mapper.contains('artistIds: _normalizedIds((song.ar ?? []).map((artist) => artist.id))')) '${_relativePath(mapperFile)} can still write raw new song artist ids',
        if (!mapper.contains('String? _normalizedOptionalId(Object? value)')) '${_relativePath(mapperFile)} does not define optional album/artist id normalization',
        if (!mapper.contains('List<String> _normalizedIds(Iterable<Object?> values)')) '${_relativePath(mapperFile)} does not define album/artist id list normalization',
        if (!mapper.contains('songs.where((song) => _normalizedSongId(song.id).isNotEmpty)')) '${_relativePath(mapperFile)} can still batch-map blank remote song ids',
        if (!mapper.contains('songs.where((song) => _normalizedSongId(song.simpleSong.id).isNotEmpty)')) '${_relativePath(mapperFile)} can still batch-map blank cloud simple song ids',
      ];

      expect(
        violations,
        isEmpty,
        reason: '网易云远端歌曲进入领域 Track 前必须规范化歌曲、专辑和歌手 id，并在批量 mapper 边界过滤空白 id，避免脏 API 数据进入播放和缓存链路。',
      );
    });

    test('netease album and artist mappers normalize remote ids', () {
      final albumMapperFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/mappers/netease_album_mapper.dart',
      );
      final artistMapperFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/mappers/netease_artist_mapper.dart',
      );
      final albumMapper = albumMapperFile.readAsStringSync();
      final artistMapper = artistMapperFile.readAsStringSync();
      final violations = <String>[
        if (!albumMapper.contains('final albumId = _normalizedAlbumId(album.id);')) '${_relativePath(albumMapperFile)} still maps album ids without normalization',
        if (!albumMapper.contains('id: _neteaseAlbumEntityId(albumId)')) '${_relativePath(albumMapperFile)} can still write raw album entity ids',
        if (!albumMapper.contains('sourceId: albumId')) '${_relativePath(albumMapperFile)} can still write raw album source ids',
        if (!albumMapper.contains('albums.where((album) => _normalizedAlbumId(album.id).isNotEmpty)')) '${_relativePath(albumMapperFile)} can still batch-map blank album ids',
        if (!albumMapper.contains('String _normalizedAlbumId(String id)')) '${_relativePath(albumMapperFile)} does not define album id normalization',
        if (!artistMapper.contains('final artistId = _normalizedArtistId(artist.id);')) '${_relativePath(artistMapperFile)} still maps artist ids without normalization',
        if (!artistMapper.contains('id: _neteaseArtistEntityId(artistId)')) '${_relativePath(artistMapperFile)} can still write raw artist entity ids',
        if (!artistMapper.contains('sourceId: artistId')) '${_relativePath(artistMapperFile)} can still write raw artist source ids',
        if (!artistMapper.contains('artists.where((artist) => _normalizedArtistId(artist.id).isNotEmpty)')) '${_relativePath(artistMapperFile)} can still batch-map blank artist ids',
        if (!artistMapper.contains('String _normalizedArtistId(String id)')) '${_relativePath(artistMapperFile)} does not define artist id normalization',
      ];

      expect(
        violations,
        isEmpty,
        reason: '网易云专辑和歌手进入领域实体前必须规范化来源 id，并在批量 mapper 边界过滤空白 id，避免脏 id 写入资料库和页面缓存。',
      );
    });

    test('album and artist detail boundaries normalize ids before local and SDK access', () {
      final albumRepositoryFile = File(
        '${projectRoot.path}/lib/features/album/album_repository.dart',
      );
      final artistRepositoryFile = File(
        '${projectRoot.path}/lib/features/artist/artist_repository.dart',
      );
      final albumRemoteFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/remote/netease_album_remote_data_source.dart',
      );
      final artistRemoteFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/remote/netease_artist_remote_data_source.dart',
      );
      final albumRepository = albumRepositoryFile.readAsStringSync();
      final artistRepository = artistRepositoryFile.readAsStringSync();
      final albumRemote = albumRemoteFile.readAsStringSync();
      final artistRemote = artistRemoteFile.readAsStringSync();
      final violations = <String>[
        if (!albumRepository.contains("import 'package:bujuan/core/entities/music_resource_id.dart';")) '${_relativePath(albumRepositoryFile)} does not use MusicResourceId',
        if (!artistRepository.contains("import 'package:bujuan/core/entities/music_resource_id.dart';")) '${_relativePath(artistRepositoryFile)} does not use MusicResourceId',
        if (!albumRepository.contains('final sourceAlbumId = _normalizedAlbumSourceId(albumId);')) '${_relativePath(albumRepositoryFile)} does not normalize album detail source ids',
        if (!artistRepository.contains('final sourceArtistId = _normalizedArtistSourceId(artistId);')) '${_relativePath(artistRepositoryFile)} does not normalize artist detail source ids',
        if (!albumRepository.contains('MusicResourceId.toNeteaseEntityId(sourceAlbumId)')) '${_relativePath(albumRepositoryFile)} does not derive album entity id from normalized source id',
        if (!artistRepository.contains('MusicResourceId.toNeteaseEntityId(sourceArtistId)')) '${_relativePath(artistRepositoryFile)} does not derive artist entity id from normalized source id',
        if (!albumRepository.contains('getTracksByAlbumId(sourceAlbumId)')) '${_relativePath(albumRepositoryFile)} does not query album tracks by normalized source id',
        if (!artistRepository.contains('getTracksByArtistId(sourceArtistId)')) '${_relativePath(artistRepositoryFile)} does not query artist tracks by normalized source id',
        if (!albumRepository.contains("ArgumentError.value(albumId, 'albumId'")) '${_relativePath(albumRepositoryFile)} does not reject blank album ids before remote fetch',
        if (!artistRepository.contains("ArgumentError.value(artistId, 'artistId'")) '${_relativePath(artistRepositoryFile)} does not reject blank artist ids before remote fetch',
        if (albumRepository.contains("getAlbum('netease:\$albumId')")) '${_relativePath(albumRepositoryFile)} still builds album entity ids with raw interpolation',
        if (artistRepository.contains("getArtist('netease:\$artistId')")) '${_relativePath(artistRepositoryFile)} still builds artist entity ids with raw interpolation',
        if (!albumRemote.contains('final normalizedAlbumId = _normalizedAlbumSourceId(albumId);')) '${_relativePath(albumRemoteFile)} does not normalize album ids at SDK boundary',
        if (!artistRemote.contains('final normalizedArtistId = _normalizedArtistSourceId(artistId);')) '${_relativePath(artistRemoteFile)} does not normalize artist ids at SDK boundary',
        if (!albumRemote.contains('_api.albumDetail(normalizedAlbumId)')) '${_relativePath(albumRemoteFile)} can still call SDK with raw album id',
        if (!artistRemote.contains('_api.artistDetail(normalizedArtistId)')) '${_relativePath(artistRemoteFile)} can still call artist detail with raw id',
        if (!artistRemote.contains('_api.artistTopSongList(normalizedArtistId)')) '${_relativePath(artistRemoteFile)} can still call artist songs with raw id',
        if (!artistRemote.contains('_api.artistAlbumList(normalizedArtistId)')) '${_relativePath(artistRemoteFile)} can still call artist albums with raw id',
      ];

      expect(
        violations,
        isEmpty,
        reason: '专辑和歌手详情链路必须把页面输入归一为网易云来源 id，再分别派生本地实体 id、关系查询 source id 和 SDK 请求 id。',
      );
    });

    test('netease radio boundary normalizes remote radio and program ids', () {
      final mapperFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/mappers/netease_radio_mapper.dart',
      );
      final remoteFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/remote/netease_radio_remote_data_source.dart',
      );
      final mapper = mapperFile.readAsStringSync();
      final remote = remoteFile.readAsStringSync();
      final violations = <String>[
        if (!mapper.contains('final radioId = _normalizedRadioId(radio.id);')) '${_relativePath(mapperFile)} still maps radio ids without normalization',
        if (!mapper.contains('id: radioId')) '${_relativePath(mapperFile)} can still write raw radio ids',
        if (!mapper.contains('radios.where((radio) => _normalizedRadioId(radio.id).isNotEmpty)')) '${_relativePath(mapperFile)} can still batch-map blank radio ids',
        if (!mapper.contains('final programId = _normalizedProgramId(program.id);')) '${_relativePath(mapperFile)} still maps program ids without normalization',
        if (!mapper.contains('id: programId')) '${_relativePath(mapperFile)} can still write raw program ids',
        if (!mapper.contains('mainTrackId: _normalizedMainTrackId(program.mainTrackId)')) '${_relativePath(mapperFile)} can still write raw program main track ids',
        if (!mapper.contains('programs.where((program) => _normalizedProgramId(program.id).isNotEmpty)')) '${_relativePath(mapperFile)} can still batch-map blank program ids',
        if (!mapper.contains('String _normalizedRadioId(String id)')) '${_relativePath(mapperFile)} does not define radio id normalization',
        if (!mapper.contains('String _normalizedProgramId(String id)')) '${_relativePath(mapperFile)} does not define program id normalization',
        if (!mapper.contains('String _normalizedMainTrackId(Object? id)')) '${_relativePath(mapperFile)} does not define main track id normalization',
        if (!remote.contains('final normalizedRadioId = _normalizedRadioSourceId(radioId);')) '${_relativePath(remoteFile)} does not normalize radio id before SDK request',
        if (!remote.contains('_api.djProgramList(\n      normalizedRadioId,')) '${_relativePath(remoteFile)} can still fetch radio programs with raw id',
        if (!remote.contains('String _normalizedRadioSourceId(String radioId)')) '${_relativePath(remoteFile)} does not define radio source id normalization',
        if (!remote.contains('MusicResourceId.toNeteaseSourceId(radioId).trim()')) '${_relativePath(remoteFile)} does not strip netease entity prefix before SDK request',
        if (!remote.contains('sourceRadioId.isEmpty || MusicResourceId.hasKnownPrefix(sourceRadioId)')) '${_relativePath(remoteFile)} can still pass blank or non-netease radio ids to SDK',
      ];

      expect(
        violations,
        isEmpty,
        reason: '网易云播客电台和节目进入领域数据或 SDK 请求前必须规范化电台 id、节目 id 和主曲目 id，空白或非网易云 id 不能进入远端请求、本地缓存和播放队列入口。',
      );
    });

    test('netease paged remote requests normalize pagination before SDK calls', () {
      final cloudFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/remote/netease_cloud_remote_data_source.dart',
      );
      final radioFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/remote/netease_radio_remote_data_source.dart',
      );
      final cloud = cloudFile.readAsStringSync();
      final radio = radioFile.readAsStringSync();
      final radioOffsetNormalizationCount = RegExp(
        r'final normalizedOffset = _normalizedOffset\(offset\);',
      ).allMatches(radio).length;
      final radioSdkOffsetUsageCount = RegExp(
        r'offset: normalizedOffset',
      ).allMatches(radio).length;
      final radioLimitGuardCount = RegExp(
        r'!_hasUsableLimit\(limit\)',
      ).allMatches(radio).length;
      final violations = <String>[
        if (!cloud.contains('if (!_hasUsableLimit(limit))')) '${_relativePath(cloudFile)} can still fetch cloud songs with a non-positive limit',
        if (!cloud.contains('final normalizedOffset = _normalizedOffset(offset);')) '${_relativePath(cloudFile)} does not normalize cloud page offsets',
        if (!cloud.contains('_api.cloudSong(offset: normalizedOffset, limit: limit)')) '${_relativePath(cloudFile)} can still fetch cloud songs with raw page offset',
        if (!cloud.contains('int _normalizedOffset(int offset)')) '${_relativePath(cloudFile)} does not define cloud offset normalization',
        if (!cloud.contains('bool _hasUsableLimit(int limit)')) '${_relativePath(cloudFile)} does not define cloud limit validation',
        if (radioOffsetNormalizationCount < 2) '${_relativePath(radioFile)} does not normalize subscribed radio and program page offsets',
        if (radioSdkOffsetUsageCount < 2) '${_relativePath(radioFile)} can still call radio SDK page requests with raw offsets',
        if (radioLimitGuardCount < 2) '${_relativePath(radioFile)} does not reject invalid subscribed radio and program page limits',
        if (!radio.contains('int _normalizedOffset(int offset)')) '${_relativePath(radioFile)} does not define radio offset normalization',
        if (!radio.contains('bool _hasUsableLimit(int limit)')) '${_relativePath(radioFile)} does not define radio limit validation',
      ];

      expect(
        violations,
        isEmpty,
        reason: '云盘和播客分页请求进入 SDK 前必须归一 offset 并拒绝非正 limit，避免无效翻页条件触发远端请求。',
      );
    });

    test('netease comment boundary normalizes remote comment ids', () {
      final mapperFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/mappers/netease_comment_mapper.dart',
      );
      final remoteFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/remote/netease_comment_remote_data_source.dart',
      );
      final mapper = mapperFile.readAsStringSync();
      final remote = remoteFile.readAsStringSync();
      final violations = <String>[
        if (!mapper.contains('final commentId = _normalizedCommentId(item.commentId);')) '${_relativePath(mapperFile)} still maps comment ids without normalization',
        if (!mapper.contains('commentId: commentId')) '${_relativePath(mapperFile)} can still write raw comment ids',
        if (!mapper.contains('items.map(fromItem).where((item) => item.commentId.isNotEmpty).toList()')) '${_relativePath(mapperFile)} can still batch-map blank comment ids',
        if (!mapper.contains('String _normalizedCommentId(String commentId)')) '${_relativePath(mapperFile)} does not define comment id normalization',
        if (!remote.contains('final normalizedId = _normalizeResourceId(id);')) '${_relativePath(remoteFile)} does not normalize resource ids before SDK calls',
        if (!remote.contains('final normalizedType = _normalizeText(type);')) '${_relativePath(remoteFile)} does not normalize comment resource type before SDK calls',
        if (!remote.contains('final normalizedParentCommentId = _normalizeCommentId(parentCommentId);')) '${_relativePath(remoteFile)} does not normalize floor parent comment ids',
        if (!remote.contains('final normalizedCommentId = _normalizeOptionalCommentId(commentId);')) '${_relativePath(remoteFile)} does not normalize optional send comment ids',
        if (!remote.contains('threadId: _typeKey(normalizedType) + normalizedId')) '${_relativePath(remoteFile)} can still derive comment thread id from raw type or id',
        if (!remote.contains('return normalizedId.substring(separatorIndex + 1).trim();')) '${_relativePath(remoteFile)} does not trim resource ids after stripping source prefix',
      ];

      expect(
        violations,
        isEmpty,
        reason: '网易云评论进入缓存和楼层入口前必须规范化评论 id；远端评论请求进入 SDK 前必须规范化资源 id、资源类型和评论 id。',
      );
    });

    test('netease playlist mapper normalizes remote playlist and track ids', () {
      final mapperFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/mappers/netease_playlist_mapper.dart',
      );
      final remoteFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/remote/netease_playlist_remote_data_source.dart',
      );
      final mapper = mapperFile.readAsStringSync();
      final remote = remoteFile.readAsStringSync();
      final violations = <String>[
        if (!mapper.contains('final playlistId = _normalizedPlaylistId(playlist.id);')) '${_relativePath(mapperFile)} still maps playlist ids without normalization',
        if (!mapper.contains('String _normalizedPlaylistId(String id)')) '${_relativePath(mapperFile)} does not define playlist id normalization',
        if (!mapper.contains('return id.trim();')) '${_relativePath(mapperFile)} does not trim remote playlist ids',
        if (!mapper.contains('id: _neteasePlaylistEntityId(playlistId)')) '${_relativePath(mapperFile)} can still write raw playlist entity ids',
        if (!mapper.contains('sourceId: playlistId')) '${_relativePath(mapperFile)} can still write raw playlist source ids',
        if (!mapper.contains('normalizeNeteaseSongIds((playlist.trackIds ?? const []).map((track) => track.id))')) '${_relativePath(mapperFile)} does not normalize playlist track refs',
        if (!mapper.contains('trackId: _neteaseSongEntityId(entry.value)')) '${_relativePath(mapperFile)} can still write raw playlist ref track ids',
        if (!mapper.contains('playlists.where((playlist) => _normalizedPlaylistId(playlist.id).isNotEmpty)')) '${_relativePath(mapperFile)} can still batch-map blank playlist ids',
        if (!remote.contains('final normalizedPlaylistId = _normalizedPlaylistSourceId(playlistId);')) '${_relativePath(remoteFile)} does not normalize playlist ids before SDK calls',
        if (!remote.contains('_api.playListDetail(normalizedPlaylistId)')) '${_relativePath(remoteFile)} can still fetch playlist detail with raw id',
        if (!remote.contains('ids: songIds.map(_normalizedSongSourceId).toList()')) '${_relativePath(remoteFile)} can still plan song detail batches from raw song ids',
        if (!remote.contains('_api.subscribePlayList(normalizedPlaylistId')) '${_relativePath(remoteFile)} can still toggle subscription with raw playlist id',
        if (!remote.contains('final normalizedSongId = _normalizedSongSourceId(songId);')) '${_relativePath(remoteFile)} does not normalize manipulated song ids before SDK calls',
        if (!remote.contains('_api.playlistManipulateTracks(normalizedPlaylistId, normalizedSongId, add)')) '${_relativePath(remoteFile)} can still manipulate playlist tracks with raw ids',
        if (!remote.contains('String _normalizedPlaylistSourceId(String playlistId)')) '${_relativePath(remoteFile)} does not define playlist source id normalization',
        if (!remote.contains('String _normalizedSongSourceId(String songId)')) '${_relativePath(remoteFile)} does not define song source id normalization',
        if (!remote.contains('trackIds: normalizeNeteaseSongIds((playlist?.trackIds ?? const []).map((track) => track.id))')) '${_relativePath(remoteFile)} can still return raw playlist index track ids',
      ];

      expect(
        violations,
        isEmpty,
        reason: '网易云歌单和歌单索引进入领域模型或 SDK 请求前必须规范化歌单 id 和歌曲 id，空白 id 不能写入歌单索引、trackRefs、本地缓存或远端操作。',
      );
    });

    test('netease song detail remote fetches use request batch planner', () {
      final plannerFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/netease_song_detail_batch_planner.dart',
      );
      final playlistFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/remote/netease_playlist_remote_data_source.dart',
      );
      final userFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/remote/netease_user_remote_data_source.dart',
      );
      final planner = plannerFile.readAsStringSync();
      final playlist = playlistFile.readAsStringSync();
      final user = userFile.readAsStringSync();
      final violations = <String>[
        if (!planner.contains('List<List<String>> planNeteaseSongDetailBatches')) '${_relativePath(plannerFile)} does not define song detail batch planning',
        if (!planner.contains('List<String> normalizeNeteaseSongIds(Iterable<String> ids)')) '${_relativePath(plannerFile)} does not expose normalized song id list planning',
        if (!planner.contains('MusicResourceId.toNeteaseSourceId(id).trim()')) '${_relativePath(plannerFile)} does not strip netease entity prefixes before request planning',
        if (!planner.contains('sourceSongId.isEmpty || MusicResourceId.hasKnownPrefix(sourceSongId)')) '${_relativePath(plannerFile)} can still pass blank or non-netease song ids to request planning',
        if (!planner.contains('ids.map(normalizeNeteaseSongId).where((id) => id.isNotEmpty).toList()')) '${_relativePath(plannerFile)} does not normalize and filter request ids',
        if (!planner.contains('for (var start = 0; start < resolvedIds.length; start += batchSize)')) '${_relativePath(plannerFile)} does not advance song detail batches by request offset',
        if (!playlist.contains('planNeteaseSongDetailBatches(')) '${_relativePath(playlistFile)} does not use song detail batch planner',
        if (!user.contains('planNeteaseSongDetailBatches(ids: ids)')) '${_relativePath(userFile)} does not use song detail batch planner',
        if (!user.contains('final normalizedStartSongId = normalizeNeteaseSongId(startSongId);')) '${_relativePath(userFile)} does not normalize heartbeat start song id before SDK request',
        if (!user.contains('final normalizedRandomLikedSongId = normalizeNeteaseSongId(randomLikedSongId);')) '${_relativePath(userFile)} does not normalize heartbeat context song id before SDK request',
        if (!user.contains('_api.playmodeIntelligenceList(')) '${_relativePath(userFile)} no longer calls heartbeat SDK through the remote data source',
        if (!user.contains('normalizedStartSongId,\n      normalizedRandomLikedSongId,')) '${_relativePath(userFile)} can still call heartbeat SDK with raw ids',
        if (!user.contains('final normalizedSongId = normalizeNeteaseSongId(songId);')) '${_relativePath(userFile)} does not normalize like song id before SDK request',
        if (!user.contains('_api.likeSong(normalizedSongId, like)')) '${_relativePath(userFile)} can still toggle like with raw song id',
        if (playlist.contains('while (tracks.length')) '${_relativePath(playlistFile)} still advances requests by returned track count',
        if (user.contains('while (tracks.length')) '${_relativePath(userFile)} still advances requests by returned track count',
      ];

      expect(
        violations,
        isEmpty,
        reason: '歌曲详情和用户歌曲操作的远端请求必须按规范化后的网易云来源 id 推进，不能把应用前缀、本地 id 或空白 id 传给 SDK。',
      );
    });

    test('netease music source normalizes resource ids before SDK requests', () {
      final sourceFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/netease_music_source.dart',
      );
      final source = sourceFile.readAsStringSync();
      final trackNormalizationCount = RegExp(
        r'final normalizedTrackId = normalizeNeteaseSongId\(trackId\);',
      ).allMatches(source).length;
      final violations = <String>[
        if (!source.contains("import 'package:bujuan/core/entities/music_resource_id.dart';")) '${_relativePath(sourceFile)} does not use MusicResourceId for playlist source ids',
        if (!source.contains("import 'package:bujuan/data/music_data/sources/netease/netease_song_detail_batch_planner.dart';")) '${_relativePath(sourceFile)} does not reuse netease song id normalization',
        if (trackNormalizationCount < 3) '${_relativePath(sourceFile)} does not normalize track id before detail, playback url and lyric SDK requests',
        if (!source.contains('_api.songDetail([normalizedTrackId])')) '${_relativePath(sourceFile)} can still fetch track detail with raw id',
        if (!source.contains('[normalizedTrackId],\n      level: qualityLevel')) '${_relativePath(sourceFile)} can still fetch playback url with raw id',
        if (!source.contains('_api.songLyric(normalizedTrackId)')) '${_relativePath(sourceFile)} can still fetch lyrics with raw id',
        if (!source.contains('final normalizedPlaylistId = _normalizePlaylistSourceId(playlistId);')) '${_relativePath(sourceFile)} does not normalize playlist id before SDK request',
        if (!source.contains('_api.playListDetail(normalizedPlaylistId)')) '${_relativePath(sourceFile)} can still fetch playlist detail with raw id',
        if (source.contains("startsWith('netease:')")) '${_relativePath(sourceFile)} still strips netease prefixes by hand',
        if (source.contains("substring('netease:'.length)")) '${_relativePath(sourceFile)} still strips netease prefixes by hand',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'NeteaseMusicSource 是仓库层访问网易云曲目、播放 URL、歌词和歌单的最后 SDK 边界，必须统一归一来源 id 并拒绝本地或空白 id。',
      );
    });

    test('netease user remote normalizes account scoped user ids', () {
      final sourceFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/remote/netease_user_remote_data_source.dart',
      );
      final source = sourceFile.readAsStringSync();
      final userNormalizationCount = RegExp(
        r'final normalizedUserId = _normalizedUserId\(userId\);',
      ).allMatches(source).length;
      final violations = <String>[
        if (userNormalizationCount < 3) '${_relativePath(sourceFile)} does not normalize user id before detail, liked song and playlist SDK requests',
        if (!source.contains('_api.userDetail(normalizedUserId)')) '${_relativePath(sourceFile)} can still fetch user detail with raw user id',
        if (!source.contains('_api.likeSongList(normalizedUserId)')) '${_relativePath(sourceFile)} can still fetch liked songs with raw user id',
        if (!source.contains('_api.userPlayLists(normalizedUserId)')) '${_relativePath(sourceFile)} can still fetch user playlists with raw user id',
        if (!source.contains('String _normalizedUserId(String userId)')) '${_relativePath(sourceFile)} does not define user id normalization',
        if (!source.contains('static const UserProfileData _emptyUserProfile')) '${_relativePath(sourceFile)} does not define an empty profile fallback for blank user ids',
      ];

      expect(
        violations,
        isEmpty,
        reason: '网易云用户远端 data source 是账号作用域数据进入 SDK 的边界，用户资料、喜欢歌曲和用户歌单请求必须先归一 userId 并拒绝空白账号。',
      );
    });

    test('netease auth remote normalizes qr login keys', () {
      final sourceFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/netease/remote/netease_auth_remote_data_source.dart',
      );
      final source = sourceFile.readAsStringSync();
      final qrKeyNormalizationCount = RegExp(
        r'final normalizedUnikey = _normalizedUnikey\(',
      ).allMatches(source).length;
      final violations = <String>[
        if (qrKeyNormalizationCount < 3) '${_relativePath(sourceFile)} does not normalize qr keys at creation, url and status boundaries',
        if (!source.contains('success: result.code == 200 && normalizedUnikey.isNotEmpty')) '${_relativePath(sourceFile)} can still treat blank qr keys as successful',
        if (!source.contains('return _api.loginQrCodeUrl(normalizedUnikey)')) '${_relativePath(sourceFile)} can still build qr url with raw key',
        if (!source.contains('_api.loginQrCodeCheck(normalizedUnikey)')) '${_relativePath(sourceFile)} can still check qr status with raw key',
        if (!source.contains("return (code: 800, message: 'Expected a non-empty qr code key');")) '${_relativePath(sourceFile)} does not reject blank qr status checks locally',
        if (!source.contains('String _normalizedUnikey(String unikey)')) '${_relativePath(sourceFile)} does not define qr key normalization',
      ];

      expect(
        violations,
        isEmpty,
        reason: '二维码登录 key 是登录轮询进入 SDK 的瞬时凭证，必须先归一并拒绝空白 key，不能让空 key 触发轮询请求。',
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
        if (!mapper.contains('MusicResourceId.toNeteaseSourceId(')) 'playback queue item mapper can still derive liked state from raw source ids',
        if (!mapper.contains('final likedSongIdSet = normalizeLikedSongIds(likedSongIds).toSet();')) 'playback queue item mapper does not normalize liked ids once before mapping',
        if (!mapper.contains('static bool _isLikedTrack({')) 'playback queue item mapper does not keep liked state derivation behind a normalized helper',
        if (mapper.contains('likedSongIds.contains(int.tryParse(track.sourceId))')) 'playback queue item mapper still parses raw sourceId for liked state',
        if (!radioMapper.contains('String _normalizedQueueItemId(String id)')) 'radio queue item mapper does not define id normalization',
        if (!radioMapper.contains('_normalizedQueueItemId(program.mainTrackId).isNotEmpty')) 'radio queue item mapper does not filter blank main track ids',
        if (!radioMapper.contains('final trackId = _normalizedQueueItemId(program.mainTrackId);')) 'radio queue item mapper does not normalize main track ids before mapping',
        if (!radioMapper.contains('id: trackId')) 'radio queue item mapper can still write raw main track ids',
        if (!radioMapper.contains('MusicResourceId.toNeteaseSourceId(trackId)')) 'radio queue item mapper can still derive liked state from raw track ids',
        if (!radioMapper.contains('final likedSongIdSet = normalizeLikedSongIds(likedSongIds).toSet();')) 'radio queue item mapper does not normalize liked ids once before mapping',
        if (!radioMapper.contains('static bool _isLikedTrack(String trackId, Set<int> likedSongIds)')) 'radio queue item mapper does not keep liked state derivation behind a normalized helper',
        if (radioMapper.contains('likedSongIds.contains(int.tryParse(trackId))')) 'radio queue item mapper still parses raw trackId for liked state',
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
        if (!content.contains('final queueItemId = _normalizedItemId(queueItem.id);')) 'does not normalize confirmed media item id before sync',
        if (!content.contains('final trackChanged = _lastPositionTrackId.isNotEmpty && _lastPositionTrackId != queueItemId')) 'does not detect media item track changes with normalized ids',
        if (!content.contains('_latestPosition = Duration.zero')) 'does not reset latest position on media item change',
        if (!content.contains('_lastPositionTrackId = queueItemId')) 'stores raw media item id as last position track',
        if (!content.contains('currentSong: normalizedQueueItem')) 'does not sync normalized media item into runtime state',
        if (!content.contains('currentPosition: trackChanged ? Duration.zero : null')) 'does not reset runtime position on media item change',
        if (!content.contains('task: () => _queueStore.saveCurrentSong(')) 'does not save current song with position in the same semantic update',
        if (!content.contains('queueItemId,')) 'does not save normalized current song id',
        if (!content.contains('position: trackChanged ? Duration.zero : null')) 'does not reset restore position with current song save',
      ];

      expect(
        violations,
        isEmpty,
        reason: '切歌时当前歌曲和恢复进度必须作为同一语义更新；不能把上一首的进度通过独立后台任务写到新歌恢复状态上。',
      );
    });

    test('playback state synchronizer normalizes confirmed current track side effects', () {
      final synchronizerFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_state_synchronizer.dart',
      );
      final content = synchronizerFile.readAsStringSync();
      final violations = <String>[
        if (!content.contains('PlaybackQueueItem _normalizedQueueItem(PlaybackQueueItem item)')) '${_relativePath(synchronizerFile)} does not normalize queue items before confirmed side effects',
        if (!content.contains('final trackId = _normalizedItemId(runtimeState().currentSong.id);')) '${_relativePath(synchronizerFile)} can still save playback state positions with raw current song id',
        if (!content.contains('if (_normalizedItemId(_selectionService.state.selectedItem.id) != trackId)')) '${_relativePath(synchronizerFile)} can still reset lyric state through raw selected/current id comparison',
        if (!content.contains('final currentSongId = _normalizedItemId(currentRuntimeState.currentSong.id);')) '${_relativePath(synchronizerFile)} can still append roaming songs from raw current song id',
        if (!content.contains('(element) => _normalizedItemId(element.id) == currentSongId')) '${_relativePath(synchronizerFile)} can still locate roaming index through raw queue ids',
        if (!content.contains('final itemId = _normalizedItemId(item.id);')) '${_relativePath(synchronizerFile)} can still schedule confirmed cache/artwork work from raw item id',
        if (!content.contains('cacheTrackForPlayback(') || !content.contains('itemId,\n      preferHighQuality')) '${_relativePath(synchronizerFile)} can still cache playback resources with raw item id',
        if (!content.contains('if (updatedItem != null && _isStillCurrentTrack(itemId, runtimeState))')) '${_relativePath(synchronizerFile)} can still write cached queue item through raw stale check',
        if (!content.contains('await syncCurrentQueueItem(_normalizedQueueItem(updatedItem));')) '${_relativePath(synchronizerFile)} can still write raw cached queue item ids',
        if (!content.contains('final normalizedItem = _normalizedQueueItem(item);')) '${_relativePath(synchronizerFile)} can still pass raw item to confirmed side effects',
        if (!content.contains('trackId: itemId')) '${_relativePath(synchronizerFile)} can still schedule confirmed side effects under raw track id',
        if (!content.contains('_cacheCurrentTrackForPlayback(\n          normalizedItem,')) '${_relativePath(synchronizerFile)} can still cache from raw confirmed item',
        if (!content.contains('await ensureCurrentTrackArtwork(normalizedItem);')) '${_relativePath(synchronizerFile)} can still ensure artwork from raw confirmed item',
        if (!content.contains('final item = _normalizedQueueItem(runtimeState().currentSong);')) '${_relativePath(synchronizerFile)} can still branch on raw runtime current song',
        if (!content.contains('if (_normalizedItemId(selection.selectedItem.id) != itemId)')) '${_relativePath(synchronizerFile)} can still compare raw selection id before confirmed side effects',
        if (!content.contains("final sideEffectKey = '\${selection.selectionVersion}:\$queueIndex:\$itemId';")) '${_relativePath(synchronizerFile)} can still deduplicate confirmed side effects with raw item id',
        if (!content.contains('_normalizedItemId(runtimeState().currentSong.id) == normalizedItemId')) '${_relativePath(synchronizerFile)} can still check runtime stale state with raw item id',
        if (!content.contains('_normalizedItemId(_selectionService.state.selectedItem.id) == normalizedItemId')) '${_relativePath(synchronizerFile)} can still check selection stale state with raw item id',
      ];

      expect(
        violations,
        isEmpty,
        reason: '确认播放后的缓存、封面、歌词和漫游追加副作用都在异步路径中执行，任务 key、stale 判断和回写入参必须使用规范化歌曲 id。',
      );
    });

    test('playback queue coordinator normalizes roaming append current song ids', () {
      final coordinatorFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_queue_coordinator.dart',
      );
      final coordinator = coordinatorFile.readAsStringSync();
      final violations = <String>[
        if (!coordinator.contains('String _normalizedQueueItemId(String id)')) '${_relativePath(coordinatorFile)} does not define queue item id normalization',
        if (!coordinator.contains('final normalizedCurrentSongId = _normalizedQueueItemId(currentSongId);')) '${_relativePath(coordinatorFile)} can still append roaming songs from a raw current song id',
        if (!coordinator.contains('currentSongId: normalizedCurrentSongId')) '${_relativePath(coordinatorFile)} can still pass raw current song id to queue service',
        if (!coordinator.contains('(element) => _normalizedQueueItemId(element.id) == normalizedCurrentSongId')) '${_relativePath(coordinatorFile)} can still locate appended roaming index through raw queue ids',
        if (coordinator.contains('(element) => element.id == currentSongId')) '${_relativePath(coordinatorFile)} still compares raw queue item ids after roaming append',
      ];

      expect(
        violations,
        isEmpty,
        reason: '漫游追加后自动续播下一首依赖当前歌曲索引，currentSongId 和 activeQueue id 必须先规范化再匹配。',
      );
    });

    test('playback mode coordinator normalizes liked queue ids before selecting current song', () {
      final coordinatorFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_mode_coordinator.dart',
      );
      final coordinator = coordinatorFile.readAsStringSync();
      final violations = <String>[
        if (!coordinator.contains('PlaybackQueueItem _normalizedQueueItem(PlaybackQueueItem item)')) '${_relativePath(coordinatorFile)} does not normalize liked mode queue items',
        if (!coordinator.contains('String _normalizedQueueItemId(String id)')) '${_relativePath(coordinatorFile)} does not define liked mode queue item id normalization',
        if (!coordinator.contains('final likedSongs = _userContentPort.likedSongs().map(_normalizedQueueItem)')) '${_relativePath(coordinatorFile)} can still build liked mode queue from raw ids',
        if (!coordinator.contains('final normalizedCurrentSong = _normalizedQueueItem(currentSong);')) '${_relativePath(coordinatorFile)} can still start liked mode from a raw current song',
        if (!coordinator.contains('final currentSongSourceId = int.tryParse(normalizedCurrentSong.sourceId);')) '${_relativePath(coordinatorFile)} can still check liked source ids through raw sourceId',
        if (!coordinator.contains('(song) => _normalizedQueueItemId(song.id) == normalizedCurrentSong.id')) '${_relativePath(coordinatorFile)} can still locate liked mode current index through raw ids',
        if (coordinator.contains('song.id == currentSong.id')) '${_relativePath(coordinatorFile)} still compares liked mode queue ids raw',
      ];

      expect(
        violations,
        isEmpty,
        reason: '喜欢歌曲队列切换会决定当前播放索引；liked queue、currentSong.id 和 sourceId 必须先规范化，避免 id 空格差异从错误歌曲开始播放。',
      );
    });

    test('playback selection service normalizes selected ids before status reset', () {
      final serviceFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_selection_service.dart',
      );
      final service = serviceFile.readAsStringSync();
      final violations = <String>[
        if (!service.contains('String _normalizedQueueItemId(String id)')) '${_relativePath(serviceFile)} does not define selection id normalization',
        if (!service.contains('final selectedIdChanged = _normalizedQueueItemId(_state.selectedItem.id) != _normalizedQueueItemId(queueState.selectedItem.id);'))
          '${_relativePath(serviceFile)} can still reset source status through raw selected id comparison',
        if (service.contains('final selectedIdChanged = _state.selectedItem.id != queueState.selectedItem.id')) '${_relativePath(serviceFile)} still compares selected ids raw before resetting source status',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'selection 从 queue fact 同步时只应在真实换歌后把 sourceStatus 重置为 idle，raw id 空格差异不能打断 mini player 的 ready/error 反馈。',
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

    test('playback restore coordinator normalizes queue ids before matching current song', () {
      final coordinatorFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_restore_coordinator.dart',
      );
      final coordinator = coordinatorFile.readAsStringSync();
      final violations = <String>[
        if (!coordinator.contains('final currentSongId = _normalizedQueueItemId(restoreState.currentSongId);')) '${_relativePath(coordinatorFile)} can still match restore current song from a raw currentSongId',
        if (!coordinator.contains('(element) => _normalizedQueueItemId(element.id) == currentSongId')) '${_relativePath(coordinatorFile)} can still match restore queue items by raw ids',
        if (!coordinator.contains('.map(_normalizedQueueItem)')) '${_relativePath(coordinatorFile)} can still return decoded restore queue items with raw ids',
        if (!coordinator.contains('PlaybackQueueItem _normalizedQueueItem(PlaybackQueueItem item)')) '${_relativePath(coordinatorFile)} does not normalize decoded restore queue items',
        if (!coordinator.contains('String _normalizedQueueItemId(String id)')) '${_relativePath(coordinatorFile)} does not define restore queue item id normalization',
        if (coordinator.contains('(element) => element.id == restoreState.currentSongId')) '${_relativePath(coordinatorFile)} still restores current index through raw id comparison',
      ];

      expect(
        violations,
        isEmpty,
        reason: '启动恢复必须按规范化 id 匹配 currentSongId 和恢复队列，否则历史队列缓存的空格差异会丢失当前索引和恢复进度。',
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
        if (!coordinatorContent.contains('_dropRemoteState(cacheKey);')) 'coordinator keeps stale remote state after local resource hit',
        if (!coordinatorContent.contains('_loads.remove(cacheKey);')) 'coordinator does not clear in-flight remote loads after local resource hit',
        if (!coordinatorContent.contains('_normalizePlaybackUrl(url)')) 'coordinator does not normalize loaded playback urls before returning them',
        if (!coordinatorContent.contains("import 'package:bujuan/core/util/playback_source_reference.dart';")) 'coordinator does not use the shared playback source reference boundary',
        if (!coordinatorContent.contains('PlaybackSourceReference.localPath(url)')) 'coordinator does not normalize local resource urls through the shared playback source reference boundary',
        if (!coordinatorContent.contains('PlaybackSourceReference.playbackReference(url)')) 'coordinator does not normalize loaded playback urls through the shared playback source reference boundary',
        if (!coordinatorContent.contains('PlaybackSourceReference.freshRemoteHttpUrl')) 'coordinator can cache malformed or expired remote playback urls',
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

    test('local resource index repository uses shared origin priority policy', () {
      final repositoryFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/resources/local_resource_index_repository.dart',
      );
      final availabilityFile = File('${projectRoot.path}/lib/core/util/track_resource_availability.dart');
      final repository = repositoryFile.readAsStringSync();
      final availability = availabilityFile.readAsStringSync();
      final violations = <String>[
        if (!repository.contains("import 'package:bujuan/core/util/track_resource_availability.dart';")) '${_relativePath(repositoryFile)} does not import TrackResourceAvailability',
        if (!repository.contains('TrackResourceAvailability.shouldKeepExistingResource(')) '${_relativePath(repositoryFile)} does not delegate overwrite decisions to the shared policy',
        if (repository.contains('int _originPriority(')) '${_relativePath(repositoryFile)} still keeps a private origin priority table',
        if (!availability.contains('static int originPriority(TrackResourceOrigin origin)')) '${_relativePath(availabilityFile)} does not expose shared origin priority',
        if (!availability.contains('static bool shouldKeepExistingResource(')) '${_relativePath(availabilityFile)} does not expose shared resource overwrite policy',
      ];

      expect(
        violations,
        isEmpty,
        reason: '资源索引写入的来源优先级必须和播放、下载、本地导入共用同一套语义，避免后续缓存重构时覆盖本地导入或正式下载事实。',
      );
    });

    test('feature repositories build queue items through playback queue builder', () {
      final repositoryFiles = _dartFiles(Directory('${projectRoot.path}/lib/features')).where((file) => file.path.endsWith('_repository.dart')).toList();
      final violations = repositoryFiles
          .where(
            (file) => file.readAsStringSync().contains('playback_queue_item_mapper.dart'),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'feature repository 只能拿数据、保存数据和提交播放意图；曲目到播放队列项的资源补齐、liked 归一和空白 id 过滤必须收口到 TrackPlaybackQueueBuilder。',
      );
    });

    test('playback queue item mapper stays behind queue builder boundary', () {
      final mapperFile = '${projectRoot.path}/lib/features/playback/application/playback_queue_item_mapper.dart';
      final builderFile = '${projectRoot.path}/lib/features/playback/application/track_playback_queue_builder.dart';
      final violations = _dartFiles(Directory('${projectRoot.path}/lib/features'))
          .where((file) => file.path != mapperFile && file.path != builderFile)
          .where(
            (file) => file.readAsStringSync().contains('playback_queue_item_mapper.dart'),
          )
          .map(_relativePath)
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'PlaybackQueueItemMapper 只能作为 TrackPlaybackQueueBuilder 的内部实现，feature 入口不能绕过统一的资源补齐和 id 归一边界。',
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
        if (!queue.contains('itemExtent: itemExtent')) '${_relativePath(queueFile)} does not fix queue list item extent',
        if (!queue.contains('bottomPanelQueueItemExtent(')) '${_relativePath(queueFile)} does not centralize queue item extent calculation',
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
        if (!panel.contains('required this.shellController')) '${_relativePath(panelFile)} does not receive shell controller',
        if (!home.contains('final appHomeControllers = Get.find<AppHomeControllerBundle>()')) '${_relativePath(homeFile)} does not resolve app home controller bundle at shell boundary',
        if (home.contains('Get.find<PlayerController>')) '${_relativePath(homeFile)} reads player controller globally',
        if (home.contains('Get.find<SettingsController>')) '${_relativePath(homeFile)} reads settings controller globally',
        if (home.contains('Get.find<CommentControllerFactory>')) '${_relativePath(homeFile)} reads comment controller factory globally',
        if (!home.contains('final playerController = appHomeControllers.playerController')) '${_relativePath(homeFile)} does not receive player controller from app home bundle',
        if (!home.contains('final settingsController = appHomeControllers.settingsController')) '${_relativePath(homeFile)} does not receive settings controller from app home bundle',
        if (!home.contains('final commentControllerFactory = appHomeControllers.commentControllerFactory')) '${_relativePath(homeFile)} does not receive comment controller factory from app home bundle',
        if (!home.contains('final shellController = appHomeControllers.shellController')) '${_relativePath(homeFile)} does not receive shell controller from app home bundle',
        if (!bootstrap.contains('Get.put<AppHomeControllerBundle>')) 'feature bootstrap does not register app home controller bundle',
        if (!bootstrap.contains('commentControllerFactory: Get.find<CommentControllerFactory>()')) 'feature bootstrap does not inject comment factory into app home bundle',
        if (!bootstrap.contains('playerController: Get.find<PlayerController>()')) 'feature bootstrap does not inject player controller into app home bundle',
        if (!bootstrap.contains('settingsController: Get.find<SettingsController>()')) 'feature bootstrap does not inject settings controller into app home bundle',
        if (!bootstrap.contains('shellController: Get.find<ShellController>()')) 'feature bootstrap does not inject shell controller into app home bundle',
        if (!home.contains('panel: BottomPanelView(')) '${_relativePath(homeFile)} does not compose bottom panel',
        if (!home.contains('shellController: shellController')) '${_relativePath(homeFile)} does not inject shell controller into bottom panel',
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

    test('bottom panel playback widgets receive shell controller explicitly', () {
      final shellInjectedFiles = [
        File('${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_view.dart'),
        File('${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_mini_player.dart'),
        File('${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_queue_view.dart'),
        File('${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_background_layers.dart'),
        File('${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_now_playing_page.dart'),
        File('${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_now_playing_metadata.dart'),
        File('${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_page_indicator.dart'),
        File('${projectRoot.path}/lib/ui/pages/shell/widgets/playback/bottom_panel_playback_controls.dart'),
        File('${projectRoot.path}/lib/ui/pages/shell/widgets/playback/lyric_view.dart'),
      ];
      final violations = <String>[
        for (final file in shellInjectedFiles)
          if (file.readAsStringSync().contains('extends GetView<ShellController>')) '${_relativePath(file)} still reads shell through GetView',
        for (final file in shellInjectedFiles)
          if (file.readAsStringSync().contains('Get.find<ShellController>')) '${_relativePath(file)} reads shell controller globally',
        for (final file in shellInjectedFiles)
          if (!file.readAsStringSync().contains('required this.shellController')) '${_relativePath(file)} does not receive shell controller explicitly',
      ];

      expect(
        violations,
        isEmpty,
        reason: '底部播放面板子组件必须显式接收 shellController，不能通过 GetView 或 Get.find 隐式读取全局 shell。',
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
        if (metadata.contains('IntrinsicWidth(')) '${_relativePath(metadataFile)} uses intrinsic width in frequently rebuilt metadata chips',
        if (!metadata.contains('bottomPanelMetadataLabelWidth(')) '${_relativePath(metadataFile)} does not centralize metadata label width',
        if (!metadata.contains('bottomPanelMetadataValueMaxWidth(')) '${_relativePath(metadataFile)} does not clamp metadata value width centrally',
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

    test('playback queue custom metadata stays in queue boundary codecs', () {
      const allowedPaths = {
        'lib/features/playback/application/playback_queue_item_adapter.dart',
        'lib/features/playback/application/playback_queue_item_cache_codec.dart',
      };
      final queueItemFile = File(
        '${projectRoot.path}/lib/core/entities/playback_queue_item.dart',
      );
      final queueItem = queueItemFile.readAsStringSync();
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
      if (queueItem.contains('final Map<String, dynamic> metadata')) {
        violations.add('${_relativePath(queueItemFile)} exposes dynamic metadata map');
      }
      if (!queueItem.contains('final PlaybackQueueItemMetadata customMetadata')) {
        violations.add('${_relativePath(queueItemFile)} does not expose typed custom metadata');
      }

      expect(
        violations,
        isEmpty,
        reason: 'PlaybackQueueItem 只能暴露 typed customMetadata；动态 metadata 键访问只能在 adapter/cache codec 边界做兼容迁移，播放 mapper、service 和 controller 必须使用显式字段。',
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

    test('playback switch coordinator normalizes queue item ids at entry', () {
      final coordinatorFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_switch_coordinator.dart',
      );
      final coordinator = coordinatorFile.readAsStringSync();
      final violations = <String>[
        if (!coordinator.contains('String _normalizedQueueItemId(String id)')) '${_relativePath(coordinatorFile)} does not define queue item id normalization',
        if (!coordinator.contains('return id.trim();')) '${_relativePath(coordinatorFile)} does not trim queue item ids',
        if (!coordinator.contains('final itemId = _normalizedQueueItemId(item.id);')) '${_relativePath(coordinatorFile)} still branches on raw queue item ids',
        if (coordinator.contains('if (item.id.isEmpty || activeIndex < 0)')) '${_relativePath(coordinatorFile)} can still let whitespace-only ids enter source resolving',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'PlaybackSwitchCoordinator 是 selection 进入底层切源的入口，必须先归一队列项 id，空白 id 不能进入 resolver、prefetcher 或底层播放器。',
      );
    });

    test('playback service normalizes ids before audio handler source replacement', () {
      final serviceFile = File(
        '${projectRoot.path}/lib/features/playback/playback_service.dart',
      );
      final service = serviceFile.readAsStringSync();
      final violations = <String>[
        if (!service.contains('String _normalizedQueueItemId(String id)')) '${_relativePath(serviceFile)} does not define queue item id normalization',
        if (!service.contains('final itemId = _normalizedQueueItemId(item.id);')) '${_relativePath(serviceFile)} can still branch on raw replacement item id',
        if (!service.contains('if (_normalizedQueueItemId(queue[activeIndex].id) != itemId)')) '${_relativePath(serviceFile)} can still compare raw active queue item id',
        if (!service.contains('final normalizedItem = itemId == item.id ? item : item.copyWith(id: itemId);')) '${_relativePath(serviceFile)} can still pass raw replacement item id to MediaItem adapter',
        if (!service.contains('mediaItemToPlay: PlaybackQueueItemAdapter.toMediaItem(normalizedItem)')) '${_relativePath(serviceFile)} does not pass normalized item to handler source replacement',
        if (!service.contains("final confirmedItemId = _normalizedQueueItemId(handler.mediaItem.value?.id ?? '');")) '${_relativePath(serviceFile)} can still read raw confirmed MediaItem id',
        if (!service.contains('queue.indexWhere((queueItem) => _normalizedQueueItemId(queueItem.id) == confirmedItemId)')) '${_relativePath(serviceFile)} can still compare raw queue ids when preserving handler current index',
        if (!service.contains('_normalizedQueueItemId(left[index].id) != _normalizedQueueItemId(right[index].id)')) '${_relativePath(serviceFile)} can still compare raw handler queue ids',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'PlaybackService 是进入 AudioServiceHandler 的边界，替换 source、同步 handler 队列和保留 currentIndex 前都必须按规范化队列项 id 判断。',
      );
    });

    test('selection UI side effects normalize item ids before delayed work', () {
      final coordinatorFile = File(
        '${projectRoot.path}/lib/features/playback/playback_selection_ui_effect_coordinator.dart',
      );
      final coordinator = coordinatorFile.readAsStringSync();
      final violations = <String>[
        if (!coordinator.contains('String _normalizedItemId(String itemId)')) '${_relativePath(coordinatorFile)} does not define selection item id normalization',
        if (!coordinator.contains('final selectedSongId = _normalizedItemId(selection.selectedItem.id);')) '${_relativePath(coordinatorFile)} can still schedule UI side effects from raw selected item id',
        if (!coordinator.contains('if (selectedSongId.isEmpty || selection.selectedIndex < 0)')) '${_relativePath(coordinatorFile)} can still schedule delayed UI side effects for blank selected ids',
        if (!coordinator.contains("final key = '\${selection.selectionVersion}:\$selectedSongId';")) '${_relativePath(coordinatorFile)} can still deduplicate selection UI work by raw id',
        if (!coordinator.contains('isStillCurrent: (trackId) => _isSelectedItem(latestSelection(), trackId)')) '${_relativePath(coordinatorFile)} does not use normalized still-current checks',
        if (!coordinator.contains('if (!_isSelectedItem(latestSelection(), selectedSongId))')) '${_relativePath(coordinatorFile)} can still cancel delayed UI work through raw id comparison',
        if (!coordinator.contains('final nextLyricState = await _lyricsPresenter.loadLyrics(selectedSong);')) '${_relativePath(coordinatorFile)} can still load lyrics with raw selected item id',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'selection UI 副作用会延迟加载歌词、取色和封面预热，调度、去重、stale 判断和 presenter 入参都必须使用规范化歌曲 id。',
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

    test('player artwork sync normalizes item ids before async artwork writeback', () {
      final artworkSyncFile = File(
        '${projectRoot.path}/lib/features/playback/player_artwork_sync.dart',
      );
      final artworkPageItemFile = File(
        '${projectRoot.path}/lib/features/playback/playback_artwork_page_item.dart',
      );
      final artworkSync = artworkSyncFile.readAsStringSync();
      final artworkPageItem = artworkPageItemFile.readAsStringSync();
      final violations = <String>[
        if (!artworkSync.contains('String _normalizedQueueItemId(String id)')) '${_relativePath(artworkSyncFile)} does not define queue item id normalization',
        if (!artworkSync.contains('final itemId = _normalizedQueueItemId(item.id);')) '${_relativePath(artworkSyncFile)} can still start artwork writeback from raw item id',
        if (!artworkSync.contains('final normalizedItem = _normalizedQueueItem(item);')) '${_relativePath(artworkSyncFile)} can still resolve artwork with a raw queue item id',
        if (!artworkSync.contains('resolveMissingArtwork(normalizedItem)')) '${_relativePath(artworkSyncFile)} does not pass the normalized item to artwork presenter',
        if (!artworkSync.contains('_normalizedQueueItemId(runtimeState.value.currentSong.id) != itemId')) '${_relativePath(artworkSyncFile)} can still drop async artwork results through raw current song comparison',
        if (!artworkSync.contains('await syncCurrentQueueItem(_normalizedQueueItem(updatedItem));')) '${_relativePath(artworkSyncFile)} can still write back raw artwork queue item ids',
        if (!artworkSync.contains('_normalizedQueueItemId(item.id) == itemId ? normalizedItem : item')) '${_relativePath(artworkSyncFile)} can still replace queue artwork by raw item id',
        if (!artworkSync.contains('final normalizedQueue = queue.map(_normalizedQueueItem).toList(growable: false);')) '${_relativePath(artworkSyncFile)} can still sync UI display queues from raw item ids',
        if (!artworkSync.contains('queueState.assignAll(normalizedQueue);')) '${_relativePath(artworkSyncFile)} can still assign raw queue display ids',
        if (!artworkSync.contains('_normalizedQueueItemId(current.id) == _normalizedQueueItemId(next.id)')) '${_relativePath(artworkSyncFile)} can still compare display queue item ids raw',
        if (!artworkPageItem.contains('id: item.id.trim()')) '${_relativePath(artworkPageItemFile)} can still build artwork page ids from raw queue item ids',
        if (!artworkPageItem.contains('id.trim() == other.id.trim()')) '${_relativePath(artworkPageItemFile)} can still compare artwork page ids raw',
      ];

      expect(
        violations,
        isEmpty,
        reason: '封面补全是异步 UI 反馈路径，回写前必须用规范化歌曲 id 判断当前歌曲和替换队列项，避免 id 空格差异导致封面丢失。',
      );
    });

    test('player controller normalizes queue item ids before UI queue writeback', () {
      final controllerFile = File(
        '${projectRoot.path}/lib/features/playback/player_controller.dart',
      );
      final stateSyncFile = File(
        '${projectRoot.path}/lib/features/playback/player_state_sync.dart',
      );
      final controller = controllerFile.readAsStringSync();
      final stateSync = stateSyncFile.readAsStringSync();
      final violations = <String>[
        if (!controller.contains('PlaybackQueueItem _normalizedPlaybackQueueItem(PlaybackQueueItem item)')) '${_relativePath(controllerFile)} does not define playback queue item normalization',
        if (!controller.contains('String _normalizedPlaybackQueueItemId(String id)')) '${_relativePath(controllerFile)} does not define playback queue item id normalization',
        if (!controller.contains('final normalizedItem = _normalizedPlaybackQueueItem(item);')) '${_relativePath(controllerFile)} can still update playback queue from a raw item id',
        if (!controller.contains('_normalizedPlaybackQueueItemId(queueItem.id) == itemId ? normalizedItem : queueItem')) '${_relativePath(controllerFile)} can still replace runtime queue items by raw id',
        if (!controller.contains('await _queueService.updateQueueItem(normalizedItem);')) '${_relativePath(controllerFile)} can still send raw queue item ids to queue service',
        if (!controller.contains('_normalizedPlaybackQueueItemId(runtimeState.value.currentSong.id) == itemId ? normalizedItem : null')) '${_relativePath(controllerFile)} can still update current runtime song through raw id comparison',
        if (!controller.contains('final selectedSongId = _normalizedPlaybackQueueItemId(selectedSong.id);')) '${_relativePath(controllerFile)} can still read selected song confirmation from raw id',
        if (!controller.contains('final confirmedSongId = _normalizedPlaybackQueueItemId(confirmedSong.id);')) '${_relativePath(controllerFile)} can still read confirmed song confirmation from raw id',
        if (!controller.contains('return selectedSongId.isNotEmpty && selectedSongId == confirmedSongId;')) '${_relativePath(controllerFile)} can still confirm selection through raw id comparison',
        if (controller.contains('selectedSong.id.isNotEmpty && selectedSong.id == confirmedSong.id')) '${_relativePath(controllerFile)} still exposes raw selected/confirmed comparison',
        if (!controller.contains('await _playbackService.updateQueueItem(normalizedItem);')) '${_relativePath(controllerFile)} can still send raw queue item ids to playback service',
        if (!stateSync.contains('final selectedItemId = _normalizedPlaybackQueueItemId(selection.selectedItem.id);')) '${_relativePath(stateSyncFile)} can still deduplicate selection error toasts by raw id',
        if (!stateSync.contains('final normalizedItem = _normalizedPlaybackQueueItem(item);')) '${_relativePath(stateSyncFile)} can still toggle liked state from a raw item id',
        if (!stateSync.contains('command = _toggleLikeFromPlayback(normalizedItem).whenComplete')) '${_relativePath(stateSyncFile)} can still pass raw item ids to the like toggle boundary',
      ];

      expect(
        violations,
        isEmpty,
        reason: '喜欢、下载和封面等队列项回写最终都会经过 PlayerController，UI runtime、队列服务和播放服务必须使用规范化歌曲 id。',
      );
    });

    test('player download commands normalize track ids before usecase and queue sync', () {
      final downloadCommandsFile = File(
        '${projectRoot.path}/lib/features/playback/player_download_commands.dart',
      );
      final downloadCommands = downloadCommandsFile.readAsStringSync();
      final violations = <String>[
        if (!downloadCommands.contains('final currentSongId = _normalizedPlaybackQueueItemId(currentSong.id);')) '${_relativePath(downloadCommandsFile)} can still start current download commands from raw current song id',
        if (!downloadCommands.contains('final normalizedTrackId = _normalizedPlaybackQueueItemId(trackId);')) '${_relativePath(downloadCommandsFile)} can still send raw track ids to download usecase',
        if (!downloadCommands.contains('_downloadUseCase.downloadTrackById(\n      normalizedTrackId,')) '${_relativePath(downloadCommandsFile)} can still download by a raw track id',
        if (!downloadCommands.contains('.map(_normalizedPlaybackQueueItemId)')) '${_relativePath(downloadCommandsFile)} can still queue raw batch download ids',
        if (!downloadCommands.contains('where((trackId) => trackId.isNotEmpty)')) '${_relativePath(downloadCommandsFile)} can still queue blank batch download ids',
        if (!downloadCommands.contains('final resultTrackId = _normalizedPlaybackQueueItemId(result.track.id);')) '${_relativePath(downloadCommandsFile)} can still compare raw download result track id',
        if (!downloadCommands.contains('currentSongId.isEmpty || currentSongId != resultTrackId')) '${_relativePath(downloadCommandsFile)} can still sync download results through raw current song comparison',
        if (!downloadCommands.contains('await syncCurrentQueueItem(_normalizedPlaybackQueueItem(result.queueItem!));')) '${_relativePath(downloadCommandsFile)} can still write back raw download queue item ids',
        if (downloadCommands.contains('currentSongState.value.id != result.track.id')) '${_relativePath(downloadCommandsFile)} still drops download results through raw id comparison',
      ];

      expect(
        violations,
        isEmpty,
        reason: '当前歌曲下载、取消、删除、重试和批量下载入口必须先规范化 track id，下载结果回写也要按规范化 id 判断当前歌曲。',
      );
    });

    test('playback control commands normalize ids before resume decisions', () {
      final commandServiceFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_ui_command_service.dart',
      );
      final stateSyncFile = File(
        '${projectRoot.path}/lib/features/playback/player_state_sync.dart',
      );
      final commandService = commandServiceFile.readAsStringSync();
      final stateSync = stateSyncFile.readAsStringSync();
      final violations = <String>[
        if (!commandService.contains('bool _hasDifferentSelection(')) '${_relativePath(commandServiceFile)} does not isolate selected/confirmed id comparison',
        if (!commandService.contains('final selectedItemId = _normalizedQueueItemId(selection.selectedItem.id);')) '${_relativePath(commandServiceFile)} can still compare raw selected item id before play',
        if (!commandService.contains('final confirmedItemId = _normalizedQueueItemId(confirmedItem.id);')) '${_relativePath(commandServiceFile)} can still compare raw confirmed item id before play',
        if (commandService.contains('selection.selectedItem.id != confirmedItem.id')) '${_relativePath(commandServiceFile)} still resumes playback through raw id comparison',
        if (!stateSync.contains('final currentSongId = _normalizedPlaybackQueueItemId(')) '${_relativePath(stateSyncFile)} does not normalize current song id before index backfill',
        if (!stateSync.contains('(element) => _normalizedPlaybackQueueItemId(element.id) == currentSongId')) '${_relativePath(stateSyncFile)} can still backfill current queue index by raw id',
        if (!stateSync.contains("details: 'id=\$currentSongId index=\$currentIndex")) '${_relativePath(stateSyncFile)} can still log raw current song id for index backfill',
      ];

      expect(
        violations,
        isEmpty,
        reason: '播放/暂停和当前索引回填是 mini player 的关键反馈路径，selection、confirmed 和 runtime queue id 必须先规范化再判断。',
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

    test('player UI commands stay outside main controller body', () {
      final controllerFile = File(
        '${projectRoot.path}/lib/features/playback/player_controller.dart',
      );
      final uiCommandsFile = File(
        '${projectRoot.path}/lib/features/playback/player_ui_commands.dart',
      );
      final controller = controllerFile.readAsStringSync();
      final uiCommands = uiCommandsFile.readAsStringSync();
      final violations = <String>[
        if (!controller.contains("part 'player_ui_commands.dart';")) 'player controller does not compose UI command part',
        if (controller.contains('IconData getRepeatIcon()')) '${_relativePath(controllerFile)} owns repeat icon UI mapping',
        if (controller.contains('void updateFullScreenLyricTimerCounter({bool cancelTimer = false})')) '${_relativePath(controllerFile)} owns full screen lyric UI timer command',
        if (!uiCommands.contains('extension PlayerUiCommands on PlayerController')) '${_relativePath(uiCommandsFile)} does not expose player UI command extension',
        if (!uiCommands.contains('IconData getRepeatIcon()')) '${_relativePath(uiCommandsFile)} does not own repeat icon UI mapping',
        if (!uiCommands.contains('void updateFullScreenLyricTimerCounter({bool cancelTimer = false})')) '${_relativePath(uiCommandsFile)} does not own lyric timer UI command',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'PlayerController 主文件只保留播放状态和命令编排，repeat 图标和歌词计时这类 UI glue 必须放在独立 part，避免主控制器继续膨胀。',
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
      final radioMapperFile = File(
        '${projectRoot.path}/lib/features/radio/radio_playback_queue_item_mapper.dart',
      );
      final radioFactoryFile = File(
        '${projectRoot.path}/lib/features/radio/radio_controller_factory.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final musicDetailBundleFile = File(
        '${projectRoot.path}/lib/features/music_detail/music_detail_controller_bundle.dart',
      );
      final cloudView = cloudViewFile.readAsStringSync();
      final cloudController = cloudControllerFile.readAsStringSync();
      final cloudFactory = cloudFactoryFile.readAsStringSync();
      final radioListView = radioListViewFile.readAsStringSync();
      final radioView = radioViewFile.readAsStringSync();
      final radioListController = radioListControllerFile.readAsStringSync();
      final radioController = radioControllerFile.readAsStringSync();
      final radioMapper = radioMapperFile.readAsStringSync();
      final radioFactory = radioFactoryFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final musicDetailBundle = musicDetailBundleFile.readAsStringSync();
      final violations = <String>[
        if (cloudView.contains('UserLibraryController')) '${_relativePath(cloudViewFile)} reads user library directly',
        if (cloudView.contains('CloudRepository')) '${_relativePath(cloudViewFile)} names cloud repository directly',
        if (cloudView.contains('UserSessionController')) '${_relativePath(cloudViewFile)} reads current user directly',
        if (cloudView.contains('likedSongIds:')) '${_relativePath(cloudViewFile)} passes liked ids from UI',
        if (cloudView.contains('Get.find<CloudPageControllerFactory>')) '${_relativePath(cloudViewFile)} reads cloud factory directly',
        if (!cloudView.contains('Get.find<MusicDetailControllerBundle>()')) '${_relativePath(cloudViewFile)} does not resolve music detail bundle at page boundary',
        if (!cloudView.contains('_controllers.cloudControllerFactory.create()')) '${_relativePath(cloudViewFile)} does not create controller through music detail bundle',
        if (cloudView.contains('Get.find<PlayerController>')) '${_relativePath(cloudViewFile)} reads playback controller directly',
        if (cloudView.contains('shrinkWrap: true')) '${_relativePath(cloudViewFile)} enables shrinkWrap on paged song list',
        if (!cloudView.contains('cacheExtent: cloudDriveListCacheExtent')) '${_relativePath(cloudViewFile)} does not bound cloud paged list cache extent',
        if (cloudController.contains('UserLibraryController')) '${_relativePath(cloudControllerFile)} reads user library directly',
        if (!cloudController.contains('required List<int> Function() likedSongIds')) 'cloud controller does not require a lazy liked ids provider',
        if (!cloudController.contains('List<int> _likedSongIdsSnapshot()')) 'cloud controller does not define a liked ids snapshot normalizer',
        if (!cloudController.contains('return normalizeLikedSongIds(_likedSongIds());')) 'cloud controller liked ids snapshot does not use shared normalizer',
        if (!cloudController.contains('likedSongIds: _likedSongIdsSnapshot()')) 'cloud controller does not pass normalized liked ids snapshots to repository',
        if (cloudController.contains('likedSongIds: _likedSongIds()')) 'cloud controller still passes raw liked ids provider output',
        if (!cloudController.contains('_userId = _normalizedUserId(userId)')) 'cloud controller does not normalize user id at controller creation',
        if (!cloudController.contains('bool get _hasUserId => _userId.isNotEmpty')) 'cloud controller does not guard normalized current user before repository access',
        if (!cloudController.contains('static String _normalizedUserId(String userId)')) 'cloud controller does not define user id normalization',
        if (!cloudFactory.contains('CloudPageController create({int pageSize = 30})')) 'cloud controller factory does not create page-local controllers',
        if (!cloudFactory.contains('userId: _currentUserId()')) 'cloud controller factory does not snapshot current user at controller creation',
        if (!cloudFactory.contains('likedSongIds: _likedSongIds')) 'cloud controller factory does not inject liked ids provider',
        if (radioListView.contains('RadioRepository')) '${_relativePath(radioListViewFile)} names radio repository directly',
        if (radioListView.contains('UserSessionController')) '${_relativePath(radioListViewFile)} reads current user directly',
        if (radioListView.contains('Get.find<RadioControllerFactory>')) '${_relativePath(radioListViewFile)} reads radio factory directly',
        if (!radioListView.contains('Get.find<MusicDetailControllerBundle>()')) '${_relativePath(radioListViewFile)} does not resolve music detail bundle at page boundary',
        if (!radioListView.contains('_controllers.radioControllerFactory.createList()')) '${_relativePath(radioListViewFile)} does not create list controller through music detail bundle',
        if (radioListView.contains('shrinkWrap: true')) '${_relativePath(radioListViewFile)} enables shrinkWrap on paged radio list',
        if (!radioListView.contains('itemExtent: myRadioListItemExtent')) '${_relativePath(radioListViewFile)} does not fix radio list item extent',
        if (!radioListView.contains('height: myRadioListItemExtent')) '${_relativePath(radioListViewFile)} does not share radio row height with item extent',
        if (!radioListController.contains('_userId = _normalizedUserId(userId)')) 'radio list controller does not normalize user id at controller creation',
        if (!radioListController.contains('bool get _hasUserId => _userId.isNotEmpty')) 'radio list controller does not guard normalized current user before repository access',
        if (!radioListController.contains('static String _normalizedUserId(String userId)')) 'radio list controller does not define user id normalization',
        if (radioView.contains('UserLibraryController')) '${_relativePath(radioViewFile)} reads user library directly',
        if (radioView.contains('RadioRepository')) '${_relativePath(radioViewFile)} names radio repository directly',
        if (radioView.contains('UserSessionController')) '${_relativePath(radioViewFile)} reads current user directly',
        if (radioView.contains('Get.find<RadioControllerFactory>')) '${_relativePath(radioViewFile)} reads radio factory directly',
        if (!radioView.contains('Get.find<MusicDetailControllerBundle>()')) '${_relativePath(radioViewFile)} does not resolve music detail bundle at page boundary',
        if (!radioView.contains('_controllers.radioControllerFactory.createDetail(radioId: _radioId)')) '${_relativePath(radioViewFile)} does not create detail controller through music detail bundle',
        if (radioView.contains('Get.find<PlayerController>')) '${_relativePath(radioViewFile)} reads playback controller directly',
        if (radioView.contains('shrinkWrap: true')) '${_relativePath(radioViewFile)} enables shrinkWrap on paged radio program list',
        if (!radioView.contains('cacheExtent: radioProgramListCacheExtent')) '${_relativePath(radioViewFile)} does not bound radio program list cache extent',
        if (radioView.contains('RadioPlaybackQueueItemMapper.fromPrograms')) '${_relativePath(radioViewFile)} maps radio queue items in UI',
        if (!radioView.contains('final queueItems = _controller.queueItems')) '${_relativePath(radioViewFile)} does not read queue items from controller',
        if (radioController.contains('UserLibraryController')) '${_relativePath(radioControllerFile)} reads user library directly',
        if (!radioController.contains('List<PlaybackQueueItem> get queueItems')) 'radio detail controller does not expose queue items',
        if (!radioController.contains('required List<int> Function() likedSongIds')) 'radio detail controller does not require a lazy liked ids provider',
        if (!radioController.contains('List<int> _likedSongIdsSnapshot()')) 'radio detail controller does not define a liked ids snapshot normalizer',
        if (!radioController.contains('return normalizeLikedSongIds(_likedSongIds());')) 'radio detail controller liked ids snapshot does not use shared normalizer',
        if (!radioController.contains('likedSongIds: _likedSongIdsSnapshot()')) 'radio detail controller does not derive liked state from normalized snapshot',
        if (radioController.contains('likedSongIds: _likedSongIds()')) 'radio detail controller still maps liked state from raw provider output',
        if (!radioController.contains('_userId = _normalizedUserId(userId)')) 'radio detail controller does not normalize user id at controller creation',
        if (!radioController.contains('bool get _hasUserId => _userId.isNotEmpty')) 'radio detail controller does not guard normalized current user before repository access',
        if (!radioController.contains('static String _normalizedUserId(String userId)')) 'radio detail controller does not define user id normalization',
        if (radioMapper.contains('metadata:')) 'radio playback queue mapper writes legacy dynamic metadata',
        if (!radioFactory.contains('RadioListController createList({int pageSize = 30})')) 'radio controller factory does not create list controllers',
        if (!radioFactory.contains('RadioDetailController createDetail({')) 'radio controller factory does not create detail controllers',
        if (!radioFactory.contains('userId: _currentUserId()')) 'radio controller factory does not snapshot current user at controller creation',
        if (!radioFactory.contains('likedSongIds: _likedSongIds')) 'radio controller factory does not inject liked ids provider',
        if (!bootstrap.contains('CloudPageControllerFactory(')) 'feature bootstrap does not register cloud controller factory',
        if (!bootstrap.contains('RadioControllerFactory(')) 'feature bootstrap does not register radio controller factory',
        if (!bootstrap.contains('Get.put<MusicDetailControllerBundle>')) 'feature bootstrap does not register music detail controller bundle',
        if (!bootstrap.contains('cloudControllerFactory: Get.find<CloudPageControllerFactory>()')) 'feature bootstrap does not inject cloud factory into music detail bundle',
        if (!bootstrap.contains('radioControllerFactory: Get.find<RadioControllerFactory>()')) 'feature bootstrap does not inject radio factory into music detail bundle',
        if (!musicDetailBundle.contains('final CloudPageControllerFactory cloudControllerFactory')) 'music detail bundle does not expose cloud controller factory',
        if (!musicDetailBundle.contains('final RadioControllerFactory radioControllerFactory')) 'music detail bundle does not expose radio controller factory',
        if (!musicDetailBundle.contains('final MusicPagePlaybackActions playbackActions')) 'music detail bundle does not expose playback actions',
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
        if (!repository.contains('String _normalizedUserId(String userId)')) '${_relativePath(repositoryFile)} does not normalize account scoped user ids',
        if (!repository.contains('final normalizedUserId = _normalizedUserId(userId);')) '${_relativePath(repositoryFile)} does not normalize user ids at repository entry points',
        if (!repository.contains('if (_isBlankUserId(normalizedUserId))')) '${_relativePath(repositoryFile)} does not guard normalized user-scoped cloud entry points',
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
      final utilityBundleFile = File(
        '${projectRoot.path}/lib/features/settings/utility_page_controller_bundle.dart',
      );
      final page = pageFile.readAsStringSync();
      final factory = factoryFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final utilityBundle = utilityBundleFile.readAsStringSync();
      final violations = <String>[
        if (page.contains('MusicDataRepository')) '${_relativePath(pageFile)} names music data repository directly',
        if (page.contains('DownloadRepository')) '${_relativePath(pageFile)} names download repository directly',
        if (page.contains('Get.find<LocalSongListControllerFactory>')) '${_relativePath(pageFile)} reads local song factory directly',
        if (!page.contains('Get.find<UtilityPageControllerBundle>()')) '${_relativePath(pageFile)} does not resolve utility page bundle at page boundary',
        if (!page.contains('_controllers.localSongListControllerFactory.create(origins: origins)')) '${_relativePath(pageFile)} does not create local song controllers through utility bundle',
        if (!factory.contains('LocalSongListController create({')) 'local song controller factory does not create page-local controllers',
        if (!factory.contains('musicDataRepository: _musicDataRepository')) 'local song controller factory does not inject music data repository',
        if (!factory.contains('downloadRepository: _downloadRepository')) 'local song controller factory does not inject download repository',
        if (!bootstrap.contains('LocalSongListControllerFactory(')) 'feature bootstrap does not register local song controller factory',
        if (!bootstrap.contains('Get.put<UtilityPageControllerBundle>')) 'feature bootstrap does not register utility page controller bundle',
        if (!bootstrap.contains('localSongListControllerFactory: Get.find<LocalSongListControllerFactory>()')) 'feature bootstrap does not inject local song factory into utility bundle',
        if (!utilityBundle.contains('final LocalSongListControllerFactory localSongListControllerFactory')) 'utility bundle does not expose local song list controller factory',
      ];

      expect(
        violations,
        isEmpty,
        reason: '下载页可以拥有 tab 和 controller 生命周期，但不能在 Widget 内直接拼装 MusicDataRepository 或 DownloadRepository。',
      );
    });

    test('local song list controller normalizes track ids before visible removal', () {
      final controllerFile = File(
        '${projectRoot.path}/lib/features/download/local_song_list_controller.dart',
      );
      final controller = controllerFile.readAsStringSync();
      final violations = <String>[
        if (!controller.contains('String _normalizedTrackId(String trackId)')) '${_relativePath(controllerFile)} does not define track id normalization',
        if (!controller.contains('final normalizedTrackId = _normalizedTrackId(trackId);')) '${_relativePath(controllerFile)} can still remove local tracks from a raw track id',
        if (!controller.contains('await _downloadRepository.removeLocalTrack(normalizedTrackId);')) '${_relativePath(controllerFile)} can still pass raw track ids to download repository',
        if (!controller.contains('(entry) => _normalizedTrackId(entry.track.id) == normalizedTrackId')) '${_relativePath(controllerFile)} can still remove visible fallback entries by raw ids',
        if (controller.contains('entry.track.id == trackId')) '${_relativePath(controllerFile)} still compares visible entries by raw track id',
      ];

      expect(
        violations,
        isEmpty,
        reason: '下载页本地歌曲列表删除后会先剔除可见 fallback；传入 id 和可见条目 id 都必须规范化，避免刷新失败时已删除资源继续显示。',
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

    test('download resource writer verifies indexed audio files before completion', () {
      final writerFile = File(
        '${projectRoot.path}/lib/features/download/application/download_resource_writer.dart',
      );
      final writer = writerFile.readAsStringSync();
      final availabilityMethod = writer.indexOf('Future<bool> _hasAvailableAudioResource');
      final violations = <String>[
        if (availabilityMethod < 0) '${_relativePath(writerFile)} is missing audio availability verification',
        if (!writer.contains("import 'package:bujuan/core/util/track_resource_availability.dart';")) '${_relativePath(writerFile)} does not use the shared resource availability policy',
        if (!writer.contains('final normalizedTrackId = _normalizedTrackId(trackId);')) '${_relativePath(writerFile)} does not normalize track ids before writing resources',
        if (!writer.contains('if (normalizedTrackId.isEmpty)')) '${_relativePath(writerFile)} does not reject blank track ids before writing resources',
        if (!writer.contains('final audioFile = TrackResourceAvailability.existingFileForPath(audioPath);')) '${_relativePath(writerFile)} does not validate the audio path before saving an audio index',
        if (!writer.contains('if (audioFile == null)')) '${_relativePath(writerFile)} can write resource indexes before audio file availability is known',
        if (!writer.contains('path: audioFile.path')) '${_relativePath(writerFile)} does not save normalized audio file paths',
        if (!writer.contains('final artworkFile = TrackResourceAvailability.existingFileForPath(artworkPath);')) '${_relativePath(writerFile)} does not validate artwork files before saving indexes',
        if (!writer.contains('final lyricsFile = TrackResourceAvailability.existingFileForPath(lyricsPath);')) '${_relativePath(writerFile)} does not validate lyrics files before saving indexes',
        if (!writer.contains('TrackResourceAvailability.isAvailableAudioResource(')) '${_relativePath(writerFile)} does not verify indexed audio through the shared policy',
        if (!writer.contains('allowedOrigins: availableAudioOrigins')) '${_relativePath(writerFile)} does not verify the expected audio resource origin',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'DownloadResourceWriter 清理下载任务或保存附属资源前，必须确认主音频资源来源正确且文件真实存在。',
      );
    });

    test('download file store normalizes paths before deleting files', () {
      final fileStoreFile = File(
        '${projectRoot.path}/lib/features/download/application/download_file_store.dart',
      );
      final fileStore = fileStoreFile.readAsStringSync();
      final deleteMethod = fileStore.indexOf('Future<void> deleteFileIfExists');
      final violations = <String>[
        if (deleteMethod < 0) '${_relativePath(fileStoreFile)} is missing deleteFileIfExists',
        if (!fileStore.contains("import 'package:bujuan/core/util/local_file_path_normalizer.dart';")) '${_relativePath(fileStoreFile)} does not import LocalFilePathNormalizer',
        if (!fileStore.contains('final localPath = LocalFilePathNormalizer.normalize(path);')) '${_relativePath(fileStoreFile)} does not normalize delete paths',
        if (!fileStore.contains('final file = File(localPath);')) '${_relativePath(fileStoreFile)} can still delete raw paths',
      ];

      expect(
        violations,
        isEmpty,
        reason: '下载失败、取消和重试清理临时文件前必须复用本地路径归一化，历史 file:// 路径可清理，远程或不安全 URI 不能被当作本地文件删除。',
      );
    });

    test('download queue planner skips available local audio resources', () {
      final plannerFile = File(
        '${projectRoot.path}/lib/features/download/application/download_queue_planner.dart',
      );
      final planner = plannerFile.readAsStringSync();
      final violations = <String>[
        if (planner.contains('_isAvailableManagedDownload')) '${_relativePath(plannerFile)} only models managed download availability',
        if (!planner.contains("import 'package:bujuan/core/util/track_resource_availability.dart';")) '${_relativePath(plannerFile)} does not use the shared resource availability policy',
        if (!planner.contains('TrackResourceAvailability.isDownloadSatisfiedAudioResource(audioResource)')) '${_relativePath(plannerFile)} does not treat available local audio as already available',
        if (!planner.contains('track.sourceType == SourceType.local || TrackResourceAvailability.isDownloadSatisfiedAudioResource(audioResource)')) '${_relativePath(plannerFile)} does not skip available local audio before queueing',
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

    test('download task dao normalizes persisted track ids', () {
      final daoFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/dao/download_task_dao.dart',
      );
      final dao = daoFile.readAsStringSync();
      final violations = <String>[
        if (!dao.contains('String _normalizedTrackId(String trackId)')) '${_relativePath(daoFile)} does not define a normalized track id helper',
        if (!dao.contains('bool _isBlankTrackId(String trackId)')) '${_relativePath(daoFile)} does not guard blank track ids',
        if (!dao.contains('final normalizedTrackId = _normalizedTrackId(trackId);')) '${_relativePath(daoFile)} does not normalize raw task lookup ids',
        if (!dao.contains('final normalizedTrackId = _normalizedTrackId(task.trackId);')) '${_relativePath(daoFile)} does not normalize saved task ids',
        if (!dao.contains('trackId: drift.Value(normalizedTrackId)')) '${_relativePath(daoFile)} can still write raw task ids into download_tasks',
        if (!dao.contains('tbl.trackId.equals(normalizedTrackId)')) '${_relativePath(daoFile)} can still query or delete raw task ids',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'download_tasks 是下载过程事实表，DAO 持久化边界也必须规范化曲目 id 并拒绝空白 id，不能只依赖上层 store。',
      );
    });

    test('track dao normalizes persisted library ids', () {
      final daoFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/dao/track_dao.dart',
      );
      final dao = daoFile.readAsStringSync();
      final violations = <String>[
        if (!dao.contains('String _normalizedTrackId(String trackId)')) '${_relativePath(daoFile)} does not normalize track ids',
        if (!dao.contains('bool _isBlankTrackId(String trackId)')) '${_relativePath(daoFile)} does not guard blank track ids',
        if (!dao.contains('String _normalizedAlbumId(String albumId)')) '${_relativePath(daoFile)} does not normalize album ids',
        if (!dao.contains('String _normalizedArtistId(String artistId)')) '${_relativePath(daoFile)} does not normalize artist ids',
        if (!dao.contains('List<String> _candidateTrackIds(Iterable<String> trackIds)')) '${_relativePath(daoFile)} does not normalize batch track lookups',
        if (!dao.contains('Track _normalizedTrackForSave(Track track)')) '${_relativePath(daoFile)} does not normalize tracks before persistence',
        if (!dao.contains('AlbumEntity _normalizedAlbumForSave(AlbumEntity album)')) '${_relativePath(daoFile)} does not normalize albums before persistence',
        if (!dao.contains('ArtistEntity _normalizedArtistForSave(ArtistEntity artist)')) '${_relativePath(daoFile)} does not normalize artists before persistence',
        if (!dao.contains('final normalizedTrackId = _normalizedTrackId(trackId);')) '${_relativePath(daoFile)} can still query lyrics or tracks by raw track ids',
        if (!dao.contains('final normalizedTracks = tracks.map(_normalizedTrackForSave).where((track) => !_isBlankTrackId(track.id)).toList();')) '${_relativePath(daoFile)} can still persist blank or raw track ids',
        if (!dao.contains('final artistRefs = normalizedTracks.expand((track) {')) '${_relativePath(daoFile)} can still write raw track artist refs',
        if (!dao.contains('trackId: drift.Value(normalizedTrackId)')) '${_relativePath(daoFile)} can still write raw lyric track ids',
        if (!dao.contains('tbl.trackId.equals(normalizedTrackId)')) '${_relativePath(daoFile)} can still read or delete raw track ids',
        if (!dao.contains('tbl.albumSourceId.equals(normalizedAlbumId)')) '${_relativePath(daoFile)} can still read raw album ids',
        if (!dao.contains('artistSourceId.equals(normalizedArtistId)')) '${_relativePath(daoFile)} can still read raw artist ids',
        if (!dao.contains('return _normalizedIds(track.resolvedArtistIds);')) '${_relativePath(daoFile)} can still write blank or duplicate artist refs',
        if (!dao.contains('albumId: drift.Value(album.id)')) '${_relativePath(daoFile)} can still write raw album ids',
        if (!dao.contains('artistId: drift.Value(artist.id)')) '${_relativePath(daoFile)} can still write raw artist ids',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'tracks、track_lyrics_entries、albums、artists 和 track_artist_refs 都是曲库事实表，DAO 边界必须归一曲目、专辑和歌手 id 并拒绝空白 key。',
      );
    });

    test('resource dao normalizes persisted local resource ids', () {
      final daoFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/dao/resource_dao.dart',
      );
      final dao = daoFile.readAsStringSync();
      final violations = <String>[
        if (!dao.contains('String _normalizedTrackId(String trackId)')) '${_relativePath(daoFile)} does not normalize track ids',
        if (!dao.contains('bool _isBlankTrackId(String trackId)')) '${_relativePath(daoFile)} does not guard blank track ids',
        if (!dao.contains('List<String> _candidateTrackIds(Iterable<String> trackIds)')) '${_relativePath(daoFile)} does not normalize batch resource lookups',
        if (!dao.contains('LocalResourceEntry _normalizedResourceForSave(LocalResourceEntry entry)')) '${_relativePath(daoFile)} does not normalize resources before persistence',
        if (!dao.contains('final normalizedTrackId = _normalizedTrackId(trackId);')) '${_relativePath(daoFile)} can still query, touch, or delete resources by raw track ids',
        if (!dao.contains('final normalizedEntry = _normalizedResourceForSave(entry);')) '${_relativePath(daoFile)} can still save raw resource track ids',
        if (!dao.contains('trackId: drift.Value(normalizedEntry.trackId)')) '${_relativePath(daoFile)} can still write raw resource track ids',
        if (!dao.contains('tbl.trackId.equals(normalizedTrackId)')) '${_relativePath(daoFile)} can still read, touch, or delete raw resource track ids',
        if (!dao.contains('entry.copyWith(trackId: _normalizedTrackId(entry.trackId))')) '${_relativePath(daoFile)} can still persist unnormalized resource entries',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'local_resource_entries 是播放和下载共享的最终资源事实表，DAO 边界必须归一曲目 id 并拒绝空白 key。',
      );
    });

    test('playlist dao normalizes persisted playlist detail ids', () {
      final daoFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/dao/playlist_dao.dart',
      );
      final dao = daoFile.readAsStringSync();
      final violations = <String>[
        if (!dao.contains('String _normalizedPlaylistEntityId(String playlistId)')) '${_relativePath(daoFile)} does not normalize playlist ids',
        if (!dao.contains('bool _isBlankPlaylistEntityId(String playlistId)')) '${_relativePath(daoFile)} does not guard blank playlist ids',
        if (!dao.contains('List<String> _normalizedPlaylistEntityIds(List<String> playlistIds)')) '${_relativePath(daoFile)} does not normalize batch playlist lookups',
        if (!dao.contains('String _normalizedTrackId(String trackId)')) '${_relativePath(daoFile)} does not normalize playlist track ids',
        if (!dao.contains('bool _isBlankTrackId(String trackId)')) '${_relativePath(daoFile)} does not guard blank playlist track ids',
        if (!dao.contains('PlaylistEntity _normalizedPlaylistForSave(PlaylistEntity playlist)')) '${_relativePath(daoFile)} does not normalize playlist details before persistence',
        if (!dao.contains('List<PlaylistTrackRef> _normalizedPlaylistTrackRefs(')) '${_relativePath(daoFile)} does not normalize playlist track refs before persistence',
        if (!dao.contains('final normalizedPlaylistId = _normalizedPlaylistEntityId(playlistId);')) '${_relativePath(daoFile)} can still query or delete playlists by raw playlist ids',
        if (!dao.contains('final normalizedPlaylists = _normalizedPlaylists(playlists);')) '${_relativePath(daoFile)} can still persist raw playlist details',
        if (!dao.contains('playlistId: drift.Value(playlist.id)')) '${_relativePath(daoFile)} can still write raw playlist ids',
        if (!dao.contains('playlistId: playlist.id')) '${_relativePath(daoFile)} can still write raw playlist ref playlist ids',
        if (!dao.contains('trackId: trackRef.trackId')) '${_relativePath(daoFile)} can still write raw playlist ref track ids',
        if (!dao.contains('MusicResourceId.sourceTypeOf(normalizedPlaylistId)')) '${_relativePath(daoFile)} does not derive source type from normalized playlist id',
        if (!dao.contains('MusicResourceId.toSourceId(normalizedPlaylistId)')) '${_relativePath(daoFile)} does not derive source id from normalized playlist id',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'playlists 和 playlist_track_refs 是歌单详情缓存事实表，DAO 边界必须归一歌单 id 和曲目 id，并拒绝空白 key。',
      );
    });

    test('cache dao normalizes persisted app cache keys', () {
      final daoFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/dao/cache_dao.dart',
      );
      final dao = daoFile.readAsStringSync();
      final violations = <String>[
        if (!dao.contains('String _normalizedCacheKey(String cacheKey)')) '${_relativePath(daoFile)} does not normalize cache keys',
        if (!dao.contains('bool _isBlankCacheKey(String cacheKey)')) '${_relativePath(daoFile)} does not guard blank cache keys',
        if (!dao.contains('final normalizedCacheKey = _normalizedCacheKey(cacheKey);')) '${_relativePath(daoFile)} can still read, write, or delete raw cache keys',
        if (!dao.contains('final normalizedCacheKeyPrefix = _normalizedCacheKey(cacheKeyPrefix);')) '${_relativePath(daoFile)} can still delete by raw cache prefixes',
        if (!dao.contains('cacheKey: drift.Value(normalizedCacheKey)')) '${_relativePath(daoFile)} can still write raw cache keys',
        if (!dao.contains('tbl.cacheKey.equals(normalizedCacheKey)')) '${_relativePath(daoFile)} can still query or delete raw cache keys',
        if (!dao.contains(r"tbl.cacheKey.like('$normalizedCacheKeyPrefix%')")) '${_relativePath(daoFile)} can still delete by raw cache prefixes',
        if (!dao.contains('if (_isBlankCacheKey(normalizedCacheKeyPrefix))')) '${_relativePath(daoFile)} can still delete the whole cache table with a blank prefix',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'app_cache_entries 是搜索和评论的短期本地优先缓存表，DAO 边界必须归一 cacheKey，并拒绝空白 key 或空白 prefix。',
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
        if (!page.contains('final SettingsPageControllerBundle controllers = Get.find<SettingsPageControllerBundle>()')) '${_relativePath(pageFile)} does not resolve settings page controller bundle at page boundary',
        if (page.contains('Get.find<SettingsController>')) '${_relativePath(pageFile)} reads settings controller globally',
        if (!page.contains('final settingsController = controllers.settingsController')) '${_relativePath(pageFile)} does not receive settings controller from settings page bundle',
        if (!bootstrap.contains('Get.put<SettingsPageControllerBundle>')) 'feature bootstrap does not register settings page controller bundle',
        if (!bootstrap.contains('settingsController: Get.find<SettingsController>()')) 'feature bootstrap does not inject settings controller into settings page bundle',
        if (!page.contains('settingsController: settingsController')) '${_relativePath(pageFile)} does not inject settings controller into sections',
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
      final utilityBundleFile = File(
        '${projectRoot.path}/lib/features/settings/utility_page_controller_bundle.dart',
      );
      final page = pageFile.readAsStringSync();
      final controller = controllerFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final utilityBundle = utilityBundleFile.readAsStringSync();
      final violations = <String>[
        if (page.contains('Get.find<CacheAnalysisService>')) '${_relativePath(pageFile)} reads cache service directly',
        if (page.contains('CacheAnalysisService')) '${_relativePath(pageFile)} names cache service directly',
        if (page.contains('Get.find<CacheAnalysisControllerFactory>')) '${_relativePath(pageFile)} reads cache analysis factory directly',
        if (!page.contains('Get.find<UtilityPageControllerBundle>()')) '${_relativePath(pageFile)} does not resolve utility page bundle at page boundary',
        if (!page.contains('_controllers.cacheAnalysisControllerFactory.create()')) '${_relativePath(pageFile)} does not create controller through utility bundle',
        if (!controller.contains('class CacheAnalysisControllerFactory')) '${_relativePath(controllerFile)} does not define cache analysis controller factory',
        if (!controller.contains('required CacheAnalysisService service')) '${_relativePath(controllerFile)} does not receive cache analysis service through constructor',
        if (!bootstrap.contains('CacheAnalysisControllerFactory(')) 'feature bootstrap does not register cache analysis controller factory',
        if (!bootstrap.contains('cacheAnalysisControllerFactory: Get.find<CacheAnalysisControllerFactory>()')) 'feature bootstrap does not inject cache analysis factory into utility bundle',
        if (!utilityBundle.contains('final CacheAnalysisControllerFactory cacheAnalysisControllerFactory')) 'utility bundle does not expose cache analysis controller factory',
      ];

      expect(
        violations,
        isEmpty,
        reason: '缓存分析页可以处理确认弹窗和 Toast，但分析/清理服务必须由 feature controller factory 注入。',
      );
    });

    test('retained cache file cleanup stays in shared cleaner', () {
      final cleanerFile = File(
        '${projectRoot.path}/lib/core/util/retained_file_cleaner.dart',
      );
      final settingsFile = File(
        '${projectRoot.path}/lib/features/settings/cache_analysis_service.dart',
      );
      final downloadFile = File(
        '${projectRoot.path}/lib/features/download/application/download_file_store.dart',
      );
      final cleaner = cleanerFile.readAsStringSync();
      final settings = settingsFile.readAsStringSync();
      final download = downloadFile.readAsStringSync();
      const privateCleanupFragments = [
        'Future<void> _deleteUnretainedDirectoryFiles',
        'Future<void> _deleteFileUnlessRetained',
        '_normalizedRetainedPaths(',
        '_deleteFileUnlessNormalizedRetained(',
      ];
      final violations = <String>[
        if (!cleaner.contains('class RetainedFileCleaner')) '${_relativePath(cleanerFile)} does not define shared cleaner',
        if (!cleaner.contains('LocalFilePathNormalizer.normalize')) '${_relativePath(cleanerFile)} does not normalize retained paths',
        if (!cleaner.contains('static Future<void> clearDirectory(')) '${_relativePath(cleanerFile)} does not expose directory cleanup',
        if (!cleaner.contains('static Future<void> deleteFileUnlessRetained(')) '${_relativePath(cleanerFile)} does not expose single-file cleanup',
        if (!cleaner.contains('static Future<void> deleteUnretainedDirectoryFiles(')) '${_relativePath(cleanerFile)} does not expose orphan directory cleanup',
        if (!settings.contains("import 'package:bujuan/core/util/retained_file_cleaner.dart';")) '${_relativePath(settingsFile)} does not import shared cleaner',
        if (!settings.contains("import 'package:bujuan/data/music_data/sources/local/resources/local_resource_retention_policy.dart';")) '${_relativePath(settingsFile)} does not import shared resource retention policy',
        if (!download.contains("import 'package:bujuan/core/util/retained_file_cleaner.dart';")) '${_relativePath(downloadFile)} does not import shared cleaner',
        if (!settings.contains('RetainedFileCleaner.clearDirectory(')) '${_relativePath(settingsFile)} does not clear cache directories through shared cleaner',
        if (!settings.contains('RetainedFileCleaner.deleteFileUnlessRetained(')) '${_relativePath(settingsFile)} does not clean indexed files through shared cleaner',
        if (!settings.contains('RetainedFileCleaner.deleteUnretainedDirectoryFiles(')) '${_relativePath(settingsFile)} does not clean orphan files through shared cleaner',
        if (!settings.contains('LocalResourceRetentionPolicy.retainedPathsAfterRemoving(')) '${_relativePath(settingsFile)} does not calculate retained indexed resources through shared policy',
        if (!settings.contains('LocalResourceRetentionPolicy.normalizedPath(resource)')) '${_relativePath(settingsFile)} does not normalize indexed resource paths through shared policy',
        if (!download.contains('RetainedFileCleaner.clearDirectory(')) '${_relativePath(downloadFile)} does not clear playback cache files through shared cleaner',
        if (privateCleanupFragments.any(settings.contains)) '${_relativePath(settingsFile)} defines private retained-file cleanup logic',
        if (privateCleanupFragments.any(download.contains)) '${_relativePath(downloadFile)} defines private retained-file cleanup logic',
      ];

      expect(
        violations,
        isEmpty,
        reason: '设置页和下载页的保留路径缓存清理必须复用 RetainedFileCleaner 和 LocalResourceRetentionPolicy，避免本地路径归一、索引保留、孤儿文件和空目录处理再次分叉。',
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
        if (!page.contains('final SettingsPageControllerBundle controllers = Get.find<SettingsPageControllerBundle>()')) '${_relativePath(pageFile)} does not resolve settings page controller bundle at page boundary',
        if (page.contains('Get.find<PlayerController>')) '${_relativePath(pageFile)} reads playback controller globally',
        if (!page.contains('final playerController = controllers.playerController')) '${_relativePath(pageFile)} does not receive playback controller from settings page bundle',
        if (!bootstrap.contains('playerController: Get.find<PlayerController>()')) 'feature bootstrap does not inject playback controller into settings page bundle',
        if (!page.contains('playerController: playerController')) '${_relativePath(pageFile)} does not inject playback controller into setting sections',
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
      final utilityBundleFile = File(
        '${projectRoot.path}/lib/features/settings/utility_page_controller_bundle.dart',
      );
      final page = pageFile.readAsStringSync();
      final factory = factoryFile.readAsStringSync();
      final controller = controllerFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final utilityBundle = utilityBundleFile.readAsStringSync();
      final violations = <String>[
        if (page.contains('UserRepository')) '${_relativePath(pageFile)} names user repository directly',
        if (page.contains('UserSessionController')) '${_relativePath(pageFile)} reads current user directly',
        if (page.contains('AuthController')) '${_relativePath(pageFile)} reads auth controller directly',
        if (page.contains('Get.find<UserProfileControllerFactory>')) '${_relativePath(pageFile)} reads profile factory directly',
        if (!page.contains('Get.find<UtilityPageControllerBundle>()')) '${_relativePath(pageFile)} does not resolve utility page bundle at page boundary',
        if (!page.contains('_controllers.userProfileControllerFactory.create()')) '${_relativePath(pageFile)} does not create profile controller through utility bundle',
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
        if (!bootstrap.contains('userProfileControllerFactory: Get.find<UserProfileControllerFactory>()')) 'feature bootstrap does not inject profile factory into utility bundle',
        if (!utilityBundle.contains('final UserProfileControllerFactory userProfileControllerFactory')) 'utility bundle does not expose user profile controller factory',
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
      final controllerFile = File(
        '${projectRoot.path}/lib/features/playlist/playlist_page_controller.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final page = pageFile.readAsStringSync();
      final factory = factoryFile.readAsStringSync();
      final controller = controllerFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (page.contains('PlaylistRepository')) '${_relativePath(pageFile)} names playlist repository directly',
        if (page.contains('UserLibraryController')) '${_relativePath(pageFile)} reads user library directly',
        if (page.contains('UserSessionController')) '${_relativePath(pageFile)} reads current user directly',
        if (page.contains('likedSongIds:')) '${_relativePath(pageFile)} passes liked ids from UI',
        if (page.contains('currentUserId:')) '${_relativePath(pageFile)} passes current user from UI',
        if (page.contains('PlaylistArtworkColorService()')) '${_relativePath(pageFile)} creates artwork color service directly',
        if (page.contains('Get.find<PlaylistPageControllerFactory>')) '${_relativePath(pageFile)} reads playlist factory directly',
        if (page.contains('Get.find<PlayerController>')) '${_relativePath(pageFile)} reads playback controller directly',
        if (page.contains('Get.find<ShellController>')) '${_relativePath(pageFile)} reads shell controller directly',
        if (page.contains('final Random _random')) '${_relativePath(pageFile)} keeps playback shuffle selection in UI',
        if (!page.contains('Get.find<MusicDetailControllerBundle>()')) '${_relativePath(pageFile)} does not resolve music detail bundle at page boundary',
        if (!page.contains('final controllerFactory = _controllers.playlistControllerFactory')) '${_relativePath(pageFile)} does not resolve playlist factory through music detail bundle',
        if (!page.contains('_controller = controllerFactory.create()')) '${_relativePath(pageFile)} does not create playlist controller through feature factory',
        if (!page.contains('_artworkColorService = controllerFactory.createArtworkColorService()')) '${_relativePath(pageFile)} does not receive artwork color service through feature factory',
        if (!page.contains('playShuffledPlaylist(')) '${_relativePath(pageFile)} does not route shuffle playback through music page playback actions',
        if (!page.contains('playSequentialPlaylist(')) '${_relativePath(pageFile)} does not route sequential playback through music page playback actions',
        if (!page.contains('playPlaylistAndOpenPanel(')) '${_relativePath(pageFile)} does not route song playback through music page playback actions',
        if (!factory.contains('PlaylistPageController create()')) 'playlist page controller factory does not create page controllers',
        if (!factory.contains('PlaylistArtworkColorService createArtworkColorService()')) 'playlist page controller factory does not expose artwork color service',
        if (!factory.contains('required PlaylistArtworkColorService artworkColorService')) 'playlist page controller factory does not receive artwork color service',
        if (!factory.contains('likedSongIds: _likedSongIds')) 'playlist page controller factory does not inject liked ids provider',
        if (!factory.contains('currentUserId: _currentUserId')) 'playlist page controller factory does not inject current user provider',
        if (!factory.contains('repository: _repository')) 'playlist page controller factory does not inject playlist repository',
        if (!controller.contains('String _currentUserIdSnapshot()')) 'playlist page controller does not centralize current user snapshots',
        if (!controller.contains('_normalizedCurrentUserId(_currentUserId())')) 'playlist page controller does not normalize current user snapshots',
        if (!controller.contains('static String _normalizedCurrentUserId(String userId)')) 'playlist page controller does not define current user normalization',
        if (!controller.contains('List<int> _likedSongIdsSnapshot()')) 'playlist page controller does not define a liked ids snapshot normalizer',
        if (!controller.contains('return normalizeLikedSongIds(_likedSongIds());')) 'playlist page controller liked ids snapshot does not use shared normalizer',
        if (!controller.contains('likedSongIds: _likedSongIdsSnapshot()')) 'playlist page controller does not pass normalized liked ids snapshots to repository',
        if (controller.contains('likedSongIds: _likedSongIds()')) 'playlist page controller still passes raw liked ids provider output',
        if (controller.contains('currentUserId: _currentUserId()')) 'playlist page controller still passes raw current user ids to repository',
        if (!bootstrap.contains('Get.put<PlaylistArtworkColorService>')) 'feature bootstrap does not register playlist artwork color service',
        if (!bootstrap.contains('PlaylistPageControllerFactory(')) 'feature bootstrap does not register playlist page controller factory',
        if (!bootstrap.contains('playlistControllerFactory: Get.find<PlaylistPageControllerFactory>()')) 'feature bootstrap does not inject playlist factory into music detail bundle',
        if (!bootstrap.contains('playbackActions: Get.find<MusicPagePlaybackActions>()')) 'feature bootstrap does not inject playback actions into music detail bundle',
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

    test('playlist page opens playback panel through music playback actions', () {
      final pageFile = File(
        '${projectRoot.path}/lib/ui/pages/playlist/playlist_page_view.dart',
      );
      final actionsFile = File(
        '${projectRoot.path}/lib/features/music_detail/music_page_playback_actions.dart',
      );
      final bootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final page = pageFile.readAsStringSync();
      final actions = actionsFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (page.contains('Get.find<ShellController>')) '${_relativePath(pageFile)} reads shell controller directly',
        if (page.contains('ShellController.to')) '${_relativePath(pageFile)} reads shell controller globally',
        if (!page.contains('playPlaylistAndOpenPanel(')) '${_relativePath(pageFile)} does not open panel through playback action boundary',
        if (!actions.contains('typedef PlaybackPanelOpener = void Function();')) '${_relativePath(actionsFile)} does not define a shell-independent panel opener boundary',
        if (!actions.contains('_openPlaybackPanel();')) '${_relativePath(actionsFile)} does not centralize playback panel opening before playlist playback',
        if (!bootstrap.contains('openPlaybackPanel: _openPlaybackPanel')) 'feature bootstrap does not inject playback panel opener into music page playback actions',
        if (!bootstrap.contains('shellController.jumpBottomPanelToPage(0)')) 'feature bootstrap panel opener does not jump bottom panel before opening',
        if (!bootstrap.contains('shellController.openBottomPanel()')) 'feature bootstrap panel opener does not open bottom panel',
      ];

      expect(
        violations,
        isEmpty,
        reason: '歌单页可以在播放歌曲时打开底部播放面板，但 shell 面板操作必须由音乐详情播放动作边界注入，不能让页面直接读取全局 shell。',
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
      final commentListController = File(
        '${projectRoot.path}/lib/features/comment/comment_list_controller.dart',
      ).readAsStringSync();
      final floorCommentController = File(
        '${projectRoot.path}/lib/features/comment/floor_comment_controller.dart',
      ).readAsStringSync();
      final pagedController = File(
        '${projectRoot.path}/lib/features/comment/comment_paged_controller.dart',
      ).readAsStringSync();
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
        if (!commentWidget.contains('const double _commentListCacheExtent = 520;')) '${_relativePath(commentWidgetFile)} does not keep a bounded comment list cache extent',
        if (!commentWidget.contains('cacheExtent: _commentListCacheExtent')) '${_relativePath(commentWidgetFile)} does not apply bounded cache extent to comment list',
        if (!commentItem.contains('required this.controllerFactory')) '${_relativePath(commentItemFile)} does not receive comment controller factory',
        if (!commentItem.contains('widget.controllerFactory.createFloor(')) '${_relativePath(commentItemFile)} does not create floor controller through injected feature factory',
        if (!commentItem.contains('widget.controllerFactory.createItem(')) '${_relativePath(commentItemFile)} does not create item controller through injected feature factory',
        if (!commentItem.contains('controllerFactory: widget.controllerFactory')) '${_relativePath(commentItemFile)} does not inject comment factory into nested replies',
        if (!floorSheet.contains('required this.controllerFactory')) '${_relativePath(floorSheetFile)} does not receive comment controller factory',
        if (!floorSheet.contains('widget.controllerFactory.createFloor(')) '${_relativePath(floorSheetFile)} does not create floor controller through injected feature factory',
        if (!floorSheet.contains('widget.controllerFactory.createReplySheet(')) '${_relativePath(floorSheetFile)} does not create reply sheet controller through injected feature factory',
        if (!floorSheet.contains('const double _floorCommentListCacheExtent = 520;')) '${_relativePath(floorSheetFile)} does not keep a bounded floor comment list cache extent',
        if (!floorSheet.contains('cacheExtent: _floorCommentListCacheExtent')) '${_relativePath(floorSheetFile)} does not apply bounded cache extent to floor comment list',
        if (!factory.contains('CommentListController createList({')) 'comment controller factory does not create list controllers',
        if (!factory.contains('FloorCommentController createFloor({')) 'comment controller factory does not create floor controllers',
        if (!factory.contains('CommentItemController createItem({')) 'comment controller factory does not create item controllers',
        if (!factory.contains('ReplySheetController createReplySheet({')) 'comment controller factory does not create reply sheet controllers',
        if (!factory.contains('repository: _repository')) 'comment controller factory does not inject comment repository',
        if (!bootstrap.contains('CommentControllerFactory(')) 'feature bootstrap does not register comment controller factory',
        if (!commentListController.contains('CommentPagedController<CommentListPageCursor>')) 'comment list controller does not reuse shared paged controller',
        if (!floorCommentController.contains('CommentPagedController<int>')) 'floor comment controller does not reuse shared paged controller',
        if (!pagedController.contains('previousState.items.isEmpty')) 'comment paged controller does not distinguish first-load and refresh failures',
        if (!pagedController.contains('generation == _requestGeneration')) 'comment paged controller does not guard stale requests by generation',
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
        if (!home.contains('final shellController = appHomeControllers.shellController')) '${_relativePath(homeFile)} does not receive shell controller from app home bundle',
        if (!home.contains('shellController: shellController')) '${_relativePath(homeFile)} does not inject shell controller',
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
        if (!controller.contains('final likedSongIds = normalizeLikedSongIds(_likedSongIds());')) 'search controller does not normalize injected liked ids before building search context',
        if (!controller.contains('final likedSongIdsSignatureValue = likedSongIdsSignature(likedSongIds);')) 'search controller signature does not reuse the shared liked ids normalizer',
        if (controller.contains('List<int> _normalizedLikedSongIds(List<int> likedSongIds)')) 'search controller still keeps a private liked ids normalizer',
        if (controller.contains('final likedSongIds = List<int>.of(_likedSongIds());')) 'search controller still copies raw liked ids provider output',
        if (!repository.contains('String? _normalizedCurrentUserId(String currentUserId)')) 'search repository does not define a current user normalizer',
        if (!repository.contains('final scopedUserId = _normalizedCurrentUserId(currentUserId)')) 'search repository does not normalize current user before user playlist cache access',
        if (!repository.contains("import 'package:bujuan/core/entities/music_resource_id.dart';")) 'search repository does not use MusicResourceId for playlist summary ids',
        if (!repository.contains('PlaylistEntity? _playlistSummaryToEntity(PlaylistSummaryData playlist)')) 'search repository does not allow invalid user playlist summaries to be dropped',
        if (!repository.contains('.whereType<PlaylistEntity>()')) 'search repository does not drop invalid user playlist summaries',
        if (!repository.contains('MusicResourceId.toNeteaseSourceId(playlist.id).trim()')) 'search repository does not normalize user playlist summary source ids',
        if (!repository.contains('MusicResourceId.toNeteaseEntityId(sourceId)')) 'search repository does not derive user playlist entity ids from normalized source ids',
        if (repository.contains("id: 'netease:\${playlist.id}'")) 'search repository still builds user playlist entity ids with raw string interpolation',
        if (repository.contains('sourceId: playlist.id')) 'search repository still exposes raw user playlist summary source ids',
        if (repository.contains('currentUserId.isEmpty')) 'search repository still checks raw current user emptiness',
        if (!bootstrap.contains('likedSongIds: _likedSongIdsSnapshot')) 'feature bootstrap does not inject liked ids provider',
        if (!bootstrap.contains('return Get.find<UserLibraryController>().likedSongIdSnapshot;')) 'feature bootstrap does not inject the user library liked ids snapshot',
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
      final shellControllerFile = File(
        '${projectRoot.path}/lib/features/shell/home_shell_controller.dart',
      );
      final home = homeFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final body = bodyFile.readAsStringSync();
      final shellController = shellControllerFile.readAsStringSync();
      final drawerStart = body.indexOf('class DrawerMainScreenView');
      final menuStart = body.indexOf('class MenuView');
      final drawerSection = drawerStart >= 0 && menuStart > drawerStart ? body.substring(drawerStart, menuStart) : '';
      final menuSection = menuStart >= 0 ? body.substring(menuStart) : '';
      final violations = <String>[
        if (drawerSection.isEmpty) '${_relativePath(bodyFile)} drawer main screen section is missing',
        if (body.contains('HomeShellController.to')) '${_relativePath(bodyFile)} reads home shell globally',
        if (home.contains('extends GetView<ShellController>')) '${_relativePath(homeFile)} still binds shell controller through GetView',
        if (body.contains('class AppBodyPageView extends GetView<ShellController>')) '${_relativePath(bodyFile)} still binds shell controller through GetView',
        if (drawerSection.contains('HomeShellController.to')) '${_relativePath(bodyFile)} drawer main screen reads home shell globally',
        if (menuSection.contains('HomeShellController.to')) '${_relativePath(bodyFile)} menu view reads home shell globally',
        if (drawerSection.contains('extends GetView<ShellController>')) '${_relativePath(bodyFile)} drawer main screen still binds shell controller through GetView',
        if (menuSection.contains('extends GetView<ShellController>')) '${_relativePath(bodyFile)} menu view still binds shell controller through GetView',
        if (drawerSection.contains('Get.find<ShellController>')) '${_relativePath(bodyFile)} drawer main screen reads shell controller globally',
        if (menuSection.contains('Get.find<ShellController>')) '${_relativePath(bodyFile)} menu view reads shell controller globally',
        if (!body.contains('final shellController = HomeShellScope.shellControllerOf(context)')) '${_relativePath(bodyFile)} does not read shell controller from local scope',
        if (!body.contains('final homeShellController = HomeShellScope.of(context)')) '${_relativePath(bodyFile)} does not read home shell from local scope',
        if (!home.contains('final appHomeControllers = Get.find<AppHomeControllerBundle>()')) '${_relativePath(homeFile)} does not resolve app home controller bundle at shell boundary',
        if (home.contains('Get.find<HomeShellController>')) '${_relativePath(homeFile)} reads home shell controller globally',
        if (!home.contains('final homeShellController = appHomeControllers.homeShellController')) '${_relativePath(homeFile)} does not receive home shell controller from app home bundle',
        if (!home.contains('final shellController = appHomeControllers.shellController')) '${_relativePath(homeFile)} does not receive shell controller from app home bundle',
        if (!bootstrap.contains('homeShellController: Get.find<HomeShellController>()')) 'feature bootstrap does not inject home shell controller into app home bundle',
        if (!bootstrap.contains('shellController: Get.find<ShellController>()')) 'feature bootstrap does not inject shell controller into app home bundle',
        if (!home.contains('HomeShellScope(')) '${_relativePath(homeFile)} does not provide home shell scope',
        if (!home.contains('homeShellController: homeShellController')) '${_relativePath(homeFile)} does not inject home shell into scope',
        if (!home.contains('shellController: shellController')) '${_relativePath(homeFile)} does not inject shell into scope',
        if (!body.contains('MenuView(')) '${_relativePath(bodyFile)} does not compose drawer menu',
        if (!body.contains('shellController: shellController')) '${_relativePath(bodyFile)} does not inject shell controller into drawer local widgets',
        if (!body.contains('DrawerMainScreenView(')) '${_relativePath(bodyFile)} does not compose drawer main screen',
        if (!body.contains('homeShellController: homeShellController')) '${_relativePath(bodyFile)} does not inject home shell into main screen',
        if (!drawerSection.contains('required this.shellController')) '${_relativePath(bodyFile)} drawer main screen does not receive shell controller',
        if (!drawerSection.contains('required this.homeShellController')) '${_relativePath(bodyFile)} drawer main screen does not receive home shell controller',
        if (!menuSection.contains('required this.shellController')) '${_relativePath(bodyFile)} menu view does not receive shell controller',
        if (!menuSection.contains('required this.homeShellController')) '${_relativePath(bodyFile)} menu view does not receive home shell controller',
        if (body.contains('CoffeePageView') || body.contains('coffee_page.dart')) '${_relativePath(bodyFile)} restores a non-listening coffee page to shell body',
        if (shellController.contains('HomeShellPageKind.coffee')) '${_relativePath(shellControllerFile)} restores coffee as a shell page kind',
        if (shellController.contains("Routes.coffee")) '${_relativePath(shellControllerFile)} restores coffee route in shell menus',
        if (shellController.contains("'捐赠'")) '${_relativePath(shellControllerFile)} restores donation as a main navigation item',
        if (body.contains('ExplorePageView') || body.contains('explore_page.dart')) '${_relativePath(bodyFile)} restores explore as a shell body page',
        if (shellController.contains('HomeShellPageKind.explore')) '${_relativePath(shellControllerFile)} restores explore as a shell page kind',
        if (shellController.contains("'探索'")) '${_relativePath(shellControllerFile)} restores explore as a main navigation item',
        if (!shellController.contains("'我的音乐'")) '${_relativePath(shellControllerFile)} does not expose focused music entry label',
        if (!shellController.contains("'设置'")) '${_relativePath(shellControllerFile)} does not expose focused settings entry label',
      ];

      expect(
        violations,
        isEmpty,
        reason: '首页壳层负责读取 HomeShellController 并通过局部 scope 传给路由子树；主导航只保留听歌相关路径，不能恢复探索、捐赠/咖啡等非核心入口。',
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
        if (page.contains('HomeContentController.to')) '${_relativePath(pageFile)} reads home content controller globally',
        if (page.contains('UserLibraryController.to')) '${_relativePath(pageFile)} reads user library controller globally',
        if (page.contains('RecentPlaybackController.to')) '${_relativePath(pageFile)} reads recent playback controller globally',
        if (page.contains('Get.find<PlayerController>')) '${_relativePath(pageFile)} reads player controller globally',
        if (body.contains('Get.find<UserLibraryController>')) '${_relativePath(bodyFile)} reads user library controller directly',
        if (!page.contains('required this.homeContentController')) '${_relativePath(pageFile)} does not receive home content controller',
        if (!page.contains('required this.userLibraryController')) '${_relativePath(pageFile)} does not receive user library controller',
        if (!page.contains('required this.recentPlaybackController')) '${_relativePath(pageFile)} does not receive recent playback controller',
        if (!page.contains('required this.playerController')) '${_relativePath(pageFile)} does not receive player controller',
        if (!page.contains('required this.shellController')) '${_relativePath(pageFile)} does not receive shell controller',
        if (!body.contains('final personalHomeControllers = Get.find<PersonalHomeControllerBundle>()')) '${_relativePath(bodyFile)} does not resolve personal home controller bundle at shell body boundary',
        if (!body.contains('personalHomeControllers: personalHomeControllers')) '${_relativePath(bodyFile)} does not inject personal home controller bundle',
        if (!bootstrap.contains('Get.put<PersonalHomeControllerBundle>')) 'feature bootstrap does not register personal home controller bundle',
        if (!bootstrap.contains('userLibraryController: Get.find<UserLibraryController>()')) 'feature bootstrap does not inject user library controller into personal home bundle',
        if (!body.contains('PersonalPageView(')) '${_relativePath(bodyFile)} does not compose personal page',
        if (!body.contains('homeContentController: personalHomeControllers.homeContentController')) '${_relativePath(bodyFile)} does not inject home content controller',
        if (!body.contains('userLibraryController: personalHomeControllers.userLibraryController')) '${_relativePath(bodyFile)} does not inject user library controller',
        if (!body.contains('recentPlaybackController: personalHomeControllers.recentPlaybackController')) '${_relativePath(bodyFile)} does not inject recent playback controller',
        if (!body.contains('playerController: personalHomeControllers.playerController')) '${_relativePath(bodyFile)} does not inject player controller',
        if (!body.contains('shellController: shellController')) '${_relativePath(bodyFile)} does not inject shell controller into personal page',
      ];

      expect(
        violations,
        isEmpty,
        reason: '个人首页主文件只负责布局模式分发，首页内容、资料库、播放和最近播放控制器必须由首页主体组合层注入。',
      );
    });

    test('core controllers do not expose global to accessors', () {
      final shellControllerFile = File('${projectRoot.path}/lib/features/shell/shell_controller.dart');
      final bootstrapFile = File('${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart');
      final shellController = shellControllerFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final controllerFiles = [
        File('${projectRoot.path}/lib/features/shell/home_shell_controller.dart'),
        shellControllerFile,
        File('${projectRoot.path}/lib/features/playback/player_controller.dart'),
        File('${projectRoot.path}/lib/features/playback/recent_playback_controller.dart'),
        File('${projectRoot.path}/lib/features/settings/settings_controller.dart'),
        File('${projectRoot.path}/lib/features/user/home_content_controller.dart'),
        File('${projectRoot.path}/lib/features/user/user_library_controller.dart'),
        File('${projectRoot.path}/lib/features/user/user_session_controller.dart'),
      ];
      final violations = <String>[
        for (final file in controllerFiles)
          if (file.readAsStringSync().contains('get to => Get.find')) _relativePath(file),
        if (shellController.contains('Get.find<')) '${_relativePath(shellControllerFile)} resolves dependencies from Get container',
        if (!shellController.contains('ShellController({')) '${_relativePath(shellControllerFile)} does not expose constructor injection',
        if (!shellController.contains('required HomeShellController homeShellController')) '${_relativePath(shellControllerFile)} does not receive home shell controller through constructor',
        if (!shellController.contains('required PlayerController playerController')) '${_relativePath(shellControllerFile)} does not receive playback controller through constructor',
        if (!shellController.contains('required UserSessionController userSessionController')) '${_relativePath(shellControllerFile)} does not receive user session controller through constructor',
        if (!bootstrap.contains('homeShellController: Get.find<HomeShellController>()')) 'feature bootstrap does not inject home shell controller into shell controller',
        if (!bootstrap.contains('playerController: Get.find<PlayerController>()')) 'feature bootstrap does not inject playback controller into shell controller',
        if (!bootstrap.contains('userSessionController: Get.find<UserSessionController>()')) 'feature bootstrap does not inject user session controller into shell controller',
      ];

      expect(
        violations,
        isEmpty,
        reason: '核心控制器必须通过 bootstrap、bundle 或页面边界注入，不能重新提供 Controller.to 这类全局快捷入口；ShellController 自身也不能再作为服务定位器读取其它核心控制器。',
      );
    });

    test('quick start rail keeps stable horizontal list bounds', () {
      final quickStartFile = File(
        '${projectRoot.path}/lib/ui/pages/user/widgets/quick_start_card_rail.dart',
      );
      final quickStart = quickStartFile.readAsStringSync();
      final violations = <String>[
        if (!quickStart.contains('ListView.builder(')) '${_relativePath(quickStartFile)} does not build quick start cards lazily',
        if (!quickStart.contains('const int quickStartPrimaryActionCount = 2;')) '${_relativePath(quickStartFile)} does not keep the focused quick start action count explicit',
        if (!quickStart.contains('itemCount: quickStartPrimaryActionCount')) '${_relativePath(quickStartFile)} does not use the focused quick start action count',
        if (!quickStart.contains('itemExtent: width + AppDimensions.paddingSmall')) '${_relativePath(quickStartFile)} does not fix quick start item extent',
        if (!quickStart.contains('cacheExtent: quickStartCardRailCacheExtent')) '${_relativePath(quickStartFile)} does not bound quick start cache extent',
        if (!quickStart.contains('itemBuilder: (context, index) => _buildQuickStartCard(index)')) '${_relativePath(quickStartFile)} does not route quick start item construction through builder boundary',
        if (!quickStart.contains('required this.recentPlaybackController')) '${_relativePath(quickStartFile)} does not receive recent playback history for local-first continue playback',
        if (!quickStart.contains('final fallbackIndex = hasCurrentSong ? -1 : _firstPlayableRecentIndex(recentTracks);')) '${_relativePath(quickStartFile)} does not fall back to local recent playback when current song is empty',
        if (!quickStart.contains("playListName: '最近播放'")) '${_relativePath(quickStartFile)} does not resume from the recent playback queue',
        if (quickStart.contains('() => ListView(')) '${_relativePath(quickStartFile)} still builds quick start cards with eager ListView children',
        if (quickStart.contains("title: '漫游模式'")) '${_relativePath(quickStartFile)} brings FM mode back to the first viewport quick start rail',
        if (quickStart.contains("title: '心动模式'")) '${_relativePath(quickStartFile)} brings heartbeat mode back to the first viewport quick start rail',
        if (quickStart.contains('UserLibraryController')) '${_relativePath(quickStartFile)} depends on library state for first viewport quick start actions',
      ];

      expect(
        violations,
        isEmpty,
        reason: '首页“开始听”横向入口只保留继续播放和每日推荐，且必须保持惰性构建、固定 itemExtent 和有界预缓存。',
      );
    });

    test('explore information feed stays removed from app runtime', () {
      final featureBootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart',
      );
      final repositoryBootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/repository_bootstrap.dart',
      );
      final dataSourceBootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/data_source_bootstrap.dart',
      );
      final contractFile = File(
        '${projectRoot.path}/lib/data/music_data/music_remote_data_sources.dart',
      );
      final appCacheFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/data_sources/app_cache_data_source.dart',
      );
      final featureBootstrap = featureBootstrapFile.readAsStringSync();
      final repositoryBootstrap = repositoryBootstrapFile.readAsStringSync();
      final dataSourceBootstrap = dataSourceBootstrapFile.readAsStringSync();
      final contract = contractFile.readAsStringSync();
      final appCache = appCacheFile.readAsStringSync();
      const removedPaths = [
        'lib/ui/pages/explore/explore_page.dart',
        'lib/ui/pages/explore/widgets/explore_filter_strip.dart',
        'lib/ui/pages/explore/widgets/explore_ranking_song_list_sliver.dart',
        'lib/features/explore/explore_page_controller.dart',
        'lib/features/explore/explore_repository.dart',
        'lib/features/explore/explore_cache_store.dart',
        'lib/features/explore/explore_playlist_catalogue_data.dart',
        'lib/features/explore/ranking_playlist_data.dart',
        'lib/data/music_data/sources/netease/remote/netease_explore_remote_data_source.dart',
      ];
      final violations = <String>[
        for (final path in removedPaths)
          if (File('${projectRoot.path}/$path').existsSync()) '$path still exists',
        if (featureBootstrap.contains('ExplorePageController')) '${_relativePath(featureBootstrapFile)} registers explore controller',
        if (featureBootstrap.contains('ExploreRepository')) '${_relativePath(featureBootstrapFile)} reads explore repository',
        if (repositoryBootstrap.contains('ExploreRepository')) '${_relativePath(repositoryBootstrapFile)} registers explore repository',
        if (repositoryBootstrap.contains('exploreRepository')) '${_relativePath(repositoryBootstrapFile)} keeps explore repository field',
        if (dataSourceBootstrap.contains('ExploreCacheStore')) '${_relativePath(dataSourceBootstrapFile)} creates explore cache store',
        if (dataSourceBootstrap.contains('NeteaseExploreRemoteDataSource')) '${_relativePath(dataSourceBootstrapFile)} creates explore remote data source',
        if (dataSourceBootstrap.contains('exploreRemoteDataSource')) '${_relativePath(dataSourceBootstrapFile)} keeps explore remote field',
        if (dataSourceBootstrap.contains('exploreCacheStore')) '${_relativePath(dataSourceBootstrapFile)} keeps explore cache field',
        if (contract.contains('ExploreRemoteDataSource')) '${_relativePath(contractFile)} keeps explore remote contract',
        if (contract.contains('ExplorePlaylistCatalogueRemoteData')) '${_relativePath(contractFile)} keeps explore catalogue DTO contract',
        if (appCache.contains('appCacheExplorePlaylistCatalogueKey')) '${_relativePath(appCacheFile)} keeps explore cache key',
        if (appCache.contains('EXPLORE_PLAYLIST_CATALOGUE')) '${_relativePath(appCacheFile)} keeps explore cache storage key',
      ];

      expect(
        violations,
        isEmpty,
        reason: '探索/发现类信息流已退出自用播放器运行时，不能继续注册 UI、controller、repository、remote data source 或短期缓存键。',
      );
    });

    test('frequent playlist section keeps playback resolution behind home controller', () {
      final sectionFile = File(
        '${projectRoot.path}/lib/ui/pages/user/widgets/frequent_playlist_section.dart',
      );
      final controllerFile = File(
        '${projectRoot.path}/lib/features/user/home_content_controller.dart',
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
        if (!section.contains('homeContentController.resolveFrequentPlaylistPlayback')) '${_relativePath(sectionFile)} does not resolve playlist playback through home controller',
        if (controller.contains('UserLibraryController')) 'home content controller reads user library controller directly',
        if (controller.contains("package:bujuan/features/user/user_session_controller.dart")) 'home content controller imports user session controller',
        if (controller.contains('UserSessionController')) 'home content controller names user session controller directly',
        if (!controller.contains('Future<UserHomePlaylistPlaybackPlan> resolveFrequentPlaylistPlayback')) 'home content controller does not expose frequent playlist playback resolution',
        if (controller.contains('getFmSongs')) 'home content controller exposes FM playback loading',
        if (controller.contains('getTodayRecommendSongs')) 'home content controller exposes explicit daily playback loading',
        if (!controller.contains('required PlaylistRepository playlistRepository')) 'home content controller does not receive playlist repository explicitly',
        if (!controller.contains('required HomeContentLibraryAccess libraryAccess')) 'home content controller does not receive library access boundary',
        if (!controller.contains('required HomeContentSessionAccess sessionAccess')) 'home content controller does not receive session access boundary',
        if (!controller.contains('String _normalizedUserId(String userId)')) 'home content controller does not normalize session user ids',
        if (!controller.contains('bool _isSignedInUserId(String userId)')) 'home content controller does not centralize signed-in account checks',
        if (!controller.contains('List<int> _likedSongIdsSnapshot()')) 'home content controller does not define a liked ids snapshot normalizer',
        if (!controller.contains('return normalizeLikedSongIds(_libraryAccess.likedSongIds());')) 'home content controller liked ids snapshot does not use shared normalizer',
        if (!controller.contains('final likedSongIds = _likedSongIdsSnapshot();')) 'home content controller does not reuse normalized liked ids snapshots for home requests',
        if (controller.contains('likedSongIds: _libraryAccess.likedSongIds()')) 'home content controller still passes raw liked ids provider output',
        if (controller.contains('final likedSongIds = _libraryAccess.likedSongIds();')) 'home content controller still snapshots raw liked ids provider output',
        if (!controller.contains('_currentUserId() == userId')) 'home content controller does not compare scoped loads against normalized current user',
        if (!bootstrap.contains('sessionAccess: HomeContentSessionAccess(')) 'feature bootstrap does not inject home content session access boundary',
        if (!bootstrap.contains('watchSession: (onChanged)')) 'feature bootstrap does not bind home content session watcher',
        if (!controller.contains('currentUserId: userId')) 'home content controller does not pass current user when resolving frequent playlist',
        if (!controller.contains('playlistIndex: index')) 'home content controller does not reuse fetched playlist index for playback songs',
      ];

      expect(
        violations,
        isEmpty,
        reason: '常用歌单 Widget 只发起播放意图，歌单摘要到播放队列的解析必须留在 HomeContentController，避免 UI 直接读喜欢列表和 PlaylistRepository。',
      );
    });

    test('playback FM loading stays behind playback user content port', () {
      final playbackBootstrapFile = File(
        '${projectRoot.path}/lib/app/bootstrap/playback_bootstrap.dart',
      );
      final homeContentControllerFile = File(
        '${projectRoot.path}/lib/features/user/home_content_controller.dart',
      );
      final playbackBootstrap = playbackBootstrapFile.readAsStringSync();
      final homeContentController = homeContentControllerFile.readAsStringSync();
      final violations = <String>[
        if (playbackBootstrap.contains('home_content_controller.dart')) '${_relativePath(playbackBootstrapFile)} imports home content controller for playback content',
        if (playbackBootstrap.contains('Get.find<HomeContentController>')) '${_relativePath(playbackBootstrapFile)} reads home content controller for playback content',
        if (!playbackBootstrap.contains('loadFmSongs: _loadFmSongs')) '${_relativePath(playbackBootstrapFile)} does not route FM through playback content port helper',
        if (!playbackBootstrap.contains('Future<List<PlaybackQueueItem>> _loadFmSongs()')) '${_relativePath(playbackBootstrapFile)} does not define FM loading helper',
        if (!playbackBootstrap.contains('Get.find<UserRepository>().fetchFmSongs(')) '${_relativePath(playbackBootstrapFile)} does not load FM through user repository',
        if (!playbackBootstrap.contains('Get.find<UserSessionController>().userInfo.value.userId')) '${_relativePath(playbackBootstrapFile)} does not read current account for FM loading',
        if (!playbackBootstrap.contains('bool _isSignedInUserId(String userId)')) '${_relativePath(playbackBootstrapFile)} does not guard FM loading with signed-in account check',
        if (homeContentController.contains('getFmSongs')) '${_relativePath(homeContentControllerFile)} still exposes FM loading',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'FM 漫游属于播放模式内容加载，不能通过首页内容控制器绕行；播放端口负责读取当前账号、喜欢歌曲快照并调用用户仓库。',
      );
    });

    test('today recommendation page reads songs through page controller boundary', () {
      final pageFile = File(
        '${projectRoot.path}/lib/ui/pages/user/today_page_view.dart',
      );
      final page = pageFile.readAsStringSync();
      final violations = <String>[
        if (page.contains('HomeContentController.to')) '${_relativePath(pageFile)} reads home content controller globally',
        if (page.contains('PlaylistRepository')) '${_relativePath(pageFile)} names playlist repository directly',
        if (page.contains('UserLibraryController')) '${_relativePath(pageFile)} reads user library directly',
        if (page.contains('Get.find<PlayerController>')) '${_relativePath(pageFile)} reads playback controller directly',
        if (!page.contains('class TodayPageView extends GetView<HomeContentController>')) '${_relativePath(pageFile)} does not use page controller boundary',
        if (!page.contains('final songs = controller.todayRecommendSongs')) '${_relativePath(pageFile)} does not read songs through page controller boundary',
        if (!page.contains('Get.find<MusicDetailControllerBundle>().playbackActions')) '${_relativePath(pageFile)} does not submit playback through music detail action boundary',
      ];

      expect(
        violations,
        isEmpty,
        reason: '今日推荐页只能展示 HomeContentController 暴露的推荐队列并提交播放意图，不能直接读取资料库或 repository。',
      );
    });

    test('home shell does not expose recommended playlist feed as a main page', () {
      final shellFile = File(
        '${projectRoot.path}/lib/features/shell/home_shell_controller.dart',
      );
      final appBodyFile = File(
        '${projectRoot.path}/lib/ui/pages/shell/app_body_page_view.dart',
      );
      final standardHomeFile = File(
        '${projectRoot.path}/lib/ui/pages/user/widgets/standard_personal_home_page.dart',
      );
      final homeContentControllerFile = File(
        '${projectRoot.path}/lib/features/user/home_content_controller.dart',
      );
      final recommendedPageFile = File(
        '${projectRoot.path}/lib/ui/pages/user/recommended_playlists_page.dart',
      );
      final recommendedSliversFile = File(
        '${projectRoot.path}/lib/ui/pages/user/widgets/recommended_playlist_slivers.dart',
      );
      final shell = shellFile.readAsStringSync();
      final appBody = appBodyFile.readAsStringSync();
      final standardHome = standardHomeFile.readAsStringSync();
      final homeContentController = homeContentControllerFile.readAsStringSync();
      final violations = <String>[
        if (recommendedPageFile.existsSync()) '${_relativePath(recommendedPageFile)} still exposes a dedicated recommendation page',
        if (recommendedSliversFile.existsSync()) '${_relativePath(recommendedSliversFile)} still exposes recommendation feed slivers',
        if (shell.contains('recommendedPlaylists')) '${_relativePath(shellFile)} keeps recommendation page enum/menu state',
        if (shell.contains('/home/recommended-playlists')) '${_relativePath(shellFile)} keeps recommendation page path',
        if (appBody.contains('recommended_playlists_page.dart')) '${_relativePath(appBodyFile)} imports recommendation page UI',
        if (appBody.contains('RecommendedPlaylistsPageView')) '${_relativePath(appBodyFile)} builds recommendation page UI',
        if (standardHome.contains('RecommendedPlaylist')) '${_relativePath(standardHomeFile)} renders recommendation feed widgets',
        if (standardHome.contains('updateRecoPlayLists(getMore: true)')) '${_relativePath(standardHomeFile)} keeps recommendation feed pagination',
        if (standardHome.contains('enablePullUp: true')) '${_relativePath(standardHomeFile)} keeps home feed pull-up loading',
        if (!standardHome.contains('RefreshIndicator(')) '${_relativePath(standardHomeFile)} does not use native pull-to-refresh',
        if (standardHome.contains('AppSmartRefresher(')) '${_relativePath(standardHomeFile)} keeps paging refresher on home',
        if (standardHome.contains('refreshController')) '${_relativePath(standardHomeFile)} still depends on home refresh controller',
        if (homeContentController.contains('RefreshController')) '${_relativePath(homeContentControllerFile)} keeps UI refresh controller state',
        if (homeContentController.contains("package:pull_to_refresh/pull_to_refresh.dart")) '${_relativePath(homeContentControllerFile)} imports paging refresh package',
        if (homeContentController.contains('recoPlayLists')) '${_relativePath(homeContentControllerFile)} keeps recommended playlist feed state',
        if (homeContentController.contains('updateRecoPlayLists')) '${_relativePath(homeContentControllerFile)} keeps recommended playlist feed refresh API',
        if (homeContentController.contains('_recoPlaylist')) '${_relativePath(homeContentControllerFile)} keeps recommended playlist feed generation state',
        if (homeContentController.contains('fetchRecommendedPlaylists(')) '${_relativePath(homeContentControllerFile)} fetches recommended playlist feed data',
      ];

      expect(
        violations,
        isEmpty,
        reason: '自用播放器首页主路径只能保留继续播放、每日推荐、最近播放、常用歌单和资料库入口，首页控制器不能重新持有推荐歌单信息流。',
      );
    });

    test('recommended playlist endpoint stays out of local user playlist cache', () {
      final userLibraryKindsFile = File(
        '${projectRoot.path}/lib/core/entities/user_library_kinds.dart',
      );
      final userRepositoryFile = File(
        '${projectRoot.path}/lib/features/user/user_repository.dart',
      );
      final userLibraryKinds = userLibraryKindsFile.readAsStringSync();
      final userRepository = userRepositoryFile.readAsStringSync();
      final recommendedMethodStart = userRepository.indexOf('Future<List<PlaylistSummaryData>> fetchRecommendedPlaylists');
      final userPlaylistsMethodStart = userRepository.indexOf('Future<List<PlaylistSummaryData>> fetchUserPlaylists');
      final recommendedMethod = recommendedMethodStart == -1 || userPlaylistsMethodStart == -1
          ? ''
          : userRepository.substring(
              recommendedMethodStart,
              userPlaylistsMethodStart,
            );
      final violations = <String>[
        if (userLibraryKinds.contains('recommended')) '${_relativePath(userLibraryKindsFile)} keeps recommended playlist cache kind',
        if (userRepository.contains('UserPlaylistListKind.recommended')) '${_relativePath(userRepositoryFile)} writes recommended playlists into local cache kind',
        if (recommendedMethod.contains('replacePlaylistItems')) '${_relativePath(userRepositoryFile)} replaces local playlist cache from recommended endpoint',
        if (recommendedMethod.contains('appendPlaylistItems')) '${_relativePath(userRepositoryFile)} appends local playlist cache from recommended endpoint',
      ];

      expect(
        violations,
        isEmpty,
        reason: '推荐歌单是上游接口复刻能力，不再作为首页或用户资料库本地缓存事实维护。',
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
      final localFirstDetailControllerFile = File(
        '${projectRoot.path}/lib/features/music_detail/local_first_detail_controller.dart',
      );
      final localFirstDetailPageMixinFile = File(
        '${projectRoot.path}/lib/ui/pages/music_detail/local_first_detail_page_mixin.dart',
      );
      final albumPage = albumPageFile.readAsStringSync();
      final artistPage = artistPageFile.readAsStringSync();
      final albumController = albumControllerFile.readAsStringSync();
      final albumFactory = albumFactoryFile.readAsStringSync();
      final artistController = artistControllerFile.readAsStringSync();
      final artistFactory = artistFactoryFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final localFirstDetailController = localFirstDetailControllerFile.readAsStringSync();
      final localFirstDetailPageMixin = localFirstDetailPageMixinFile.readAsStringSync();
      final violations = <String>[
        if (albumPage.contains('AlbumRepository')) '${_relativePath(albumPageFile)} names album repository directly',
        if (artistPage.contains('ArtistRepository')) '${_relativePath(artistPageFile)} names artist repository directly',
        if (albumPage.contains('Get.find<AlbumPageController>()')) '${_relativePath(albumPageFile)} reads album controller singleton directly',
        if (artistPage.contains('Get.find<ArtistPageController>()')) '${_relativePath(artistPageFile)} reads artist controller singleton directly',
        if (albumPage.contains('Get.find<AlbumPageControllerFactory>')) '${_relativePath(albumPageFile)} reads album factory directly',
        if (artistPage.contains('Get.find<ArtistPageControllerFactory>')) '${_relativePath(artistPageFile)} reads artist factory directly',
        if (albumPage.contains('Get.find<PlayerController>')) '${_relativePath(albumPageFile)} reads playback controller directly',
        if (artistPage.contains('Get.find<PlayerController>')) '${_relativePath(artistPageFile)} reads playback controller directly',
        if (!albumPage.contains('Get.find<MusicDetailControllerBundle>()')) '${_relativePath(albumPageFile)} does not resolve music detail bundle at page boundary',
        if (!artistPage.contains('Get.find<MusicDetailControllerBundle>()')) '${_relativePath(artistPageFile)} does not resolve music detail bundle at page boundary',
        if (!albumPage.contains('_controllers.albumControllerFactory.create()')) '${_relativePath(albumPageFile)} does not create album page controller through music detail bundle',
        if (!artistPage.contains('_controllers.artistControllerFactory.create()')) '${_relativePath(artistPageFile)} does not create artist page controller through music detail bundle',
        if (albumPage.contains('_controller.loadLocalDetail(')) '${_relativePath(albumPageFile)} directly runs album local detail loading',
        if (artistPage.contains('_controller.loadLocalDetail(')) '${_relativePath(artistPageFile)} directly runs artist local detail loading',
        if (!albumPage.contains('_controller.loadInitialDetail(albumId)')) '${_relativePath(albumPageFile)} does not load album initial detail through controller boundary',
        if (!artistPage.contains('_controller.loadInitialDetail(artistId)')) '${_relativePath(artistPageFile)} does not load artist initial detail through controller boundary',
        if (!albumPage.contains('with LocalFirstDetailPageMixin<AlbumPageView>')) '${_relativePath(albumPageFile)} does not reuse album local-first page state machine',
        if (!artistPage.contains('with LocalFirstDetailPageMixin<ArtistPageView>')) '${_relativePath(artistPageFile)} does not reuse artist local-first page state machine',
        if (!albumPage.contains('loadInitialLocalFirstDetail<AlbumDetailData>')) '${_relativePath(albumPageFile)} does not run album local-first initial detail flow',
        if (!artistPage.contains('loadInitialLocalFirstDetail<ArtistDetailData>')) '${_relativePath(artistPageFile)} does not run artist local-first initial detail flow',
        if (!albumPage.contains('refreshLocalFirstDetail<AlbumDetailData>')) '${_relativePath(albumPageFile)} does not run album refresh through shared state machine',
        if (!artistPage.contains('refreshLocalFirstDetail<ArtistDetailData>')) '${_relativePath(artistPageFile)} does not run artist refresh through shared state machine',
        if (!artistPage.contains('cacheExtent: artistHotAlbumCacheExtent')) '${_relativePath(artistPageFile)} does not bound hot album rail cache extent',
        if (!albumController.contains('typedef AlbumInitialDetailData = LocalFirstDetailInitialData<AlbumDetailData>')) '${_relativePath(albumControllerFile)} does not define album initial detail boundary',
        if (!artistController.contains('typedef ArtistInitialDetailData = LocalFirstDetailInitialData<ArtistDetailData>')) '${_relativePath(artistControllerFile)} does not define artist initial detail boundary',
        if (albumController.contains('UserLibraryController')) '${_relativePath(albumControllerFile)} reads user library directly',
        if (artistController.contains('UserLibraryController')) '${_relativePath(artistControllerFile)} reads user library directly',
        if (!albumController.contains('required List<int> Function() likedSongIds')) 'album page controller does not require liked ids provider',
        if (!artistController.contains('required List<int> Function() likedSongIds')) 'artist page controller does not require liked ids provider',
        if (!albumController.contains('LocalFirstDetailController<AlbumDetailData>')) 'album page controller does not reuse local-first detail controller',
        if (!artistController.contains('LocalFirstDetailController<ArtistDetailData>')) 'artist page controller does not reuse local-first detail controller',
        if (!localFirstDetailController.contains('normalizeLikedSongIds(_likedSongIds())')) 'local-first detail controller does not normalize liked ids snapshots',
        if (!localFirstDetailController.contains('catch (_)')) 'local-first detail controller does not tolerate local cache failures',
        if (!localFirstDetailPageMixin.contains('generation != _detailRefreshGeneration')) 'local-first detail page mixin does not ignore stale refresh results',
        if (!localFirstDetailPageMixin.contains('detailLoadFailed = !hasLoadedDetail')) 'local-first detail page mixin does not preserve visible detail after refresh failure',
        if (albumController.contains('likedSongIds: _likedSongIds()')) 'album page controller still passes raw liked ids provider output',
        if (artistController.contains('likedSongIds: _likedSongIds()')) 'artist page controller still passes raw liked ids provider output',
        if (!albumFactory.contains('AlbumPageController create()')) 'album page controller factory does not create page controllers',
        if (!artistFactory.contains('ArtistPageController create()')) 'artist page controller factory does not create page controllers',
        if (!albumFactory.contains('repository: _repository')) 'album page controller factory does not inject album repository',
        if (!artistFactory.contains('repository: _repository')) 'artist page controller factory does not inject artist repository',
        if (!albumFactory.contains('likedSongIds: _likedSongIds')) 'album page controller factory does not inject liked ids provider',
        if (!artistFactory.contains('likedSongIds: _likedSongIds')) 'artist page controller factory does not inject liked ids provider',
        if (!bootstrap.contains('AlbumPageControllerFactory(')) 'feature bootstrap does not register album page controller factory',
        if (!bootstrap.contains('ArtistPageControllerFactory(')) 'feature bootstrap does not register artist page controller factory',
        if (!bootstrap.contains('albumControllerFactory: Get.find<AlbumPageControllerFactory>()')) 'feature bootstrap does not inject album factory into music detail bundle',
        if (!bootstrap.contains('artistControllerFactory: Get.find<ArtistPageControllerFactory>()')) 'feature bootstrap does not inject artist factory into music detail bundle',
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
        if (!dataSource.contains('String _normalizedTrackId(String trackId)')) 'drift playback history data source does not define track id normalization',
        if (!dataSource.contains('MusicResourceId.toNeteaseEntityId(trackId.trim())')) 'drift playback history data source does not normalize track ids through MusicResourceId',
        if (!dataSource.contains('trackId: drift.Value(normalizedTrackId)')) 'drift playback history data source can write raw track ids',
        if (!queueStore.contains('String _normalizedCurrentSongId(String currentSongId)')) 'queue store does not normalize current song ids before restore/history writes',
        if (!queueStore.contains('final normalizedCurrentSongId = _normalizedCurrentSongId(currentSongId);')) 'queue store can still branch on raw current song ids',
        if (!queueStore.contains('if (normalizedCurrentSongId.isEmpty)')) 'queue store can still write blank current song ids',
        if (_containsAny(controllerFile, const [
          'PlayerController',
          'PlaybackQueueService',
          'activeQueue',
          'confirmedItem',
          'currentSongState',
        ]))
          '${_relativePath(controllerFile)} derives history from current playback state',
        if (!queueStore.contains('await _repository.recordPlayedTrack(normalizedCurrentSongId);')) 'queue store does not record confirmed current song with normalized id',
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

    test('playback source error recovery normalizes item ids', () {
      final gateFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_source_error_recovery_gate.dart',
      );
      final synchronizerFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_state_synchronizer.dart',
      );
      final gate = gateFile.readAsStringSync();
      final synchronizer = synchronizerFile.readAsStringSync();
      final violations = <String>[
        if (!gate.contains('String _normalizedItemId(String itemId)')) '${_relativePath(gateFile)} does not define item id normalization',
        if (!gate.contains('final normalizedCurrentItemId = _normalizedItemId(currentItemId);')) '${_relativePath(gateFile)} can still branch on raw current item id',
        if (!gate.contains('final normalizedSelectedItemId = _normalizedItemId(selection.selectedItem.id);')) '${_relativePath(gateFile)} can still compare raw selected item id',
        if (!gate.contains('normalizedSelectedItemId != normalizedCurrentItemId')) '${_relativePath(gateFile)} does not compare normalized item ids',
        if (!gate.contains("final recoveryKey = '\${selection.selectionVersion}:\$normalizedCurrentItemId';")) '${_relativePath(gateFile)} can still generate recovery keys from raw item ids',
        if (!synchronizer.contains('final normalizedItemId = _normalizedItemId(item.id);')) '${_relativePath(synchronizerFile)} can still start source recovery from raw current item id',
        if (!synchronizer.contains('currentItemId: normalizedItemId,')) '${_relativePath(synchronizerFile)} does not pass normalized item id to recovery gate',
        if (!synchronizer.contains('final recoveryItemId = normalizedItemId;')) '${_relativePath(synchronizerFile)} can still store raw recovery item id',
        if (!synchronizer.contains('final normalizedSelectedItemId = _normalizedItemId(selection.selectedItem.id);')) '${_relativePath(synchronizerFile)} can still compare raw selected item id before retry',
        if (!synchronizer.contains('normalizedSelectedItemId != normalizedItemId')) '${_relativePath(synchronizerFile)} does not compare normalized retry item ids',
      ];

      expect(
        violations,
        isEmpty,
        reason: '播放源错误恢复负责远程 URL 失败后的强刷重试，同一首歌的 current/selected id 必须先归一再判断、去重和提交重试。',
      );
    });

    test('playback source resolver validates final remote urls', () {
      final resolverFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_source_resolver.dart',
      );
      final resolver = resolverFile.readAsStringSync();
      final violations = <String>[
        if (!resolver.contains("import 'package:bujuan/core/util/playback_source_reference.dart';")) '${_relativePath(resolverFile)} does not use the shared playback source reference boundary',
        if (!resolver.contains("import 'package:bujuan/core/util/track_resource_availability.dart';")) '${_relativePath(resolverFile)} does not use the shared resource availability policy',
        if (!resolver.contains('PlaybackSourceReference.localPath(url)')) '${_relativePath(resolverFile)} does not normalize local playback URLs before final source resolution',
        if (!resolver.contains('PlaybackSourceReference.isExistingLocalPath(localPath)')) '${_relativePath(resolverFile)} does not verify repository local paths still exist',
        if (!resolver.contains('PlaybackSourceReference.remoteHttpUrl(url)')) '${_relativePath(resolverFile)} can return malformed remote playback URLs to the player',
        if (resolver.contains('PlaybackSourceReference.existingLocalPath(item.playbackUrl)')) '${_relativePath(resolverFile)} still trusts queue item playbackUrl as local resource fact',
        if (!resolver.contains('final indexedSource = await _resolveIndexedAudioSource(')) '${_relativePath(resolverFile)} does not check indexed local resources before remote resolving',
        if (!resolver.contains('final audio = trackWithResources?.resources.audio')) '${_relativePath(resolverFile)} does not resolve local audio from TrackWithResources',
        if (!resolver.contains('TrackResourceAvailability.existingLocalPath(')) '${_relativePath(resolverFile)} does not verify indexed audio paths through the shared resource policy',
        if (!resolver.contains('allowedOrigins: TrackResourceAvailability.playableAudioOrigins')) '${_relativePath(resolverFile)} does not restrict indexed audio to playable origins',
        if (!resolver.contains('TrackResourceAvailability.isCachedAudioResource(audio)')) '${_relativePath(resolverFile)} does not derive cached state from indexed resource origin',
        if (!resolver.contains('String _normalizedQueueItemId(String id)')) '${_relativePath(resolverFile)} does not define queue item id normalization',
        if (!resolver.contains('return id.trim();')) '${_relativePath(resolverFile)} does not trim queue item ids before repository calls',
        if (!resolver.contains('final itemId = _normalizedQueueItemId(item.id);')) '${_relativePath(resolverFile)} can still call repository with raw queue item ids',
        if (!resolver.contains('_repository.fetchPlaybackUrl(\n          itemId,')) '${_relativePath(resolverFile)} does not resolve remote playback URLs with normalized ids',
        if (!resolver.contains('_repository.getTrackWithResources(itemId)')) '${_relativePath(resolverFile)} does not prune missing resources with normalized ids',
      ];

      expect(
        violations,
        isEmpty,
        reason: 'PlaybackSourceResolver 是进入底层播放器前的最终边界，必须阻断非 HTTP(S) 或缺 authority 的远程播放地址，并且进入 repository 前先归一队列项 id。',
      );
    });

    test('playback source prefetcher caches only usable sources', () {
      final prefetcherFile = File(
        '${projectRoot.path}/lib/features/playback/application/playback_source_prefetcher.dart',
      );
      final prefetcher = prefetcherFile.readAsStringSync();
      final violations = <String>[
        if (!prefetcher.contains('final usableSource = _usableResolvedSource(source)')) '${_relativePath(prefetcherFile)} caches raw resolved sources before usability normalization',
        if (!prefetcher.contains('!usableSource.isEmpty')) '${_relativePath(prefetcherFile)} can cache empty or unusable sources',
        if (!prefetcher.contains("import 'package:bujuan/core/util/playback_source_reference.dart';")) '${_relativePath(prefetcherFile)} does not use the shared playback source reference boundary',
        if (!prefetcher.contains('PlaybackSourceReference.existingLocalPath(source.url)')) '${_relativePath(prefetcherFile)} does not validate cached local source files',
        if (!prefetcher.contains('PlaybackSourceReference.freshRemoteHttpUrl(source.url')) '${_relativePath(prefetcherFile)} does not validate cached remote source URLs and expiry',
        if (!prefetcher.contains('PlaybackSourceReference.localPath(item.playbackUrl)')) '${_relativePath(prefetcherFile)} does not normalize local playback cache keys through the shared boundary',
      ];

      expect(
        violations,
        isEmpty,
        reason: '播放源预取缓存只能保存仍可用的本地文件或有效 HTTP(S) 远程地址，不能缓存空白、过期或畸形 source。',
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

    test('audio service handler normalizes pending restore media item ids', () {
      final handlerFile = File(
        '${projectRoot.path}/lib/features/playback/application/audio_service_handler.dart',
      );
      final handler = handlerFile.readAsStringSync();
      final violations = <String>[
        if (!handler.contains('String _normalizedMediaItemId(String id)')) '${_relativePath(handlerFile)} does not define media item id normalization',
        if (!handler.contains('final normalizedRestoreMediaItemId = _normalizedMediaItemId(restoreMediaItemId ?? \'\');')) '${_relativePath(handlerFile)} can still compare raw pending restore media item id',
        if (!handler.contains('final normalizedMediaItemToPlayId = _normalizedMediaItemId(mediaItemToPlay.id);')) '${_relativePath(handlerFile)} can still compare raw media item id before restore seek',
        if (!handler.contains('restoreMediaItemId == null || normalizedRestoreMediaItemId == normalizedMediaItemToPlayId')) '${_relativePath(handlerFile)} can still skip restore seek through raw id comparison',
        if (handler.contains('restoreMediaItemId == mediaItemToPlay.id')) '${_relativePath(handlerFile)} still applies restore seek through raw id comparison',
      ];

      expect(
        violations,
        isEmpty,
        reason: '待恢复进度属于指定媒体项，AudioServiceHandler 应按规范化 media item id 判断是否应用 seek，避免空格差异跳过恢复进度。',
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
              (_contains(
                    file,
                    "package:bujuan/features/playback/application/playback_queue_item_mapper.dart",
                  ) ||
                  _contains(
                    file,
                    "package:bujuan/features/playback/application/track_playback_queue_builder.dart",
                  ))) {
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
        'lib/features/comment/comment_cache_store.dart',
      ];
      final appStorageKeys = File('${projectRoot.path}/lib/data/app_storage/app_cache_keys.dart').readAsStringSync();
      final appCacheDataSource = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/data_sources/app_cache_data_source.dart',
      ).readAsStringSync();
      final violations = <String>[
        if (appStorageKeys.contains('SEARCH_HOT_KEYWORDS')) 'search hot keywords key stays in app_storage',
        if (appStorageKeys.contains('COMMENT_LIST')) 'comment list key stays in app_storage',
        if (appStorageKeys.contains('FLOOR_COMMENT')) 'floor comment key stays in app_storage',
        if (!appCacheDataSource.contains('appCacheSearchHotKeywordsKey')) 'missing search app cache key',
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
        reason: '搜索和评论短期缓存使用 Drift app_cache_entries，缓存 key 应归属 AppCacheDataSource 边界，不能继续混在 Hive/app_storage key 里。',
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

    test('auth UI receives controller through auth bundle', () {
      final loginPageFile = File('${projectRoot.path}/lib/ui/pages/auth/login_page_view.dart');
      final effectListenerFile = File('${projectRoot.path}/lib/ui/widgets/auth/auth_ui_effect_listener.dart');
      final bundleFile = File('${projectRoot.path}/lib/features/auth/auth_controller_bundle.dart');
      final bootstrapFile = File('${projectRoot.path}/lib/app/bootstrap/feature_bootstrap.dart');
      final loginPage = loginPageFile.readAsStringSync();
      final effectListener = effectListenerFile.readAsStringSync();
      final bundle = bundleFile.readAsStringSync();
      final bootstrap = bootstrapFile.readAsStringSync();
      final violations = <String>[
        if (loginPage.contains("features/auth/auth_controller.dart")) '${_relativePath(loginPageFile)} imports auth controller directly',
        if (effectListener.contains("features/auth/auth_controller.dart")) '${_relativePath(effectListenerFile)} imports auth controller directly',
        if (loginPage.contains('Get.find<AuthController>')) '${_relativePath(loginPageFile)} reads auth controller directly',
        if (effectListener.contains('Get.find<AuthController>')) '${_relativePath(effectListenerFile)} reads auth controller directly',
        if (!loginPage.contains('Get.find<AuthControllerBundle>().authController')) '${_relativePath(loginPageFile)} does not resolve auth controller through auth bundle',
        if (!effectListener.contains('Get.find<AuthControllerBundle>().authController')) '${_relativePath(effectListenerFile)} does not resolve auth controller through auth bundle',
        if (!bundle.contains('final AuthController authController')) '${_relativePath(bundleFile)} does not expose auth controller boundary',
        if (!bootstrap.contains('Get.put<AuthControllerBundle>')) 'feature bootstrap does not register auth controller bundle',
        if (!bootstrap.contains('authController: Get.find<AuthController>()')) 'feature bootstrap does not inject auth controller into auth bundle',
      ];

      expect(
        violations,
        isEmpty,
        reason: '登录页和登录副作用监听器只能解析 AuthControllerBundle，不能在 UI 内直接读取 AuthController。',
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
        if (!controller.contains('List<int> get likedSongIdSnapshot => normalizeLikedSongIds(likedSongIds)')) 'user library controller does not expose normalized liked id snapshot',
        if (!controller.contains('final requestedLikedSongIds = uniqueLikedSongIds(likedSongIds);')) 'user library liked songs queue loading does not preserve library order',
        if (!controller.contains('final orderedLikedSongIds = uniqueLikedSongIds(nextLikedSongIds);')) 'user library refresh does not preserve liked song ordering while deduplicating',
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
        if (!repository.contains('String _normalizedUserId(String userId)')) '${_relativePath(repositoryFile)} does not normalize account scoped user ids',
        if (!repository.contains('final normalizedUserId = _normalizedUserId(userId);')) '${_relativePath(repositoryFile)} does not normalize user ids at repository entry points',
        if (!repository.contains('if (_isBlankUserId(normalizedUserId))')) '${_relativePath(repositoryFile)} does not guard normalized user-scoped repository entry points',
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

    test('user scoped dao normalizes persisted scope keys', () {
      final profileDaoFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/dao/user_profile_dao.dart',
      );
      final trackListDaoFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/dao/user_track_list_dao.dart',
      );
      final playlistDaoFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/dao/playlist_dao.dart',
      );
      final subscriptionDaoFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/dao/user_playlist_subscription_dao.dart',
      );
      final syncMarkerDaoFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/dao/user_sync_marker_dao.dart',
      );
      final radioDaoFile = File(
        '${projectRoot.path}/lib/data/music_data/sources/local/database/dao/radio_dao.dart',
      );
      final profileDao = profileDaoFile.readAsStringSync();
      final trackListDao = trackListDaoFile.readAsStringSync();
      final playlistDao = playlistDaoFile.readAsStringSync();
      final subscriptionDao = subscriptionDaoFile.readAsStringSync();
      final syncMarkerDao = syncMarkerDaoFile.readAsStringSync();
      final radioDao = radioDaoFile.readAsStringSync();
      final violations = <String>[
        if (!profileDao.contains('String _normalizedUserId(String userId)')) '${_relativePath(profileDaoFile)} does not normalize profile user ids',
        if (!profileDao.contains('if (_isBlankUserId(normalizedUserId))')) '${_relativePath(profileDaoFile)} can still read or write blank profile user ids',
        if (!profileDao.contains('userId: drift.Value(normalizedUserId)')) '${_relativePath(profileDaoFile)} can still write raw profile user ids',
        if (!trackListDao.contains('String _normalizedUserId(String userId)')) '${_relativePath(trackListDaoFile)} does not normalize track list user ids',
        if (!trackListDao.contains('String _normalizedTrackId(String trackId)')) '${_relativePath(trackListDaoFile)} does not normalize scoped track ids',
        if (!trackListDao.contains('List<String> _normalizedTrackIds(List<String> trackIds)')) '${_relativePath(trackListDaoFile)} does not filter track lists through a normalized helper',
        if (!trackListDao.contains('userId: normalizedUserId')) '${_relativePath(trackListDaoFile)} can still insert raw replacement user ids',
        if (!trackListDao.contains('userId: drift.Value(normalizedUserId)')) '${_relativePath(trackListDaoFile)} can still upsert raw user ids',
        if (!trackListDao.contains('trackId: drift.Value(normalizedTrackId)')) '${_relativePath(trackListDaoFile)} can still upsert raw track ids',
        if (!playlistDao.contains('String _normalizedUserId(String userId)')) '${_relativePath(playlistDaoFile)} does not normalize user playlist list user ids',
        if (!playlistDao.contains('String _normalizedPlaylistEntityId(String playlistId)')) '${_relativePath(playlistDaoFile)} does not normalize user playlist ids',
        if (!playlistDao.contains('List<PlaylistSummaryData> _normalizedPlaylistSummaries(')) '${_relativePath(playlistDaoFile)} does not normalize user playlist summaries through a helper',
        if (!playlistDao.contains('userId: normalizedUserId')) '${_relativePath(playlistDaoFile)} can still insert raw user playlist list user ids',
        if (!playlistDao.contains('userId: drift.Value(normalizedUserId)')) '${_relativePath(playlistDaoFile)} can still upsert raw user playlist list user ids',
        if (!playlistDao.contains('id: _normalizedPlaylistEntityId(item.id)')) '${_relativePath(playlistDaoFile)} can still write raw user playlist ids',
        if (!subscriptionDao.contains('String _normalizedUserId(String userId)')) '${_relativePath(subscriptionDaoFile)} does not normalize subscription user ids',
        if (!subscriptionDao.contains('String _normalizedPlaylistId(String playlistId)')) '${_relativePath(subscriptionDaoFile)} does not normalize subscription playlist ids',
        if (!subscriptionDao.contains('userId: drift.Value(normalizedUserId)')) '${_relativePath(subscriptionDaoFile)} can still write raw subscription user ids',
        if (!subscriptionDao.contains('playlistId: drift.Value(normalizedPlaylistId)')) '${_relativePath(subscriptionDaoFile)} can still write raw subscription playlist ids',
        if (!syncMarkerDao.contains('String _normalizedUserId(String userId)')) '${_relativePath(syncMarkerDaoFile)} does not normalize sync marker user ids',
        if (!syncMarkerDao.contains('String _normalizedMarkerKey(String markerKey)')) '${_relativePath(syncMarkerDaoFile)} does not normalize marker keys',
        if (!syncMarkerDao.contains('userId: drift.Value(normalizedUserId)')) '${_relativePath(syncMarkerDaoFile)} can still write raw marker user ids',
        if (!syncMarkerDao.contains('markerKey: drift.Value(normalizedMarkerKey)')) '${_relativePath(syncMarkerDaoFile)} can still write raw marker keys',
        if (!radioDao.contains('String _normalizedUserId(String userId)')) '${_relativePath(radioDaoFile)} does not normalize radio user ids',
        if (!radioDao.contains('String _normalizedRadioId(String radioId)')) '${_relativePath(radioDaoFile)} does not normalize radio ids',
        if (!radioDao.contains('String _normalizedProgramId(String programId)')) '${_relativePath(radioDaoFile)} does not normalize program ids',
        if (!radioDao.contains('List<RadioSummaryData> _normalizedRadioSummaries(List<RadioSummaryData> items)')) '${_relativePath(radioDaoFile)} does not normalize subscribed radio lists through a helper',
        if (!radioDao.contains('List<RadioProgramData> _normalizedPrograms(List<RadioProgramData> items)')) '${_relativePath(radioDaoFile)} does not normalize radio program lists through a helper',
        if (!radioDao.contains('userId: normalizedUserId')) '${_relativePath(radioDaoFile)} can still insert raw radio replacement user ids',
        if (!radioDao.contains('radioId: normalizedRadioId')) '${_relativePath(radioDaoFile)} can still insert raw program radio ids',
        if (!radioDao.contains('userId: drift.Value(normalizedUserId)')) '${_relativePath(radioDaoFile)} can still upsert raw radio user ids',
        if (!radioDao.contains('radioId: drift.Value(normalizedRadioId)')) '${_relativePath(radioDaoFile)} can still upsert raw program radio ids',
        if (!radioDao.contains('id: _normalizedRadioId(item.id)')) '${_relativePath(radioDaoFile)} can still write raw subscribed radio ids',
        if (!radioDao.contains('id: _normalizedProgramId(item.id)')) '${_relativePath(radioDaoFile)} can still write raw program ids',
      ];

      expect(
        violations,
        isEmpty,
        reason: '账号作用域事实表的 DAO 持久化边界必须归一 userId、playlistId、trackId、radioId、programId 和 markerKey，并拒绝空白 key，不能只依赖上层 repository。',
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
        reason: '不要恢复只有转发价值的 service/usecase/port/factory；页面应走 controller/repository、播放壳层 PlayerController 或明确的页面动作边界。',
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
