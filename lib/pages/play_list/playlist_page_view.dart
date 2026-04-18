import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/common/netease_api/src/api/play/bean.dart';
import 'package:bujuan/features/playlist/repository/playlist_repository.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../common/constants/other.dart';
import '../../controllers/app_controller.dart';
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
                                AppController.to.audioHandler.changeRepeatMode(
                                    newRepeatMode: AudioServiceRepeatMode.all);
                                AppController.to.bottomPanelPageController
                                    .jumpToPage(0);
                                AppController.to.bottomPanelController.open();
                                // 根据当前播放模式，决定从哪个位置开始播放
                                int startIndex =
                                    AppController.to.curRepeatMode.value ==
                                            AudioServiceRepeatMode.none
                                        ? Random().nextInt(loadedMediaItemCount)
                                        : 0;
                                await AppController.to.playNewPlayList(
                                    songs, startIndex,
                                    playListName: playList.name ?? "无名歌单",
                                    playListNameHeader: "歌单");
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
                                AppController.to.audioHandler.changeRepeatMode(
                                    newRepeatMode: AudioServiceRepeatMode.none);
                                AppController.to.bottomPanelPageController
                                    .jumpToPage(0);
                                AppController.to.bottomPanelController.open();
                                // 根据当前播放模式，决定从哪个位置开始播放
                                int startIndex =
                                    AppController.to.curRepeatMode.value ==
                                            AudioServiceRepeatMode.none
                                        ? Random().nextInt(loadedMediaItemCount)
                                        : 0;
                                await AppController.to.playNewPlayList(
                                    songs, startIndex,
                                    playListName: playList.name ?? "无名歌单",
                                    playListNameHeader: "歌单");
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

class Header extends StatelessWidget {
  final String title;
  final double padding;
  const Header(this.title, {Key? key, this.padding = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.headerHeight,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(padding),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class UniversalListTile extends StatelessWidget {
  final String titleString;
  final String? subTitleString;
  final String? picUrl;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onLongPress;
  final Color? stringColor;
  const UniversalListTile(
      {super.key,
      required this.titleString,
      this.subTitleString,
      this.picUrl,
      this.stringColor,
      this.onTap,
      this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            if (picUrl != null)
              SimpleExtendedImage(
                '${picUrl ?? ''}?param=150y150',
                width: 44,
                height: 44,
                cacheWidth: 120, // 显著降低内存占用
                borderRadius: BorderRadius.circular(8),
              ),
            if (picUrl != null)
              const SizedBox(width: AppDimensions.paddingSmall),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleString,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: stringColor ??
                              context.theme.colorScheme.onPrimary,
                        ),
                  ),
                  if (subTitleString != null)
                    Text(
                      subTitleString!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: (stringColor ??
                                    context.theme.colorScheme.onPrimary)
                                .withValues(alpha: 0.5),
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单曲
class SongItem extends StatelessWidget {
  final int index;
  final List<MediaItem> playlist;
  final String playListName;
  final String playListHeader;
  final Function()? beforeOnTap;
  final Color? stringColor;
  final bool showPic;
  final bool showIndex;

  const SongItem(
      {Key? key,
      this.beforeOnTap,
      this.stringColor,
      this.showPic = true,
      this.showIndex = false,
      this.playListHeader = "",
      required this.playlist,
      required this.index,
      required this.playListName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UniversalListTile(
      picUrl: showPic ? (playlist[index].extras?['image']) : null,
      titleString: playlist[index].title,
      subTitleString: playlist[index].artist,
      stringColor: stringColor,
      onTap: () async {
        if (beforeOnTap != null) await beforeOnTap!();
        AppController.to.playNewPlayList(playlist, index,
            playListName: playListName, playListNameHeader: playListHeader);
      },
    );
  }
}

/// 歌单
class PlayListItem extends StatelessWidget {
  final PlayList play;
  final Function()? beforeOnTap;

  const PlayListItem(this.play, {Key? key, this.beforeOnTap}) : super(key: key);

  @override
  build(BuildContext context) {
    final router = context.router;
    return UniversalListTile(
        picUrl: play.coverImgUrl ?? play.picUrl,
        titleString: play.name ?? "无歌单名",
        subTitleString: play.trackCount == null || play.trackCount == 0
            ? null
            : "${play.trackCount}首",
        onTap: () async {
          if (beforeOnTap != null) await beforeOnTap!();
          router.push(gr.PlayListRouteView(playList: play));
        });
  }
}

/// 专辑
class AlbumItem extends StatelessWidget {
  final Album album;
  final Function()? beforeOnTap;

  const AlbumItem({Key? key, required this.album, this.beforeOnTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = context.router;
    return UniversalListTile(
        picUrl: album.picUrl ?? '',
        titleString: album.name ?? '',
        subTitleString: '${album.size ?? 0} 首',
        onTap: () async {
          if (beforeOnTap != null) await beforeOnTap!();
          router.push(const gr.AlbumRouteView()
              .copyWith(queryParams: {'albumId': album.id}));
        });
  }
}

/// 歌手
class ArtistsItem extends StatelessWidget {
  final Artist artist;
  final Function()? beforeOnTap;

  const ArtistsItem({Key? key, required this.artist, this.beforeOnTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final router = context.router;
    return UniversalListTile(
        picUrl: artist.picUrl ?? '',
        titleString: artist.name ?? '',
        subTitleString: '${artist.albumSize ?? 0} 专辑',
        onTap: () async {
          if (beforeOnTap != null) await beforeOnTap!();
          router.push(const gr.ArtistRouteView()
              .copyWith(queryParams: {'artistId': artist.id}));
        });
  }
}
