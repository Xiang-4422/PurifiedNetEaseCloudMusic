import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/layout/my_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 底部播放面板页面指示器，展示队列、正在播放和评论分页。
class BottomPanelPageIndicator extends GetView<ShellController> {
  /// 创建页面指示器。
  const BottomPanelPageIndicator({
    required this.playerController,
    required this.settingsController,
    super.key,
  });

  /// 播放控制器，提供当前播放会话标题。
  final PlayerController playerController;

  /// 设置控制器，提供播放面板取色。
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    return Container(
      alignment: Alignment.bottomCenter,
      child: Obx(
        () => Container(
          color: settingsController.albumColor.value,
          child: Obx(() {
            final sessionState = playerController.sessionState.value;
            return Container(
              height: albumPadding,
              margin: const EdgeInsets.symmetric(
                horizontal: albumPadding,
              ),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: controller.isBigAlbum.isTrue ? settingsController.panelWidgetColor.value.withValues(alpha: 0.05) : Colors.transparent,
                borderRadius: BorderRadius.circular(albumPadding),
              ),
              child: MyTabBarItemAnimatedSwitcher(
                isTabBarVisible: controller.curPanelPageIndex.value == 0,
                replaceItem: Row(
                  children: [
                    Offstage(
                      offstage: sessionState.playlistHeader.isEmpty,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: albumPadding / 2,
                        ),
                        decoration: BoxDecoration(
                          color: settingsController.panelWidgetColor.value.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(albumPadding),
                        ),
                        child: Text(
                          sessionState.playlistHeader,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: settingsController.panelWidgetColor.value.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: AlignmentDirectional.center,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            sessionState.playlistName,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: settingsController.panelWidgetColor.value.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                tabItem: MyTabBar(
                  height: albumPadding,
                  color: settingsController.panelWidgetColor.value,
                  controller: controller.bottomPanelTabController,
                  tabs: [
                    Text(
                      '播放列表',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: settingsController.panelWidgetColor.value.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      '正在播放',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: settingsController.panelWidgetColor.value.withValues(alpha: 0.5),
                      ),
                    ),
                    Obx(
                      () => MyTabBarItemAnimatedSwitcher(
                        isTabBarVisible: controller.curPanelPageIndex.value > 1,
                        tabItem: Text(
                          '歌曲评论',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: settingsController.panelWidgetColor.value.withValues(alpha: 0.5),
                          ),
                        ),
                        replaceItem: MyTabBar(
                          height: albumPadding,
                          controller: controller.bottomPanelCommentTabController,
                          color: settingsController.panelWidgetColor.value,
                          tabs: [
                            Text(
                              '热',
                              style: context.textTheme.titleMedium?.copyWith(
                                color: settingsController.panelWidgetColor.value.withValues(alpha: 0.5),
                              ),
                            ),
                            Text(
                              '新',
                              style: context.textTheme.titleMedium?.copyWith(
                                color: settingsController.panelWidgetColor.value.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
