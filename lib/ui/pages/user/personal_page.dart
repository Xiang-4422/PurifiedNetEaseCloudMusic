import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playback/recent_playback_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/ui/pages/user/widgets/library_shortcut_bar.dart';
import 'package:bujuan/ui/pages/user/widgets/recent_playback_strip.dart';
import 'package:bujuan/ui/widgets/playlist/playlist_widgets.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/widgets/user/personal_home_layout_metrics.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/assets/app_assets.dart';
import 'package:bujuan/app/routing/router.gr.dart' as gr;
import 'package:bujuan/ui/widgets/common/image/async_image_color.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/interaction/long_press_overlay_transition.dart';
import 'package:bujuan/ui/widgets/common/refresh/app_smart_refresher.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:bujuan/ui/widgets/common/layout/scroll_helpers.dart';
import 'package:bujuan/ui/widgets/common/layout/section_header.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

Future<void> _playPlaylistSummary(PlaylistSummaryData playlist) async {
  final playerController = Get.find<PlayerController>();
  if (playerController.sessionState.value.playlistName == playlist.title) {
    await playerController.playOrPause();
    return;
  }
  final likedSongIds = UserLibraryController.to.likedSongIds.toList();
  final repository = Get.find<PlaylistRepository>();
  final index = await repository.fetchPlaylistIndex(
    playlist.id,
    likedSongIds: likedSongIds,
  );
  final songs = await repository.fetchPlaylistSongs(
    playlistId: playlist.id,
    likedSongIds: likedSongIds,
    playlistIndex: index,
  );
  await playerController.playPlaylist(
    songs,
    0,
    playListName: index.name,
    playListNameHeader: '歌单',
  );
}

String _playbackArtworkPath(PlaybackQueueItem item) {
  return ArtworkPathResolver.resolvePlaybackArtwork(
        artworkUrl: item.artworkUrl,
        localArtworkPath: item.localArtworkPath,
      ) ??
      '';
}

