import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/pages/home/view/lyric_view.dart';
import 'package:bujuan/pages/home/view/playlist_view.dart';
import 'package:bujuan/pages/talk/talk_view.dart';
import 'package:bujuan/widget/my_get_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../../common/appConstants.dart';
import '../../../widget/music_visualizer.dart';

class PanelView extends GetView<HomePageController> {
  const PanelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyGetView(
        child: Stack(
          children: [
            // 背景层
            Obx(() => BlurryContainer(
              blur: 20,
              // 去除默认padding
              padding: const EdgeInsets.all(0),
              borderRadius: controller.panelOpened50.value
                  ? BorderRadius.all(Radius.circular(0))
                  : BorderRadius.all(Radius.circular(42.5)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        controller.isGradientBackground.value
                            ? controller.albumColors.value.lightVibrantColor?.color.withOpacity(controller.panelOpened50.value ? 1 : 0)
                            ?? controller.albumColors.value.lightMutedColor?.color.withOpacity(controller.panelOpened50.value ? 1 : 0)
                            ?? Colors.transparent
                            : controller.albumColors.value.darkVibrantColor?.color.withOpacity(controller.panelOpened50.value ? 1 : 0)
                            ?? controller.albumColors.value.darkMutedColor?.color.withOpacity(controller.panelOpened50.value ? 1 : 0)
                            ?? Colors.transparent,
                        controller.albumColors.value.darkVibrantColor?.color
                            ?? controller.albumColors.value.darkMutedColor?.color
                            ?? controller.albumColors.value.lightVibrantColor?.color
                            ?? Colors.transparent,
                      ],
                    )
                ),
              ),
            )),
            Stack(
              children: [
                TabBarView(
                  controller: controller.panelTabController,
                  children: [
                    // 播放列表
                    Column(
                      children: [
                        Container(
                          height: AppDimensions.appBarHeight + context.mediaQueryPadding.top,
                        ),
                        Obx(() => Offstage(
                          offstage: !controller.isAlbumVisible.value,
                          child: Container(
                            height: context.width,
                          ),
                        ),
                        ),
                        const Expanded(
                          child: PlayListView(),
                        ),
                      ],
                    ),
                    // 歌词 & 控制组件
                    _buildBodyContent(context),
                    // 评论
                    Column(
                      children: [
                        Container(
                          height: AppDimensions.appBarHeight + context.mediaQueryPadding.top,
                        ),
                        Obx(() => Offstage(
                          offstage: !controller.isAlbumVisible.value,
                          child: Container(
                            height: context.width,
                          ),
                        ),
                        ),
                        Expanded(
                          child: Obx(() => TalkView(
                            key: ValueKey(controller.curMediaItem.value.id),
                            id: controller.curMediaItem.value.id,
                            type: "song",
                          )),
                        ),
                      ],
                    ),

                  ],
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: TabBar(
                    controller: controller.panelTabController,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Text("列表"),
                      Text("歌词"),
                      Text("评论"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  /// 默认页（歌词）
  Widget _buildBodyContent(BuildContext context) {
    return Stack(
      children: [
      // 歌词
      GestureDetector(
        onTap: () => controller.isAlbumVisible.value = !controller.isAlbumVisible.value,
        child: AbsorbPointer(
          absorbing: false,
          child: Obx(() => Visibility(
              visible: controller.isAlbumVisible.isFalse,
              child: const LyricView()
            ),
          )
        ),
      ),
      // 控制
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
                    borderRadius: BorderRadius.all(Radius.circular(0)),
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
          padding: EdgeInsets.symmetric(horizontal: 10),
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
}
