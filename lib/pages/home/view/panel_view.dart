
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/pages/home/view/lyric_view.dart';
import 'package:bujuan/pages/talk/comment_page_view.dart';
import 'package:bujuan/widget/keep_alive.dart';
import 'package:bujuan/widget/my_get_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../../common/constants/appConstants.dart';
import '../../../widget/music_visualizer.dart';
import '../../../widget/simple_extended_image.dart';
import '../../../widget/swipeable.dart';

class PanelView extends GetView<HomePageController> {
  const PanelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double albumPadding = context.width * (1 - AppDimensions.albumMaxWidth) / 2;
    return MyGetView(
        child: Stack(
          children: [
              // 背景层
              Obx(() => BlurryContainer(
                  blur: 20,
                  // 去除默认padding
                  padding: const EdgeInsets.all(0),
                  borderRadius: BorderRadius.all(Radius.circular(controller.panelOpened50.value ? 0 : 42.5)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            controller.isGradientBackground.value
                                ? controller.albumColors.value.lightMutedColor?.color.withOpacity(controller.panelOpened50.value ? 1 : 0)
                                  ?? controller.albumColors.value.lightVibrantColor?.color.withOpacity(controller.panelOpened50.value ? 1 : 0)
                                  ?? Colors.transparent
                                : controller.albumColors.value.darkMutedColor?.color.withOpacity(controller.panelOpened50.value ? 1 : 0)
                                  ?? controller.albumColors.value.darkVibrantColor?.color.withOpacity(controller.panelOpened50.value ? 1 : 0)
                                  ?? Colors.transparent,
                            controller.albumColors.value.darkMutedColor?.color
                                ?? controller.albumColors.value.darkVibrantColor?.color
                                ?? controller.albumColors.value.lightVibrantColor?.color
                                ?? Colors.transparent,
                          ],
                        )
                    ),
                  ),
                )),
              // 内容
              Column(
                children: [
                  // panel关闭后占位，避免panel中的内容在header中显示
                  Obx(() => Offstage(
                    offstage: controller.panelFullyClosed.isFalse,
                    child: Container(
                      height: AppDimensions.appBarHeight + context.mediaQueryPadding.top,
                    ),
                  )),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView(
                          controller: controller.panelPageController,
                          children: [
                            _buildCurPlayingListPage(context),
                            _buildCurPlayingPage(context),
                            _buildCommentPage(context, 2),
                            _buildCommentPage(context, 3),
                          ],
                        ),
                        // 页面指示TabBar
                        Obx(() => BlurryContainer(
                          blur: (controller.curPanelPageIndex.value == 1) ? 0 : 20,
                          padding: EdgeInsets.symmetric(horizontal: albumPadding),
                          borderRadius: BorderRadius.circular(0),
                            child: SizedBox(
                              height: albumPadding,
                              child: TabBar(
                                controller: controller.panelTabController,
                                dividerColor: Colors.transparent,
                                indicatorSize: TabBarIndicatorSize.tab,
                                indicatorWeight: 0,
                                indicator: BoxDecoration(
                                  color: controller.bodyColor.value.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(albumPadding),
                                ),
                                tabs: [
                                  // TODO YU4422 进入播放列表页面的时候显示当前播放歌单名
                                  const Text("播放列表"),
                                  const Text("正在播放"),
                                  Obx(() => AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      //执行缩放动画
                                      return ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child));
                                    },
                                    child: Visibility(
                                      key: ValueKey(controller.curPanelPageIndex.value > 1),
                                      visible: controller.curPanelPageIndex.value > 1,
                                      replacement: const Text("歌曲评论"),
                                      child: SizedBox(
                                        height: albumPadding,
                                        child: TabBar(
                                          controller: controller.panelCommentTabController,
                                          dividerColor: Colors.transparent,
                                          indicatorColor: Colors.red,
                                          indicatorWeight: 0,
                                          indicatorSize: TabBarIndicatorSize.tab,
                                          indicator: BoxDecoration(
                                            color: controller.bodyColor.value.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(albumPadding),
                                          ),
                                          tabs: const [
                                            Text("热"),
                                            Text("新"),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          )),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  /// 播放列表页
  Widget _buildCurPlayingListPage(BuildContext context) {
    double panelAppBarHeight = AppDimensions.appBarHeight + context.mediaQueryPadding.top;
    return KeepAliveWrapper(
      child: Obx(() => Container(
        key: ValueKey(controller.curPlayList),
        padding: EdgeInsets.symmetric(horizontal: context.width * (1 - AppDimensions.albumMaxWidth) / 2),
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
              child: ListView.builder(
                controller: controller.playListScrollController,
                itemExtent: 110.w,
                padding: EdgeInsets.only(
                  top: controller.isAlbumVisible.value
                      ? 0
                      : panelAppBarHeight,
                  bottom: context.width * (1 - AppDimensions.albumMaxWidth) / 2,
                ),
                itemCount: controller.curPlayList.length,
                itemBuilder: (context, index) {
                  return _buildCurPlayingListItem(controller.curPlayList[index], index, context);
                },
              ),
            ),
          ],
        ),
      )),
    );
  }
  Widget _buildCurPlayingListItem(MediaItem mediaItem, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => controller.audioServeHandler.playIndex(index),
      // 透明 Container 用于触发点击
      child: Container(
        color: Colors.transparent,
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
                          color: (controller.curPlayIndex.value == index) ? Colors.red : controller.bodyColor.value,
                      ),
                    )),
                    Obx(() => Text(
                      mediaItem.artist ?? '',
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 24.sp,
                          color: (controller.curPlayIndex.value == index) ? Colors.red : controller.bodyColor.value,
                      ),
                    ))
                  ],
                )
            ),
            // TODO YU4422 删除歌曲功能，是否保留待定
            // Obx(() => IconButton(
            //     onPressed: () => controller.curMediaItem.value.id == mediaItem.id ? null : controller.audioServeHandler.removeQueueItemAt(index),
            //     icon: Icon(
            //       controller.curMediaItem.value.id == mediaItem.id
            //           ? TablerIcons.circle_letter_p
            //           : TablerIcons.trash_x,
            //       color: controller.curMediaItem.value.id == mediaItem.id ? Colors.red : controller.bodyColor.value,
            //       // size: 42.w,
            //     )
            // )),
            Obx(() => Offstage(
              offstage: controller.curMediaItem.value.id != mediaItem.id,
              child: const Icon(
                    TablerIcons.circle_letter_p,
                    color: Colors.red,
                    // size: 42.w,
                  )
            )),
          ],
        ),
      ),
    );
  }

  /// 默认页（歌词）
  Widget _buildCurPlayingPage(BuildContext context) {
    double albumPadding = context.width * (1 - AppDimensions.albumMaxWidth) / 2;
    double remainWidth = context.width - albumPadding * 2;
    double textWidth = measureTextWidth("歌手：", TextStyle(color: controller.bodyColor.value)) + albumPadding / 4;
    return KeepAliveWrapper(
      child: Stack(
        children: [
          // 歌词
          GestureDetector(
            onTap: () => controller.isAlbumVisible.value = !controller.isAlbumVisible.value,
            child: AbsorbPointer(
                absorbing: true,
                child: Obx(() => Offstage(
                    offstage: controller.isAlbumVisible.value,
                    child: const LyricView(),
                )),
            ),
          ),
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
                                  color: controller.bodyColor.value.withOpacity(0.05),
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
                                            color: controller.bodyColor.value,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: controller.bodyColor.value.withOpacity(0.05),
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
                                                color: controller.bodyColor.value
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
                                  color: controller.bodyColor.value.withOpacity(0.05),
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
                                              color: controller.bodyColor.value,
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
                                                    color: controller.bodyColor.value.withOpacity(0.05),
                                                    borderRadius: BorderRadius.circular(albumPadding),
                                                  ),
                                                  child: Obx(() => Text(
                                                    artist,
                                                    style: TextStyle(
                                                        color: controller.bodyColor.value
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
                child: Obx(() => BlurryContainer(
                    blur: controller.isAlbumVisible.isTrue ? 0 : 20,
                    padding: EdgeInsets.symmetric(horizontal: albumPadding),
                    borderRadius: const BorderRadius.all(Radius.circular(0)),
                    child: Column(
                        children: [
                          // 播放控制
                          Expanded(child: _buildPlayController(context)),
                          // tabBar占位
                          Container(height: albumPadding),
                        ]
                    ),
                  ),
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
              controller.bodyColor.value.withAlpha(50),
              controller.bodyColor.value.withAlpha(80),
              controller.bodyColor.value.withAlpha(110),
              controller.bodyColor.value.withAlpha(140)
            ],
          )),
        ),
        Obx(() => ProgressBar(
          progress: controller.curPlayDuration.value,
          buffered: controller.curPlayDuration.value,
          total: controller.curMediaItem.value.duration ?? const Duration(seconds: 10),
          progressBarColor: controller.bodyColor.value.withOpacity(.1),
          baseBarColor: controller.bodyColor.value.withOpacity(.05),
          bufferedBarColor: Colors.transparent,
          thumbColor: controller.bodyColor.value.withOpacity(.05),
          barHeight: albumPadding,
          thumbRadius: 0,
          thumbGlowRadius: 0,
          thumbCanPaintOutsideBar: false,
          barCapShape: BarCapShape.round,
          timeLabelLocation: TimeLabelLocation.below,
          timeLabelPadding: 0,
          timeLabelTextStyle: TextStyle(fontSize: 0.sp),
          // onSeek: (duration) => controller.audioServeHandler.seek(duration),
          onDragUpdate: (duration) => controller.audioServeHandler.seek(duration.timeStamp),
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
            onPressed: () => controller.likeSong(),
            icon: Obx(() => Icon(
                controller.likeIds.contains(int.tryParse(controller.curMediaItem.value.id))
                    ? Icons.favorite
                    : Icons.favorite_border,
                size: 46.w,
                color: controller.likeIds.contains(int.tryParse(controller.curMediaItem.value.id))
                    ? Colors.red
                    : controller.bodyColor.value
            ))
        ),
        // 上一首
        IconButton(
            onPressed: () {
              if (controller.isFmMode.value) {
                return;
              }
              if (controller.intervalClick(500)) {
                controller.audioServeHandler.skipToPrevious();
              }
            },
            icon: Obx(() => Icon(
                TablerIcons.player_skip_back_filled,
                size: 30,
                color: controller.bodyColor.value,
              ),
            )
        ),
        // 播放按钮
        IconButton(
          onPressed: () => controller.playOrPause(),
          icon: Obx(() => Icon(
            controller.isPlaying.value ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
            size: 60,
            color: controller.bodyColor.value,
          )),
        ),
        // 下一首
        IconButton(
            onPressed: () {
              if (controller.intervalClick(500)) {
                controller.audioServeHandler.skipToNext();
              }
            },
            icon: Obx(() => Icon(
              TablerIcons.player_skip_forward_filled,
              size: 30,
              color: controller.bodyColor.value,
            ))
        ),
        // 循环模式
        IconButton(
            onPressed: () async {
              if (controller.isFmMode.value) {
                return;
              }
              await controller.changeRepeatMode();
            },
            icon: Obx(() => Icon(
              key: ValueKey(controller.isFmMode.value),
              controller.getRepeatIcon(),
              size: 43.w,
              color: controller.bodyColor.value,
            ))
        ),
      ],
    );
  }
  
  /// 评论页
  Widget _buildCommentPage(BuildContext context, int commentType) {
    double panelAppBarHeight = AppDimensions.appBarHeight + context.mediaQueryPadding.top;
    return KeepAliveWrapper(
      child: Column(
        children: [
          Obx(() => Offstage(
            offstage: !controller.isAlbumVisible.value,
            child: Container(
              height: context.width + panelAppBarHeight,
            ),
          )),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: context.width * (1 - AppDimensions.albumMaxWidth) / 2),
              child: Obx(() => ListWidget(
                key: ValueKey(controller.curMediaItem.value.id),
                id: controller.curMediaItem.value.id,
                idType: "song",
                commentType: commentType,
                listPaddingTop: controller.isAlbumVisible.value ? 0 : panelAppBarHeight,
                context: context,
              ),),
            ),
          ),
        ],
      ),
    );
  }

  double measureTextWidth(String text, TextStyle style, {double maxWidth = double.infinity, int? maxLines}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr, // 必须设置文本方向
      maxLines: maxLines, // 可选：如果文本有行数限制
    )..layout(minWidth: 0, maxWidth: maxWidth); // 布局文本，给定最大宽度

    return textPainter.size.width; // 返回计算出的宽度
  }
}

