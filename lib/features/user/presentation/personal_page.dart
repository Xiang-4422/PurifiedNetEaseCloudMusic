import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/features/playback/application/playback_action_port.dart';
import 'package:bujuan/features/playlist/application/playlist_playback_action.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/presentation/personal_home_layout_metrics.dart';
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

/// 个人首页，展示快速播放、推荐歌单和用户歌单入口。
class PersonalPageView extends GetView<ShellController> {
  /// 创建个人首页。
  const PersonalPageView({Key? key}) : super(key: key);

  /// 横向区域中一屏展示的歌单卡片数量。
  final double albumCountInScreen = 3.2;

  /// 横向区域中一屏展示的快速入口卡片数量。
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
      final layoutMetrics = PersonalHomeLayoutMetrics(
        MediaQuery.sizeOf(context),
      );
      if (layoutMetrics.isSquareLike) {
        return _SquarePersonalPageView(
          metrics: layoutMetrics,
          recommendationController: recommendationController,
          libraryController: libraryController,
          playbackAction: playbackAction,
          shellController: controller,
        );
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

class _SquarePersonalPageView extends StatefulWidget {
  const _SquarePersonalPageView({
    required this.metrics,
    required this.recommendationController,
    required this.libraryController,
    required this.playbackAction,
    required this.shellController,
  });

  final PersonalHomeLayoutMetrics metrics;
  final RecommendationController recommendationController;
  final UserLibraryController libraryController;
  final PlaybackActionPort playbackAction;
  final ShellController shellController;

  @override
  State<_SquarePersonalPageView> createState() =>
      _SquarePersonalPageViewState();
}

class _SquarePersonalPageViewState extends State<_SquarePersonalPageView> {
  final PageController _pageController = PageController();
  final ScrollController _recommendedScrollController = ScrollController();
  int _pageIndex = 0;
  bool _recommendedListAwayFromBoundary = false;
  bool _recommendedPageTurnInFlight = false;

  @override
  void dispose() {
    _pageController.dispose();
    _recommendedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: _pageIndex == 2 && _recommendedListAwayFromBoundary
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            onPageChanged: (index) => setState(() => _pageIndex = index),
            children: [
              _buildQuickStartPage(context),
              _buildLibraryPage(context),
              _buildRecommendedPage(context),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.bottomPanelHeaderHeight),
      ],
    );
  }

