import 'dart:io';

import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/features/local_media/local_media_scan_repository.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/shell/app_controller.dart';
import 'package:bujuan/pages/coverflow_demo_page_view.dart';
import 'package:bujuan/pages/download_task_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingPageView extends StatefulWidget {
  const SettingPageView({Key? key}) : super(key: key);

  @override
  State<SettingPageView> createState() => _SettingPageViewState();
}

class _SettingPageViewState extends State<SettingPageView> {
  final LocalMediaScanRepository _localMediaScanRepository =
      LocalMediaScanRepository();

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
      WidgetUtil.showToast('未获得本地音频读取权限');
      return;
    }

    final directoryPaths = await _resolveDefaultScanDirectories();
    if (directoryPaths.isEmpty) {
      WidgetUtil.showToast('未找到可扫描的本地目录');
      return;
    }

    if (!mounted) {
      return;
    }
    WidgetUtil.showLoadingDialog(context);
    try {
      final importedCount = await _localMediaScanRepository.importDirectories(
        directoryPaths,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      if (importedCount <= 0) {
        WidgetUtil.showToast('未发现可导入的本地音频');
        return;
      }
      WidgetUtil.showToast('已导入 $importedCount 首本地音乐');
    } catch (_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      WidgetUtil.showToast('扫描本地音乐失败');
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
                AppController.to.isGradientBackground.value
                    ? TablerIcons.toggle_right
                    : TablerIcons.toggle_left,
                size: 56,
                color: Theme.of(context).cardColor.withValues(
                    alpha:
                        AppController.to.isGradientBackground.value ? 0.7 : .4),
              )),
          onTap: () {
            AppController.to.settingsController.toggleGradientBackground();
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: const Text(
            '圆形专辑',
            style: TextStyle(fontSize: 30),
          ),
          trailing: Obx(() => Icon(
                AppController.to.isRoundAlbumOpen.value
                    ? TablerIcons.toggle_right
                    : TablerIcons.toggle_left,
                size: 56,
                color: Theme.of(context).cardColor.withValues(
                    alpha: AppController.to.isRoundAlbumOpen.value ? 0.7 : .4),
              )),
          onTap: () {
            AppController.to.settingsController.toggleRoundAlbumOpen();
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
                AppController.to.isHighSoundQualityOpen.value
                    ? TablerIcons.toggle_right
                    : TablerIcons.toggle_left,
                size: 56,
                color: Theme.of(context).cardColor.withValues(
                    alpha: AppController.to.isHighSoundQualityOpen.value
                        ? 0.7
                        : .4),
              )),
          onTap: () {
            AppController.to.settingsController.toggleHighSoundQualityOpen();
          },
        ),
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: const Text(
            '下载管理',
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
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DownloadTaskPageView(),
              ),
            );
          },
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
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => const CoverFlowDemoPageView(),
                fullscreenDialog: true,
              ),
            );
          },
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
                AppController.to.isOfflineModeEnabled.value
                    ? TablerIcons.toggle_right
                    : TablerIcons.toggle_left,
                size: 56,
                color: Theme.of(context).cardColor.withValues(
                    alpha:
                        AppController.to.isOfflineModeEnabled.value ? 0.7 : .4),
              )),
          onTap: () {
            AppController.to.settingsController.toggleOfflineMode();
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
        //     WidgetUtil.showLoadingDialog(context);
        //     await Downloader.clearCachedFiles();
        //     if (mounted) Navigator.of(context).pop();
        //   },
        // ),
      ],
    );
  }
}