String _firstPlaybackArtworkPath(List<PlaybackQueueItem> songs) {
  if (songs.isEmpty) {
    return '';
  }
  return _playbackArtworkPath(songs.first);
}

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
    final playbackAction = Get.find<PlayerController>();
    final recentPlaybackController = RecentPlaybackController.to;
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
          recentPlaybackController: recentPlaybackController,
          shellController: controller,
        );
      }
      return AppSmartRefresher(
        controller: recommendationController.refreshController,
        enablePullUp: true,
        onLoading: () => recommendationController.updateRecoPlayLists(getMore: true),
        child: CustomScrollView(cacheExtent: 120, physics: const ClampingScrollPhysics(), slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: context.mediaQueryPadding.top,
            ),
          ),

          // 我的歌单 Header
          SliverToBoxAdapter(
            child: const Header('马上开始', padding: AppDimensions.paddingSmall).marginOnly(top: AppDimensions.paddingSmall),
          ),

          // 快速播放卡片
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double userItemWidth = (constraints.maxWidth - AppDimensions.paddingSmall * userItemCountInScreen.ceil()) / userItemCountInScreen;
                return Obx(() => Container(
                    margin: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                    height: userItemWidth * 1.3,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: SnappingScrollPhysics(itemExtent: userItemWidth + AppDimensions.paddingSmall),
                      children: [
                        _ContinuePlaybackQuickStartCard(
                          width: userItemWidth,
                          height: userItemWidth * 1.3,
                          playbackAction: playbackAction,
                          shellController: controller,
                        ).marginSymmetric(horizontal: AppDimensions.paddingSmall),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            LongPressOverlayTransition(
                              child: QuickStartCard(
                                width: userItemWidth,
                                height: userItemWidth * 1.3,
                                albumUrl: _firstPlaybackArtworkPath(
                                  recommendationController.todayRecommendSongs,
                                ),
                                icon: TablerIcons.calendar,
                                title: "每日推荐",
                                onTap: () => context.router.push(const gr.TodayRouteView()),
                              ),
                              builder: (_) {
                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: recommendationController.todayRecommendSongs.length,
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
                              visible: playbackAction.isPlaying.value && (playbackAction.sessionState.value.playlistName == "每日推荐"),
                              replacement: IconButton(
                                  onPressed: () {
                                    if (playbackAction.sessionState.value.playlistName != "每日推荐") {
                                      playbackAction.playPlaylist(
                                        recommendationController.todayRecommendSongs,
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
                              child: Lottie.asset(AppAssets.lottieMusicPlaying, width: 50),
                            )
                          ],
                        ).marginOnly(right: AppDimensions.paddingSmall),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Obx(() {
                              final currentSong = playbackAction.currentSongState.value;
                              return QuickStartCard(
                                width: userItemWidth,
                                height: userItemWidth * 1.3,
                                albumUrl: playbackAction.isFmModeValue
                                    ? _playbackArtworkPath(currentSong)
                                    : _firstPlaybackArtworkPath(
                                        recommendationController.fmSongs,
                                      ),
                                icon: TablerIcons.infinity,
                                title: "漫游模式",
                                onTap: () {
                                  controller.jumpBottomPanelToPage(1);
                                  controller.openBottomPanel();
                                  playbackAction.openFmMode();
                                },
                              );
                            }),
                            Offstage(offstage: !playbackAction.isFmModeValue || !playbackAction.isPlaying.value, child: Lottie.asset(AppAssets.lottieMusicPlaying, width: 50)),
                          ],
                        ).marginOnly(right: AppDimensions.paddingSmall),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Obx(() {
                              final currentSong = playbackAction.currentSongState.value;
                              return QuickStartCard(
                                width: userItemWidth,
                                height: userItemWidth * 1.3,
                                albumUrl: playbackAction.isHeartBeatModeValue ? _playbackArtworkPath(currentSong) : libraryController.randomLikedSongAlbumUrl.value,
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
                            Offstage(offstage: !playbackAction.isHeartBeatModeValue || !playbackAction.isPlaying.value, child: Lottie.asset(AppAssets.lottieMusicPlaying, width: 50)),
                          ],
                        ).marginOnly(right: AppDimensions.paddingSmall),
                      ],
                    )));
              },
            ),
          ),

          SliverToBoxAdapter(
            child: RecentPlaybackStrip(
              controller: recentPlaybackController,
              playbackAction: playbackAction,
            ),
          ),

          // 常用歌单 Header
          SliverToBoxAdapter(
            child: const Header('常用歌单', padding: AppDimensions.paddingSmall).marginOnly(top: AppDimensions.paddingSmall),
          ),
          // 常用歌单
          SliverToBoxAdapter(
            child: Obx(
              () => PlayListWidget(
                playLists: libraryController.homeFrequentPlaylists,
                albumCountInWidget: 3.2,
                albumMargin: AppDimensions.paddingSmall,
                showSongCount: false,
                isPlaying: playbackAction.isPlaying.value,
                playingPlaylistName: playbackAction.sessionState.value.playlistName,
                onPlayPlaylist: _playPlaylistSummary,
              ),
            ),
          ),
          // 我的喜欢
          SliverToBoxAdapter(child: PlayListItem(libraryController.userLikedSongPlayList.value).paddingSymmetric(horizontal: AppDimensions.paddingSmall)),

          SliverToBoxAdapter(
            child: const Header('资料库', padding: AppDimensions.paddingSmall).marginOnly(top: AppDimensions.paddingSmall),
          ),
          const SliverToBoxAdapter(
            child: LibraryShortcutBar(),
          ),

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
                  padding: isPinned ? EdgeInsets.only(top: context.mediaQueryPadding.top) : EdgeInsets.zero,
                  child: const Header('推荐歌单', padding: AppDimensions.paddingSmall),
                ),
              );
            },
          ),
          // 推荐歌单列表
          SliverList.builder(
            itemCount: recommendationController.recoPlayLists.length,
            itemBuilder: (BuildContext context, int index) {
              return PlayListItem(recommendationController.recoPlayLists[index]).paddingSymmetric(horizontal: AppDimensions.paddingSmall);
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.bottomPanelHeaderHeight),
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
    required this.recentPlaybackController,
    required this.shellController,
  });

  final PersonalHomeLayoutMetrics metrics;
  final RecommendationController recommendationController;
  final UserLibraryController libraryController;
  final PlayerController playbackAction;
  final RecentPlaybackController recentPlaybackController;
  final ShellController shellController;

  @override
  State<_SquarePersonalPageView> createState() => _SquarePersonalPageViewState();
}

