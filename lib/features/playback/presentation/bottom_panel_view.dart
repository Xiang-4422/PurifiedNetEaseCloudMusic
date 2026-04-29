import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/presentation/bottom_panel_artwork_layer.dart';
import 'package:bujuan/features/playback/presentation/bottom_panel_comment_page.dart';
import 'package:bujuan/features/playback/presentation/bottom_panel_header.dart';
import 'package:bujuan/features/playback/presentation/bottom_panel_playback_controls.dart';
import 'package:bujuan/features/playback/presentation/bottom_panel_queue_view.dart';
import 'package:bujuan/features/playback/presentation/lyric_view.dart';
import 'package:bujuan/features/settings/settings_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/common_widgets.dart';
import 'package:bujuan/widget/keep_alive_wrapper.dart';
import 'package:bujuan/widget/my_tab_bar.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:bujuan/widget/swipeable.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

/// BottomPanelView。
class BottomPanelView extends GetView<ShellController> {
  /// 创建 BottomPanelView。
  const BottomPanelView({Key? key}) : super(key: key);

  List<_ArtistChipData> _artistEntries(PlaybackQueueItem item) {
    final artistNames = item.artistNames.isNotEmpty
        ? item.artistNames
        : (item.artist ?? '')
            .split(' / ')
            .where((artist) => artist.isNotEmpty)
            .toList();
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
                  color: SettingsController.to.albumColor.value
                      .withValues(alpha: 0.5 + 0.5 * panelOpenDegree),
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
                                    SettingsController.to.albumColor.value
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
                                    SettingsController.to.albumColor.value
                                        .withValues(alpha: 0),
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
                  margin: EdgeInsets.symmetric(horizontal: albumPadding),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: controller.isBigAlbum.isTrue
                        ? SettingsController.to.panelWidgetColor.value
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
                              color: SettingsController
                                  .to.panelWidgetColor.value
                                  .withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(albumPadding),
                            ),
                            child: Text(
                              sessionState.playlistHeader,
                              style: context.textTheme.titleMedium?.copyWith(
                                  color: SettingsController
                                      .to.panelWidgetColor.value
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
                                    color: SettingsController
                                        .to.panelWidgetColor.value
                                        .withValues(alpha: 0.5)),
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
                        Text("播放列表",
                            style: context.textTheme.titleMedium?.copyWith(
                                color: SettingsController
                                    .to.panelWidgetColor.value
                                    .withValues(alpha: 0.5))),
                        Text("正在播放",
                            style: context.textTheme.titleMedium?.copyWith(
                                color: SettingsController
                                    .to.panelWidgetColor.value
                                    .withValues(alpha: 0.5))),
                        Obx(() => MyTabBarItemAnimatedSwitcher(
                              isTabBarVisible:
                                  controller.curPanelPageIndex.value > 1,
                              tabItem: Text("歌曲评论",
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(
                                          color: SettingsController
                                              .to.panelWidgetColor.value
                                              .withValues(alpha: 0.5))),
                              replaceItem: MyTabBar(
                                height: albumPadding,
                                controller:
                                    controller.bottomPanelCommentTabController,
                                color: SettingsController
                                    .to.panelWidgetColor.value,
                                tabs: [
                                  Text("热",
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                              color: SettingsController
                                                  .to.panelWidgetColor.value
                                                  .withValues(alpha: 0.5))),
                                  Text("新",
                                      style: context.textTheme.titleMedium
                                          ?.copyWith(
                                              color: SettingsController
                                                  .to.panelWidgetColor.value
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
    return const BottomPanelQueueView();
  }

  /// 默认页（歌词）
  Widget _buildCurPlayingPage(BuildContext context) {
    double albumPadding = AppDimensions.paddingLarge;
    double remainWidth = context.width - albumPadding * 2;
    double textWidth = _measureTextWidth("歌手：",
            TextStyle(color: SettingsController.to.panelWidgetColor.value)) +
        albumPadding +
        4;
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
                      PlayerController.to
                          .updateFullScreenLyricTimerCounter(cancelTimer: true);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: albumPadding),
                    child: const LyricView(EdgeInsets.symmetric(vertical: 10)),
                  ),
                ))),
            // 控制、进度条、页面指示占位
            Obx(() => Offstage(
                  offstage: PlayerController.to.isFullScreenLyricOpen.isTrue &&
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
                                                color: SettingsController
                                                    .to.panelWidgetColor.value
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
                                                          color: SettingsController
                                                              .to
                                                              .panelWidgetColor
                                                              .value,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      final runtimeState =
                                                          PlayerController
                                                              .to
                                                              .runtimeState
                                                              .value;
                                                      if (PlayerController
                                                          .to
                                                          .runtimeState
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
                                                                    .metadata[
                                                                'albumId']
                                                          }));
                                                    },
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        color: SettingsController
                                                            .to
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
                                                                PlayerController
                                                                    .to
                                                                    .runtimeState
                                                                    .value
                                                                    .currentSong
                                                                    .album
                                                                    .orDefault(
                                                                        "未知专辑"),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: SettingsController
                                                                        .to
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
                                              color: SettingsController
                                                  .to.panelWidgetColor.value
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
                                                        color: SettingsController
                                                            .to
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
                                                        children: PlayerController
                                                                .to
                                                                .runtimeState
                                                                .value
                                                                .currentSong
                                                                .artist
                                                                .isNullOrEmpty
                                                            ? [
                                                                Text(
                                                                  "未知歌手",
                                                                  style: TextStyle(
                                                                      color: SettingsController
                                                                          .to
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
                                                                    in _artistEntries(PlayerController
                                                                        .to
                                                                        .runtimeState
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
                                                                      color: SettingsController
                                                                          .to
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
                                                                                style: TextStyle(color: SettingsController.to.panelWidgetColor.value),
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
                                    const BottomPanelProgressBar()
                                        .marginOnly(top: albumPadding),
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

  double _measureTextWidth(String text, TextStyle style,
      {double maxWidth = double.infinity, int? maxLines}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr, // 必须设置文本方向
      maxLines: maxLines, // 可选：如果文本有行数限制
    )..layout(minWidth: 0, maxWidth: maxWidth); // 布局文本，给定最大宽度

    return textPainter.size.width; // 返回计算出的宽度
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

/// BottomPanelHeaderView。
class BottomPanelHeaderView extends GetView<ShellController> {
  /// 创建 BottomPanelHeaderView。
  const BottomPanelHeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSong = PlayerController.to.currentSongState.value;
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
                              PlayerController.to.skipToPreviousTrack(),
                          onSwipeRight: () =>
                              PlayerController.to.skipToNextTrack(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSong.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: context.textTheme.titleLarge?.copyWith(
                                  color: SettingsController
                                      .to.panelWidgetColor.value,
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
                                  color: SettingsController
                                      .to.panelWidgetColor.value
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
                              currentSong.artworkUrl ??
                                  currentSong.localArtworkPath,
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
                            currentSong.artworkUrl ??
                                currentSong.localArtworkPath,
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
                                    final currentDuration = PlayerController
                                        .to.currentPositionState.value;
                                    return CircularPlaybackProgress(
                                      progress: currentDuration.inMilliseconds /
                                          currentSong.duration!.inMilliseconds,
                                      size: AppDimensions.albumMinSize,
                                      strokeWidth: 2,
                                      progressColor: SettingsController
                                          .to.panelWidgetColor.value,
                                      backgroundColor: SettingsController
                                          .to.panelWidgetColor.value
                                          .withAlpha(50),
                                    );
                                  }),
                                // 播放按钮
                                IconButton(
                                    onPressed: () =>
                                        PlayerController.to.playOrPause(),
                                    padding: const EdgeInsets.all(
                                        AppDimensions.albumMinSize * 1 / 3 / 2),
                                    icon: Obx(() => Icon(
                                          PlayerController.to.isPlaying.value
                                              ? TablerIcons.player_pause_filled
                                              : TablerIcons.player_play_filled,
                                          color: SettingsController
                                              .to.panelWidgetColor.value,
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
