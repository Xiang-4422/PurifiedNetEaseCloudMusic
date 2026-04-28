import 'dart:async';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

class PlayListPageView extends StatefulWidget {
  const PlayListPageView({
    required this.playlistId,
    required this.playlistName,
    this.coverUrl,
    this.trackCount,
    super.key,
  });

  final String playlistId;
  final String playlistName;
  final String? coverUrl;
  final int? trackCount;

  @override
  State<PlayListPageView> createState() => _PlayListPageViewState();
}

class _PlayListPageViewState extends State<PlayListPageView> {
  PlaylistRepository get _repository => Get.find<PlaylistRepository>();

  String playlistName = '';
  String? coverUrl;
  int? trackCount;
  List<MediaItem> songs = <MediaItem>[];
  int loadedMediaItemCount = 0;

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
                            "歌单·${trackCount ?? loadedMediaItemCount}首",
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
                                  await ShellController.to.playerController
                                      .setRepeatMode(
                                          AudioServiceRepeatMode.all);
                                  ShellController.to.jumpBottomPanelToPage(0);
                                  ShellController.to.openBottomPanel();
                                  // 根据当前播放模式，决定从哪个位置开始播放
                                  int startIndex = ShellController
                                              .to
                                              .playbackSessionState
                                              .value
                                              .repeatMode ==
                                          AudioServiceRepeatMode.none
                                      ? Random().nextInt(loadedMediaItemCount)
                                      : 0;
                                  await ShellController.to.playerController
                                      .playPlaylist(
                                    songs,
                                    startIndex,
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
                                  await ShellController.to.playerController
                                      .setRepeatMode(
                                          AudioServiceRepeatMode.none);
                                  ShellController.to.jumpBottomPanelToPage(0);
                                  ShellController.to.openBottomPanel();
                                  // 根据当前播放模式，决定从哪个位置开始播放
                                  int startIndex = ShellController
                                              .to
                                              .playbackSessionState
                                              .value
                                              .repeatMode ==
                                          AudioServiceRepeatMode.none
                                      ? Random().nextInt(loadedMediaItemCount)
                                      : 0;
                                  await ShellController.to.playerController
                                      .playPlaylist(
                                    songs,
                                    startIndex,
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
                          );
                        },
                        childCount: loadedMediaItemCount,
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
    final localDetail = await _repository.loadLocalPlaylistDetail(
      playlistId: widget.playlistId,
      likedSongIds: ShellController.to.likedSongIds.toList(),
      currentUserId: ShellController.to.userInfo.value.userId,
    );
    final cachedSnapshot =
        await _repository.loadCachedSnapshot(widget.playlistId);
    if (cachedSnapshot != null) {
      playlistName = cachedSnapshot.name;
      coverUrl = cachedSnapshot.coverUrl ?? coverUrl;
      trackCount = cachedSnapshot.trackCount ?? trackCount;
    }
    if (localDetail != null) {
      songs = localDetail.songs;
      loadedMediaItemCount = songs.length;
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
    final data = await _repository.fetchPlaylistDetail(
      playlistId: widget.playlistId,
      likedSongIds: ShellController.to.likedSongIds.toList(),
      currentUserId: ShellController.to.userInfo.value.userId,
    );
    final snapshot = await _repository.loadCachedSnapshot(widget.playlistId);
    if (snapshot != null) {
      playlistName = snapshot.name;
      coverUrl = snapshot.coverUrl ?? coverUrl;
      trackCount = snapshot.trackCount ?? trackCount;
    }
    songs = data.songs;
    loadedMediaItemCount = songs.length;
    isSubscribed = data.isSubscribed;
    isMyPlayList = data.isMyPlayList;
    await _updateArtworkColors(_resolvedCoverUrl);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateArtworkColors(String? artworkPath) async {
    albumColor = await OtherUtils.getImageColor(artworkPath);
    widgetColor = albumColor.invertedColor;
  }

  String? get _resolvedCoverUrl => ArtworkPathResolver.resolvePreferredArtwork(
        coverUrl,
        fallbackItems: songs,
      );

  Future<void> _subscribePlayList() async {
    final value = await _repository.toggleSubscription(
      widget.playlistId,
      subscribe: !isSubscribed,
      currentUserId: ShellController.to.userInfo.value.userId,
    );
    if (value.success && mounted) {
      setState(() {
        isSubscribed = !isSubscribed;
      });
    }
  }
}
