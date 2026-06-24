import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/layout/my_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 播放队列会话标题的完整辅助语义标签。
@visibleForTesting
String bottomPanelSessionTitleLabel({
  required String playlistHeader,
  required String playlistName,
}) {
  final header = playlistHeader.trim();
  final name = playlistName.trim();
  if (header.isEmpty && name.isEmpty) {
    return '当前播放列表';
  }
  if (header.isEmpty) {
    return '当前播放列表：$name';
  }
  if (name.isEmpty) {
    return '当前播放列表：$header';
  }
  return '当前播放列表：$header $name';
}

/// 底部播放面板页面指示器，展示队列、正在播放和评论分页。
class BottomPanelPageIndicator extends StatelessWidget {
  /// 创建页面指示器。
  const BottomPanelPageIndicator({
    required this.shellController,
    required this.playerController,
    required this.settingsController,
    super.key,
  });

  /// 壳层控制器，提供当前面板分页和 tab 控制器。
  final ShellController shellController;

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
            final sessionTitleLabel = bottomPanelSessionTitleLabel(
              playlistHeader: sessionState.playlistHeader,
              playlistName: sessionState.playlistName,
            );
            return Container(
              height: albumPadding,
              margin: const EdgeInsets.symmetric(
                horizontal: albumPadding,
              ),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: shellController.isBigAlbum.isTrue ? settingsController.panelWidgetColor.value.withValues(alpha: 0.05) : Colors.transparent,
                borderRadius: BorderRadius.circular(albumPadding),
              ),
              child: MyTabBarItemAnimatedSwitcher(
                isTabBarVisible: shellController.curPanelPageIndex.value == 0,
                replaceItem: Tooltip(
                  message: sessionTitleLabel,
                  excludeFromSemantics: true,
                  child: Semantics(
                    label: sessionTitleLabel,
                    child: ExcludeSemantics(
                      child: Row(
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
                    ),
                  ),
                ),
                tabItem: MyTabBar(
                  height: albumPadding,
                  color: settingsController.panelWidgetColor.value,
                  controller: shellController.bottomPanelTabController,
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
                        isTabBarVisible: shellController.curPanelPageIndex.value > 1,
                        tabItem: Text(
                          '歌曲评论',
                          style: context.textTheme.titleMedium?.copyWith(
                            color: settingsController.panelWidgetColor.value.withValues(alpha: 0.5),
                          ),
                        ),
                        replaceItem: MyTabBar(
                          height: albumPadding,
                          controller: shellController.bottomPanelCommentTabController,
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
