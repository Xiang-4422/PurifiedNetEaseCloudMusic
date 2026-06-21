import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_artwork_layer.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_comment_page.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_header.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_playback_controls.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/bottom_panel_queue_view.dart';
import 'package:bujuan/ui/pages/shell/widgets/playback/lyric_view.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/app/routing/router.gr.dart' as gr;
import 'package:bujuan/ui/widgets/common/layout/keep_alive_wrapper.dart';
import 'package:bujuan/ui/widgets/common/layout/my_tab_bar.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

/// 底部播放面板主视图，组合队列、歌词、评论和播放控制区域。
class BottomPanelView extends GetView<ShellController> {
  /// 创建底部播放面板主视图。
  const BottomPanelView({Key? key}) : super(key: key);

  List<_ArtistChipData> _artistEntries(PlaybackQueueItem item) {
    final artistNames = item.artistNames.isNotEmpty ? item.artistNames : (item.artist ?? '').split(' / ').where((artist) => artist.isNotEmpty).toList();
    final artistIds = item.artistIds;
    return List.generate(
      artistNames.length,
      (index) => _ArtistChipData(
        name: artistNames[index],
        id: index < artistIds.length ? artistIds[index] : '',
      ),
    );
  }

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
                    children: [
                      _buildCurPlayingListPage(context),
                      _buildCurPlayingPage(
                        context,
                      ),
                      const BottomPanelCommentPage(commentType: 2),
                      const BottomPanelCommentPage(commentType: 3),
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
        Container(
          alignment: Alignment.bottomCenter,
          child: Obx(
            () => Container(
              color: SettingsController.to.albumColor.value,
              child: Obx(() {
                final sessionState = PlayerController.to.sessionState.value;
                return Container(
                  height: albumPadding,
                  margin: const EdgeInsets.symmetric(
                    horizontal: albumPadding,
                  ),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: controller.isBigAlbum.isTrue ? SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.05) : Colors.transparent,
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
                              color: SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(albumPadding),
                            ),
                            child: Text(
                              sessionState.playlistHeader,
                              style: context.textTheme.titleMedium?.copyWith(color: SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.5)),
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
                                style: context.textTheme.titleMedium?.copyWith(color: SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.5)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    tabItem: MyTabBar(
                      height: albumPadding,
                      color: SettingsController.to.panelWidgetColor.value,
                      controller: controller.bottomPanelTabController,
                      tabs: [
                        Text("播放列表", style: context.textTheme.titleMedium?.copyWith(color: SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.5))),
                        Text("正在播放", style: context.textTheme.titleMedium?.copyWith(color: SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.5))),
                        Obx(() => MyTabBarItemAnimatedSwitcher(
                              isTabBarVisible: controller.curPanelPageIndex.value > 1,
                              tabItem: Text("歌曲评论", style: context.textTheme.titleMedium?.copyWith(color: SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.5))),
                              replaceItem: MyTabBar(
                                height: albumPadding,
                                controller: controller.bottomPanelCommentTabController,
                                color: SettingsController.to.panelWidgetColor.value,
                                tabs: [
                                  Text("热", style: context.textTheme.titleMedium?.copyWith(color: SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.5))),
                                  Text("新", style: context.textTheme.titleMedium?.copyWith(color: SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.5))),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  /// 播放列表页
  Widget _buildCurPlayingListPage(BuildContext context) {
    return const BottomPanelQueueView();
  }

  /// 默认页（歌词）
  Widget _buildCurPlayingPage(BuildContext context) {
    const albumPadding = AppDimensions.paddingLarge;
    final remainWidth = (context.width - albumPadding * 2).clamp(0.0, double.infinity);
    final textWidth = _measureTextWidth("歌手：", TextStyle(color: SettingsController.to.panelWidgetColor.value)) + albumPadding + 4;
    return KeepAliveWrapper(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          PlayerController.to.updateFullScreenLyricTimerCounter();
        },
        onPointerMove: (event) {
          PlayerController.to.updateFullScreenLyricTimerCounter();
        },
        onPointerUp: (event) {
          PlayerController.to.updateFullScreenLyricTimerCounter();
        },
        child: Stack(
          children: [
            // 歌词
            Obx(() => Offstage(
                offstage: controller.isBigAlbum.value,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (PlayerController.to.isFullScreenLyricOpen.isTrue) {
                      PlayerController.to.isFullScreenLyricOpen.value = false;
                    } else {
                      controller.isAlbumScaleEnded.value = false;
                      controller.isBigAlbum.value = true;
                      PlayerController.to.updateFullScreenLyricTimerCounter(cancelTimer: true);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: albumPadding,
                    ),
                    child: const LyricView(EdgeInsets.symmetric(vertical: 10)),
                  ),
                ))),
            // 控制、进度条、页面指示占位
            Obx(() => Offstage(
                  offstage: PlayerController.to.isFullScreenLyricOpen.isTrue && controller.isBigAlbum.isFalse,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 占位: 专辑封面
                      Obx(() => Container(height: controller.isBigAlbum.isTrue ? 0 : context.width - albumPadding)),
                      // 专辑、歌手、进度条
                      Obx(() => Visibility(
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            visible: controller.isBigAlbum.isTrue,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: albumPadding,
                              ),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                // 专辑
                                SizedBox(
                                    height: albumPadding,
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(albumPadding),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // 这里测量的宽度不准确，强制将text适配到测量的宽度
                                              IntrinsicWidth(
                                                child: Container(
                                                  padding: const EdgeInsets.only(left: albumPadding / 2),
                                                  child: Text(
                                                    "专辑：",
                                                    style: TextStyle(
                                                      color: SettingsController.to.panelWidgetColor.value,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  final currentSong = PlayerController.to.currentSongState.value;
                                                  final albumId = currentSong.albumId;
                                                  if (albumId?.isNotEmpty != true) {
                                                    return;
                                                  }
                                                  final router = context.router;
                                                  await controller.bottomPanelController.close();
                                                  router.push(const gr.AlbumRouteView().copyWith(queryParams: {'albumId': albumId}));
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(albumPadding),
                                                  ),
                                                  child: ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      maxWidth: remainWidth - textWidth,
                                                    ),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: albumPadding / 2),
                                                      child: Obx(() => Text(
                                                            PlayerController.to.currentSongState.value.albumTitle ?? "未知专辑",
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(color: SettingsController.to.panelWidgetColor.value),
                                                            overflow: TextOverflow.ellipsis,
                                                          )),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Expanded(child: Container())
                                            ],
                                          ),
                                        ),
                                        Expanded(child: Container())
                                      ],
                                    )).marginOnly(top: albumPadding),
                                // 歌手
                                SizedBox(
                                  height: albumPadding,
                                  child: Row(
                                    children: [
                                      Container(
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          color: SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(albumPadding),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IntrinsicWidth(
                                              child: Container(
                                                padding: const EdgeInsets.only(left: albumPadding / 2),
                                                child: Text(
                                                  "歌手：",
                                                  style: TextStyle(
                                                    color: SettingsController.to.panelWidgetColor.value,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: remainWidth - textWidth,
                                              ),
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Obx(() {
                                                  final currentSong = PlayerController.to.currentSongState.value;
                                                  final artists = _artistEntries(currentSong);
                                                  return Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: artists.isEmpty
                                                        ? [
                                                            Text(
                                                              "未知歌手",
                                                              style: TextStyle(color: SettingsController.to.panelWidgetColor.value),
                                                              overflow: TextOverflow.ellipsis,
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ]
                                                        : [
                                                            for (final artist in artists)
                                                              Container(
                                                                alignment: Alignment.center,
                                                                padding: const EdgeInsets.symmetric(horizontal: albumPadding / 2),
                                                                decoration: BoxDecoration(
                                                                  color: SettingsController.to.panelWidgetColor.value.withValues(alpha: 0.1),
                                                                  borderRadius: BorderRadius.circular(albumPadding),
                                                                ),
                                                                child: GestureDetector(
                                                                  onTap: () async {
                                                                    if (artist.id.isEmpty) {
                                                                      return;
                                                                    }
                                                                    final router = context.router;
                                                                    await controller.closeBottomPanel();
                                                                    router.push(const gr.ArtistRouteView().copyWith(queryParams: {'artistId': artist.id}));
                                                                  },
                                                                  child: Text(
                                                                    artist.name,
                                                                    style: TextStyle(color: SettingsController.to.panelWidgetColor.value),
                                                                    overflow: TextOverflow.ellipsis,
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                  );
                                                }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(child: Container())
                                    ],
                                  ),
                                ).marginOnly(top: albumPadding),
                                // 播放进度条
                                const BottomPanelProgressBar().marginOnly(top: albumPadding),
                              ]),
                            ),
                          )),
                      // 播放控制
                      const Expanded(child: BottomPanelPlaybackControls()),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  double _measureTextWidth(String text, TextStyle style, {double maxWidth = double.infinity, int? maxLines}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr, // 必须设置文本方向
      maxLines: maxLines, // 可选：如果文本有行数限制
    )..layout(minWidth: 0, maxWidth: maxWidth); // 布局文本，给定最大宽度

    return textPainter.size.width; // 返回计算出的宽度
  }
}

/// 底部面板歌手 chip 的展示数据。
class _ArtistChipData {
  const _ArtistChipData({
    required this.name,
    required this.id,
  });

  final String name;
  final String id;
}
