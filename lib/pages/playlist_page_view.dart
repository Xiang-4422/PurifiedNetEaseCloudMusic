import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/common/netease_api/src/api/play/bean.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../common/constants/other.dart';
import 'package:bujuan/features/shell/app_controller.dart';
import '../../widget/simple_extended_image.dart';

class PlayListPageView extends StatefulWidget {
  final PlayList playList;

  const PlayListPageView(this.playList, {super.key});

  @override
  State<PlayListPageView> createState() => _PlayListPageViewState();
}

class _PlayListPageViewState extends State<PlayListPageView> {
  final PlaylistRepository _repository = PlaylistRepository();
  late final PlayList playList;

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
    playList = widget.playList;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      albumColor = await OtherUtils.getImageColor(
          playList.coverImgUrl ?? playList.picUrl);
      widgetColor = albumColor.invertedColor;
      await _loadPlaylistData();
      if (!mounted) {
        return;
      }
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      color: albumColor,
      child: loading
          ? const LoadingView()
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  toolbarHeight: AppDimensions.appBarHeight,
                  expandedHeight: context.width - context.mediaQueryPadding.top,
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
                          playList.name ?? "无名歌单",
                          style: context.textTheme.titleLarge?.copyWith(
                            color: widgetColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "歌单·${playList.trackCount ?? 0}首",
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
                      playList.picUrl ?? playList.coverImgUrl ?? '',
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
                                await AppController.to.playerController
                                    .setRepeatMode(AudioServiceRepeatMode.all);
                                AppController.to.bottomPanelPageController
                                    .jumpToPage(0);
                                AppController.to.bottomPanelController.open();
                                // 根据当前播放模式，决定从哪个位置开始播放
                                int startIndex =
                                    AppController.to.curRepeatMode.value ==
                                            AudioServiceRepeatMode.none
                                        ? Random().nextInt(loadedMediaItemCount)
                                        : 0;
                                await AppController.to.playerController
                                    .playPlaylist(
                                  songs,
                                  startIndex,
                                  playListName: playList.name ?? "无名歌单",
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
                                    color:
                                        isSubscribed ? Colors.red : widgetColor,
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
                                await AppController.to.playerController
                                    .setRepeatMode(AudioServiceRepeatMode.none);
                                AppController.to.bottomPanelPageController
                                    .jumpToPage(0);
                                AppController.to.bottomPanelController.open();
                                // 根据当前播放模式，决定从哪个位置开始播放
                                int startIndex =
                                    AppController.to.curRepeatMode.value ==
                                            AudioServiceRepeatMode.none
                                        ? Random().nextInt(loadedMediaItemCount)
                                        : 0;
                                await AppController.to.playerController
                                    .playPlaylist(
                                  songs,
                                  startIndex,
                                  playListName: playList.name ?? "无名歌单",
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
                          playListName: playList.name ?? "无名歌单",
                          playListHeader: "歌单",
                          stringColor: widgetColor,
                          beforeOnTap: () {
                            AppController.to.bottomPanelPageController
                                .jumpToPage(0);
                            AppController.to.bottomPanelController.open();
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
    );
  }

  Future<void> _loadPlaylistData() async {
    final cachedSongs = await _repository.loadCachedSongs(playList.id);
    if (cachedSongs != null && cachedSongs.isNotEmpty) {
      songs = cachedSongs;
      loadedMediaItemCount = songs.length;
      if (mounted) {
        setState(() {});
      }
    }

    final data = await _repository.fetchPlaylistDetail(
      playlistId: playList.id,
      likedSongIds: AppController.to.likedSongIds.toList(),
      currentUserId: AppController.to.userInfo.value.profile?.userId,
    );
    songs = data.songs;
    loadedMediaItemCount = songs.length;
    isSubscribed = data.isSubscribed;
    isMyPlayList = data.isMyPlayList;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _subscribePlayList() async {
    final value = await _repository.toggleSubscription(
      playList.id,
      subscribe: !isSubscribed,
    );
    if (value.code == 200 && mounted) {
      setState(() {
        isSubscribed = !isSubscribed;
      });
    }
  }
}
