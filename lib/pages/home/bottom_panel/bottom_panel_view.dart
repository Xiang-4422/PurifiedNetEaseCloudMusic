
import 'dart:convert';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/pages/artist/artist_page_view.dart';
import 'package:bujuan/pages/home/bottom_panel/lyric_view.dart';
import 'package:bujuan/pages/talk/comment_widget.dart';
import 'package:bujuan/widget/keep_alive_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;

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
      alignment: Alignment.bottomCenter,
      children: [
        // 背景层
        AnimatedBuilder(
          animation: controller.bottomPanelAnimationController,
          builder: (BuildContext context, Widget? child) {
            double panelOpenDegree = controller.bottomPanelAnimationController.value;
            return Obx(() => BlurryContainer(
              blur: 20 * (1 - panelOpenDegree),
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.all(Radius.circular(AppDimensions.phoneCornerRadius * (1 - panelOpenDegree))),
              color: controller.albumColor.value.withOpacity(0.5 * (1 + panelOpenDegree)),
              child: Container(),
            ),
            );
          },
        ),
        // 内容
        Column(
          children: [
            // Panel关闭占位，显示透明
            Obx(() => Offstage(
              offstage: controller.bottomPanelFullyClosed.isFalse,
              child: Container (
                height: AppDimensions.bottomPanelHeaderHeight,
              ),
            )),
            // 专辑
            Obx(() => Offstage(
              offstage: controller.isAlbumVisible.isFalse,
              child: Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: controller.bottomPanelFullyOpened.isTrue,
                child: Container(
                  margin: EdgeInsets.only(top: context.mediaQueryPadding.top + AppDimensions.appBarHeight),
                  height: context.width,
                  child: OverflowBox(
                    maxWidth: context.width * 3,
                    child: Obx(() => NotificationListener<ScrollNotification>(
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
                        itemCount: controller.curPlayList.length,
                        onPageChanged: (index) {
                          if (controller.isAlbumScrollingManully) {
                            controller.audioHandler.playIndex(audioSourceIndex: index, playNow: true);
                          }
                        },
                        itemBuilder: (BuildContext context, int index) {
                          print("albumbuildIndex: $index");
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
                              margin: EdgeInsets.all(AppDimensions.paddingLarge),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  controller.bottomPanelFullyOpened.value
                                      ? BoxShadow(
                                    color: Colors.black.withOpacity(0.4), // 阴影颜色
                                    blurRadius: 12, // 模糊半径
                                    spreadRadius: 2, // 扩散半径
                                  )
                                      : const BoxShadow()
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  controller.isAlbumVisible.value = !controller.isAlbumVisible.value;
                                },
                                child: Obx(() => SimpleExtendedImage(
                                  '${controller.curPlayList[index].extras?['image'] ?? ''}?param=500y500',
                                )),
                              ),
                            ),
                          );
                        },
                      ),
                    )),
                  ),
                ),
              ),
            )),
            Expanded(
              child: PageView(
                controller: controller.bottomPanelPageController,
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
          child: Obx(() => Offstage(
            offstage: controller.bottomPanelFullyOpened.isFalse,
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
                )
              ],
            ),
          )),
        ),
        // 页面指示TabBar
        Container(
          padding: EdgeInsets.symmetric(horizontal: albumPadding),
          height: albumPadding,
          child: TabBar(
            padding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            controller: controller.bottomPanelTabController,
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
                      controller: controller.bottomPanelCommentTabController,
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
    );
  }

  /// 播放列表页
  Widget _buildCurPlayingListPage(BuildContext context) {
    double panelAppBarHeight = AppDimensions.appBarHeight + context.mediaQueryPadding.top;
    double albumPadding = AppDimensions.paddingLarge;
    return KeepAliveWrapper(
      child: Obx(() => Container(
        padding: EdgeInsets.symmetric(horizontal: albumPadding),
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
      )),
    );
  }
  Widget _buildSongItem(MediaItem mediaItem, int index, BuildContext context) {
    return Obx(() => UniversalListTile(
        titleString: mediaItem.title,
        subTitleString: mediaItem.artist,
        stringColor: (controller.curPlayIndex.value == index)
            ? Colors.red
            : controller.panelWidgetColor.value,
        onTap: () => controller.audioHandler.playIndex(audioSourceIndex: index, playNow: true),
      ),
    );
  }

  /// 默认页（歌词）
  Widget _buildCurPlayingPage(BuildContext context) {
    double albumPadding = AppDimensions.paddingLarge;
    double remainWidth = context.width - albumPadding * 2;
    double textWidth = _measureTextWidth("歌手：", TextStyle(color: controller.panelWidgetColor.value)) + albumPadding / 2;
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
              Obx(() => Offstage(
                  offstage: controller.isAlbumVisible.isTrue,
                    child: Container(height: context.width + AppDimensions.appBarHeight + context.mediaQueryPadding.top)
                ),
              ),
              Obx(() => Visibility(
                // replacement: Container(
                //   height: albumPadding * 5,
                // ),
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: controller.isAlbumVisible.value,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: albumPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 专辑
                        Container(
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
                                    Container(
                                      width: textWidth,
                                      padding: EdgeInsets.only(left: albumPadding / 2),
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
                                    GestureDetector(
                                      onTap: () {
                                        controller.bottomPanelController.close();
                                        AppController.to.updateAppBarTitle(title: controller.curMediaItem.value.album, subTitle: "专辑", direction: NewAppBarTitleComingDirection.right, willRollBack: true);
                                        context.router.push(const gr.AlbumRouteView().copyWith(queryParams: {'albumId': controller.curMediaItem.value.extras?['albumId']}));
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
                          // width: remainWidth,
                          height: albumPadding,
                          margin: EdgeInsets.symmetric(vertical: albumPadding),
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
                                    // 这里测量的宽度不准确，强制将text适配到测量的宽度
                                    Container(
                                      width: textWidth,
                                      padding: EdgeInsets.only(left: albumPadding / 2),
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
                                            for(Artist artist in (controller.curMediaItem.value.extras!['artist']?.split(' / ').map((e) => Artist.fromJson(jsonDecode(e))).toList() ?? []))
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
                                                    AppController.to.updateAppBarTitle(title: artist.name, subTitle: "歌手", direction: NewAppBarTitleComingDirection.right, willRollBack: true);
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
                        ),
                        // 播放进度条
                        _buildProgressBar(context),
                      ]
                    ),
                  ),
                )),
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
      total: controller.curMediaItem.value.duration ?? const Duration(seconds: 10),

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 喜欢按钮
        _buildButtonBackground(IconButton(
            onPressed: () => controller.toggleLikeStatus(),
            icon: Obx(() => Icon(
                controller.likeIds.contains(int.tryParse(controller.curMediaItem.value.id))
                    ? TablerIcons.heart_filled
                    : TablerIcons.heart,
                size: 30,
                color: controller.likeIds.contains(int.tryParse(controller.curMediaItem.value.id))
                    ? Colors.red
                    : controller.panelWidgetColor.value
            ))
        )),
        // 上一首
        _buildButtonBackground(IconButton(
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
              if (controller.isFmMode.value) {
                return;
              }
              await controller.audioHandler.changeRepeatMode();
            },
            icon: Obx(() => Icon(
              key: ValueKey(controller.isFmMode.value),
              controller.getRepeatIcon(),
              size: 30,
              color: controller.panelWidgetColor.value,
            ))
        )),
      ],
    );
  }
  Widget _buildButtonBackground(IconButton iconButton) {
    return Obx(() => BlurryContainer(
      blur: controller.isAlbumVisible.isTrue ? 0 : 5,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(100),
      color: controller.panelWidgetColor.value.withOpacity(controller.isAlbumVisible.isTrue ? 0 : 0.05),
      child: iconButton,
    ));
  }
  
  /// 评论页
  Widget _buildCommentPage(BuildContext context, int commentType) {
    double panelAppBarHeight = AppDimensions.appBarHeight + context.mediaQueryPadding.top;
    double albumPadding = AppDimensions.paddingLarge;

    return KeepAliveWrapper(
      child: Obx(() => Container(
          margin: EdgeInsets.only(top: controller.isAlbumVisible.isFalse ? panelAppBarHeight : 0),
          padding: EdgeInsets.symmetric(horizontal: albumPadding),
          child: Obx(() => CommentWidget(
            key: ValueKey(controller.curMediaItem.value.id),
            context: context,
            id: controller.curMediaItem.value.id,
            idType: "song",
            commentType: commentType,
            listPaddingTop: controller.isAlbumVisible.value
                ? 0
                : albumPadding,
            listPaddingBottom: albumPadding,
            stringColor: controller.panelWidgetColor.value,
          ),),
        ),
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
            /// 完全展开宽度
            double albumMaxSize = context.width - AppDimensions.paddingLarge * 2;
            /// 完全展开LeftMargin
            double albumMaxPadding = AppDimensions.paddingLarge;

            double panelOpenDegree = controller.bottomPanelAnimationController.value;
            // 实时Album宽度、margin
            double realTimeAlbumWidth = AppDimensions.albumMinSize + (albumMaxSize - AppDimensions.albumMinSize) * panelOpenDegree;
            double realTimeAlbumPadding = AppDimensions.paddingSmall +  (albumMaxPadding - AppDimensions.paddingSmall) * panelOpenDegree;
            double realTimeAppBarPadding = (context.mediaQueryPadding.top + AppDimensions.appBarHeight) * panelOpenDegree;
            double realTimeAlbumBorderRadius = AppDimensions.albumMinSize * (1 - panelOpenDegree);
            return Container(
              width: context.width,
              child: Row(
                children: [
                  Visibility(
                    visible: controller.bottomPanelFullyClosed.isTrue || controller.isAlbumVisible.isTrue,
                    child: Container(
                      margin: EdgeInsets.only(top: realTimeAppBarPadding),
                      padding: EdgeInsets.all(realTimeAlbumPadding),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(realTimeAlbumBorderRadius),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Obx(() => SimpleExtendedImage(
                          width: realTimeAlbumWidth,
                          height: realTimeAlbumWidth,
                          '${controller.curMediaItem.value.extras?['image'] ?? ''}?param=500y500',
                        )),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(() => Visibility(
                      visible: controller.bottomPanelFullyClosed.isTrue,
                      child: Row(
                        children: [
                          Expanded(
                            child: Swipeable(
                              background: const SizedBox.shrink(),
                              onSwipeLeft: () => controller.audioHandler.skipToPrevious(),
                              onSwipeRight: () => controller.audioHandler.skipToNext(),
                              child: Obx(() => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${AppController.to.curMediaItem.value.title}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: context.textTheme.titleLarge?.copyWith(
                                      color: controller.panelWidgetColor.value,
                                    ),
                                  ),
                                  Text(
                                    '${AppController.to.curMediaItem.value.artist ?? ''}',
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
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                            child: IconButton(
                              onPressed: () => controller.playOrPause(),
                              padding: const EdgeInsets.all(AppDimensions.albumMinSize * 1 / 3 / 2),
                              icon: Obx(() => Icon(
                                  controller.isPlaying.value ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
                                  color: controller.panelWidgetColor.value,
                                  size: AppDimensions.albumMinSize * 2 / 3,
                                ))
                            ),
                          ),
                        ]
                      ),
                    )),
                  )
                ],
              ),
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