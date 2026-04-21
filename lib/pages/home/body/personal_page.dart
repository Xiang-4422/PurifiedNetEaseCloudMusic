import 'package:auto_route/auto_route.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/constants/app_constants.dart';
import '../../../common/constants/other.dart';
import 'package:bujuan/features/shell/app_controller.dart';
import '../../../routes/router.gr.dart' as gr;
import '../../../widget/common_widgets.dart';
import '../../../widget/scroll_helpers.dart';
import '../../../widget/simple_extended_image.dart';

/// 这里仍保留在 `pages/home/body`，因为它和首页壳层状态绑定很紧，过早拆去 feature 只会增加跨目录跳转。
class PersonalPageView extends GetView<AppController> {
  const PersonalPageView({Key? key}) : super(key: key);

  final double albumCountInScreen = 3.2;
  final double userItemCountInScreen = 2.5;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.dateLoaded.isFalse) return const LoadingView();
      return SmartRefresher(
        onRefresh: () async {
          controller.updateData();
        },
        enablePullUp: true,
        enablePullDown: true,
        onLoading: () => controller.updateRecoPlayLists(getMore: true),
        footer: ClassicFooter(
            height: 60 + AppDimensions.bottomPanelHeaderHeight,
            outerBuilder: (child) {
              return Container(
                  height: 60,
                  margin: const EdgeInsets.only(
                      bottom: AppDimensions.bottomPanelHeaderHeight),
                  alignment: Alignment.center,
                  child: child);
            }),
        controller: controller.refreshController,
        child: CustomScrollView(cacheExtent: 120, slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: context.mediaQueryPadding.top,
            ),
          ),

          // 我的歌单 Header
          SliverToBoxAdapter(
            child: const Header('马上开始', padding: AppDimensions.paddingSmall)
                .marginOnly(top: AppDimensions.paddingSmall),
          ),

          // 快速播放卡片
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double userItemWidth = (constraints.maxWidth -
                        AppDimensions.paddingSmall *
                            userItemCountInScreen.ceil()) /
                    userItemCountInScreen;
                return Obx(() => Container(
                    margin: const EdgeInsets.only(
                        bottom: AppDimensions.paddingSmall),
                    height: userItemWidth * 1.3,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: SnappingScrollPhysics(
                          itemExtent:
                              userItemWidth + AppDimensions.paddingSmall),
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            LongPressOverlayTransition(
                              child: QuickStartCard(
                                width: userItemWidth,
                                height: userItemWidth * 1.3,
                                fallbackColor: const Color(0xFFB86A4A),
                                albumUrl:
                                    controller.todayRecommendSongs.isNotEmpty
                                        ? (controller.todayRecommendSongs[0]
                                                .extras?['image'] ??
                                            '')
                                        : '',
                                icon: TablerIcons.calendar,
                                title: "每日推荐",
                                onTap: () => context.router
                                    .push(const gr.TodayRouteView()),
                              ),
                              builder: (_) {
                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount:
                                      controller.todayRecommendSongs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return SongItem(
                                      playlist: controller.todayRecommendSongs,
                                      index: index,
                                      playListName: '',
                                    );
                                  },
                                );
                              },
                            ),
                            Visibility(
                              visible: controller.isPlaying.isTrue &&
                                  (controller.playbackSessionState.value
                                          .playlistName ==
                                      "每日推荐"),
                              replacement: IconButton(
                                  onPressed: () {
                                    if (controller.playbackSessionState.value
                                            .playlistName !=
                                        "每日推荐") {
                                      controller.playerController.playPlaylist(
                                        controller.todayRecommendSongs,
                                        0,
                                        playListName: "每日推荐",
                                      );
                                    } else {
                                      controller.playOrPause();
                                    }
                                  },
                                  icon: const Icon(
                                    TablerIcons.player_play_filled,
                                    color: Colors.white,
                                  )),
                              child: Lottie.asset(
                                  'assets/lottie/music_playing.json',
                                  width: 50),
                            )
                          ],
                        ).marginSymmetric(
                            horizontal: AppDimensions.paddingSmall),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Obx(() {
                              final runtimeState =
                                  controller.playbackRuntimeState.value;
                              return QuickStartCard(
                                width: userItemWidth,
                                height: userItemWidth * 1.3,
                                fallbackColor: const Color(0xFF2D6C8C),
                                albumUrl: controller.isFmMode.isTrue
                                    ? (runtimeState
                                            .currentSong.extras?['image'] ??
                                        '')
                                    : (controller.fmSongs.isNotEmpty
                                        ? (controller
                                                .fmSongs[0].extras?['image'] ??
                                            '')
                                        : ''),
                                icon: TablerIcons.infinity,
                                title: "漫游模式",
                                onTap: () {
                                  controller.bottomPanelPageController
                                      .jumpToPage(1);
                                  controller.bottomPanelController.open();
                                  controller.playerController.openFmMode();
                                },
                              );
                            }),
                            Offstage(
                                offstage: controller.isFmMode.isFalse ||
                                    controller.isPlaying.isFalse,
                                child: Lottie.asset(
                                    'assets/lottie/music_playing.json',
                                    width: 50)),
                          ],
                        ).marginOnly(right: AppDimensions.paddingSmall),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Obx(() {
                              final runtimeState =
                                  controller.playbackRuntimeState.value;
                              return QuickStartCard(
                                width: userItemWidth,
                                height: userItemWidth * 1.3,
                                fallbackColor: const Color(0xFF8B3D5D),
                                albumUrl: controller.isHeartBeatMode.isTrue
                                    ? (runtimeState
                                            .currentSong.extras?['image'] ??
                                        '')
                                    : controller.randomLikedSongAlbumUrl.value,
                                icon: TablerIcons.heartbeat,
                                title: "心动模式",
                                onTap: () {
                                  controller.bottomPanelPageController
                                      .jumpToPage(1);
                                  controller.bottomPanelController.open();
                                  controller.playerController.openHeartBeatMode(
                                    controller.randomLikedSongId.value,
                                    fromPlayAll: true,
                                  );
                                },
                              );
                            }),
                            Offstage(
                                offstage: controller.isHeartBeatMode.isFalse ||
                                    controller.isPlaying.isFalse,
                                child: Lottie.asset(
                                    'assets/lottie/music_playing.json',
                                    width: 50)),
                          ],
                        ).marginOnly(right: AppDimensions.paddingSmall),
                      ],
                    )));
              },
            ),
          ),

          // 我的歌单 Header
          SliverToBoxAdapter(
            child: const Header('我的歌单', padding: AppDimensions.paddingSmall)
                .marginOnly(top: AppDimensions.paddingSmall),
          ),
          // 我的歌单
          SliverToBoxAdapter(
              child: PlayListWidget(
            playLists: controller.userPlayLists,
            albumCountInWidget: 3.2,
            albumMargin: AppDimensions.paddingSmall,
            showSongCount: false,
          )),
          // 我的喜欢
          SliverToBoxAdapter(
              child: PlayListItem(controller.userLikedSongPlayList.value)
                  .paddingSymmetric(horizontal: AppDimensions.paddingSmall)),

          // 推荐歌单 Header
          SliverLayoutBuilder(
            builder: (BuildContext context, SliverConstraints constraints) {
              // 计算是否处于悬浮状态
              // 当 scrollOffset > 0 时，说明 Header 已经触顶并开始“固定”了
              final bool isPinned = constraints.scrollOffset > 0;
              return PinnedHeaderSliver(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: Colors.white,
                  padding: isPinned
                      ? EdgeInsets.only(top: context.mediaQueryPadding.top)
                      : EdgeInsets.zero,
                  child:
                      const Header('推荐歌单', padding: AppDimensions.paddingSmall),
                ),
              );
            },
          ),
          // 推荐歌单列表
          SliverList.builder(
            itemCount: controller.recoPlayLists.length,
            itemBuilder: (BuildContext context, int index) {
              return PlayListItem(controller.recoPlayLists[index])
                  .paddingSymmetric(horizontal: AppDimensions.paddingSmall);
            },
          ),
        ]),
      );
    });
  }
}

