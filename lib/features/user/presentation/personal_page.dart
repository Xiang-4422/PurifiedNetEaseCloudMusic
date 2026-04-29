import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/user_controller.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;
import 'package:bujuan/widget/common_widgets.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/scroll_helpers.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PersonalPageView extends GetView<ShellController> {
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
                                albumUrl: UserController
                                        .to.todayRecommendSongs.isNotEmpty
                                    ? (UserController.to.todayRecommendSongs[0]
                                            .artworkUrl ??
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
                                  itemCount: UserController
                                      .to.todayRecommendSongs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return SongItem(
                                      playlist:
                                          UserController.to.todayRecommendSongs,
                                      index: index,
                                      playListName: '',
                                    );
                                  },
                                );
                              },
                            ),
                            Visibility(
                              visible: PlayerController.to.isPlaying.isTrue &&
                                  (PlayerController
                                          .to.sessionState.value.playlistName ==
                                      "每日推荐"),
                              replacement: IconButton(
                                  onPressed: () {
                                    if (PlayerController.to.sessionState.value
                                            .playlistName !=
                                        "每日推荐") {
                                      PlayerController.to.playPlaylist(
                                        UserController.to.todayRecommendSongs,
                                        0,
                                        playListName: "每日推荐",
                                      );
                                    } else {
                                      PlayerController.to.playOrPause();
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
                              final currentSong =
                                  PlayerController.to.currentSongState.value;
                              return QuickStartCard(
                                width: userItemWidth,
                                height: userItemWidth * 1.3,
                                albumUrl: PlayerController.to.isFmMode.isTrue
                                    ? (currentSong.artworkUrl ?? '')
                                    : (UserController.to.fmSongs.isNotEmpty
                                        ? (UserController
                                                .to.fmSongs[0].artworkUrl ??
                                            '')
                                        : ''),
                                icon: TablerIcons.infinity,
                                title: "漫游模式",
                                onTap: () {
                                  controller.jumpBottomPanelToPage(1);
                                  controller.openBottomPanel();
                                  PlayerController.to.openFmMode();
                                },
                              );
                            }),
                            Offstage(
                                offstage:
                                    PlayerController.to.isFmMode.isFalse ||
                                        PlayerController.to.isPlaying.isFalse,
                                child: Lottie.asset(
                                    'assets/lottie/music_playing.json',
                                    width: 50)),
                          ],
                        ).marginOnly(right: AppDimensions.paddingSmall),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Obx(() {
                              final currentSong =
                                  PlayerController.to.currentSongState.value;
                              return QuickStartCard(
                                width: userItemWidth,
                                height: userItemWidth * 1.3,
                                albumUrl:
                                    PlayerController.to.isHeartBeatMode.isTrue
                                        ? (currentSong.artworkUrl ?? '')
                                        : UserController
                                            .to.randomLikedSongAlbumUrl.value,
                                icon: TablerIcons.heartbeat,
                                title: "心动模式",
                                onTap: () {
                                  controller.jumpBottomPanelToPage(1);
                                  controller.openBottomPanel();
                                  PlayerController.to.openHeartBeatMode(
                                    UserController.to.randomLikedSongId.value,
                                    fromPlayAll: true,
                                  );
                                },
                              );
                            }),
                            Offstage(
                                offstage: PlayerController
                                        .to.isHeartBeatMode.isFalse ||
                                    PlayerController.to.isPlaying.isFalse,
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
            playLists: UserController.to.userPlayLists,
            albumCountInWidget: 3.2,
            albumMargin: AppDimensions.paddingSmall,
            showSongCount: false,
          )),
          // 我的喜欢
          SliverToBoxAdapter(
              child: PlayListItem(UserController.to.userLikedSongPlayList.value)
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
            itemCount: UserController.to.recoPlayLists.length,
            itemBuilder: (BuildContext context, int index) {
              return PlayListItem(UserController.to.recoPlayLists[index])
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
    this.icon,
    required this.title,
  }) : super(key: key);

  final double width;
  final double height;
  final Function()? onTap;
  final String albumUrl;
  final IconData? icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    bool isEnabled = onTap != null;
    final localAlbumPath = ArtworkPathResolver.resolveDisplayPath(albumUrl);

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          width: width,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.paddingSmall),
          ),
          child: AsyncImageColor(
            imageUrl: localAlbumPath,
            child: Column(
              children: [
                Expanded(
                    child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black, Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      icon == null
                          ? const SizedBox.shrink()
                          : Icon(
                              icon,
                              color: Colors.white,
                            ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
                SimpleExtendedImage(
                  height: width,
                  width: width,
                  localAlbumPath,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
