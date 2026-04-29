import 'dart:io';

import 'package:bujuan/app/bootstrap/feature_controller_factory.dart';
import 'package:bujuan/app/ui/dialog_service.dart';
import 'package:bujuan/app/ui/toast_service.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/local_media/local_media_scan_controller.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/app/presentation_adapters/settings_navigation_port.dart';
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
  final LocalMediaScanController _localMediaScanController =
      Get.find<FeatureControllerFactory>().localMediaScan();
  final SettingsNavigationPort _navigationPort =
      Get.find<SettingsNavigationPort>();

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
      final homeDirectoryPath =
          Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
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
        _buildUiSetting(),
        _buildAppSetting(),
      ],
    );
  }

  Widget _buildUiSetting() {
    return Column(
      children: [
        const Header('UI设置'),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: const Text(
            '渐变播放背景(需开启智能取色)',
            style: TextStyle(fontSize: 30),
          ),
          trailing: Obx(() => Icon(
                SettingsController.to.isGradientBackground.value
                    ? TablerIcons.toggle_right
                    : TablerIcons.toggle_left,
                size: 56,
                color: Theme.of(context).cardColor.withValues(
                    alpha: SettingsController.to.isGradientBackground.value
                        ? 0.7
                        : .4),
              )),
          onTap: () {
            SettingsController.to.toggleGradientBackground();
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: const Text(
            '圆形专辑',
            style: TextStyle(fontSize: 30),
          ),
          trailing: Obx(() => Icon(
                SettingsController.to.isRoundAlbumOpen.value
                    ? TablerIcons.toggle_right
                    : TablerIcons.toggle_left,
                size: 56,
                color: Theme.of(context).cardColor.withValues(
                    alpha: SettingsController.to.isRoundAlbumOpen.value
                        ? 0.7
                        : .4),
              )),
          onTap: () {
            SettingsController.to.toggleRoundAlbumOpen();
          },
        ),
      ],
    );
  }

  Widget _buildAppSetting() {
    return Column(
      children: [
        const Header('App设置'),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: const Text(
            '开启高音质(与会员有关)',
            style: TextStyle(fontSize: 30),
          ),
          trailing: Obx(() => Icon(
                SettingsController.to.isHighSoundQualityOpen.value
                    ? TablerIcons.toggle_right
                    : TablerIcons.toggle_left,
                size: 56,
                color: Theme.of(context).cardColor.withValues(
                    alpha: SettingsController.to.isHighSoundQualityOpen.value
                        ? 0.7
                        : .4),
              )),
          onTap: () {
            SettingsController.to.toggleHighSoundQualityOpen();
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: const Text(
            '本地歌曲',
            style: TextStyle(fontSize: 30),
          ),
          subtitle: Text(
            '查看下载任务、失败重试和本地清理',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).cardColor.withValues(alpha: .5),
            ),
          ),
          trailing: Icon(
            TablerIcons.chevron_right,
            size: 32,
            color: Theme.of(context).cardColor.withValues(alpha: .5),
          ),
          onTap: () => _navigationPort.openLocalSongs(context),
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: const Text(
            '扫描本地音乐',
            style: TextStyle(fontSize: 30),
          ),
          subtitle: Text(
            '导入常见音乐目录中的音频、封面和歌词',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).cardColor.withValues(alpha: .5),
            ),
          ),
          trailing: Icon(
            TablerIcons.chevron_right,
            size: 32,
            color: Theme.of(context).cardColor.withValues(alpha: .5),
          ),
          onTap: _scanLocalMedia,
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: const Text(
            'CoverFlow Demo',
            style: TextStyle(fontSize: 30),
          ),
          subtitle: Text(
            '使用当前播放列表的封面验证 CoverFlow 交互',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).cardColor.withValues(alpha: .5),
            ),
          ),
          trailing: Icon(
            TablerIcons.chevron_right,
            size: 32,
            color: Theme.of(context).cardColor.withValues(alpha: .5),
          ),
          onTap: () => _navigationPort.openCoverFlowDemo(context),
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: const Text(
            '离线模式',
            style: TextStyle(fontSize: 30),
          ),
          subtitle: Text(
            '仅使用本地已存在的数据与资源',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).cardColor.withValues(alpha: .5),
            ),
          ),
          trailing: Obx(() => Icon(
                SettingsController.to.isOfflineModeEnabled.value
                    ? TablerIcons.toggle_right
                    : TablerIcons.toggle_left,
                size: 56,
                color: Theme.of(context).cardColor.withValues(
                    alpha: SettingsController.to.isOfflineModeEnabled.value
                        ? 0.7
                        : .4),
              )),
          onTap: () {
            SettingsController.to.toggleOfflineMode();
          },
        ),
        // ListTile(
        //   title: Text(
        //     '清理缓存',
        //     style: TextStyle(fontSize: 30),
        //   ),
        //   trailing: Icon(
        //     TablerIcons.chevron_right,
        //     size: 42),
        //     color: Theme.of(context).cardColor.withOpacity(.6),
        //   ),
        //   onTap: () async {
        //     DialogService.showLoading(context);
        //     await Downloader.clearCachedFiles();
        //     if (mounted) Navigator.of(context).pop();
        //   },
        // ),
      ],
    );
  }
}
