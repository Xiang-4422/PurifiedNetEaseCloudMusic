
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/my_tab_bar.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../common/constants/other.dart';
import '../../widget/simple_extended_image.dart';
import '../../controllers/app_controller.dart';

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
      albumColor = await OtherUtils.getImageColor(playList.coverImgUrl ?? playList.picUrl);
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
      child: LayoutBuilder(builder: (context, constraints) {
        if (loading) return const LoadingView();
        return CustomScrollView(
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
              // backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const <StretchMode>[
                  StretchMode.zoomBackground, // 背景图缩放
                  // StretchMode.blurBackground, // 背景图模糊
                  // StretchMode.fadeTitle,      // 标题渐隐
                ],
                collapseMode: CollapseMode.pin,
                title: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            style: context.textTheme.titleLarge!.copyWith(
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = widgetColor.invertedColor,
                            ),
                            playList.name ?? "无名歌单",
                          ),
                          Text(
                            style: context.textTheme.titleSmall!.copyWith(
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = widgetColor.invertedColor,
                            ),
                            "歌单·" + playList.trackCount.toString() + "首",
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            style: context.textTheme.titleLarge!.copyWith(
                              color: widgetColor,
                            ),
                            playList.name ?? "无名歌单",
                          ),
                          Text(
                            style: context.textTheme.titleSmall!.copyWith(
                              color: widgetColor,
                            ),
                            "歌单·" + playList.trackCount.toString() + "首",
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                expandedTitleScale: 1.5,
                titlePadding: EdgeInsets.only(bottom: 60 + AppDimensions.paddingSmall,top: context.mediaQueryPadding.top, left: AppDimensions.paddingSmall, right: AppDimensions.paddingSmall),
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
                                AppController.to.audioHandler.changeRepeatMode(newRepeatMode: AudioServiceRepeatMode.all);
                                AppController.to.bottomPanelPageController.jumpToPage(0);
                                AppController.to.bottomPanelController.open();
                                // 根据当前播放模式，决定从哪个位置开始播放
                                int startIndex = AppController.to.curRepeatMode.value == AudioServiceRepeatMode.none
                                    ? Random().nextInt(loadedMediaItemCount)
                                    : 0;
                                await AppController.to.playNewPlayList(songs, startIndex, playListName: playList.name ?? "无名歌单", playListNameHeader: "歌单");
                              },
                              icon: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Icon(
                                    TablerIcons.repeat ,
                                    color: widgetColor,
                                  ),
                                  Text(
                                      '顺序播放',
                                      style: context.textTheme.titleMedium?.copyWith(
                                          color: widgetColor
                                      )
                                  ),
                                ],
                              ),
                            ),
                          )
                      ),
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
                                color: isSubscribed ? Colors.red : widgetColor,
                              )
                          ),
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
                                AppController.to.audioHandler.changeRepeatMode(newRepeatMode: AudioServiceRepeatMode.none);
                                AppController.to.bottomPanelPageController.jumpToPage(0);
                                AppController.to.bottomPanelController.open();
                                // 根据当前播放模式，决定从哪个位置开始播放
                                int startIndex = AppController.to.curRepeatMode.value == AudioServiceRepeatMode.none
                                    ? Random().nextInt(loadedMediaItemCount)
                                    : 0;
                                await AppController.to.playNewPlayList(songs, startIndex, playListName: playList.name ?? "无名歌单", playListNameHeader: "歌单");
                              },
                              icon: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Icon(
                                    TablerIcons.arrows_shuffle,
                                    color: widgetColor,
                                  ),
                                  Text(
                                      '随机播放',
                                      style: context.textTheme.titleMedium?.copyWith(
                                          color: widgetColor
                                      )
                                  ),
                                ],
                              ),
                            ),
                          )
                      ),
                    ],
                  ).paddingAll(AppDimensions.paddingSmall)
              ),
            ),
            SliverList.builder(
              itemCount: loadedMediaItemCount + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == loadedMediaItemCount) {
                  return const SizedBox(
                    height: AppDimensions.bottomPanelHeaderHeight,
                  );
                }
                return SongItem(
                  index: index,
                  playlist: songs,
                  playListName: playList.name ?? "无名歌单",
                  playListHeader: "歌单",
                  stringColor: widgetColor,
                  beforeOnTap: () {
                    AppController.to.bottomPanelPageController.jumpToPage(0);
                    AppController.to.bottomPanelController.open();
                  },
                ).paddingSymmetric(horizontal: AppDimensions.paddingSmall);
              },
            ),
          ],
          // children: [
          //   // 歌单列表页、评论页
          //   // 歌单详情
          //   BlurryContainer(
          //     blur: 20,
          //     borderRadius: BorderRadius.zero,
          //     color: controller.albumColor.value.withOpacity(0.5),
          //     padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + AppDimensions.appBarHeight),
          //     child: Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         // 详情（高100）
          //         Container(
          //           height: 100,
          //           width: context.width,
          //           margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
          //           child: Row(
          //             children: [
          //               // 歌单图片
          //               SimpleExtendedImage(
          //                 '${playList.coverImgUrl ?? playList.picUrl ?? ''}?param=400y400',
          //                 width: 100,
          //                 height: 100,
          //               ).marginOnly(right: AppDimensions.paddingSmall),
          //               Expanded(
          //                 child: SingleChildScrollView(
          //                   child: Column(
          //                       mainAxisAlignment: MainAxisAlignment.start,
          //                       children: [
          //                         // 用户
          //                         Row(
          //                             crossAxisAlignment: CrossAxisAlignment.center,
          //                             children: [
          //                               SimpleExtendedImage.avatar(
          //                                 '${playList.creator?.avatarUrl ?? ''}?param=80y80',
          //                                 width: 25,
          //                               ),
          //                               Text(
          //                                 playList.creator?.nickname ?? '',
          //                                 style: TextStyle(
          //                                     color: controller.widgetColor.value,
          //                                     fontSize: 15
          //                                 ),
          //                               ).marginOnly(left: 10)
          //                             ]
          //                         ).marginOnly(bottom: 10),
          //                         // 歌单描述
          //                         Container(
          //                           alignment: Alignment.centerLeft,
          //                           child: Text(
          //                             (playList.description ?? '歌单没介绍，我们直接听吧！').replaceAll('\n', ''),
          //                             // overflow: TextOverflow.ellipsis,
          //                             // maxLines: 4,
          //                             // textAlign: TextAlign.start,
          //                             style: TextStyle(
          //                                 fontSize: 15,
          //                                 color: controller.widgetColor.value
          //                             ),
          //                           ),
          //                         ),
          //                       ]
          //                   ),
          //                 ),
          //               )
          //             ],
          //           ),
          //         ),
          //
          //       ],
          //     ),
          //   ),
          // ],
        );
      }),
    );
  }

  _getAlbumColor() async {
    await OtherUtils.getImageColorPalette(playList.coverImgUrl).then((paletteGenerator) {
      albumColor = paletteGenerator.dominantColor?.color
          ?? paletteGenerator.darkMutedColor?.color
          ?? paletteGenerator.darkVibrantColor?.color
          ?? Colors.black;
      widgetColor = albumColor.invertedColor;
    });
  }

  _getMediaItems(id) async {
    // 获取歌单详情
    details ??= await NeteaseMusicApi().playListDetail(id);
    isMyPlayList = details?.playlist?.creator?.userId == AppController.to.userData.value.profile?.userId;
    isSubscribed = details?.playlist?.subscribed ?? false;
    List<String> ids = details?.playlist?.trackIds?.map((e) => e.id).toList() ?? [];
    // 获取歌曲，先获取1000首，结束loading，后台继续加载剩余歌曲
    songs.clear();
    SongDetailWrap songDetailWrap = await NeteaseMusicApi().songDetail(ids.sublist(0, min(1000, ids.length)));
    songs.addAll(AppController.to.song2ToMedia(songDetailWrap.songs ?? []));
    loadedMediaItemCount = songs.length;

    if (ids.length > 1000) {
      while (loadedMediaItemCount != ids.length) {
        SongDetailWrap songDetailWrap = await NeteaseMusicApi().songDetail(ids.sublist(loadedMediaItemCount, min(loadedMediaItemCount + 1000, ids.length)));
        songs.addAll(AppController.to.song2ToMedia(songDetailWrap.songs ?? []));
        loadedMediaItemCount = songs.length;
      }
    }
  }

  _subscribePlayList() {
    NeteaseMusicApi().subscribePlayList(playList.id, subscribe: !isSubscribed).then((value) {
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
  const UniversalListTile({super.key,required this.titleString, this.subTitleString, this.picUrl, this.stringColor, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: stringColor ?? context.theme.colorScheme.onPrimary,
      ),
      subtitleTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: (stringColor ?? context.theme.colorScheme.onPrimary).withOpacity(0.5),
      ),
      leading: picUrl != null
          ? SimpleExtendedImage(
        '${picUrl ?? ''}?param=200y200',
        borderRadius: BorderRadius.circular(10),
      )
          : null,
      title: Text(
        titleString,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      subtitle: subTitleString == null
          ? null
          : Text(
        subTitleString!,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
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

  const SongItem({
    Key? key,
    this.beforeOnTap,
    this.stringColor,
    this.showPic = true,
    this.showIndex = false,
    this.playListHeader = "",
    required this.playlist,
    required this.index,
    required this.playListName
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: UniversalListTile(
            picUrl: showPic ? (playlist[index].extras?['image']) : null,
            titleString: playlist[index].title,
            subTitleString: playlist[index].artist,
            stringColor: stringColor,
            onTap: () async {
              if (beforeOnTap != null) await beforeOnTap!();
              AppController.to.playNewPlayList(playlist, index, playListName: playListName, playListNameHeader: playListHeader);
            },
          ),
        ),
        showIndex ? Text("${index + 1}", style: TextStyle(color: stringColor)) : Container(),
      ],
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
        subTitleString: play.trackCount == null || play.trackCount == 0 ? null : "${play.trackCount}首",
        onTap: () async {
          if (beforeOnTap != null) await beforeOnTap!();
          context.router.push(gr.PlayListRouteView(playList: play));
        }
    );
  }
}
/// 专辑
class AlbumItem extends StatelessWidget {
  final Album album;
  final Function()? beforeOnTap;

  const AlbumItem({Key? key, required this.album, this.beforeOnTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UniversalListTile(
        picUrl: album.picUrl ?? '',
        titleString: album.name ?? '',
        subTitleString: '${album.size ?? 0} 首',
        onTap: () async {
          if (beforeOnTap != null) await beforeOnTap!();
          context.router.push(const gr.AlbumRouteView().copyWith(queryParams: {'albumId': album.id}));
        }
    );
  }
}
/// 歌手
class ArtistsItem extends StatelessWidget {
  final Artist artist;
  final Function()? beforeOnTap;

  const ArtistsItem({Key? key, required this.artist, this.beforeOnTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UniversalListTile(
      picUrl: artist.picUrl ?? '',
      titleString: artist.name ?? '',
      subTitleString: '${artist.albumSize ?? 0} 专辑',
      onTap: () async {
        if (beforeOnTap != null) await beforeOnTap!();
        context.router.push(const gr.ArtistRouteView().copyWith(queryParams: {'artistId': artist.id}));
      }
    );
  }
}

