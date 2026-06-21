import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_artwork_layer.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_comment_page.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_header.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_now_playing_page.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_page_indicator.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_queue_view.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

/// 底部播放面板主视图，组合队列、歌词、评论和播放控制区域。
class BottomPanelView extends GetView<ShellController> {
  /// 创建底部播放面板主视图。
  const BottomPanelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 背景层
        AnimatedBuilder(
          animation: controller.bottomPanelAnimationController,
          builder: (BuildContext context, Widget? child) {
            double panelOpenDegree = controller.bottomPanelAnimationController.value;
            return Obx(() => BlurryContainer(
                  blur: 20,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.all(Radius.circular(AppDimensions.phoneCornerRadius * (1 - panelOpenDegree))),
                  color: SettingsController.to.albumColor.value.withValues(alpha: 0.5 + 0.5 * panelOpenDegree),
                  child: Container(),
                ));
          },
        ),
        // 内容
        Column(
          children: [
            BottomPanelHeader(controller: controller),
            // 专辑占位
            Obx(() => Offstage(
                  offstage: controller.isBigAlbum.isFalse,
                  child: Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: controller.bottomPanelFullyOpened.isTrue && controller.isAlbumScaleEnded.isTrue,
                    child: SizedBox(height: context.width - albumPadding),
                  ),
                )),
            // 播放列表、正在播放、歌曲评论
            Expanded(
              child: Stack(
                children: [
                  PageView(
                    controller: controller.bottomPanelPageController,
                    children: const [
                      BottomPanelQueueView(),
                      BottomPanelNowPlayingPage(),
                      BottomPanelCommentPage(commentType: 2),
                      BottomPanelCommentPage(commentType: 3),
                    ],
                  ),
                  Obx(() => Offstage(
                        offstage: controller.bottomPanelFullyOpened.isFalse,
                        child: Column(
                          children: [
                            Container(
                              height: albumPadding,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter, // 渐变开始于顶部
                                  end: Alignment.bottomCenter, // 渐变结束于底部
                                  colors: [
                                    SettingsController.to.albumColor.value,
                                    SettingsController.to.albumColor.value.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(child: Container()),
                            Container(
                              height: albumPadding,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter, // 渐变开始于顶部
                                  end: Alignment.bottomCenter, // 渐变结束于底部
                                  colors: [
                                    SettingsController.to.albumColor.value.withValues(alpha: 0),
                                    SettingsController.to.albumColor.value,
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                ],
              ),
            ),
            // TabBar占位
            Container(
              height: AppDimensions.paddingLarge,
            )
          ],
        ),
        BottomPanelArtworkTransitionLayer(controller: controller),
        BottomPanelArtworkPageLayer(controller: controller),

        // 页面指示TabBar
        const BottomPanelPageIndicator(),
      ],
    );
  }
}
