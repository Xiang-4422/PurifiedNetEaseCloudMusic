import 'dart:async';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/app/bootstrap/feature_controller_factory.dart';
import 'package:bujuan/app/theme/image_color_service.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/features/playlist/application/playlist_playback_use_case.dart';
import 'package:bujuan/features/playlist/playlist_page_controller.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

/// 歌单详情页面，展示歌单元信息和歌曲列表。
class PlayListPageView extends StatefulWidget {
  /// 创建歌单详情页面。
  const PlayListPageView({
    required this.playlistId,
    required this.playlistName,
    this.coverUrl,
    this.trackCount,
    super.key,
  });

  /// 歌单 id。
  final String playlistId;

  /// 歌单名称，用作初始标题和播放队列名。
  final String playlistName;

  /// 歌单封面地址。
  final String? coverUrl;

  /// 歌单歌曲总数。
  final int? trackCount;

  @override
  State<PlayListPageView> createState() => _PlayListPageViewState();
}

class _PlayListPageViewState extends State<PlayListPageView> {
  final PlaylistPageController _controller =
      Get.find<FeatureControllerFactory>().playlistPage();
  final PlaylistPlaybackUseCase _playbackUseCase =
      Get.find<PlaylistPlaybackUseCase>();

  String playlistName = '';
  String? coverUrl;
  int? trackCount;
  List<PlaybackQueueItem> songs = <PlaybackQueueItem>[];
  int loadedSongCount = 0;

  bool isSubscribed = false;
  bool isMyPlayList = false;

  bool loading = true;

