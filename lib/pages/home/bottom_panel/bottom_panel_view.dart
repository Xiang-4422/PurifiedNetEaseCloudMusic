import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/features/shell/app_controller.dart';
import 'package:bujuan/features/user/user_controller.dart';
import 'package:bujuan/pages/home/bottom_panel/lyric_view.dart';
import 'package:bujuan/pages/talk/comment_widget.dart';
import 'package:bujuan/widget/common_widgets.dart';
import 'package:bujuan/widget/keep_alive_wrapper.dart';
import 'package:bujuan/widget/my_tab_bar.dart';
import 'package:bujuan/widget/scroll_helpers.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../../common/constants/app_constants.dart';
import '../../../widget/artwork_path_resolver.dart';
import '../../../widget/simple_extended_image.dart';
import '../../../widget/swipeable.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;

class BottomPanelView extends GetView<AppController> {
  const BottomPanelView({Key? key}) : super(key: key);

  List<_ArtistChipData> _artistEntries(MediaItem mediaItem) {
    final artistNames = (mediaItem.extras?['artistNames'] as List?)
            ?.map((artist) => '$artist')
            .where((artist) => artist.isNotEmpty)
            .toList() ??
        (mediaItem.artist ?? '')
            .split(' / ')
            .where((artist) => artist.isNotEmpty)
            .toList();
    final artistIds = (mediaItem.extras?['artistIds'] as List?)
            ?.map((artistId) => '$artistId')
            .toList() ??
        const <String>[];
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
    double albumPadding = AppDimensions.paddingLarge;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // 背景层
        AnimatedBuilder(
          animation: controller.bottomPanelAnimationController,
          builder: (BuildContext context, Widget? child) {
            double panelOpenDegree =
                controller.bottomPanelAnimationController.value;
            return Obx(() => BlurryContainer(
                  blur: 20,
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.all(Radius.circular(
                      AppDimensions.phoneCornerRadius * (1 - panelOpenDegree))),
                  color: controller.albumColor.value
                      .withValues(alpha: 0.5 + 0.5 * panelOpenDegree),
                  child: Container(),
                ));
          },
        ),
        // 内容
        Column(
          children: [
            // 歌名&歌手
            Container(
              margin: EdgeInsets.only(top: context.mediaQueryPadding.top),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge),
              height: AppDimensions.appBarHeight,
              width: context.width,
              child: Obx(() => Visibility(
                    visible: controller.bottomPanelFullyOpened.isTrue,
                    child: Builder(builder: (context) {
                      final currentSong = controller.currentSong.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentSong.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    color: controller.panelWidgetColor.value,
                                  ),
                                ),
                                Text(
                                  currentSong.artist ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontSize: context
                                            .textTheme.titleLarge!.fontSize! /
                                        2,
                                    color: controller.panelWidgetColor.value
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Obx(() => Offstage(
                                offstage: controller.isBigAlbum.isTrue,
                                child: Visibility(
                                  visible: controller.isAlbumScaleEnded.isTrue,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (controller
                                          .isFullScreenLyricOpen.isTrue) {
                                        controller.isFullScreenLyricOpen.value =
                                            false;
                                      } else {
                                        controller.isAlbumScaleEnded.value =
                                            false;
                                        controller.isBigAlbum.value = true;
                                        controller
                                            .updateFullScreenLyricTimerCounter(
                                                cancelTimer: true);
                                      }
                                    },
                                    child: SimpleExtendedImage(
                                      width: AppDimensions.albumMinSize,
                                      height: AppDimensions.albumMinSize,
                                      shape: BoxShape.circle,
                                      ArtworkPathResolver.resolveDisplayPath(
                                        controller.currentSong.value
                                            .extras?['image'] as String?,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                        ],
                      );
                    }),
                  )),
            ),
            // 专辑占位
            Obx(() => Offstage(
                  offstage: controller.isBigAlbum.isFalse,
                  child: Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: controller.bottomPanelFullyOpened.isTrue &&
                        controller.isAlbumScaleEnded.isTrue,
                    child: Container(
                      height: context.width - albumPadding,
                    ),
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
                                    controller.albumColor.value
                                        .withValues(alpha: 0),
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
                                    controller.albumColor.value
                                        .withValues(alpha: 0),
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
                          ? EdgeInsets.only(
                              right: AppDimensions.paddingLarge,
                              top: AppDimensions.appBarHeight +
                                  context.mediaQueryPadding.top +
                                  AppDimensions.paddingLarge)
                          : EdgeInsets.only(
                              right: AppDimensions.paddingLarge,
                              top: context.mediaQueryPadding.top +
                                  AppDimensions.paddingSmall),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(
                            controller.isBigAlbum.isTrue
                                ? AppDimensions.paddingLarge / 2
                                : AppDimensions.albumMinSize),
                      ),
                      clipBehavior: Clip.hardEdge,
                      width: controller.isBigAlbum.isTrue
                          ? context.width - AppDimensions.paddingLarge * 2
                          : AppDimensions.albumMinSize,
                      height: controller.isBigAlbum.isTrue
                          ? context.width - AppDimensions.paddingLarge * 2
                          : AppDimensions.albumMinSize,
                      child: Obx(() {
                        return SimpleExtendedImage(
                          ArtworkPathResolver.resolveDisplayPath(
                            controller.currentSong.value.extras?['image']
                                as String?,
                          ),
                        );
                      }),
                      onEnd: () => controller.isAlbumScaleEnded.value = true,
                    )),
              ),
            )),
        // 专辑单独图层
        Obx(() => Offstage(
              offstage: controller.bottomPanelFullyOpened.isFalse ||
                  controller.isBigAlbum.isFalse ||
                  controller.isAlbumScaleEnded.isFalse,
              child: Container(
                margin: EdgeInsets.only(
                    top: context.mediaQueryPadding.top +
                        AppDimensions.appBarHeight),
                height: context.width,
                child: NotificationListener<ScrollNotification>(
                  // 监听滚动状态
                  onNotification: (notification) {
                    // 判断滚动是否是用户手势触发
                    if (notification is ScrollStartNotification) {
                      if (notification.dragDetails != null) {
                        // 用户开始手动拖拽，如果是程序动画中，则劫持它
                        controller.isAlbumScrollingManully = true;
                        controller.isAlbumScrollingProgrammatic = false;
                      }
                    } else if (notification is ScrollEndNotification) {
                      controller.isAlbumScrollingManully = false;
                    }
                    // 返回 false 让通知继续冒泡，以便 itemPositionsNotifier 也能收到
                    return false;
                  },
                  child: PageView.builder(
                    controller: controller.albumPageController,
                    itemCount: controller.playbackQueue.length,
                    allowImplicitScrolling: true,

                    // TODO YU4422：切歌卡顿
                    onPageChanged: (index) {
                      controller.onAlbumPageChanged(index);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          margin:
                              const EdgeInsets.all(AppDimensions.paddingLarge),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.paddingLarge / 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 12, // 模糊半径
                                spreadRadius: 2, // 扩散半径
                              )
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              controller.isAlbumScaleEnded.value = false;
                              controller.isBigAlbum.value = false;
                              if (controller.curPanelPageIndex.value == 1) {
                                controller.updateFullScreenLyricTimerCounter();
                              }
                            },
                            child: Obx(() => SimpleExtendedImage(
                                  ArtworkPathResolver.resolveDisplayPath(
                                    controller.playbackQueue[index]
                                        .extras?['image'] as String?,
                                  ),
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
          child: Obx(
            () => Container(
              color: controller.albumColor.value,
              child: Obx(() {
                final sessionState = controller.playbackSessionState.value;
                return Container(
                  height: albumPadding,
                  margin: EdgeInsets.symmetric(horizontal: albumPadding),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: controller.isBigAlbum.isTrue
                        ? controller.panelWidgetColor.value
                            .withValues(alpha: 0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(albumPadding),
                  ),
                  child: MyTabBarItemAnimatedSwitcher(
                    isTabBarVisible: controller.curPanelPageIndex.value == 0,
                    replaceItem: Row(
                      children: [
                        Offstage(
                          offstage: sessionState.playlistHeader.isEmpty,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: albumPadding / 2),
                            decoration: BoxDecoration(
                              color: controller.panelWidgetColor.value
                                  .withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(albumPadding),
                            ),
                            child: Text(
                              sessionState.playlistHeader,
                              style: context.textTheme.titleMedium?.copyWith(
                                  color: controller.panelWidgetColor.value
                                      .withValues(alpha: 0.5)),
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
                                style: context.textTheme.titleMedium?.copyWith(
                                    color: controller.panelWidgetColor.value
                                        .withValues(alpha: 0.5)),
                              ),
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
                        Text("播放列表",
                            style: context.textTheme.titleMedium?.copyWith(
                                color: controller.panelWidgetColor.value
                                    .withValues(alpha: 0.5))),
                        Text("正在播放",
                            style: context.textTheme.titleMedium?.copyWith(
                                color: controller.panelWidgetColor.value
                                    .withValues(alpha: 0.5))),
                        Obx(() => MyTabBarItemAnimatedSwitcher(
                              isTabBarVisible:
                                  controller.curPanelPageIndex.value > 1,
                              tabItem: Text("歌曲评论",
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(
                                          color: controller
                                              .panelWidgetColor.value
                                              .withValues(alpha: 0.5))),
                              replaceItem: MyTabBar(
                                height: albumPadding,
                                controller:
                                    controller.bottomPanelCommentTabController,
                                color: controller.panelWidgetColor.value,
                                tabs: [
                                  Text("热",
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                              color: controller
                                                  .panelWidgetColor.value
                                                  .withValues(alpha: 0.5))),
                                  Text("新",
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                              color: controller
                                                  .panelWidgetColor.value
                                                  .withValues(alpha: 0.5))),
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
    double albumPadding = AppDimensions.paddingLarge;
    return KeepAliveWrapper(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: albumPadding),
        child: ScrollConfiguration(
          behavior: const NoGlowScrollBehavior(),
          child: Obx(
            () => ListView.builder(
              controller: controller.playListScrollController,
              physics: const ClampingScrollPhysics(),
              itemExtent: 55,
              padding: EdgeInsets.symmetric(vertical: albumPadding),
              itemCount: controller.playbackQueue.length,
              itemBuilder: (context, index) {
                return _buildSongItem(
                  controller.playbackQueue[index],
                  index,
                  context,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongItem(MediaItem mediaItem, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => controller.playerController.playQueueIndex(index),
      child: Obx(() {
        final isCurrent = controller.playbackQueueIndex.value == index;
        return Container(
          color: Colors.transparent,
          alignment: AlignmentDirectional.centerStart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mediaItem.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isCurrent
                          ? Colors.red
                          : controller.panelWidgetColor.value,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                mediaItem.artist ?? "未知歌手",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: controller.panelWidgetColor.value
                          .withValues(alpha: 0.5),
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        );
      }),
    );
  }

  /// 默认页（歌词）
  Widget _buildCurPlayingPage(BuildContext context) {
    double albumPadding = AppDimensions.paddingLarge;
    double remainWidth = context.width - albumPadding * 2;
    double textWidth = _measureTextWidth(
            "歌手：", TextStyle(color: controller.panelWidgetColor.value)) +
        albumPadding +
        4;
    return KeepAliveWrapper(
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          controller.updateFullScreenLyricTimerCounter();
        },
        onPointerMove: (event) {
          controller.updateFullScreenLyricTimerCounter();
        },
        onPointerUp: (event) {
          controller.updateFullScreenLyricTimerCounter();
        },
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
                      controller.updateFullScreenLyricTimerCounter(
                          cancelTimer: true);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: albumPadding),
                    child: const LyricView(EdgeInsets.symmetric(vertical: 10)),
                  ),
                ))),
            // 控制、进度条、页面指示占位
            Obx(() => Offstage(
                  offstage: controller.isFullScreenLyricOpen.isTrue &&
                      controller.isBigAlbum.isFalse,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 占位: 专辑封面
                      Obx(() => Container(
                          height: controller.isBigAlbum.isTrue
                              ? 0
                              : context.width - albumPadding)),
                      // 专辑、歌手、进度条
                      Obx(() => Visibility(
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            visible: controller.isBigAlbum.isTrue,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: albumPadding),
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
                                                color: controller
                                                    .panelWidgetColor.value
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        albumPadding),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // 这里测量的宽度不准确，强制将text适配到测量的宽度
                                                  IntrinsicWidth(
                                                    child: Container(
                                                      padding: EdgeInsets.only(
                                                          left:
                                                              albumPadding / 2),
                                                      child: Text(
                                                        "专辑：",
                                                        style: TextStyle(
                                                          color: controller
                                                              .panelWidgetColor
                                                              .value,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final runtimeState =
                                                          controller
                                                              .playbackRuntimeState
                                                              .value;
                                                      if (controller
                                                          .playbackRuntimeState
                                                          .value
                                                          .currentSong
                                                          .album
                                                          .isNullOrEmpty) {
                                                        return;
                                                      }
                                                      final router =
                                                          context.router;
                                                      await controller
                                                          .bottomPanelController
                                                          .close();
                                                      router.push(const gr
                                                              .AlbumRouteView()
                                                          .copyWith(
                                                              queryParams: {
                                                            'albumId': runtimeState
                                                                    .currentSong
                                                                    .extras?[
                                                                'albumId']
                                                          }));
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: controller
                                                            .panelWidgetColor
                                                            .value
                                                            .withValues(
                                                                alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                albumPadding),
                                                      ),
                                                      child: ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                          maxWidth:
                                                              remainWidth -
                                                                  textWidth,
                                                        ),
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      albumPadding /
                                                                          2),
                                                          child: Obx(() => Text(
                                                                controller
                                                                    .playbackRuntimeState
                                                                    .value
                                                                    .currentSong
                                                                    .album
                                                                    .orDefault(
                                                                        "未知专辑"),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: controller
                                                                        .panelWidgetColor
                                                                        .value),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
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
                                              color: controller
                                                  .panelWidgetColor.value
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      albumPadding),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IntrinsicWidth(
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: albumPadding / 2),
                                                    child: Text(
                                                      "歌手：",
                                                      style: TextStyle(
                                                        color: controller
                                                            .panelWidgetColor
                                                            .value,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxWidth:
                                                        remainWidth - textWidth,
                                                  ),
                                                  child: SingleChildScrollView(
                                                    scrollDirection: Axis
                                                        .horizontal, // 允许水平滚动
                                                    child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: controller
                                                                .playbackRuntimeState
                                                                .value
                                                                .currentSong
                                                                .artist
                                                                .isNullOrEmpty
                                                            ? [
                                                                Text(
                                                                  "未知歌手",
                                                                  style: TextStyle(
                                                                      color: controller
                                                                          .panelWidgetColor
                                                                          .value),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ]
                                                            : [
                                                                for (final artist
                                                                    in _artistEntries(controller
                                                                        .playbackRuntimeState
                                                                        .value
                                                                        .currentSong))
                                                                  Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            albumPadding /
                                                                                2),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: controller
                                                                          .panelWidgetColor
                                                                          .value
                                                                          .withValues(
                                                                              alpha: 0.1),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              albumPadding),
                                                                    ),
                                                                    child: Obx(
                                                                        () =>
                                                                            GestureDetector(
                                                                              onTap: () async {
                                                                                if (artist.id.isEmpty) {
                                                                                  return;
                                                                                }
                                                                                final router = context.router;
                                                                                await controller.closeBottomPanel();
                                                                                router.push(const gr.ArtistRouteView().copyWith(queryParams: {
                                                                                  'artistId': artist.id
                                                                                }));
                                                                              },
                                                                              child: Text(
                                                                                artist.name,
                                                                                style: TextStyle(color: controller.panelWidgetColor.value),
                                                                                overflow: TextOverflow.ellipsis,
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            )),
                                                                  ),
                                                              ]),
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
                                    _buildProgressBar(context)
                                        .marginOnly(top: albumPadding),
                                  ]),
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

  double _measureTextWidth(String text, TextStyle style,
      {double maxWidth = double.infinity, int? maxLines}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr, // 必须设置文本方向
      maxLines: maxLines, // 可选：如果文本有行数限制
    )..layout(minWidth: 0, maxWidth: maxWidth); // 布局文本，给定最大宽度

    return textPainter.size.width; // 返回计算出的宽度
  }

  Widget _buildProgressBar(BuildContext context) {
    return Obx(() {
      final currentSong = controller.currentSong.value;
      final currentPosition = controller.currentPosition.value;
      return ProgressBar(
        progress: currentPosition,
        buffered: currentPosition,
        total: currentSong.duration ?? const Duration(seconds: 10),
        barHeight: AppDimensions.paddingLarge,
        barCapShape: BarCapShape.round,
        progressBarColor:
            controller.panelWidgetColor.value.withValues(alpha: .1),
        baseBarColor: controller.panelWidgetColor.value.withValues(alpha: .05),
        bufferedBarColor: Colors.transparent,
        thumbColor: controller.panelWidgetColor.value.withValues(alpha: .05),
        thumbRadius: AppDimensions.paddingLarge / 2,
        thumbGlowRadius: AppDimensions.paddingLarge * 2 / 3,
        thumbCanPaintOutsideBar: false,
        timeLabelLocation: TimeLabelLocation.below,
        // timeLabelPadding: 0,
        timeLabelTextStyle: const TextStyle(fontSize: 0),
        onSeek: (duration) => controller.playerController.seekTo(duration),
      );
    });
  }

  Widget _buildPlayController(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
      child: Obx(() {
        final currentSong = controller.currentSong.value;
        final currentSongId = int.tryParse(currentSong.id);
        final isLiked = controller.likedSongIds.contains(currentSongId);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 喜欢按钮
            _buildButtonBackground(GestureDetector(
                onTap: () => UserController.to.toggleLikeStatus(currentSong),
                child: Icon(
                    isLiked ? TablerIcons.heart_filled : TablerIcons.heart,
                    size: 30,
                    color: isLiked
                        ? Colors.red
                        : controller.panelWidgetColor.value))),
            // 上一首
            _buildButtonBackground(GestureDetector(
                onTap: () {
                  controller.playerController.skipToPreviousTrack();
                },
                child: Obx(
                  () => Icon(
                    TablerIcons.player_skip_back_filled,
                    size: 30,
                    color: controller.panelWidgetColor.value,
                  ),
                ))),
            // 播放按钮
            _buildButtonBackground(GestureDetector(
              onTap: () => controller.playOrPause(),
              child: Obx(() => Icon(
                    controller.isPlaying.value
                        ? TablerIcons.player_pause_filled
                        : TablerIcons.player_play_filled,
                    size: 60,
                    color: controller.panelWidgetColor.value,
                  )),
            )),
            // 下一首
            _buildButtonBackground(GestureDetector(
                onTap: () {
                  controller.playerController.skipToNextTrack();
                },
                child: Obx(() => Icon(
                      TablerIcons.player_skip_forward_filled,
                      size: 30,
                      color: controller.panelWidgetColor.value,
                    )))),
            // 循环模式
            _buildButtonBackground(GestureDetector(
                onTap: () async {
                  await controller.playerController.handleRepeatModeTap();
                },
                child: Obx(() => Icon(
                      controller.getRepeatIcon(),
                      size: 30,
                      color: controller.panelWidgetColor.value,
                    )))),
          ],
        );
      }),
    );
  }

  Widget _buildButtonBackground(Widget child) {
    return Obx(() => BlurryContainer(
          blur: controller.isBigAlbum.isTrue ? 0 : 5,
          padding: const EdgeInsets.all(10),
          borderRadius: BorderRadius.circular(100),
          color: controller.panelWidgetColor.value.withValues(
            alpha: controller.isBigAlbum.isTrue ? 0 : 0.05,
          ),
          child: child,
        ));
  }

  /// 评论页
  Widget _buildCommentPage(BuildContext context, int commentType) {
    double albumPadding = AppDimensions.paddingLarge;

    return KeepAliveWrapper(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: albumPadding),
        child: Obx(() {
          final currentSong = controller.currentSong.value;
          return CommentWidget(
            key: ValueKey(currentSong.id),
            context: context,
            id: currentSong.id,
            idType: "song",
            commentType: commentType,
            listPaddingTop: albumPadding,
            listPaddingBottom: albumPadding,
            stringColor: controller.panelWidgetColor.value,
          );
        }),
      ),
    );
  }
}

class _ArtistChipData {
  const _ArtistChipData({
    required this.name,
    required this.id,
  });

  final String name;
  final String id;
}

class BottomPanelHeaderView extends GetView<AppController> {
  const BottomPanelHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSong = controller.currentSong.value;
      if (currentSong.id.isEmpty) {
        return const SizedBox.shrink();
      }
      return Offstage(
        offstage: controller.bottomPanelFullyOpened.isTrue,
        child: GestureDetector(
          onTap: () => controller.openBottomPanel(),
          child: AnimatedBuilder(
            animation: controller.bottomPanelAnimationController,
            builder: (context, child) {
              // 完全展开专辑图片状态
              /// 完全展开，专辑图片Size
              double albumMaxSize =
                  context.width - AppDimensions.paddingLarge * 2;

              /// 完全展开，专辑图片Margin
              double albumMaxPadding = AppDimensions.paddingLarge;

              /// 完全展开，专辑图片Radius
              double albumMinBorderRadius = AppDimensions.paddingLarge / 2;

              /// panel展开程度
              double panelOpenDegree =
                  controller.bottomPanelAnimationController.value;
              // 实时Album宽度、margin
              double realTimeAlbumWidth = AppDimensions.albumMinSize +
                  (albumMaxSize - AppDimensions.albumMinSize) * panelOpenDegree;
              double realTimeAlbumPadding = AppDimensions.paddingSmall +
                  (albumMaxPadding - AppDimensions.paddingSmall) *
                      panelOpenDegree;
              double realTimeAlbumTopMargin =
                  (context.mediaQueryPadding.top + AppDimensions.appBarHeight) *
                      panelOpenDegree;
              double realTimeAlbumBorderRadius = AppDimensions.albumMinSize +
                  (albumMinBorderRadius - AppDimensions.albumMinSize) *
                      panelOpenDegree;

              return SizedBox(
                width: context.width,
                child: Stack(
                  children: [
                    // 歌名&歌手
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        left: (AppDimensions.albumMinSize +
                                    AppDimensions.paddingSmall * 2 -
                                    albumMaxPadding) *
                                (1 - panelOpenDegree) +
                            albumMaxPadding,
                        right: (AppDimensions.albumMinSize +
                                    AppDimensions.paddingSmall * 2 -
                                    albumMaxPadding) *
                                (1 - panelOpenDegree) +
                            albumMaxPadding,
                        top: context.mediaQueryPadding.top * panelOpenDegree,
                      ),
                      child: SizedBox(
                        height: AppDimensions.bottomPanelHeaderHeight,
                        child: Swipeable(
                          background: const SizedBox.shrink(),
                          onSwipeLeft: () =>
                              controller.playerController.skipToPreviousTrack(),
                          onSwipeRight: () =>
                              controller.playerController.skipToNextTrack(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSong.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: context.textTheme.titleLarge?.copyWith(
                                  color: controller.panelWidgetColor.value,
                                ),
                              ),
                              Text(
                                currentSong.artist ?? '',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontSize:
                                      context.textTheme.titleLarge!.fontSize! /
                                          2,
                                  color: controller.panelWidgetColor.value
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 大专辑图片
                    Visibility(
                      visible: controller.isBigAlbum.isTrue &&
                          controller.bottomPanelFullyOpened.isFalse,
                      child: Container(
                        margin: EdgeInsets.only(top: realTimeAlbumTopMargin),
                        padding: EdgeInsets.all(realTimeAlbumPadding),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                realTimeAlbumBorderRadius),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: SimpleExtendedImage(
                            width: realTimeAlbumWidth,
                            height: realTimeAlbumWidth,
                            ArtworkPathResolver.resolveDisplayPath(
                              currentSong.extras?['image'] as String?,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // 小专辑图片
                    Visibility(
                      visible: controller.isBigAlbum.isFalse &&
                          controller.bottomPanelFullyOpened.isFalse,
                      child: Container(
                        height: AppDimensions.bottomPanelHeaderHeight,
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(
                            top:
                                context.mediaQueryPadding.top * panelOpenDegree,
                            left: AppDimensions.paddingSmall +
                                panelOpenDegree *
                                    (context.width -
                                        AppDimensions.paddingLarge -
                                        AppDimensions.albumMinSize -
                                        AppDimensions.paddingSmall)),
                        child: SimpleExtendedImage(
                          width: AppDimensions.albumMinSize,
                          height: AppDimensions.albumMinSize,
                          shape: BoxShape.circle,
                          ArtworkPathResolver.resolveDisplayPath(
                            currentSong.extras?['image'] as String?,
                          ),
                        ),
                      ),
                    ),
                    // 播放按钮
                    Obx(() => Offstage(
                          offstage: controller.bottomPanelFullyClosed.isFalse,
                          child: Container(
                            alignment: Alignment.centerRight,
                            margin: const EdgeInsets.all(
                                AppDimensions.paddingSmall),
                            child: Stack(
                              children: [
                                // 播放进度
                                if ((currentSong.duration?.inMilliseconds ??
                                        0) >
                                    0)
                                  Obx(() {
                                    final currentDuration =
                                        controller.currentPosition.value;
                                    return CircularPlaybackProgress(
                                      progress: currentDuration.inMilliseconds /
                                          currentSong.duration!.inMilliseconds,
                                      size: AppDimensions.albumMinSize,
                                      strokeWidth: 2,
                                      progressColor:
                                          controller.panelWidgetColor.value,
                                      backgroundColor: controller
                                          .panelWidgetColor.value
                                          .withAlpha(50),
                                    );
                                  }),
                                // 播放按钮
                                IconButton(
                                    onPressed: () => controller.playOrPause(),
                                    padding: const EdgeInsets.all(
                                        AppDimensions.albumMinSize * 1 / 3 / 2),
                                    icon: Obx(() => Icon(
                                          controller.isPlaying.value
                                              ? TablerIcons.player_pause_filled
                                              : TablerIcons.player_play_filled,
                                          color:
                                              controller.panelWidgetColor.value,
                                          size: AppDimensions.albumMinSize *
                                              2 /
                                              3,
                                        ))),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
