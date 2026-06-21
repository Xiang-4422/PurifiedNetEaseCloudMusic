import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/routing/router.dart';
import 'package:bujuan/ui/services/dialog_service.dart';
import 'package:bujuan/ui/services/toast_service.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/pages/debug/coverflow_demo_page_view.dart';
import 'package:bujuan/ui/pages/download/download_task_page_view.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/local_media/local_media_scan_controller.dart';
import 'package:bujuan/features/local_media/local_media_scan_repository.dart';
import 'package:bujuan/ui/pages/settings/cache_analysis_page.dart';
import 'package:bujuan/ui/pages/settings/lottie_preview_page.dart';
import 'package:bujuan/ui/pages/settings/widgets/setting_section_widgets.dart';
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
        _buildAccountSetting(context),
        _buildPlaybackSetting(context),
        _buildCacheSetting(context),
        _buildDownloadSetting(context),
        _buildAppearanceSetting(context),
        _buildDebugSetting(context),
      ],
    );
  }

  Widget _buildAccountSetting(BuildContext context) {
    return SettingSection(
      title: '账号',
      children: [
        SettingNavigationTile(
          icon: TablerIcons.user_circle,
          title: '账号资料',
          subtitle: '查看当前账号资料和注销登录',
          onTap: () => context.router.pushNamed(Routes.userProfile),
        ),
      ],
    );
  }

  Widget _buildPlaybackSetting(BuildContext context) {
    return SettingSection(
      title: '音质',
      children: [
        SettingToggleTile(
          icon: TablerIcons.music_up,
          title: '高音质优先',
          subtitle: '播放源解析时优先请求高音质地址',
          isEnabled: () => SettingsController.to.isHighSoundQualityOpen.value,
          onTap: () {
            SettingsController.to.toggleHighSoundQualityOpen();
          },
        ),
      ],
    );
  }

  Widget _buildDownloadSetting(BuildContext context) {
    return SettingSection(
      title: '下载',
      children: [
        SettingNavigationTile(
          icon: TablerIcons.download,
          title: '本地歌曲与下载',
          subtitle: '查看下载任务、失败重试和本地清理',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const DownloadTaskPageView(),
            ),
          ),
        ),
        SettingNavigationTile(
          icon: TablerIcons.folder_search,
          title: '扫描本地音乐',
          subtitle: '导入常见音乐目录中的音频、封面和歌词',
          onTap: _scanLocalMedia,
        ),
      ],
    );
  }

  Widget _buildCacheSetting(BuildContext context) {
    return SettingSection(
      title: '缓存',
      children: [
        SettingNavigationTile(
          icon: TablerIcons.database_search,
          title: '缓存分析',
          subtitle: '分析图片、封面、播放缓存和临时文件',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const CacheAnalysisPageView(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSetting(BuildContext context) {
    return SettingSection(
      title: '外观',
      children: [
        SettingToggleTile(
          icon: TablerIcons.gradienter,
          title: '渐变播放背景',
          subtitle: '根据封面主色调整播放页背景',
          isEnabled: () => SettingsController.to.isGradientBackground.value,
          onTap: () {
            SettingsController.to.toggleGradientBackground();
          },
        ),
        SettingToggleTile(
          icon: TablerIcons.circle,
          title: '圆形专辑',
          subtitle: '播放页使用圆形专辑封面',
          isEnabled: () => SettingsController.to.isRoundAlbumOpen.value,
          onTap: () {
            SettingsController.to.toggleRoundAlbumOpen();
          },
        ),
      ],
    );
  }

  Widget _buildDebugSetting(BuildContext context) {
    return SettingSection(
      title: '调试',
      children: [
        SettingNavigationTile(
          icon: TablerIcons.live_photo,
          title: 'Lottie 动画预览',
          subtitle: '自动读取 assets/lottie 下的动画资源',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const LottiePreviewPageView(),
            ),
          ),
        ),
        SettingNavigationTile(
          icon: TablerIcons.stack_2,
          title: 'CoverFlow Demo',
          subtitle: '使用当前播放列表的封面验证 CoverFlow 交互',
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => const CoverFlowDemoPageView(),
              fullscreenDialog: true,
            ),
          ),
        ),
      ],
    );
  }
}
