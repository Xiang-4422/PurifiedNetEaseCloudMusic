import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/shell/app_controller.dart';
import 'package:bujuan/pages/download_task_page_view.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPageView extends StatefulWidget {
  const SettingPageView({Key? key}) : super(key: key);

  @override
  State<SettingPageView> createState() => _SettingPageViewState();
}

class _SettingPageViewState extends State<SettingPageView> {
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
            '开启缓存',
            style: TextStyle(fontSize: 30),
          ),
          trailing: Obx(() => Icon(
                AppController.to.isCacheOpen.value
                    ? TablerIcons.toggle_right
                    : TablerIcons.toggle_left,
                size: 56,
                color: Theme.of(context).cardColor.withValues(
                    alpha: AppController.to.isCacheOpen.value ? 0.7 : .4),
              )),
          onTap: () {
            AppController.to.settingsController.toggleCacheOpen();
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
