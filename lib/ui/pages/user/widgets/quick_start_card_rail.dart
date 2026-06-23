import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/routing/router.gr.dart' as gr;
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/assets/app_assets.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/image/async_image_color.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:bujuan/ui/widgets/common/interaction/long_press_overlay_transition.dart';
import 'package:bujuan/ui/widgets/common/layout/scroll_helpers.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

/// 个人首页顶部的快速播放入口列表。
class QuickStartCardRail extends StatelessWidget {
  /// 创建快速播放入口列表。
  const QuickStartCardRail({
    super.key,
    required this.width,
    required this.height,
    required this.recommendationController,
    required this.libraryController,
    required this.playbackAction,
    required this.shellController,
  });

  /// 单张入口卡片宽度。
  final double width;

  /// 单张入口卡片高度。
  final double height;

  /// 首页推荐控制器。
  final RecommendationController recommendationController;

  /// 用户资料库控制器。
  final UserLibraryController libraryController;

  /// 播放控制器。
  final PlayerController playbackAction;

  /// Shell 控制器，用于打开底部播放页。
  final ShellController shellController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView(
        scrollDirection: Axis.horizontal,
        physics: SnappingScrollPhysics(
          itemExtent: width + AppDimensions.paddingSmall,
        ),
        children: [
          _ContinuePlaybackQuickStartCard(
            width: width,
            height: height,
            playbackAction: playbackAction,
            shellController: shellController,
          ).marginSymmetric(horizontal: AppDimensions.paddingSmall),
          _DailyRecommendQuickStartCard(
            width: width,
            height: height,
            recommendationController: recommendationController,
            playbackAction: playbackAction,
          ).marginOnly(right: AppDimensions.paddingSmall),
          _FmQuickStartCard(
            width: width,
            height: height,
            recommendationController: recommendationController,
            playbackAction: playbackAction,
            shellController: shellController,
          ).marginOnly(right: AppDimensions.paddingSmall),
          _HeartBeatQuickStartCard(
            width: width,
            height: height,
            libraryController: libraryController,
            playbackAction: playbackAction,
            shellController: shellController,
          ).marginOnly(right: AppDimensions.paddingSmall),
        ],
      ),
    );
  }
}

class _DailyRecommendQuickStartCard extends StatelessWidget {
  const _DailyRecommendQuickStartCard({
    required this.width,
    required this.height,
    required this.recommendationController,
    required this.playbackAction,
  });

  final double width;
  final double height;
  final RecommendationController recommendationController;
  final PlayerController playbackAction;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        LongPressOverlayTransition(
          child: QuickStartCard(
            width: width,
            height: height,
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
    );
  }
}

class _FmQuickStartCard extends StatelessWidget {
  const _FmQuickStartCard({
    required this.width,
    required this.height,
    required this.recommendationController,
    required this.playbackAction,
    required this.shellController,
  });

  final double width;
  final double height;
  final RecommendationController recommendationController;
  final PlayerController playbackAction;
  final ShellController shellController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Obx(() {
          final currentSong = playbackAction.currentSongState.value;
          return QuickStartCard(
            width: width,
            height: height,
            albumUrl: playbackAction.isFmModeValue
                ? _playbackArtworkPath(currentSong)
                : _firstPlaybackArtworkPath(
                    recommendationController.fmSongs,
                  ),
            icon: TablerIcons.infinity,
            title: '漫游模式',
            onTap: () {
              shellController.jumpBottomPanelToPage(1);
              shellController.openBottomPanel();
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
    );
  }
}

class _HeartBeatQuickStartCard extends StatelessWidget {
  const _HeartBeatQuickStartCard({
    required this.width,
    required this.height,
    required this.libraryController,
    required this.playbackAction,
    required this.shellController,
  });

  final double width;
  final double height;
  final UserLibraryController libraryController;
  final PlayerController playbackAction;
  final ShellController shellController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Obx(() {
          final currentSong = playbackAction.currentSongState.value;
          return QuickStartCard(
            width: width,
            height: height,
            albumUrl: playbackAction.isHeartBeatModeValue ? _playbackArtworkPath(currentSong) : libraryController.randomLikedSongAlbumUrl.value,
            icon: TablerIcons.heartbeat,
            title: '心动模式',
            onTap: () {
              shellController.jumpBottomPanelToPage(1);
              shellController.openBottomPanel();
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

/// 个人首页顶部的快速播放入口卡片。
class QuickStartCard extends StatelessWidget {
  /// 创建快速播放入口卡片。
  const QuickStartCard({
    super.key,
    required this.width,
    required this.height,
    this.onTap,
    required this.albumUrl,
    this.icon,
    required this.title,
  });

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
    final isEnabled = onTap != null;
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
