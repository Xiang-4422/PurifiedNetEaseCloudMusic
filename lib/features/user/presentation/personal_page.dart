import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/playback/application/playback_action_port.dart';
import 'package:bujuan/features/playlist/application/playlist_playback_action.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
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

/// PersonalPageView。
class PersonalPageView extends GetView<ShellController> {
  /// 创建 PersonalPageView。
  const PersonalPageView({Key? key}) : super(key: key);

  /// albumCountInScreen。
  final double albumCountInScreen = 3.2;

  /// userItemCountInScreen。
  final double userItemCountInScreen = 2.5;

  @override
  Widget build(BuildContext context) {
    final recommendationController = RecommendationController.to;
    final libraryController = UserLibraryController.to;
    final playbackAction = Get.find<PlaybackActionPort>();
    return Obx(() {
      if (recommendationController.dateLoaded.isFalse) {
        return const LoadingView();
      }
      return SmartRefresher(
        onRefresh: () async {
          recommendationController.updateData();
        },
        enablePullUp: true,
        enablePullDown: true,
        onLoading: () =>
            recommendationController.updateRecoPlayLists(getMore: true),
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
        controller: recommendationController.refreshController,
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
                                albumUrl: recommendationController
                                        .todayRecommendSongs.isNotEmpty
                                    ? (recommendationController
                                            .todayRecommendSongs[0]
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
                                  itemCount: recommendationController
                                      .todayRecommendSongs.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return SongItem(
                                      playlist: recommendationController
                                          .todayRecommendSongs,
                                      index: index,
                                      playListName: '',
                                      onPlay: playbackAction.playPlaylist,
                                    );
                                  },
                                );
                              },
                            ),
                            Visibility(
                              visible: playbackAction.isPlaying() &&
                                  (playbackAction.sessionState().playlistName ==
                                      "每日推荐"),
                              replacement: IconButton(
                                  onPressed: () {
                                    if (playbackAction
                                            .sessionState()
                                            .playlistName !=
                                        "每日推荐") {
                                      playbackAction.playPlaylist(
                                        recommendationController
                                            .todayRecommendSongs,
                                        0,
                                        playListName: "每日推荐",
                                      );
                                    } else {
                                      playbackAction.playOrPause();
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
                              final currentSong = playbackAction.currentSong();
                              return QuickStartCard(
                                width: userItemWidth,
                                height: userItemWidth * 1.3,
                                albumUrl: playbackAction.isFmMode()
                                    ? (currentSong.artworkUrl ?? '')
                                    : (recommendationController
                                            .fmSongs.isNotEmpty
                                        ? (recommendationController
                                                .fmSongs[0].artworkUrl ??
                                            '')
                                        : ''),
                                icon: TablerIcons.infinity,
                                title: "漫游模式",
                                onTap: () {
                                  controller.jumpBottomPanelToPage(1);
                                  controller.openBottomPanel();
                                  playbackAction.openFmMode();
                                },
                              );
                            }),
                            Offstage(
                                offstage: !playbackAction.isFmMode() ||
                                    !playbackAction.isPlaying(),
                                child: Lottie.asset(
                                    'assets/lottie/music_playing.json',
                                    width: 50)),
                          ],
                        ).marginOnly(right: AppDimensions.paddingSmall),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Obx(() {
                              final currentSong = playbackAction.currentSong();
                              return QuickStartCard(
                                width: userItemWidth,
                                height: userItemWidth * 1.3,
                                albumUrl: playbackAction.isHeartBeatMode()
                                    ? (currentSong.artworkUrl ?? '')
                                    : libraryController
                                        .randomLikedSongAlbumUrl.value,
                                icon: TablerIcons.heartbeat,
                                title: "心动模式",
                                onTap: () {
                                  controller.jumpBottomPanelToPage(1);
                                  controller.openBottomPanel();
                                  playbackAction.openHeartBeatMode(
                                    libraryController.randomLikedSongId.value,
                                    fromPlayAll: true,
                                  );
                                },
                              );
                            }),
                            Offstage(
                                offstage: !playbackAction.isHeartBeatMode() ||
                                    !playbackAction.isPlaying(),
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
            child: Obx(
              () => PlayListWidget(
                playLists: libraryController.userPlayLists,
                albumCountInWidget: 3.2,
                albumMargin: AppDimensions.paddingSmall,
                showSongCount: false,
                isPlaying: playbackAction.isPlaying(),
                playingPlaylistName: playbackAction.sessionState().playlistName,
                onPlayPlaylist: Get.find<PlaylistPlaybackAction>().play,
              ),
            ),
          ),
          // 我的喜欢
          SliverToBoxAdapter(
              child: PlayListItem(libraryController.userLikedSongPlayList.value)
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
            itemCount: recommendationController.recoPlayLists.length,
            itemBuilder: (BuildContext context, int index) {
              return PlayListItem(recommendationController.recoPlayLists[index])
                  .paddingSymmetric(horizontal: AppDimensions.paddingSmall);
            },
          ),
        ]),
      );
    });
  }
}

/// QuickStartCard。
class QuickStartCard extends StatelessWidget {
  /// 创建 QuickStartCard。
  const QuickStartCard({
    Key? key,
    required this.width,
    required this.height,
    this.onTap,
    required this.albumUrl,
    this.icon,
    required this.title,
  }) : super(key: key);

  /// width。
  final double width;

  /// height。
  final double height;

  /// 创建 Function。
  final Function()? onTap;

  /// albumUrl。
  final String albumUrl;

  /// icon。
  final IconData? icon;

  /// title。
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