  Widget _buildQuickStartPage(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentHeight = constraints.maxHeight -
              widget.metrics.squareHeaderHeight -
              AppDimensions.paddingSmall * 2;
          final cardSize = widget.metrics.squareQuickCardSize(
            maxWidth: constraints.maxWidth,
            maxHeight: contentHeight,
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(
                '马上开始',
                padding: AppDimensions.paddingSmall,
                height: widget.metrics.squareHeaderHeight,
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: cardSize.height,
                    child: _buildQuickStartCards(
                      context,
                      cardSize: cardSize,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLibraryPage(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(
                '我的歌单',
                padding: AppDimensions.paddingSmall,
                height: widget.metrics.squareHeaderHeight,
              ),
              Obx(
                () => PlayListWidget(
                  playLists: widget.libraryController.userPlayLists,
                  albumCountInWidget: widget.metrics.squarePlaylistCardCount,
                  albumMargin: AppDimensions.paddingSmall,
                  showSongCount: false,
                  isPlaying: widget.playbackAction.isPlaying(),
                  playingPlaylistName:
                      widget.playbackAction.sessionState().playlistName,
                  onPlayPlaylist: Get.find<PlaylistPlaybackAction>().play,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              PlayListItem(widget.libraryController.userLikedSongPlayList.value)
                  .paddingSymmetric(horizontal: AppDimensions.paddingSmall),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecommendedPage(BuildContext context) {
    return SmartRefresher(
      onRefresh: () async {
        await widget.recommendationController.updateData();
      },
      enablePullUp: true,
      enablePullDown: true,
      onLoading: () =>
          widget.recommendationController.updateRecoPlayLists(getMore: true),
      footer: ClassicFooter(
        height: 60,
        outerBuilder: (child) {
          return SizedBox(
            height: 60,
            child: Center(child: child),
          );
        },
      ),
      controller: widget.recommendationController.refreshController,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleRecommendedScrollNotification,
        child: CustomScrollView(
          controller: _recommendedScrollController,
          cacheExtent: 120,
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: context.mediaQueryPadding.top),
            ),
            SliverToBoxAdapter(
              child: Header(
                '推荐歌单',
                padding: AppDimensions.paddingSmall,
                height: widget.metrics.squareHeaderHeight,
              ),
            ),
            SliverList.builder(
              itemCount: widget.recommendationController.recoPlayLists.length,
              itemBuilder: (BuildContext context, int index) {
                return PlayListItem(
                  widget.recommendationController.recoPlayLists[index],
                ).paddingSymmetric(horizontal: AppDimensions.paddingSmall);
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _handleRecommendedScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final metrics = notification.metrics;
    if (notification is OverscrollNotification &&
        notification.overscroll < 0 &&
        metrics.pixels <= metrics.minScrollExtent + 12) {
      _goToPreviousSquarePageFromRecommended();
      return false;
    }
    final canScroll = metrics.maxScrollExtent > metrics.minScrollExtent;
    final awayFromBoundary = canScroll &&
        metrics.pixels > metrics.minScrollExtent + 12 &&
        metrics.pixels < metrics.maxScrollExtent - 12;
    if (awayFromBoundary != _recommendedListAwayFromBoundary) {
      setState(() => _recommendedListAwayFromBoundary = awayFromBoundary);
    }
    return false;
  }

  void _goToPreviousSquarePageFromRecommended() {
    if (_pageIndex != 2 ||
        _recommendedPageTurnInFlight ||
        !_pageController.hasClients) {
      return;
    }
    _recommendedPageTurnInFlight = true;
    _recommendedListAwayFromBoundary = false;
    _pageController
        .previousPage(
          duration: AppDurations.animationDurationShort,
          curve: Curves.easeOut,
        )
        .whenComplete(() => _recommendedPageTurnInFlight = false);
  }

  Widget _buildQuickStartCards(
    BuildContext context, {
    required Size cardSize,
  }) {
    final recommendationController = widget.recommendationController;
    final libraryController = widget.libraryController;
    final playbackAction = widget.playbackAction;
    return Obx(
      () => ListView(
        scrollDirection: Axis.horizontal,
        physics: SnappingScrollPhysics(
          itemExtent: cardSize.width + AppDimensions.paddingSmall,
        ),
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              LongPressOverlayTransition(
                child: QuickStartCard(
                  width: cardSize.width,
                  height: cardSize.height,
                  albumUrl:
                      recommendationController.todayRecommendSongs.isNotEmpty
                          ? (recommendationController
                                  .todayRecommendSongs[0].artworkUrl ??
                              '')
                          : '',
                  icon: TablerIcons.calendar,
                  title: '每日推荐',
                  onTap: () => context.router.push(const gr.TodayRouteView()),
                ),
                builder: (_) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount:
                        recommendationController.todayRecommendSongs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SongItem(
                        playlist: recommendationController.todayRecommendSongs,
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
                    playbackAction.sessionState().playlistName == '每日推荐',
                replacement: IconButton(
                  onPressed: () {
                    if (playbackAction.sessionState().playlistName != '每日推荐') {
                      playbackAction.playPlaylist(
                        recommendationController.todayRecommendSongs,
                        0,
                        playListName: '每日推荐',
                      );
                    } else {
                      playbackAction.playOrPause();
                    }
                  },
                  icon: const Icon(
                    TablerIcons.player_play_filled,
                    color: Colors.white,
                  ),
                ),
                child: Lottie.asset(
                  'assets/lottie/music_playing.json',
                  width: 50,
                ),
              ),
            ],
          ).marginSymmetric(horizontal: AppDimensions.paddingSmall),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Obx(() {
                final currentSong = playbackAction.currentSong();
                return QuickStartCard(
                  width: cardSize.width,
                  height: cardSize.height,
                  albumUrl: playbackAction.isFmMode()
                      ? (currentSong.artworkUrl ?? '')
                      : (recommendationController.fmSongs.isNotEmpty
                          ? (recommendationController.fmSongs[0].artworkUrl ??
                              '')
                          : ''),
                  icon: TablerIcons.infinity,
                  title: '漫游模式',
                  onTap: () {
                    widget.shellController.jumpBottomPanelToPage(1);
                    widget.shellController.openBottomPanel();
                    playbackAction.openFmMode();
                  },
                );
              }),
              Offstage(
                offstage:
                    !playbackAction.isFmMode() || !playbackAction.isPlaying(),
                child: Lottie.asset(
                  'assets/lottie/music_playing.json',
                  width: 50,
                ),
              ),
            ],
          ).marginOnly(right: AppDimensions.paddingSmall),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Obx(() {
                final currentSong = playbackAction.currentSong();
                return QuickStartCard(
                  width: cardSize.width,
                  height: cardSize.height,
                  albumUrl: playbackAction.isHeartBeatMode()
                      ? (currentSong.artworkUrl ?? '')
                      : libraryController.randomLikedSongAlbumUrl.value,
                  icon: TablerIcons.heartbeat,
                  title: '心动模式',
                  onTap: () {
                    widget.shellController.jumpBottomPanelToPage(1);
                    widget.shellController.openBottomPanel();
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
                  width: 50,
                ),
              ),
            ],
          ).marginOnly(right: AppDimensions.paddingSmall),
        ],
      ),
    );
  }
}

/// 个人首页顶部的快速播放入口卡片。
class QuickStartCard extends StatelessWidget {
  /// 创建快速播放入口卡片。
  const QuickStartCard({
    Key? key,
    required this.width,
    required this.height,
    this.onTap,
    required this.albumUrl,
    this.icon,
    required this.title,
  }) : super(key: key);

  /// 卡片宽度。
  final double width;

  /// 卡片高度。
  final double height;

  /// 点击卡片时触发的动作；为空时卡片呈禁用态。
  final Function()? onTap;

  /// 卡片背景封面地址。
  final String albumUrl;

  /// 卡片前景图标。
  final IconData? icon;

  /// 卡片标题。
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
          height: height,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.paddingSmall),
          ),
          child: AsyncImageColor(
            imageUrl: localAlbumPath,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final imageSize = math.min(
                  width,
                  constraints.maxHeight * 0.78,
                );
                return Column(
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
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: SimpleExtendedImage(
                        localAlbumPath,
                        height: imageSize,
                        width: imageSize,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
