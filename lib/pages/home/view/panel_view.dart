import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/pages/home/home_page_controller.dart';
import 'package:bujuan/pages/home/view/z_comment_view.dart';
import 'package:bujuan/pages/home/view/z_lyric_view.dart';
import 'package:bujuan/pages/home/view/z_playlist_view.dart';
import 'package:bujuan/widget/my_get_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../../common/appConstants.dart';
import '../../../widget/music_visualizer.dart';

// 展开后的第一层panel
class PanelView extends GetView<HomePageController> {
  const PanelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyGetView(
        child: _buildDefaultBody(context),
    );
  }

  Widget _buildDefaultBody(BuildContext context) {
    return Stack(
      children: [
        // 背景层
        Obx(() => BlurryContainer(
          blur: 20,
          // 去除默认padding
          padding: const EdgeInsets.all(0),
          borderRadius: controller.panelFullyOpened.value
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
                        ? controller.albumColor.value.lightVibrantColor?.color.withOpacity(controller.panelOpened50.value ? 1 : 0)
                          ?? controller.albumColor.value.lightMutedColor?.color.withOpacity(controller.panelOpened50.value ? 1 : 0)
                          ?? Colors.transparent
                        : controller.albumColor.value.darkVibrantColor?.color.withOpacity(controller.panelOpened50.value ? 1 : 0)
                          ?? controller.albumColor.value.darkMutedColor?.color.withOpacity(controller.panelOpened50.value ? 1 : 0)
                          ?? Colors.transparent,
                    controller.albumColor.value.darkVibrantColor?.color
                        ?? controller.albumColor.value.darkMutedColor?.color
                        ?? controller.albumColor.value.lightVibrantColor?.color
                        ?? Colors.transparent,
                  ],
                )
            ),
          ),
        )),
        DefaultTabController(
          length: 3,
          child: Stack(
            children: [
              TabBarView(
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
                      Expanded(
                          child: ZPlayListView(),
                      ),
                    ],
                  ),
                  // 歌词 & 控制组件
                  _buildBodyContent(context),
                  // 评论
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: CommentView(),
                  )
                ],
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: const TabBar(
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
        ),
      ],
    );
  }

  /// 默认页（歌词）
  Widget _buildBodyContent(BuildContext context) {
    return Stack(
      children: [
        // 歌词
        Obx(() => Offstage(
            offstage: controller.isAlbumVisible.value,
            child: GestureDetector(
              onTap: () {
                controller.isAlbumVisible.value = !controller.isAlbumVisible.value;
              },
              child: const AbsorbPointer(
                absorbing: true,
                child: LyricView()
              ),
            ),
        ),),
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
                    flex: 1,
                    child: BlurryContainer(
                      blur: 20,
                      child: Column(
                          children: [
                            // 播放进度条
                            Expanded(
                              flex: 2,
                              child: _buildProgressBar(context),
                            ),
                            Expanded(
                              flex: 4,
                              child: _buildPlayController(context),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(),
                            ),
                          // 播放控制
                      ]),
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
    return Container(
      // width: 750.w,
      // padding: EdgeInsets.only(left: context.width / 12, right: context.width / 12,),
      child: Stack(
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
                  progress: controller.duration.value,
                  buffered: controller.duration.value,
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
      ),
    );
  }
  Widget _buildPlayController(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () => controller.likeSong(),
              icon: Obx(() => Icon(controller.likeIds.contains(int.tryParse(controller.curMediaItem.value.id)) ? Icons.favorite : Icons.favorite_border,
                  size: 46.w, color: controller.likeIds.contains(int.tryParse(controller.curMediaItem.value.id)) ? Colors.red : controller.bodyColor.value))),
          Obx(() => IconButton(
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
                size: 46.w,
                color: controller.bodyColor.value,
              ))),
          InkWell(
            child: Obx(() => Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 5.h),
              height: 125.w,
              width: 125.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(80.w),
                border: Border.all(color: controller.bodyColor.value.withOpacity(.04), width: 5.w),
                color: controller.bodyColor.value.withOpacity(0.06),
              ),
              child: Icon(
                controller.isPlaying.value ? TablerIcons.player_pause : TablerIcons.player_play,
                size: 54.w,
                color: controller.bodyColor.value,
              ),
            )),
            onTap: () => controller.playOrPause(),
          ),
          IconButton(
              onPressed: () {
                if (controller.intervalClick(1)) {
                  controller.audioServeHandler.skipToNext();
                }
              },
              icon: Obx(() => Icon(
                TablerIcons.player_skip_forward,
                size: 46.w,
                color: controller.bodyColor.value,
              ))),
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
