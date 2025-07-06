
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/pages/home/app_controller.dart';
import 'package:bujuan/pages/home/view/lyric_view.dart';
import 'package:bujuan/pages/talk/comment_widget.dart';
import 'package:bujuan/widget/keep_alive.dart';
import 'package:bujuan/widget/my_get_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;

import '../../../common/constants/appConstants.dart';
import '../../../widget/music_visualizer.dart';
import '../../../widget/simple_extended_image.dart';
import '../../../widget/swipeable.dart';

class PanelView extends GetView<AppController> {
  const PanelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double albumPadding = context.width * (1 - AppDimensions.albumMaxWidth) / 2;
    return MyGetView(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // 背景层
            AnimatedBuilder(
              animation: controller.panelAnimationController,
              builder: (BuildContext context, Widget? child) {
                return Stack(
                  children: [
                    // 磨砂层
                    Obx(() => Offstage(
                      offstage: controller.panelFullyOpened.isTrue,
                      child: BlurryContainer(
                        blur: 20 * (1 - controller.panelAnimationController.value),
                        padding: EdgeInsets.zero,
                        borderRadius: BorderRadius.all(Radius.circular(AppDimensions.phoneCornerRadius)),
                        child: Container(),
                      ),
                    )),
                    // 背景色层
                    Obx(() => Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: controller.albumColor.value.withOpacity(0.5 * (1 + controller.panelAnimationController.value)),
                          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.phoneCornerRadius * (1 - controller.panelAnimationController.value))),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
            // 内容
            Column(
              children: [
                Obx(() => Offstage(
                  offstage: controller.panelFullyClosed.isFalse,
                  child: Container (
                    height: AppDimensions.bottomPanelHeaderHeight,
                  ),
                )),
                Expanded(
                  child: PageView(
                    controller: controller.panelPageController,
                    children: [
                      _buildCurPlayingListPage(context),
                      _buildCurPlayingPage(context),
                      _buildCommentPage(context, 2),
                      _buildCommentPage(context, 3),
                    ],
                  ),
                ),
              ],
            ),
            // appbar背景遮盖
            IgnorePointer(
              child: Obx(() {
                return Offstage(
                  offstage: controller.panelFullyOpened.isFalse,
                  child: Column(
                    children: [
                      Container(
                        color: controller.albumColor.value,
                        height: context.mediaQueryPadding.top + AppDimensions.appBarHeight,
                      ),
                      Container(
                        height: albumPadding,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, // 渐变开始于顶部
                            end: Alignment.bottomCenter, // 渐变结束于底部
                            colors: [
                              controller.albumColor.value,
                              controller.albumColor.value.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                      Expanded(child: Container()),
                      Container(
                        height: albumPadding * 2,
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, // 渐变开始于顶部
                            end: Alignment.bottomCenter, // 渐变结束于底部
                            colors: [
                              controller.albumColor.value.withOpacity(0),
                              controller.albumColor.value,
                              controller.albumColor.value,
                            ],
                            stops: [0,0.5, 1],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            // 页面指示TabBar
            Container(
              padding: EdgeInsets.symmetric(horizontal: albumPadding),
              height: albumPadding,
              child: TabBar(
                padding: EdgeInsets.zero,
                labelPadding: EdgeInsets.zero,
                controller: controller.panelTabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 0,
                indicator: BoxDecoration(
                  color: controller.panelWidgetColor.value.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(albumPadding),
                ),
                tabs: [
                  // TODO YU4422 进入播放列表页面的时候显示当前播放歌单名
                  Text("播放列表", style: context.textTheme.titleMedium?.copyWith(color: controller.panelWidgetColor.value.withOpacity(0.5))),
                  Text("正在播放", style: context.textTheme.titleMedium?.copyWith(color: controller.panelWidgetColor.value.withOpacity(0.5))),
                  Obx(() => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      //执行缩放动画
                      return ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child));
                    },
                    child: Visibility(
                      key: ValueKey(controller.curPanelPageIndex.value > 1),
                      visible: controller.curPanelPageIndex.value > 1,
                      replacement: Text("歌曲评论", style: context.textTheme.titleMedium?.copyWith(color: controller.panelWidgetColor.value.withOpacity(0.5))),
                      child: Container(
                        height: albumPadding,
                        child: TabBar(
                          controller: controller.panelCommentTabController,
                          labelPadding: EdgeInsets.zero,
                          dividerColor: Colors.transparent,
                          indicatorWeight: 0,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: controller.panelWidgetColor.value.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(albumPadding),
                          ),
                          tabs: [
                            Text("热", style: context.textTheme.titleMedium?.copyWith(color: controller.panelWidgetColor.value.withOpacity(0.5))),
                            Text("新", style: context.textTheme.titleMedium?.copyWith(color: controller.panelWidgetColor.value.withOpacity(0.5))),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
    );
  }

  /// 播放列表页
  Widget _buildCurPlayingListPage(BuildContext context) {
    double panelAppBarHeight = AppDimensions.appBarHeight + context.mediaQueryPadding.top;
    double albumPadding = context.width * (1 - AppDimensions.albumMaxWidth) / 2;
    return KeepAliveWrapper(
      child: Obx(() => Container(
        padding: EdgeInsets.symmetric(horizontal: albumPadding),
        child: Column(
          children: [
            Obx(() => Offstage(
              key: ValueKey(controller.isAlbumVisible.isFalse),
              offstage: !controller.isAlbumVisible.value,
              child: Container(
                height: panelAppBarHeight + context.width,
              ),
            )),
            Expanded(
              child: ScrollConfiguration(
                behavior: const NoGlowScrollBehavior(),
                child: ListView.builder(
                  controller: controller.playListScrollController,
                  physics: const ClampingScrollPhysics(),
                  itemExtent: 60,
                  padding: EdgeInsets.only(
                    top: controller.isAlbumVisible.value
                        ? 0
                        : panelAppBarHeight + albumPadding,
                    bottom: albumPadding * 2,
                  ),
                  itemCount: controller.curPlayList.length,
                  itemBuilder: (context, index) {
                    return _buildSongItem(controller.curPlayList[index], index, context);
                  },
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
  Widget _buildSongItem(MediaItem mediaItem, int index, BuildContext context) {
    return TextButton(
      onPressed: () => controller.audioHandler.playIndex(audioSourceIndex: index, playNow: true),
      // 透明 Container 用于触发点击
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() => Text(
                    mediaItem.title,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 30.sp,
                        color: (controller.curPlayIndex.value == index) ? Colors.red : controller.panelWidgetColor.value,
                    ),
                  )),
                  Obx(() => Text(
                    mediaItem.artist ?? '',
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 24.sp,
                        color: (controller.curPlayIndex.value == index) ? Colors.red : controller.panelWidgetColor.value,
                    ),
                  ))
                ],
              )
          ),
          Obx(() => Offstage(
            offstage: controller.curPlayIndex.value != index,
            child: const Icon(
                  TablerIcons.circle_letter_p,
                  color: Colors.red,
                  // size: 42.w,
                )
          )),
        ],
      ),
    );
  }

  /// 默认页（歌词）
  Widget _buildCurPlayingPage(BuildContext context) {
    double albumPadding = context.width * (1 - AppDimensions.albumMaxWidth) / 2;
    double remainWidth = context.width - albumPadding * 2;
    double textWidth = _measureTextWidth("歌手：", TextStyle(color: controller.panelWidgetColor.value)) + albumPadding / 4;
    return KeepAliveWrapper(
      child: Stack(
        children: [
          // 歌词
          Obx(() => Offstage(
              offstage: controller.isAlbumVisible.value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: albumPadding),
                child: const LyricView(EdgeInsets.symmetric(vertical: 10)),
              ),
          )),
          // 控制、进度条、页面指示占位
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 专辑封面占位
              Container(height: context.width + AppDimensions.appBarHeight + context.mediaQueryPadding.top),
              Obx(() => Visibility(
                // replacement: Container(
                //   height: albumPadding * 5,
                // ),
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: controller.isAlbumVisible.value,
                  child: Container(
                    width: context.width,
                    padding: EdgeInsets.symmetric(horizontal: albumPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 专辑
                        Container(
                          width: remainWidth,
                          height: albumPadding,
                          // alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: controller.panelWidgetColor.value.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(albumPadding),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 这里测量的宽度不准确，强制将text适配到测量的宽度
                                    Container(
                                      width: textWidth,
                                      padding: EdgeInsets.only(left: albumPadding / 4),
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                          "专辑：",
                                          style: TextStyle(
                                            color: controller.panelWidgetColor.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: controller.panelWidgetColor.value.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(albumPadding),
                                      ),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: remainWidth - textWidth,
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: albumPadding / 4),
                                          child: Obx(() => Text(
                                            controller.curMediaItem.value.album ?? "",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: controller.panelWidgetColor.value
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                        ),
                                      ),
                                    ),
                                    // Expanded(child: Container())
                                  ],
                                ),
                              ),
                              Expanded(child: Container())
                            ],
                          )
                        ),
                        // 歌手
                        Container(
                          width: remainWidth,
                          height: albumPadding,
                          margin: EdgeInsets.symmetric(vertical: albumPadding),
                          child: Row(
                            children: [
                              Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: controller.panelWidgetColor.value.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(albumPadding),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 这里测量的宽度不准确，强制将text适配到测量的宽度
                                    Container(
                                      width: textWidth,
                                      padding: EdgeInsets.only(left: albumPadding / 4),
                                      child: FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child: Text(
                                          "歌手：",
                                          style: TextStyle(
                                              color: controller.panelWidgetColor.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: remainWidth - textWidth,
                                      ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal, // 允许水平滚动
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              for(String artist in controller.curMediaItem.value.artist?.split("/") ?? <String>[])
                                                Container(
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.symmetric(horizontal: albumPadding / 4),
                                                  decoration: BoxDecoration(
                                                    color: controller.panelWidgetColor.value.withOpacity(0.05),
                                                    borderRadius: BorderRadius.circular(albumPadding),
                                                  ),
                                                  child: Obx(() => Text(
                                                    artist,
                                                    style: TextStyle(
                                                        color: controller.panelWidgetColor.value
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  )),
                                              ),
                                            ]
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(child: Container())
                            ],
                          ),
                        ),
                        // 播放进度条
                        _buildProgressBar(context),
                      ]
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                    children: [
                      // 播放控制
                      Expanded(child: _buildPlayController(context)),
                      // tabBar占位
                      Container(height: albumPadding),
                    ]
                ),
              )
            ],
          )
        ],
      ),
    );
  }
  Widget _buildProgressBar(BuildContext context) {
    double albumPadding = context.width * (1 - AppDimensions.albumMaxWidth) / 2;
    return Stack(
      alignment: Alignment.center,
      children: [
        // 音频可视化背景
        SizedBox(
          height: albumPadding,
          child: Obx(() => MusicVisualizer(
            key: ValueKey<int>(controller.curPlayIndex.value),
            barCount: 35,
            colors: [
              controller.panelWidgetColor.value.withAlpha(50),
              controller.panelWidgetColor.value.withAlpha(80),
              controller.panelWidgetColor.value.withAlpha(110),
              controller.panelWidgetColor.value.withAlpha(140)
            ],
          )),
        ),
        Obx(() => ProgressBar(
          progress: controller.curPlayDuration.value,
          buffered: controller.curPlayDuration.value,
          total: controller.curMediaItem.value.duration ?? const Duration(seconds: 10),
          progressBarColor: controller.panelWidgetColor.value.withOpacity(.1),
          baseBarColor: controller.panelWidgetColor.value.withOpacity(.05),
          bufferedBarColor: Colors.transparent,
          thumbColor: controller.panelWidgetColor.value.withOpacity(.05),
          barHeight: albumPadding,
          thumbRadius: 0,
          thumbGlowRadius: 0,
          thumbCanPaintOutsideBar: false,
          barCapShape: BarCapShape.round,
          timeLabelLocation: TimeLabelLocation.below,
          timeLabelPadding: 0,
          timeLabelTextStyle: TextStyle(fontSize: 0.sp),
          onSeek: (duration) => controller.audioHandler.seek(duration),
        ))
      ],
    );
  }
  Widget _buildPlayController(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // 喜欢按钮
        IconButton(
            color: Colors.black,
            onPressed: () => controller.toggleLikeStatus(),
            icon: Obx(() => Icon(
                controller.likeIds.contains(int.tryParse(controller.curMediaItem.value.id))
                    ? TablerIcons.heart_filled
                    : TablerIcons.heart,
                size: 46.w,
                color: controller.likeIds.contains(int.tryParse(controller.curMediaItem.value.id))
                    ? Colors.red
                    : controller.panelWidgetColor.value
            ))
        ),
        // 上一首
        IconButton(
            onPressed: () {
              if (controller.isFmMode.value) {
                return;
              }
              controller.audioHandler.skipToPrevious();
            },
            icon: Obx(() => Icon(
              TablerIcons.player_skip_back_filled,
              size: 30,
              color: controller.panelWidgetColor.value,
            ),
            )
        ),
        // 播放按钮
        IconButton(
          onPressed: () => controller.playOrPause(),
          icon: Obx(() => Icon(
            controller.isPlaying.value ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
            size: 60,
            color: controller.panelWidgetColor.value,
          )),
        ),
        // 下一首
        IconButton(
            onPressed: () {
              controller.audioHandler.skipToNext();
            },
            icon: Obx(() => Icon(
              TablerIcons.player_skip_forward_filled,
              size: 30,
              color: controller.panelWidgetColor.value,
            ))
        ),
        // 循环模式
        IconButton(
            onPressed: () async {
              if (controller.isFmMode.value) {
                return;
              }
              await controller.audioHandler.changeRepeatMode();
            },
            icon: Obx(() => Icon(
              key: ValueKey(controller.isFmMode.value),
              controller.getRepeatIcon(),
              size: 43.w,
              color: controller.panelWidgetColor.value,
            ))
        ),
      ],
    );
  }
  
  /// 评论页
  Widget _buildCommentPage(BuildContext context, int commentType) {
    double panelAppBarHeight = AppDimensions.appBarHeight + context.mediaQueryPadding.top;
    double albumPadding = context.width * (1 - AppDimensions.albumMaxWidth) / 2;

    return KeepAliveWrapper(
      child: Column(
        children: [
          Obx(() => Container(
            height: controller.isAlbumVisible.value ? context.width + panelAppBarHeight - albumPadding: panelAppBarHeight,
          )),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: albumPadding),
              child: Obx(() => CommentWidget(
                key: ValueKey(controller.curMediaItem.value.id),
                context: context,
                id: controller.curMediaItem.value.id,
                idType: "song",
                commentType: commentType,
                listPaddingTop: albumPadding,
                listPaddingBottom: albumPadding,
              ),),
            ),
          ),
        ],
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

class PanelHeaderView extends GetView<AppController> {
  const PanelHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.panelAnimationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => {
            if (controller.panelFullyClosed.value) {
              controller.panelController.open()
            }
          },
          child: SizedBox(
            width: context.width,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                _buildAlbum(context),
                _buildMediaTitle(context),
              ],
            ),
          ),
        );
      },
    );
  }
  /// 播放状态栏——歌曲标题和播放按钮
  Widget _buildMediaTitle(BuildContext context) {
    return Obx(() => Visibility(
      visible: controller.panelFullyClosed.value,
      child: Row(
        children: [
          Container(
            width: AppDimensions.bottomPanelHeaderHeight,
          ),
          Expanded(
            child: Swipeable(
              background: const SizedBox.shrink(),
              onSwipeLeft: () => controller.audioHandler.skipToPrevious(),
              onSwipeRight: () => controller.audioHandler.skipToNext(),
              child: Container(
                height: AppDimensions.bottomPanelHeaderHeight,
                alignment: Alignment.centerLeft,
                child: Obx(() => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppController.to.curMediaItem.value.title}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 42.sp,
                          color: controller.panelWidgetColor.value,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      '${AppController.to.curMediaItem.value.artist ?? ''}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 21.sp,
                          color: controller.panelWidgetColor.value.withOpacity(0.5),
                      ),
                    ),
                  ],
                )
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: AppDimensions.bottomPanelHeaderHeight,
            height: AppDimensions.bottomPanelHeaderHeight,
            child: IconButton(
                onPressed: () => controller.playOrPause(),
                icon: Obx(() => Icon(
                  controller.isPlaying.value ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
                  color: controller.panelWidgetColor.value,
                  size: 65.sp,
                ))),
          ),
        ],
      ),
    ),
    );
  }
  /// 播放状态栏——专辑图片
  Widget _buildAlbum(BuildContext context) {
    /// 完全展开宽度
    double panelAlbumMaxWidth = context.width * AppDimensions.albumMaxWidth;
    /// 完全展开LeftMargin
    double maxMarginLeft = (context.width - panelAlbumMaxWidth) / 2;

    // 实时Album宽度、margin
    double realTimeAlbumWidth = AppDimensions.albumMinWidth + (panelAlbumMaxWidth - AppDimensions.albumMinWidth) * controller.panelAnimationController.value;
    double realTimeAlbumPadding = AppDimensions.albumPadding +  (maxMarginLeft - AppDimensions.albumPadding) * controller.panelAnimationController.value;
    double realTimeAppBarPadding = (context.mediaQueryPadding.top + AppDimensions.appBarHeight) * controller.panelAnimationController.value;
    double realTimeAlbumBorderRadius = AppDimensions.albumMinWidth * (1 - controller.panelAnimationController.value);

    return Obx(() => IgnorePointer(
      ignoring: !controller.isAlbumVisible.value || controller.panelFullyClosed.value,
      child: Container(
        margin: EdgeInsets.only(top: realTimeAppBarPadding),
        width: realTimeAlbumWidth + realTimeAlbumPadding * 2,
        height: realTimeAlbumWidth + realTimeAlbumPadding * 2,
        child: OverflowBox(
          maxWidth: (realTimeAlbumWidth + realTimeAlbumPadding * 2) * 3,
          child: NotificationListener<ScrollNotification>(
            // 监听滚动状态
            onNotification: (notification) {
              // 判断滚动是否是用户手势触发
              if (notification is ScrollStartNotification) {
                if (notification.dragDetails != null && !controller.isAlbumScrollingProgrammatic) {
                  controller.isAlbumScrollingManully = true;
                }
                // 滚动结束时重置用户滚动状态 (这里只是一个辅助，主要靠计时器)
              } else if (notification is ScrollEndNotification) {
                controller.isAlbumScrollingManully = false;
              }
              // 返回 false 让通知继续冒泡，以便 itemPositionsNotifier 也能收到
              return false;
            },
            child: Obx(() => PageView.builder(
              controller: controller.albumPageController,
              itemCount: controller.curPlayList.length,
              physics: controller.panelFullyClosed.value ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
              onPageChanged: (index) {
                DateTime now = DateTime.now();
                print('统计开始: $now');
                if (controller.isAlbumScrollingManully) {
                  Future.microtask(() async {
                    await controller.audioHandler.playIndex(audioSourceIndex: index, playNow: true);
                  });
                }
                now = DateTime.now();
                print('统计结束: $now');
              },
              itemBuilder: (BuildContext context, int index) {
                return Obx(() => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Visibility(
                    visible: controller.isAlbumVisible.isTrue
                        ? controller.panelFullyOpened.isTrue
                          ? true
                          : index == controller.curPlayIndex.value
                        : controller.panelFullyClosed.value && index == controller.curPlayIndex.value,
                    child: Container(
                      margin: EdgeInsets.all(realTimeAlbumPadding),
                      child: GestureDetector(
                        onTap: () {
                          controller.isAlbumVisible.value = !controller.isAlbumVisible.value;
                        },
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(realTimeAlbumBorderRadius),
                            boxShadow: [
                              controller.panelFullyOpened.value
                                  ? BoxShadow(
                                    color: Colors.black.withOpacity(0.4), // 阴影颜色
                                    blurRadius: 12, // 模糊半径
                                    spreadRadius: 2, // 扩散半径
                                  )
                                  : const BoxShadow()
                            ],
                          ),
                          child: Obx(() => SimpleExtendedImage(
                            '${controller.curPlayList[index].extras?['image'] ?? ''}?param=500y500',
                          )),
                        ),
                      ),
                    ),
                  ),
                ),
                );
              },
            )),
          ),
        ),
      ),
    ));
  }
}

// 定义一个自定义的 ScrollBehavior 来移除 OverscrollIndicator
class NoGlowScrollBehavior extends ScrollBehavior {
  const NoGlowScrollBehavior(); // 添加 const 构造函数

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    // 返回子 Widget，不添加任何发光指示器
    return child;
  }
}