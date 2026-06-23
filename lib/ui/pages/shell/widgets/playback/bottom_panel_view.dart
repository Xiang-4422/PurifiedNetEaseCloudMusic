import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_artwork_layer.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_background_layers.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_comment_page.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_header.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_now_playing_page.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_page_indicator.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_queue_view.dart';
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
    final playerController = PlayerController.to;
    final settingsController = SettingsController.to;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 背景层
        BottomPanelBackgroundLayer(
          controller: controller,
          settingsController: settingsController,
        ),
        // 内容
        Column(
          children: [
            BottomPanelHeader(
              controller: controller,
              playerController: playerController,
              settingsController: settingsController,
            ),
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
                    children: [
                      BottomPanelQueueView(
                        playerController: playerController,
                        settingsController: settingsController,
                      ),
                      const BottomPanelNowPlayingPage(),
                      BottomPanelCommentPage(
                        commentType: 2,
                        playerController: playerController,
                        settingsController: settingsController,
                      ),
                      BottomPanelCommentPage(
                        commentType: 3,
                        playerController: playerController,
                        settingsController: settingsController,
                      ),
                    ],
                  ),
                  BottomPanelContentFadeMask(
                    settingsController: settingsController,
                  ),
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
        BottomPanelPageIndicator(
          playerController: playerController,
          settingsController: settingsController,
        ),
      ],
    );
  }
}