class PanelHeaderView extends GetView<HomePageController> {
  const PanelHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildHeader(context);
  }

  /// 底部播放状态栏
  Widget _buildHeader(BuildContext context) {
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
              onSwipeLeft: () => controller.audioServeHandler.skipToPrevious(),
              onSwipeRight: () => controller.audioServeHandler.skipToNext(),
              child: Container(
                height: AppDimensions.bottomPanelHeaderHeight,
                alignment: Alignment.centerLeft,
                child: Obx(() => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${HomePageController.to.curMediaItem.value.title}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 42.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      '${HomePageController.to.curMediaItem.value.artist ?? ''}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 21.sp,
                          color: Colors.black.withOpacity(0.5)
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
                  color: Theme.of(context).cardColor.withOpacity(.7),
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
    double albumWidth = AppDimensions.albumMinWidth + (panelAlbumMaxWidth - AppDimensions.albumMinWidth) * controller.panelAnimationController.value;
    double albumPadding = AppDimensions.panelHeaderPadding +  (maxMarginLeft - AppDimensions.panelHeaderPadding) * controller.panelAnimationController.value;
    double appBarPadding = (context.mediaQueryPadding.top + AppDimensions.appBarHeight) * controller.panelAnimationController.value;
    double albumBorderRadius = AppDimensions.albumMinWidth * (1 - controller.panelAnimationController.value);

    return Obx(() => IgnorePointer(
      ignoring: !controller.isAlbumVisible.value || controller.panelFullyClosed.value,
      child: Container(
        margin: EdgeInsets.only(top: appBarPadding),
        width: albumWidth + albumPadding * 2,
        height: albumWidth + albumPadding * 2,
        child: OverflowBox(
          maxWidth: (albumWidth + albumPadding * 2) * 3,
          child: Obx(() => PageView.builder(
            // key: ValueKey<List>(controller.curPlayList),
            controller: controller.albumPageController,
            itemCount: controller.curPlayList.length,
            physics: controller.panelFullyClosed.value ? NeverScrollableScrollPhysics() : PageScrollPhysics(),
            onPageChanged: (index) async {
              if (index != controller.curPlayIndex.value) {
                index > controller.curPlayIndex.value
                    ? await controller.audioServeHandler.skipToNext()
                    : await controller.audioServeHandler.skipToPrevious();
              }
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
                  visible: controller.isAlbumVisible.value
                      ? controller.panelFullyOpened.value
                      ? true
                      : index == controller.curPlayIndex.value
                      : controller.panelFullyClosed.value && index == controller.curPlayIndex.value,
                  child: Container(
                    margin: EdgeInsets.all(albumPadding),
                    child: GestureDetector(
                      onTap: () {
                        controller.isAlbumVisible.value = !controller.isAlbumVisible.value;
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(albumBorderRadius),
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
          ),
          ),
        ),
      ),
    ),
    );
  }

}