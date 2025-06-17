import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/pages/home/view/lyric_view.dart';
import 'package:bujuan/pages/talk/comment_page_view.dart';
import 'package:bujuan/widget/keep_alive.dart';
import 'package:bujuan/widget/my_get_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../../common/constants/appConstants.dart';
import '../../../widget/music_visualizer.dart';

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
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // 内容
                  PageView(
                    controller: controller.panelPageController,
                    children: [
                      // 播放列表
                      _buildCurPlayingListPage(context),
                      _buildCurPlayingPage(context),
                      _buildCommentPage(context, 2),
                      _buildCommentPage(context, 3),
                    ],
                  ),
                  // 页面指示TabBar
                  BlurryContainer(
                      blur: 20,
                      borderRadius: BorderRadius.circular(0),
                      child: SizedBox(
                        height: albumPadding,
                        child: TabBar(
                          controller: controller.panelTabController,
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorWeight: 0,
                          indicator: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(albumPadding),
                          ),
                          tabs: [
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
                                      color: Colors.black.withOpacity(0.2),
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
    // WidgetsBinding.instance.addPostFrameCallback((_) => controller.animatePlayListToCurPlayIndex());
    return KeepAliveWrapper(
      child: Obx(() => Container(
        key: ValueKey(controller.curPlayList),
        padding: EdgeInsets.symmetric(horizontal: context.width * (1 - AppDimensions.albumMaxWidth) / 2),
        child: Column(
          children: [
            Obx(() => Offstage(
              key: ValueKey(!controller.isAlbumVisible.value),
              offstage: !controller.isAlbumVisible.value,
              child: Container(
                height: panelAppBarHeight + context.width,
              ),
            )),
            Expanded(
              child: ListView.builder(
                controller: controller.playListScrollController,
                itemExtent: 110.w,
                padding: EdgeInsets.only(top: controller.isAlbumVisible.value
                    ? 0
                    : panelAppBarHeight
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
            Obx(() => IconButton(
                onPressed: () => controller.curMediaItem.value.id == mediaItem.id ? null : controller.audioServeHandler.removeQueueItemAt(index),
                icon: Icon(
                  controller.curMediaItem.value.id == mediaItem.id
                      ? TablerIcons.circle_letter_p
                      : TablerIcons.trash_x,
                  color: controller.bodyColor.value,
                  // size: 42.w,
                )
            ),
            )
          ],
        ),
      ),
    );
  }

  /// 默认页（歌词）
  Widget _buildCurPlayingPage(BuildContext context) {
    return KeepAliveWrapper(
      child: Stack(
        children: [
          // 歌词
          GestureDetector(
            onTap: () => controller.isAlbumVisible.value = !controller.isAlbumVisible.value,
            child: AbsorbPointer(
                absorbing: false,
                child: Obx(() => Offstage(
                    offstage: controller.isAlbumVisible.value,
                    child: const AbsorbPointer(
                      absorbing: true,
                      child: LyricView(),
                    ),
                )),
            ),
          ),
          // 控制、进度条、页面指示
          Column(
            children: [
              // Album让位
              Container(
                height: AppDimensions.appBarHeight + context.width + context.mediaQueryPadding.top,
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 2,
                      child: BlurryContainer(
                        blur: 20,
                        padding: const EdgeInsets.all(0),
                        borderRadius: const BorderRadius.all(Radius.circular(0)),
                        child: Column(
                            children: [
                              // 播放进度条
                              Expanded(
                                flex: 1,
                                child: _buildProgressBar(context),
                              ),
                              // 播放控制
                              Expanded(
                                flex: 2,
                                child: _buildPlayController(context),
                              ),
                              // 占位
                              Expanded(
                                flex: 1,
                                child: Container(),
                              ),
                            ]
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
  Widget _buildProgressBar(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 音频可视化背景
        SizedBox(
          height: 50,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Obx(() => ProgressBar(
            progress: controller.curPlayDuration.value,
            buffered: controller.curPlayDuration.value,
            total: controller.curMediaItem.value.duration ?? const Duration(seconds: 10),
            progressBarColor: Colors.transparent,
            baseBarColor: Colors.transparent,
            bufferedBarColor: Colors.transparent,
            thumbColor: controller.bodyColor.value.withOpacity(.38),
            barHeight: 0.w,
            thumbRadius: 10,
            barCapShape: BarCapShape.square,
            timeLabelType: TimeLabelType.remainingTime,
            timeLabelLocation: TimeLabelLocation.none,
            timeLabelTextStyle: TextStyle(color: controller.bodyColor.value, fontSize: 20.sp),
            onSeek: (duration) => controller.audioServeHandler.seek(duration),
          )),
        )
      ],
    );
  }
  Widget _buildPlayController(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                if (controller.intervalClick(1)) {
                  controller.audioServeHandler.skipToPrevious();
                }
              },
              icon: Icon(
                TablerIcons.player_skip_back,
                size: 30,
                color: controller.bodyColor.value,
              )
          ),
          // 播放按钮
          GestureDetector(
            onTap: () => controller.playOrPause(),
            child: Obx(() => Icon(
              controller.isPlaying.value ? TablerIcons.player_pause : TablerIcons.player_play,
              size: 60,
              color: controller.bodyColor.value,
            ),),
          ),
          // 下一首
          IconButton(
              onPressed: () {
                if (controller.intervalClick(1)) {
                  controller.audioServeHandler.skipToNext();
                }
              },
              icon: Obx(() => Icon(
                TablerIcons.player_skip_forward,
                size: 30,
                color: controller.bodyColor.value,
              ))),
          // 循环模式
          IconButton(
              onPressed: () {
                if (controller.isFmMode.value) {
                  return;
                }
                controller.changeRepeatMode();
              },
              icon: Obx(() => Icon(
                controller.getRepeatIcon(),
                size: 43.w,
                color: controller.bodyColor.value,
              ))),
        ],
      ),
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
}