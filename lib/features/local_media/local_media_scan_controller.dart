import 'dart:io';

import 'package:bujuan/features/local_media/local_media_scan_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// 请求本地音频读取权限。
typedef LocalMediaPermissionRequest = Future<bool> Function();

/// 解析默认本地音乐扫描目录。
typedef LocalMediaDefaultDirectoryResolver = Future<List<String>> Function();

/// 默认本地音乐扫描准备状态。
enum LocalMediaDefaultScanPreparationStatus {
  /// 当前平台没有授权本地音频读取权限。
  permissionDenied,

  /// 没有找到可扫描的默认本地目录。
  noDirectories,

  /// 已准备好目录，可以进入正式扫描导入阶段。
  ready,
}

/// 默认本地音乐扫描的准备结果。
class LocalMediaDefaultScanPreparation {
  const LocalMediaDefaultScanPreparation._({
    required this.status,
    this.directoryPaths = const <String>[],
  });

  /// 表示当前没有本地音频读取权限。
  const LocalMediaDefaultScanPreparation.permissionDenied()
      : this._(
          status: LocalMediaDefaultScanPreparationStatus.permissionDenied,
        );

  /// 表示默认目录解析完成，但没有可扫描目录。
  const LocalMediaDefaultScanPreparation.noDirectories()
      : this._(
          status: LocalMediaDefaultScanPreparationStatus.noDirectories,
        );

  /// 表示 [directoryPaths] 可以进入扫描导入。
  const LocalMediaDefaultScanPreparation.ready(List<String> directoryPaths)
      : this._(
          status: LocalMediaDefaultScanPreparationStatus.ready,
          directoryPaths: directoryPaths,
        );

  /// 准备阶段的最终状态。
  final LocalMediaDefaultScanPreparationStatus status;

  /// 可扫描的默认目录；只有 [status] 为 ready 时才有内容。
  final List<String> directoryPaths;

  /// 当前准备结果是否可以进入正式导入。
  bool get isReady => status == LocalMediaDefaultScanPreparationStatus.ready;
}

/// 本地扫描页动作入口，避免设置页直接持有扫描 repository。
class LocalMediaScanController {
  /// 创建本地媒体扫描控制器。
  ///
  /// [requestPermission] 和 [resolveDefaultDirectories] 仅用于注入平台能力，
  /// 生产环境默认请求系统权限并解析常见音乐目录。
  LocalMediaScanController({
    required LocalMediaScanRepository scanRepository,
    LocalMediaPermissionRequest? requestPermission,
    LocalMediaDefaultDirectoryResolver? resolveDefaultDirectories,
  })  : _scanRepository = scanRepository,
        _requestPermission = requestPermission ?? _requestLocalMediaPermission,
        _resolveDefaultDirectories = resolveDefaultDirectories ?? _resolveDefaultScanDirectories;

  final LocalMediaScanRepository _scanRepository;
  final LocalMediaPermissionRequest _requestPermission;
  final LocalMediaDefaultDirectoryResolver _resolveDefaultDirectories;

  /// 请求权限并解析默认扫描目录，供页面决定是否进入导入 loading。
  Future<LocalMediaDefaultScanPreparation> prepareDefaultDirectoryImport() async {
    final permissionGranted = await _requestPermission();
    if (!permissionGranted) {
      return const LocalMediaDefaultScanPreparation.permissionDenied();
    }

    final directoryPaths = await _resolveDefaultDirectories();
    if (directoryPaths.isEmpty) {
      return const LocalMediaDefaultScanPreparation.noDirectories();
    }

    return LocalMediaDefaultScanPreparation.ready(directoryPaths);
  }

  /// 扫描并导入目录中的支持音频文件。
  Future<int> importDirectories(List<String> directoryPaths) {
    return _scanRepository.importDirectories(directoryPaths);
  }

  static Future<bool> _requestLocalMediaPermission() async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return true;
    }

    final permissions = <Permission>[];
    if (Platform.isAndroid) {
      permissions.add(Permission.audio);
      permissions.add(Permission.storage);
    } else {
      permissions.add(Permission.mediaLibrary);
    }

    for (final permission in permissions) {
      final status = await permission.request();
      if (status.isGranted || status.isLimited) {
        return true;
      }
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    }
    return false;
  }

  static Future<List<String>> _resolveDefaultScanDirectories() async {
    final directories = <String>{};

    void addPath(String? path) {
      if (path == null || path.isEmpty) {
        return;
      }
      final directory = Directory(path);
      if (directory.existsSync()) {
        directories.add(directory.path);
      }
    }

    try {
      final downloadsDirectory = await getDownloadsDirectory();
      addPath(downloadsDirectory?.path);
    } catch (_) {
      // path_provider 在部分平台或测试环境可能没有下载目录实现。
    }

    if (Platform.isAndroid) {
      addPath('/storage/emulated/0/Music');
      addPath('/storage/emulated/0/Download');
      addPath('/sdcard/Music');
      addPath('/sdcard/Download');
    } else {
      final homeDirectoryPath = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      addPath(homeDirectoryPath == null ? null : '$homeDirectoryPath/Music');
      addPath(
        homeDirectoryPath == null ? null : '$homeDirectoryPath/Downloads',
      );
    }

    return directories.toList();
  }
}