class _SquarePersonalPageViewState extends State<_SquarePersonalPageView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
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
            physics: const PageScrollPhysics(),
            children: [
              _buildQuickStartPage(context),
              _buildLibraryPage(context),
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
          final contentHeight = constraints.maxHeight - widget.metrics.squareHeaderHeight - AppDimensions.paddingSmall * 2;
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
      child: CustomScrollView(
        cacheExtent: 120,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: RecentPlaybackStrip(
              controller: widget.recentPlaybackController,
              playbackAction: widget.playbackAction,
            ),
          ),
          SliverToBoxAdapter(
            child: Header(
              '常用歌单',
              padding: AppDimensions.paddingSmall,
              height: widget.metrics.squareHeaderHeight,
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(
              () => PlayListWidget(
                playLists: widget.libraryController.homeFrequentPlaylists,
                albumCountInWidget: widget.metrics.squarePlaylistCardCount,
                albumMargin: AppDimensions.paddingSmall,
                showSongCount: false,
                isPlaying: widget.playbackAction.isPlaying.value,
                playingPlaylistName: widget.playbackAction.sessionState.value.playlistName,
                onPlayPlaylist: _playPlaylistSummary,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.paddingSmall),
          ),
          SliverToBoxAdapter(
            child: PlayListItem(widget.libraryController.userLikedSongPlayList.value).paddingSymmetric(horizontal: AppDimensions.paddingSmall),
          ),
          SliverToBoxAdapter(
            child: Header(
              '资料库',
              padding: AppDimensions.paddingSmall,
              height: widget.metrics.squareHeaderHeight,
            ),
          ),
          const SliverToBoxAdapter(
            child: LibraryShortcutBar(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.paddingSmall),
          ),
        ],
      ),
    );
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
          _ContinuePlaybackQuickStartCard(
            width: cardSize.width,
            height: cardSize.height,
            playbackAction: playbackAction,
            shellController: widget.shellController,
          ).marginSymmetric(horizontal: AppDimensions.paddingSmall),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              LongPressOverlayTransition(
                child: QuickStartCard(
                  width: cardSize.width,
                  height: cardSize.height,
                  albumUrl: _firstPlaybackArtworkPath(
                    recommendationController.todayRecommendSongs,
                  ),
                  icon: TablerIcons.calendar,
                  title: '每日推荐',
                  onTap: () => context.router.push(const gr.TodayRouteView()),
                ),
                builder: (_) {
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: recommendationController.todayRecommendSongs.length,
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
                visible: playbackAction.isPlaying.value && playbackAction.sessionState.value.playlistName == '每日推荐',
                replacement: IconButton(
                  onPressed: () {
                    if (playbackAction.sessionState.value.playlistName != '每日推荐') {
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
                  AppAssets.lottieMusicPlaying,
                  width: 50,
                ),
              ),
            ],
          ).marginOnly(right: AppDimensions.paddingSmall),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Obx(() {
                final currentSong = playbackAction.currentSongState.value;
                return QuickStartCard(
                  width: cardSize.width,
                  height: cardSize.height,
                  albumUrl: playbackAction.isFmModeValue
                      ? _playbackArtworkPath(currentSong)
                      : _firstPlaybackArtworkPath(
                          recommendationController.fmSongs,
                        ),
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
                offstage: !playbackAction.isFmModeValue || !playbackAction.isPlaying.value,
                child: Lottie.asset(
                  AppAssets.lottieMusicPlaying,
                  width: 50,
                ),
              ),
            ],
          ).marginOnly(right: AppDimensions.paddingSmall),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Obx(() {
                final currentSong = playbackAction.currentSongState.value;
                return QuickStartCard(
                  width: cardSize.width,
                  height: cardSize.height,
                  albumUrl: playbackAction.isHeartBeatModeValue ? _playbackArtworkPath(currentSong) : libraryController.randomLikedSongAlbumUrl.value,
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
                offstage: !playbackAction.isHeartBeatModeValue || !playbackAction.isPlaying.value,
                child: Lottie.asset(
                  AppAssets.lottieMusicPlaying,
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

class _ContinuePlaybackQuickStartCard extends StatelessWidget {
  const _ContinuePlaybackQuickStartCard({
    required this.width,
    required this.height,
    required this.playbackAction,
    required this.shellController,
  });

  final double width;
  final double height;
  final PlayerController playbackAction;
  final ShellController shellController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSong = playbackAction.currentSongState.value;
      final hasCurrentSong = currentSong.id.isNotEmpty;
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          QuickStartCard(
            width: width,
            height: height,
            albumUrl: _playbackArtworkPath(currentSong),
            icon: TablerIcons.player_play,
            title: '继续播放',
            onTap: hasCurrentSong
                ? () async {
                    shellController.jumpBottomPanelToPage(1);
                    shellController.openBottomPanel();
                    if (!playbackAction.isPlaying.value) {
                      await playbackAction.playOrPause();
                    }
                  }
                : null,
          ),
          Offstage(
            offstage: !hasCurrentSong || !playbackAction.isPlaying.value,
            child: Lottie.asset(
              AppAssets.lottieMusicPlaying,
              width: 50,
            ),
          ),
        ],
      );
    });
  }
}

/// 方屏首页侧边菜单中的独立推荐歌单页。
class RecommendedPlaylistsPageView extends StatelessWidget {
  /// 创建独立推荐歌单页。
  const RecommendedPlaylistsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final recommendationController = RecommendationController.to;
    return Obx(() {
      if (recommendationController.dateLoaded.isFalse) {
        return const LoadingView();
      }
      return AppSmartRefresher(
        controller: recommendationController.refreshController,
        enablePullUp: true,
        onLoading: () => recommendationController.updateRecoPlayLists(getMore: true),
        child: CustomScrollView(
          cacheExtent: 120,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: context.mediaQueryPadding.top),
            ),
            const SliverToBoxAdapter(
              child: Header(
                '推荐歌单',
                padding: AppDimensions.paddingSmall,
              ),
            ),
            SliverList.builder(
              itemCount: recommendationController.recoPlayLists.length,
              itemBuilder: (BuildContext context, int index) {
                return PlayListItem(recommendationController.recoPlayLists[index]).paddingSymmetric(horizontal: AppDimensions.paddingSmall);
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.bottomPanelHeaderHeight),
            ),
          ],
        ),
      );
    });
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
