
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/common_widget.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/pages/home/bottom_panel/lyric_view.dart';
import 'package:bujuan/pages/talk/comment_widget.dart';
import 'package:bujuan/widget/keep_alive_wrapper.dart';
import 'package:bujuan/widget/my_tab_bar.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

import '../../../common/constants/appConstants.dart';
import '../../../common/netease_api/src/api/play/bean.dart';
import '../../../widget/simple_extended_image.dart';
import '../../../widget/swipeable.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;

import '../../play_list/playlist_page_view.dart';


class BottomPanelView extends GetView<AppController> {
  const BottomPanelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double albumPadding = AppDimensions.paddingLarge;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 背景层
        AnimatedBuilder(
          animation: controller.bottomPanelAnimationController,
          builder: (BuildContext context, Widget? child) {
            double panelOpenDegree = controller.bottomPanelAnimationController.value;
            return Obx(() => BlurryContainer(
              blur: 20 * panelOpenDegree,
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.phoneCornerRadius * (1 - panelOpenDegree))),
              color: controller.albumColor.value.withOpacity(panelOpenDegree),
              child: Container(),
            ));
          },
        ),
        // 内容
        Column(
          children: [
            // 歌名&歌手
            Container (
                margin: EdgeInsets.only(top: context.mediaQueryPadding.top),
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
                height: AppDimensions.appBarHeight,
                width: context.width,
                child: Obx(() => Visibility(
                  visible: controller.bottomPanelFullyOpened.isTrue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppController.to.curPlayingSong.value.title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.titleLarge?.copyWith(
                                color: controller.panelWidgetColor.value,
                              ),
                            ),
                            Text(
                              AppController.to.curPlayingSong.value.artist ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: context.textTheme.titleLarge?.copyWith(
                                fontSize: context.textTheme.titleLarge!.fontSize! / 2,
                                color: controller.panelWidgetColor.value.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(() => Offstage(
                        offstage: controller.isBigAlbum.isTrue,
                        child: Visibility(
                          visible: controller.isAlbumScaleEnded.isTrue,
                          child: Obx(() => GestureDetector(
                            onTap: () {
                              if (controller.isFullScreenLyricOpen.isTrue) {
                                controller.isFullScreenLyricOpen.value = false;
                              } else {
                                controller.isAlbumScaleEnded.value = false;
                                controller.isBigAlbum.value = true;
                                controller.updateFullScreenLyricTimerCounter(cancelTimer: true);
                              }
                            },
                            child: SimpleExtendedImage(
                              width: AppDimensions.albumMinSize,
                              height: AppDimensions.albumMinSize,
                              shape: BoxShape.circle,
                              '${controller.curPlayingSong.value.extras?['image'] ?? ''}?param=500y500',
                            ),
                          )),
                        ),
                      )),
                    ],
                  ),
                )),
              ),
            // 专辑占位
            Obx(() => Offstage(
              offstage: controller.isBigAlbum.isFalse,
              child: Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: controller.bottomPanelFullyOpened.isTrue && controller.isAlbumScaleEnded.isTrue,
                child: Container(height: context.width - albumPadding,),
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
                      _buildCurPlayingPage(context),
                      _buildCommentPage(context, 2),
                      _buildCommentPage(context, 3),
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
                                controller.albumColor.value,
                                controller.albumColor.value.withOpacity(0),
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
                                controller.albumColor.value.withOpacity(0),
                                controller.albumColor.value,
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
        // 专辑缩放临时动画图层
        Obx(() => Offstage(
          offstage: controller.isAlbumScaleEnded.isTrue,
          child: Container(
            alignment: Alignment.topRight,
            child: Obx(() => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: controller.isBigAlbum.isTrue
                  ? EdgeInsets.only(right: AppDimensions.paddingLarge, top: AppDimensions.appBarHeight + context.mediaQueryPadding.top + AppDimensions.paddingLarge)
                  : EdgeInsets.only(right: AppDimensions.paddingLarge, top: context.mediaQueryPadding.top + AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(controller.isBigAlbum.isTrue ? AppDimensions.paddingLarge / 2 : AppDimensions.albumMinSize),
              ),
              clipBehavior: Clip.hardEdge,
              width: controller.isBigAlbum.isTrue ? context.width - AppDimensions.paddingLarge * 2 : AppDimensions.albumMinSize,
              height: controller.isBigAlbum.isTrue ? context.width - AppDimensions.paddingLarge * 2 : AppDimensions.albumMinSize,
              child: Obx(() => SimpleExtendedImage(
                '${controller.curPlayingSong.value.extras?['image'] ?? ''}?param=500y500',
              )),
              onEnd: () => controller.isAlbumScaleEnded.value = true,
            )),
          ),
        )),
        // 专辑单独图层
        Obx(() => Offstage(
          offstage: controller.bottomPanelFullyOpened.isFalse || controller.isBigAlbum.isFalse || controller.isAlbumScaleEnded.isFalse,
          child: Container(
            margin: EdgeInsets.only(top: context.mediaQueryPadding.top + AppDimensions.appBarHeight),
            height: context.width,
            child: NotificationListener<ScrollNotification>(
              // 监听滚动状态
              onNotification: (notification) {
                // 判断滚动是否是用户手势触发
                if (notification is ScrollStartNotification) {
                  if (notification.dragDetails != null && !controller.isAlbumScrollingProgrammatic) {
                    controller.isAlbumScrollingManully = true;
                  }
                  // 滚动结束时重置用户滚动状态
                } else if (notification is ScrollEndNotification) {
                  controller.isAlbumScrollingManully = false;
                  controller.isAlbumScrollingProgrammatic = false;
                }
                // 返回 false 让通知继续冒泡，以便 itemPositionsNotifier 也能收到
                return false;
              },
              child: PageView.builder(

                controller: controller.albumPageController,
                itemCount: controller.curPlayingSongs.length,
                allowImplicitScrolling: true,

                // TODO YU4422：切歌卡顿
                onPageChanged: (index) {
                  if (controller.isAlbumScrollingManully) {
                    controller.audioHandler.playIndex(audioSourceIndex: index, playNow: true);
                  }
                },
                itemBuilder: (BuildContext context, int index) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.all(AppDimensions.paddingLarge),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDimensions.paddingLarge/2),
                        boxShadow: [
                           BoxShadow(
                            color: Colors.black.withOpacity(0.4), // 阴影颜色
                            blurRadius: 12, // 模糊半径
                            spreadRadius: 2, // 扩散半径
                          )
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          controller.isAlbumScaleEnded.value = false;
                          controller.isBigAlbum.value = false;
                          if (controller.curPanelPageIndex.value == 1) controller.updateFullScreenLyricTimerCounter();
                        },
                        child: Obx(() => SimpleExtendedImage(
                          '${controller.curPlayingSongs[index].extras?['image'] ?? ''}?param=500y500',
                        )),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        )),

        // 页面指示TabBar
        Container(
          alignment: Alignment.bottomCenter,
          child: Obx(() => Container(
              color: controller.albumColor.value,
              child: Obx(() => Container(
                  height: albumPadding,
                  margin: EdgeInsets.symmetric(horizontal: albumPadding),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    // color: Colors.red,
                    color: controller.isBigAlbum.isTrue ? controller.panelWidgetColor.value.withOpacity(0.05) : Colors.transparent ,
                    borderRadius: BorderRadius.circular(albumPadding),
                  ),
                  child: MyTabBarItemAnimatedSwitcher(
                    isTabBarVisible: controller.curPanelPageIndex.value == 0,
                    replaceItem: Row(
                      children: [
                        Offstage(
                          offstage: controller.curPlayListNameHeader.value.isEmpty,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: albumPadding/2),
                            decoration: BoxDecoration(
                              color: controller.panelWidgetColor.value.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(albumPadding),
                            ),
                            child: Obx(() => Text(
                              controller.curPlayListNameHeader.value,
                              style: context.textTheme.titleMedium?.copyWith(color: controller.panelWidgetColor.value.withOpacity(0.5)),
                            )),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: AlignmentDirectional.center,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Obx(() => Text(
                                controller.curPlayListName.value,
                                style: context.textTheme.titleMedium?.copyWith(color: controller.panelWidgetColor.value.withOpacity(0.5)),
                              )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    tabItem: MyTabBar(
                      height: albumPadding,
                      color: controller.panelWidgetColor.value,
                      controller: controller.bottomPanelTabController,
                      tabs: [
                        // TODO YU4422 进入播放列表页面的时候显示当前播放歌单名
                        Text("播放列表", style: context.textTheme.titleMedium?.copyWith(color: controller.panelWidgetColor.value.withOpacity(0.5))),
                        Text("正在播放", style: context.textTheme.titleMedium?.copyWith(color: controller.panelWidgetColor.value.withOpacity(0.5))),
                        Obx(() => MyTabBarItemAnimatedSwitcher(
                          isTabBarVisible: controller.curPanelPageIndex.value > 1,
                          tabItem: Text("歌曲评论", style: context.textTheme.titleMedium?.copyWith(color: controller.panelWidgetColor.value.withOpacity(0.5))),
                          replaceItem: MyTabBar(
                            height: albumPadding,
                            controller: controller.bottomPanelCommentTabController,
                            color: controller.panelWidgetColor.value,
                            tabs: [
                              Text("热", style: context.textTheme.titleMedium?.copyWith(color: controller.panelWidgetColor.value.withOpacity(0.5))),
                              Text("新", style: context.textTheme.titleMedium?.copyWith(color: controller.panelWidgetColor.value.withOpacity(0.5))),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                )),
            ),
          ),
        ),
      ],
    );
  }

  /// 播放列表页
  Widget _buildCurPlayingListPage(BuildContext context) {
    double albumPadding = AppDimensions.paddingLarge;
    return KeepAliveWrapper(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: albumPadding),
        child: ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: Obx(() => ListView.builder(
              controller: controller.playListScrollController,
              physics: const ClampingScrollPhysics(),
              itemExtent: 55,
              padding: EdgeInsets.symmetric(vertical: albumPadding),
              itemCount: controller.curPlayingSongs.length,
              itemBuilder: (context, index) {
                return _buildSongItem(controller.curPlayingSongs[index], index, context);
              },
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildSongItem(MediaItem mediaItem, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => controller.audioHandler.playIndex(audioSourceIndex: index, playNow: true),
      child: Obx(() => Container(
        color: Colors.transparent,  // 加个颜色让透明区域也能点击
        alignment: AlignmentDirectional.centerStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mediaItem.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ((controller.curPlayIndex.value == index)
                    ? Colors.red
                    : controller.panelWidgetColor.value),            ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              mediaItem.artist ?? "未知歌手",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: controller.panelWidgetColor.value.withOpacity(0.5),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      )),
    );
  }

  /// 默认页（歌词）
  Widget _buildCurPlayingPage(BuildContext context) {
    double albumPadding = AppDimensions.paddingLarge;
    double remainWidth = context.width - albumPadding * 2;
    double textWidth = _measureTextWidth("歌手：", TextStyle(color: controller.panelWidgetColor.value)) + albumPadding + 4;
    return KeepAliveWrapper(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown:(event) {controller.updateFullScreenLyricTimerCounter();},
        onPointerMove: (event) {controller.updateFullScreenLyricTimerCounter();},
        onPointerUp: (event) {controller.updateFullScreenLyricTimerCounter();},
        child: Stack(
          children: [
            // 歌词
            Obx(() => Offstage(
              offstage: controller.isBigAlbum.value,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (controller.isFullScreenLyricOpen.isTrue) {
                    controller.isFullScreenLyricOpen.value = false;
                  } else {
                    controller.isAlbumScaleEnded.value = false;
                    controller.isBigAlbum.value = true;
                    controller.updateFullScreenLyricTimerCounter(cancelTimer: true);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: albumPadding),
                  child: const LyricView(EdgeInsets.symmetric(vertical: 10)),
                ),
              )
            )),
            // 控制、进度条、页面指示占位
            Obx(() => Offstage(
              offstage: controller.isFullScreenLyricOpen.isTrue && controller.isBigAlbum.isFalse,
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
                      padding: EdgeInsets.symmetric(horizontal: albumPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 专辑
                          SizedBox(
                            height: albumPadding,
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: controller.panelWidgetColor.value.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(albumPadding),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 这里测量的宽度不准确，强制将text适配到测量的宽度
                                      IntrinsicWidth(
                                        child: Container(
                                          padding: EdgeInsets.only(left: albumPadding / 2),
                                          child: Text(
                                            "专辑：",
                                            style: TextStyle(
                                              color: controller.panelWidgetColor.value,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          if (controller.curPlayingSong.value.album.isNullOrEmpty) return;
                                          await controller.bottomPanelController.close();
                                          context.router.push(const gr.AlbumRouteView().copyWith(queryParams: {'albumId': controller.curPlayingSong.value.extras?['albumId']}));
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: controller.panelWidgetColor.value.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(albumPadding),
                                          ),
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: remainWidth - textWidth,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: albumPadding / 2),
                                              child: Obx(() => Text(
                                                controller.curPlayingSong.value.album.orDefault("未知专辑"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: controller.panelWidgetColor.value
                                                ),
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
                            )
                          ).marginOnly(top: albumPadding),
                          // 歌手
                          SizedBox(
                            height: albumPadding,
                            child: Row(
                              children: [
                                Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: controller.panelWidgetColor.value.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(albumPadding),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IntrinsicWidth(
                                        child: Container(
                                          padding: EdgeInsets.only(left: albumPadding / 2),
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
                                            children: controller.curPlayingSong.value.artist.isNullOrEmpty
                                                ? [
                                                  Text(
                                                    "未知歌手",
                                                    style: TextStyle(
                                                        color: controller.panelWidgetColor.value
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ]
                                                : [
                                                  for(Artist artist in (controller.curPlayingSong.value.extras?['artist'].split(' / ').map((e) => Artist.fromJson(jsonDecode(e))).toList() ?? []))
                                                  Container(
                                                      alignment: Alignment.center,
                                                      padding: EdgeInsets.symmetric(horizontal: albumPadding / 2),
                                                      decoration: BoxDecoration(
                                                        color: controller.panelWidgetColor.value.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(albumPadding),
                                                      ),
                                                      child: Obx(() => GestureDetector(
                                                        onTap: () async {
                                                          await controller.bottomPanelController.close();
                                                          context.router.push(const gr.ArtistRouteView().copyWith(queryParams: {'artistId': artist.id}));
                                                        },
                                                        child: Text(
                                                          artist.name ?? "无名作者",
                                                          style: TextStyle(
                                                              color: controller.panelWidgetColor.value
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          textAlign: TextAlign.center,
                                                        ),
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
                          ).marginOnly(top: albumPadding),
                          // 播放进度条
                          _buildProgressBar(context).marginOnly(top: albumPadding),
                        ]
                      ),
                    ),
                  )),
                  // 播放控制
                  Expanded(child: _buildPlayController(context)),
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
  Widget _buildProgressBar(BuildContext context) {
    return Obx(() => ProgressBar(
      progress: controller.curPlayDuration.value,
      buffered: controller.curPlayDuration.value,
      total: controller.curPlayingSong.value.duration ?? const Duration(seconds: 10),
      barHeight: AppDimensions.paddingLarge,
      barCapShape: BarCapShape.round,
      progressBarColor: controller.panelWidgetColor.value.withOpacity(.1),
      baseBarColor: controller.panelWidgetColor.value.withOpacity(.05),
      bufferedBarColor: Colors.transparent,
      thumbColor: controller.panelWidgetColor.value.withOpacity(.05),
      thumbRadius: AppDimensions.paddingLarge / 2,
      thumbGlowRadius: AppDimensions.paddingLarge * 2 / 3,
      thumbCanPaintOutsideBar: false,
      timeLabelLocation: TimeLabelLocation.below,
      // timeLabelPadding: 0,
      timeLabelTextStyle: const TextStyle(
        fontSize: 0
      ),
      onSeek: (duration) => controller.audioHandler.seek(duration),
    ));
  }
  Widget _buildPlayController(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 喜欢按钮
          _buildButtonBackground(IconButton(
              onPressed: () => controller.toggleLikeStatus(),
              icon: Obx(() => Icon(
                  controller.likedSongIds.contains(int.tryParse(controller.curPlayingSong.value.id))
                      ? TablerIcons.heart_filled
                      : TablerIcons.heart,
                  size: 30,
                  color: controller.likedSongIds.contains(int.tryParse(controller.curPlayingSong.value.id))
                      ? Colors.red
                      : controller.panelWidgetColor.value
              ))
          )),
          // 上一首
          _buildButtonBackground(IconButton(
              onPressed: () {
                controller.audioHandler.skipToPrevious();
              },
              icon: Obx(() => Icon(
                TablerIcons.player_skip_back_filled,
                size: 30,
                color: controller.panelWidgetColor.value,
              ),
              )
          )),
          // 播放按钮
          _buildButtonBackground(IconButton(
            onPressed: () => controller.playOrPause(),
            icon: Obx(() => Icon(
              controller.isPlaying.value ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
              size: 60,
              color: controller.panelWidgetColor.value,
            )),
          )),
          // 下一首
          _buildButtonBackground(IconButton(
              onPressed: () {
                controller.audioHandler.skipToNext();
              },
              icon: Obx(() => Icon(
                TablerIcons.player_skip_forward_filled,
                size: 30,
                color: controller.panelWidgetColor.value,
              ))
          )),
          // 循环模式
          _buildButtonBackground(IconButton(
              onPressed: () async {
                if (controller.isFmMode.isTrue) {
                  // 漫游模式：直接返回
                  return;
                } else if (controller.isHeartBeatMode.isTrue){
                  // 心动模式：退出心动模式，并播放喜欢歌单，并切换到顺序播放
                  controller.quitHeartBeatMode();
                  await controller.audioHandler.changeRepeatMode(newRepeatMode: AudioServiceRepeatMode.all);
                  controller.playUserLikedSongs();
                  return;
                } else if (controller.isPlayingLikedSongs.isTrue && controller.audioHandler.curRepeatMode == AudioServiceRepeatMode.none) {
                  // 正在播放喜欢歌单：随机播放模式后再切换，开启心动模式
                  controller.openHeartBeatMode(controller.curPlayingSong.value.id, false);
                }else {
                  await controller.audioHandler.changeRepeatMode();
                }
              },
              icon: Obx(() => Icon(
                controller.getRepeatIcon(),
                size: 30,
                color: controller.panelWidgetColor.value,
              ))
          )),
        ],
      ),
    );
  }
  Widget _buildButtonBackground(IconButton iconButton) {
    return Obx(() => BlurryContainer(
      blur: controller.isBigAlbum.isTrue ? 0 : 5,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(100),
      color: controller.panelWidgetColor.value.withOpacity(controller.isBigAlbum.isTrue ? 0 : 0.05),
      child: iconButton,
    ));
  }
  
  /// 评论页
  Widget _buildCommentPage(BuildContext context, int commentType) {
    double albumPadding = AppDimensions.paddingLarge;

    return KeepAliveWrapper(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: albumPadding),
        child: Obx(() => CommentWidget(
          key: ValueKey(controller.curPlayingSong.value.id),
          context: context,
          id: controller.curPlayingSong.value.id,
          idType: "song",
          commentType: commentType,
          listPaddingTop: albumPadding,
          listPaddingBottom: albumPadding,
          stringColor: controller.panelWidgetColor.value,
        )),
      ),
    );
  }

}

class BottomPanelHeaderView extends GetView<AppController> {
  const BottomPanelHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Offstage(
      offstage: controller.bottomPanelFullyOpened.isTrue,
      child: GestureDetector(
        onTap: () => controller.bottomPanelController.open(),
        child: AnimatedBuilder(
          animation: controller.bottomPanelAnimationController,
          builder: (context, child) {
            // 完全展开专辑图片状态
            /// 完全展开，专辑图片Size
            double albumMaxSize = context.width - AppDimensions.paddingLarge * 2;
            /// 完全展开，专辑图片Margin
            double albumMaxPadding = AppDimensions.paddingLarge;
            /// 完全展开，专辑图片Radius
            double albumMinBorderRadius = AppDimensions.paddingLarge/2;

            /// panel展开程度
            double panelOpenDegree = controller.bottomPanelAnimationController.value;
            // 实时Album宽度、margin
            double realTimeAlbumWidth = AppDimensions.albumMinSize + (albumMaxSize - AppDimensions.albumMinSize) * panelOpenDegree;
            double realTimeAlbumPadding = AppDimensions.paddingSmall +  (albumMaxPadding - AppDimensions.paddingSmall) * panelOpenDegree;
            double realTimeAlbumTopMargin = (context.mediaQueryPadding.top + AppDimensions.appBarHeight) * panelOpenDegree;
            double realTimeAlbumBorderRadius = AppDimensions.albumMinSize + (albumMinBorderRadius - AppDimensions.albumMinSize) * panelOpenDegree;

            return Stack(
              alignment: Alignment.center,
              children: [
                Obx(() => BlurryContainer(
                    // width: context.width - realTimeAlbumPadding * 2,
                    // height: controller.isBigAlbum.isTrue ? realTimeAlbumWidth + realTimeAlbumTopMargin : AppDimensions.albumMinSize,
                    width: context.width,
                    height: controller.isBigAlbum.isTrue ? realTimeAlbumWidth + realTimeAlbumPadding * 2 + realTimeAlbumTopMargin : AppDimensions.bottomPanelHeaderHeight,
                    blur: 20 * (1 - panelOpenDegree),
                    padding: EdgeInsets.zero,
                    color: controller.albumColor.value.withOpacity(0.5 * (1 - panelOpenDegree)),
                    // borderRadius:  BorderRadius.circular(controller.isBigAlbum.isTrue ? realTimeAlbumBorderRadius : AppDimensions.albumMinSize),
                    borderRadius:  BorderRadius.circular(controller.isBigAlbum.isTrue ? AppDimensions.bottomPanelHeaderHeight/2 * (1 - controller.bottomPanelAnimationController.value) : AppDimensions.albumMinSize),

                    child: Container(),
                  ).marginOnly(top: controller.isBigAlbum.isTrue ? 0 : context.mediaQueryPadding.top * panelOpenDegree),
                ),
                Container(
                  width: context.width,
                  child: Stack(
                    children: [
                      // 歌名&歌手
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          left: (AppDimensions.albumMinSize + AppDimensions.paddingSmall * 2 - albumMaxPadding) * (1 - panelOpenDegree) + albumMaxPadding,
                          right: (AppDimensions.albumMinSize + AppDimensions.paddingSmall * 2 - albumMaxPadding) * (1 - panelOpenDegree) + albumMaxPadding,
                          top: context.mediaQueryPadding.top * panelOpenDegree,
                        ),
                        child: SizedBox(
                          height: AppDimensions.bottomPanelHeaderHeight,
                          child: Swipeable(
                            background: const SizedBox.shrink(),
                            onSwipeLeft: () => controller.audioHandler.skipToPrevious(),
                            onSwipeRight: () => controller.audioHandler.skipToNext(),
                            child: Obx(() => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppController.to.curPlayingSong.value.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    color: controller.panelWidgetColor.value,
                                  ),
                                ),
                                Text(
                                  AppController.to.curPlayingSong.value.artist ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontSize: context.textTheme.titleLarge!.fontSize! / 2,
                                    color: controller.panelWidgetColor.value.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            )),
                          ),
                        ),
                      ),
                      // 大专辑图片
                      Visibility(
                        visible: controller.isBigAlbum.isTrue && controller.bottomPanelFullyOpened.isFalse,
                        child: Container(
                          margin: EdgeInsets.only(top: realTimeAlbumTopMargin),
                          padding: EdgeInsets.all(realTimeAlbumPadding),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(realTimeAlbumBorderRadius),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Obx(() => SimpleExtendedImage(
                              width: realTimeAlbumWidth,
                              height: realTimeAlbumWidth,
                              '${controller.curPlayingSong.value.extras?['image'] ?? ''}?param=500y500',
                            )),
                          ),
                        ),
                      ),
                      // 小专辑图片
                      Visibility(
                        visible: controller.isBigAlbum.isFalse && controller.bottomPanelFullyOpened.isFalse,
                        child: Container(
                          height: AppDimensions.bottomPanelHeaderHeight,
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(
                            top: context.mediaQueryPadding.top * panelOpenDegree,
                            left: AppDimensions.paddingSmall + panelOpenDegree * (context.width - AppDimensions.paddingLarge - AppDimensions.albumMinSize - AppDimensions.paddingSmall)),
                          child: Obx(() => SimpleExtendedImage(
                            width: AppDimensions.albumMinSize,
                            height: AppDimensions.albumMinSize,
                            shape: BoxShape.circle,
                            '${controller.curPlayingSong.value.extras?['image'] ?? ''}?param=500y500',
                          )),
                        ),
                      ),
                      // 播放按钮
                      Obx(() => Offstage(
                        offstage: controller.bottomPanelFullyClosed.isFalse,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Container(
                            margin: const EdgeInsets.all(AppDimensions.paddingSmall),
                            child: Stack(
                              children: [
                                CircularPlaybackProgress(
                                  progress: controller.curPlayDuration.value.inMilliseconds / controller.curPlayingSong.value.duration!.inMilliseconds,
                                  size: AppDimensions.albumMinSize,
                                  strokeWidth: 2,
                                  progressColor: controller.panelWidgetColor.value,
                                  backgroundColor: controller.panelWidgetColor.value.withAlpha(50),
                                ),
                                IconButton(
                                  onPressed: () => controller.playOrPause(),
                                    padding: const EdgeInsets.all(AppDimensions.albumMinSize * 1 / 3 / 2),
                                    icon: Obx(() => Icon(
                                    controller.isPlaying.value ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
                                    color: controller.panelWidgetColor.value,
                                    size: AppDimensions.albumMinSize * 2 / 3,
                                  ))
                                ),

                              ],
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            );
          },
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