class QuickStartCard extends StatelessWidget {
  const QuickStartCard({
    Key? key,
    required this.width,
    required this.height,
    this.onTap,
    required this.albumUrl,
    required this.fallbackColor,
    this.icon,
    required this.title,
  }) : super(key: key);

  final double width;
  final double height;
  final Function()? onTap;
  final String albumUrl;
  final Color fallbackColor;
  final IconData? icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final resolvedAlbumUrl =
        OtherUtils.buildSizedImageUrl(albumUrl, size: '500y500');
    final borderRadius =
        BorderRadius.circular(AppDimensions.paddingSmall + 2);

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: SizedBox(
          width: width,
          height: height,
          child: AsyncImageColor(
            imageUrl: resolvedAlbumUrl,
            fallbackColor: fallbackColor,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: fallbackColor.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (resolvedAlbumUrl.isNotEmpty)
                    SimpleExtendedImage(
                      resolvedAlbumUrl,
                      width: width,
                      height: height,
                      cacheWidth: (width * 2).round(),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          fallbackColor.withValues(alpha: 0.88),
                          fallbackColor.withValues(alpha: 0.42),
                          Colors.black.withValues(alpha: 0.22),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.12),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.42),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (icon != null) ...[
                                Icon(
                                  icon,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 1.05,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _descriptionFor(title),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.82),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _descriptionFor(String title) {
    switch (title) {
      case '每日推荐':
        return '从今天开始，直接播';
      case '漫游模式':
        return '让队列自己延展下去';
      case '心动模式':
        return '围绕你的喜欢继续发散';
      default:
        return '';
    }
  }
}
