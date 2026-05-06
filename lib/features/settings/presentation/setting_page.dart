import 'dart:io';

import 'package:bujuan/app/ui/adaptive_layout_metrics.dart';
import 'package:bujuan/app/ui/dialog_service.dart';
import 'package:bujuan/app/ui/toast_service.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/debug/presentation/coverflow_demo_page_view.dart';
import 'package:bujuan/features/download/presentation/download_task_page_view.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/local_media/local_media_scan_controller.dart';
import 'package:bujuan/features/local_media/local_media_scan_repository.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/settings/presentation/cache_analysis_page.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// 设置页，承接主题、缓存、本地扫描和调试入口。
class SettingPageView extends StatefulWidget {
  /// 创建设置页。
  const SettingPageView({Key? key}) : super(key: key);

  @override
  State<SettingPageView> createState() => _SettingPageViewState();
}

class _SettingPageViewState extends State<SettingPageView> {
  late final LocalMediaScanController _localMediaScanController = LocalMediaScanController(
    scanRepository: LocalMediaScanRepository(
      localMediaRepository: Get.find<LocalMediaRepository>(),
    ),
  );

  String version = '1.0.0';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _getVersion());
  }

  Future<void> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  Future<void> _scanLocalMedia() async {
    final permissionGranted = await _requestLocalMediaPermission();
    if (!permissionGranted) {
      ToastService.show('未获得本地音频读取权限');
      return;
    }

    final directoryPaths = await _resolveDefaultScanDirectories();
    if (directoryPaths.isEmpty) {
      ToastService.show('未找到可扫描的本地目录');
      return;
    }

    if (!mounted) {
      return;
    }
    DialogService.showLoading(context);
    try {
      final importedCount = await _localMediaScanController.importDirectories(
        directoryPaths,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      if (importedCount <= 0) {
        ToastService.show('未发现可导入的本地音频');
        return;
      }
      ToastService.show('已导入 $importedCount 首本地音乐');
    } catch (_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ToastService.show('扫描本地音乐失败');
    }
  }

  Future<bool> _requestLocalMediaPermission() async {
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

  Future<List<String>> _resolveDefaultScanDirectories() async {
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

    // 本地扫描先走用户最常见的音乐和下载目录，避免默认扫全盘。
    final downloadsDirectory = await getDownloadsDirectory();
    addPath(downloadsDirectory?.path);

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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(
        top: context.mediaQueryPadding.top,
        bottom: AppDimensions.bottomPanelHeaderHeight,
        left: AppDimensions.paddingSmall,
        right: AppDimensions.paddingSmall,
      ),
      children: [
        _buildUiSetting(context),
        _buildAppSetting(context),
      ],
    );
  }

  Widget _buildUiSetting(BuildContext context) {
    return Column(
      children: [
        const Header('UI设置'),
        _buildToggleTile(
          context,
          title: '渐变播放背景(需开启智能取色)',
          isEnabled: () => SettingsController.to.isGradientBackground.value,
          onTap: () {
            SettingsController.to.toggleGradientBackground();
          },
        ),
        _buildToggleTile(
          context,
          title: '圆形专辑',
          isEnabled: () => SettingsController.to.isRoundAlbumOpen.value,
          onTap: () {
            SettingsController.to.toggleRoundAlbumOpen();
          },
        ),
      ],
    );
  }

  Widget _buildAppSetting(BuildContext context) {
    return Column(
      children: [
        const Header('App设置'),
        _buildToggleTile(
          context,
          title: '开启高音质(与会员有关)',
          isEnabled: () => SettingsController.to.isHighSoundQualityOpen.value,
          onTap: () {
            SettingsController.to.toggleHighSoundQualityOpen();
          },
        ),
        _buildNavigationTile(
          context,
          title: '本地歌曲',
          subtitle: '查看下载任务、失败重试和本地清理',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DownloadTaskPageView(),
            ),
          ),
        ),
        _buildNavigationTile(
          context,
          title: '扫描本地音乐',
          subtitle: '导入常见音乐目录中的音频、封面和歌词',
          onTap: _scanLocalMedia,
        ),
        _buildNavigationTile(
          context,
          title: '缓存分析',
          subtitle: '分析图片、封面、播放缓存和临时文件',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CacheAnalysisPageView(),
            ),
          ),
        ),
        _buildNavigationTile(
          context,
          title: 'CoverFlow Demo',
          subtitle: '使用当前播放列表的封面验证 CoverFlow 交互',
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => const CoverFlowDemoPageView(),
              fullscreenDialog: true,
            ),
          ),
        ),
        _buildToggleTile(
          context,
          title: '离线模式',
          subtitle: '仅使用本地已存在的数据与资源',
          isEnabled: () => SettingsController.to.isOfflineModeEnabled.value,
          onTap: () {
            SettingsController.to.toggleOfflineMode();
          },
        ),
      ],
    );
  }

  Widget _buildToggleTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required bool Function() isEnabled,
    required VoidCallback onTap,
  }) {
    final metrics = AdaptiveLayoutMetrics.of(context);
    final iconSize = (AppDimensions.iconSizeLarge * metrics.textScale).clamp(34.0, 46.0).toDouble();
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: metrics.listTileMinHeight),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleLarge,
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).cardColor.withValues(alpha: .5),
                ),
              ),
        trailing: Obx(() {
          final enabled = isEnabled();
          return Icon(
            enabled ? TablerIcons.toggle_right : TablerIcons.toggle_left,
            size: iconSize,
            color: Theme.of(context).cardColor.withValues(
                  alpha: enabled ? 0.7 : .4,
                ),
          );
        }),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final metrics = AdaptiveLayoutMetrics.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: metrics.listTileMinHeight),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleLarge,
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).cardColor.withValues(alpha: .5),
          ),
        ),
        trailing: Icon(
          TablerIcons.chevron_right,
          size: AppDimensions.iconSizeLarge,
          color: Theme.of(context).cardColor.withValues(alpha: .5),
        ),
        onTap: onTap,
      ),
    );
  }
}
