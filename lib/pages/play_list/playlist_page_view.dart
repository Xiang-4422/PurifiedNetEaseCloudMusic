import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;
import 'package:bujuan/widget/data_widget.dart';
// 移除 my_tab_bar
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../common/constants/other.dart';
import '../../widget/simple_extended_image.dart';
import '../../controllers/app_controller.dart';
import 'package:bujuan/common/bujuan_audio_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_it/get_it.dart';

class PlayListPageView extends StatefulWidget {
  final PlayList playList;

  const PlayListPageView(this.playList, {super.key});

  @override
  State<PlayListPageView> createState() => _PlayListPageViewState();
}

class _PlayListPageViewState extends State<PlayListPageView> {
  late final PlayList playList;

  SinglePlayListWrap? details;
  List<MediaItem> songs = <MediaItem>[];
  int loadedMediaItemCount = 0;

  bool isSubscribed = false;
  bool isMyPlayList = false;

  bool loading = true;

  Color albumColor = Colors.transparent;
  Color widgetColor = Colors.transparent;

  @override
  void initState() {
    playList = widget.playList;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      albumColor = await OtherUtils.getImageColor(
          playList.coverImgUrl ?? playList.picUrl);
      widgetColor = albumColor.invertedColor;
      await _getMediaItems(playList.id);
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
                            color: widgetColor.withOpacity(0.8),
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
                            padding: EdgeInsetsGeometry.zero,
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
                              padding: EdgeInsetsGeometry.zero,
                              color: widgetColor.withOpacity(0.05),
                              child: IconButton(
                                  color: Colors.red,
                                  padding: EdgeInsetsGeometry.zero,
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
                            padding: EdgeInsetsGeometry.zero,
                            color: widgetColor.withOpacity(0.05),
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

  _getAlbumColor() async {
    await OtherUtils.getImageColorPalette(playList.coverImgUrl)
        .then((paletteGenerator) {
      albumColor = paletteGenerator.dominantColor?.color ??
          paletteGenerator.darkMutedColor?.color ??
          paletteGenerator.darkVibrantColor?.color ??
          Colors.black;
      widgetColor = albumColor.invertedColor;
    });
  }

  _getMediaItems(id) async {
    Box box = GetIt.instance<Box>();
    String cacheKey = "PLAYLIST_SONGS_$id";
    // 1. 尝试从缓存加载
    List<String>? cachedSongsStr = box.get(cacheKey)?.cast<String>();
    if (cachedSongsStr != null) {
      songs = await stringToPlayList(cachedSongsStr);
      loadedMediaItemCount = songs.length;
      setState(() {
        loading = false;
      });
    }

    // 2. 网络获取最新详情 (静默更新)
    details ??= await NeteaseMusicApi().playListDetail(id);
    isMyPlayList = details?.playlist?.creator?.userId ==
        AppController.to.userInfo.value.profile?.userId;
    isSubscribed = details?.playlist?.subscribed ?? false;
    List<String> ids =
        details?.playlist?.trackIds?.map((e) => e.id).toList() ?? [];

    if (ids.isEmpty) return;

    // 3. 获取歌曲详情
    List<MediaItem> remoteSongs = [];
    SongDetailWrap songDetailWrap = await NeteaseMusicApi()
        .songDetail(ids.sublist(0, min(1000, ids.length)));
    remoteSongs
        .addAll(AppController.to.song2ToMedia(songDetailWrap.songs ?? []));

    if (ids.length > 1000) {
      int currentLoaded = remoteSongs.length;
      while (currentLoaded != ids.length) {
        SongDetailWrap wrap = await NeteaseMusicApi().songDetail(
            ids.sublist(currentLoaded, min(currentLoaded + 1000, ids.length)));
        remoteSongs.addAll(AppController.to.song2ToMedia(wrap.songs ?? []));
        currentLoaded = remoteSongs.length;
      }
    }

    // 4. 更新 UI 和缓存
    songs = remoteSongs;
    loadedMediaItemCount = songs.length;
    if (mounted) {
      setState(() {
        loading = false;
      });
    }

    playListToString(songs).then((value) {
      box.put(cacheKey, value);
    });
  }

  _subscribePlayList() {
    NeteaseMusicApi()
        .subscribePlayList(playList.id, subscribe: !isSubscribed)
        .then((value) {
      if (value.code == 200) {
        setState(() {
          isSubscribed = !isSubscribed;
        });
      }
    });
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
                                .withOpacity(0.5),
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

  _getSongFeeType(int fee) {
    String feeStr = '';
    switch (fee) {
      case 1:
        feeStr = '  vip';
        break;
      case 4:
        feeStr = '  need buy';
        break;
    }
    return feeStr;
  }
}

/// 歌单
class PlayListItem extends StatelessWidget {
  final PlayList play;
  final Function()? beforeOnTap;

  const PlayListItem(this.play, {Key? key, this.beforeOnTap}) : super(key: key);

  @override
  build(BuildContext context) {
    return UniversalListTile(
        picUrl: play.coverImgUrl ?? play.picUrl,
        titleString: play.name ?? "无歌单名",
        subTitleString: play.trackCount == null || play.trackCount == 0
            ? null
            : "${play.trackCount}首",
        onTap: () async {
          if (beforeOnTap != null) await beforeOnTap!();
          context.router.push(gr.PlayListRouteView(playList: play));
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
    return UniversalListTile(
        picUrl: album.picUrl ?? '',
        titleString: album.name ?? '',
        subTitleString: '${album.size ?? 0} 首',
        onTap: () async {
          if (beforeOnTap != null) await beforeOnTap!();
          context.router.push(const gr.AlbumRouteView()
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
    return UniversalListTile(
        picUrl: artist.picUrl ?? '',
        titleString: artist.name ?? '',
        subTitleString: '${artist.albumSize ?? 0} 专辑',
        onTap: () async {
          if (beforeOnTap != null) await beforeOnTap!();
          context.router.push(const gr.ArtistRouteView()
              .copyWith(queryParams: {'artistId': artist.id}));
        });
  }
}