  Color albumColor = Colors.transparent;
  Color widgetColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    playlistName = widget.playlistName;
    coverUrl = widget.coverUrl;
    trackCount = widget.trackCount;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPlaylistData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      color: albumColor,
      child: loading
          ? const LoadingView()
          : RefreshIndicator(
              onRefresh: () => _refreshPlaylistData(showLoadingState: false),
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    toolbarHeight: AppDimensions.appBarHeight,
                    expandedHeight:
                        context.width - context.mediaQueryPadding.top,
                    pinned: true,
                    stretch: true,
                    automaticallyImplyLeading: true,
                    foregroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    backgroundColor: albumColor,
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const <StretchMode>[
                        StretchMode.zoomBackground,
                      ],
                      collapseMode: CollapseMode.pin,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            playlistName,
                            style: context.textTheme.titleLarge?.copyWith(
                              color: widgetColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "歌单·${trackCount ?? loadedSongCount}首",
                            style: context.textTheme.titleSmall?.copyWith(
                              color: widgetColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      expandedTitleScale: 1.5,
                      titlePadding: EdgeInsets.only(
                          bottom: 60 + AppDimensions.paddingSmall,
                          top: context.mediaQueryPadding.top,
                          left: AppDimensions.paddingSmall,
                          right: AppDimensions.paddingSmall),
                      background: SimpleExtendedImage(
                        width: context.width,
                        height: context.width,
                        _resolvedCoverUrl ?? '',
                      ),
                    ),
                    bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(60),
                        child: Row(
                          spacing: AppDimensions.paddingSmall,
                          children: [
                            // 播放全部
                            Flexible(
                                child: BlurryContainer(
                              borderRadius: BorderRadius.circular(60),
                              padding: EdgeInsets.zero,
                              color: widgetColor.withValues(alpha: 0.05),
                              child: IconButton(
                                onPressed: () async {
                                  ShellController.to.jumpBottomPanelToPage(0);
                                  ShellController.to.openBottomPanel();
                                  await _playbackUseCase.playSequential(
                                    songs,
                                    playListName: playlistName,
                                    playListNameHeader: "歌单",
                                  );
                                },
                                icon: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      TablerIcons.repeat,
                                      color: widgetColor,
                                    ),
                                    Text('顺序播放',
                                        style: context.textTheme.titleMedium
                                            ?.copyWith(color: widgetColor)),
                                  ],
                                ),
                              ),
                            )),
                            Offstage(
                              offstage: isMyPlayList,
                              child: BlurryContainer(
                                borderRadius: BorderRadius.circular(60),
                                padding: EdgeInsets.zero,
                                color: widgetColor.withValues(alpha: 0.05),
                                child: IconButton(
                                    color: Colors.red,
                                    padding: EdgeInsets.zero,
                                    onPressed: () => _subscribePlayList(),
                                    icon: Icon(
                                      isSubscribed
                                          ? TablerIcons.heart_filled
                                          : TablerIcons.heart,
                                      color: isSubscribed
                                          ? Colors.red
                                          : widgetColor,
                                    )),
                              ),
                            ),
                            // 评论、收藏
                            Flexible(
                                child: BlurryContainer(
                              borderRadius: BorderRadius.circular(60),
                              padding: EdgeInsets.zero,
                              color: widgetColor.withValues(alpha: 0.05),
                              child: IconButton(
                                onPressed: () async {
                                  ShellController.to.jumpBottomPanelToPage(0);
                                  ShellController.to.openBottomPanel();
                                  await _playbackUseCase.playShuffle(
                                    songs,
                                    playListName: widget.playlistName,
                                    playListNameHeader: "歌单",
                                  );
                                },
                                icon: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      TablerIcons.arrows_shuffle,
                                      color: widgetColor,
                                    ),
                                    Text('随机播放',
                                        style: context.textTheme.titleMedium
                                            ?.copyWith(color: widgetColor)),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ).paddingAll(AppDimensions.paddingSmall)),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingSmall),
                    sliver: SliverFixedExtentList(
                      itemExtent: 56,
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return SongItem(
                            index: index,
                            playlist: songs,
                            playListName: playlistName,
                            playListHeader: "歌单",
                            stringColor: widgetColor,
                            beforeOnTap: () {
                              ShellController.to.jumpBottomPanelToPage(0);
                              ShellController.to.openBottomPanel();
                            },
                            onPlay: _playbackUseCase.playAt,
                          );
                        },
                        childCount: loadedSongCount,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: AppDimensions.bottomPanelHeaderHeight,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _loadPlaylistData() async {
    final localDetail = await _controller.loadLocalDetail(widget.playlistId);
    final cachedSnapshot =
        await _controller.loadCachedSnapshot(widget.playlistId);
    if (cachedSnapshot != null) {
      playlistName = cachedSnapshot.name;
      coverUrl = cachedSnapshot.coverUrl ?? coverUrl;
      trackCount = cachedSnapshot.trackCount ?? trackCount;
    }
    if (localDetail != null && localDetail.songs.isNotEmpty) {
      songs = localDetail.songs;
      loadedSongCount = songs.length;
      isSubscribed = localDetail.isSubscribed;
      isMyPlayList = localDetail.isMyPlayList;
      await _updateArtworkColors(_resolvedCoverUrl);
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      unawaited(_refreshPlaylistData(showLoadingState: false));
      return;
    }
    await _refreshPlaylistData(showLoadingState: true);
  }

  Future<void> _refreshPlaylistData({required bool showLoadingState}) async {
    if (showLoadingState && mounted) {
      setState(() {
        loading = true;
      });
    }
    final data = await _controller.fetchDetail(widget.playlistId);
    final snapshot = await _controller.loadCachedSnapshot(widget.playlistId);
    if (snapshot != null) {
      playlistName = snapshot.name;
      coverUrl = snapshot.coverUrl ?? coverUrl;
      trackCount = snapshot.trackCount ?? trackCount;
    }
    songs = data.songs;
    loadedSongCount = songs.length;
    isSubscribed = data.isSubscribed;
    isMyPlayList = data.isMyPlayList;
    await _updateArtworkColors(_resolvedCoverUrl);
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _updateArtworkColors(String? artworkPath) async {
    albumColor = await ImageColorService.dominantColor(artworkPath);
    widgetColor = albumColor.invertedColor;
  }

  String? get _resolvedCoverUrl => ArtworkPathResolver.resolvePreferredArtwork(
        coverUrl,
        fallbackItems: songs,
      );

  Future<void> _subscribePlayList() async {
    final value = await _controller.toggleSubscription(
      widget.playlistId,
      subscribe: !isSubscribed,
    );
    if (value.success && mounted) {
      setState(() {
        isSubscribed = !isSubscribed;
      });
    }
  }
}
