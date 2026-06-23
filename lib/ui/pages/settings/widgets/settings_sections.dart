import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/routing/router.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/ui/pages/debug/coverflow_demo_page_view.dart';
import 'package:bujuan/ui/pages/download/download_task_page_view.dart';
import 'package:bujuan/ui/pages/settings/cache_analysis_page.dart';
import 'package:bujuan/ui/pages/settings/lottie_preview_page.dart';
import 'package:bujuan/ui/pages/settings/widgets/setting_section_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// 设置页可见分组列表。
class SettingsSectionsList extends StatelessWidget {
  /// 创建设置页可见分组列表。
  const SettingsSectionsList({
    super.key,
    required this.onScanLocalMedia,
  });

  /// 扫描本地音乐动作。
  final VoidCallback onScanLocalMedia;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAccountSetting(context),
        _buildPlaybackSetting(),
        _buildCacheSetting(context),
        _buildDownloadSetting(context),
        _buildAppearanceSetting(),
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

  Widget _buildPlaybackSetting() {
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
          onTap: onScanLocalMedia,
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

  Widget _buildAppearanceSetting() {
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
