import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/features/comment/comment_controller_factory.dart';
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
class BottomPanelView extends StatelessWidget {
  /// 创建底部播放面板主视图。
  const BottomPanelView({
    required this.shellController,
    required this.commentControllerFactory,
    required this.playerController,
    required this.settingsController,
    Key? key,
  }) : super(key: key);

  /// 壳层控制器。
  final ShellController shellController;

  /// 评论控制器工厂。
  final CommentControllerFactory commentControllerFactory;

  /// 播放控制器。
  final PlayerController playerController;

  /// 设置控制器。
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 背景层
        BottomPanelBackgroundLayer(
          controller: shellController,
          settingsController: settingsController,
        ),
        // 内容
        Column(
          children: [
            BottomPanelHeader(
              controller: shellController,
              playerController: playerController,
              settingsController: settingsController,
            ),
            // 专辑占位
            Obx(() => Offstage(
                  offstage: shellController.isBigAlbum.isFalse,
                  child: Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: shellController.bottomPanelFullyOpened.isTrue && shellController.isAlbumScaleEnded.isTrue,
                    child: SizedBox(height: context.width - albumPadding),
                  ),
                )),
            // 播放列表、正在播放、歌曲评论
            Expanded(
              child: Stack(
                children: [
                  PageView(
                    controller: shellController.bottomPanelPageController,
                    children: [
                      BottomPanelQueueView(
                        shellController: shellController,
                        playerController: playerController,
                        settingsController: settingsController,
                      ),
                      BottomPanelNowPlayingPage(
                        shellController: shellController,
                        playerController: playerController,
                        settingsController: settingsController,
                      ),
                      BottomPanelCommentPage(
                        commentType: 2,
                        commentControllerFactory: commentControllerFactory,
                        playerController: playerController,
                        settingsController: settingsController,
                      ),
                      BottomPanelCommentPage(
                        commentType: 3,
                        commentControllerFactory: commentControllerFactory,
                        playerController: playerController,
                        settingsController: settingsController,
                      ),
                    ],
                  ),
                  BottomPanelContentFadeMask(
                    shellController: shellController,
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
        BottomPanelArtworkTransitionLayer(
          controller: shellController,
          playerController: playerController,
        ),
        BottomPanelArtworkPageLayer(
          controller: shellController,
          playerController: playerController,
        ),

        // 页面指示TabBar
        BottomPanelPageIndicator(
          shellController: shellController,
          playerController: playerController,
          settingsController: settingsController,
        ),
      ],
    );
  }
}
