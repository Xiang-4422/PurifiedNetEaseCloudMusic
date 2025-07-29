
import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/common/constants/enmu.dart' as type;
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/pages/play_list/playlist_controller.dart';
import 'package:bujuan/pages/talk/comment_widget.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/my_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../widget/simple_extended_image.dart';
import '../../controllers/app_controller.dart';

class PlayListPageView extends GetView<PlayListController> {
  final PlayList playList;

  const PlayListPageView(this.playList, {super.key});

  @override
  Widget build(BuildContext context) {
    controller.playList = playList;
    return Stack(
      children: [
        // 背景
        Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          color: controller.albumColor.value == Colors.transparent
              ? context.theme.colorScheme.primary
              : controller.albumColor.value,
        )),
        // 页面内容
        Obx(() => Visibility(
          visible: !controller.loading.value,
          replacement: const LoadingView(),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // 歌单列表页、评论页
              PageView(
                controller: controller.pageController,
                scrollDirection: Axis.horizontal,
                children: [
                  // 歌单歌曲列表
                  Obx(() => Scrollbar(
                    thickness: 5,
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        top: 160 + AppDimensions.appBarHeight + context.mediaQueryPadding.top,
                        bottom: AppDimensions.bottomPanelHeaderHeight,
                        left: AppDimensions.paddingSmall,
                        right: AppDimensions.paddingSmall,
                      ),
                      itemCount: controller.loadedMediaItemCount.value,
                      itemBuilder: (BuildContext context, int index) => SongItem(
                        index: index,
                        playlist: controller.mediaItems,
                        stringColor: controller.widgetColor.value,
                        beforeOnTap: () {
                          AppController.to.bottomPanelPageController.jumpToPage(0);
                          AppController.to.bottomPanelController.open();
                        },
                      ),
                    ),
                  )),
                  CommentWidget(
                    context: context,
                    id: playList.id,
                    idType: 'playlist',
                    commentType: 2,
                    listPaddingTop: 160+ AppDimensions.appBarHeight + context.mediaQueryPadding.top,
                    listPaddingBottom: AppDimensions.bottomPanelHeaderHeight,
                    stringColor: controller.widgetColor.value,
                  ).paddingSymmetric(horizontal: AppDimensions.paddingSmall),
                  CommentWidget(
                    context: context,
                    id: playList.id,
                    idType: 'playlist',
                    commentType: 3,
                    listPaddingTop: 160 + AppDimensions.appBarHeight + context.mediaQueryPadding.top,
                    listPaddingBottom: AppDimensions.bottomPanelHeaderHeight,
                    stringColor: controller.widgetColor.value,
                  ).paddingSymmetric(horizontal: AppDimensions.paddingSmall)
                ]
              ),
              // 歌单详情
              BlurryContainer(
                blur: 20,
                borderRadius: BorderRadius.zero,
                color: controller.albumColor.value.withOpacity(0.5),
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + AppDimensions.appBarHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 详情（高100）
                    Container(
                      height: 100,
                      width: context.width,
                      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
                      child: Row(
                        children: [
                          // 歌单图片
                          SimpleExtendedImage(
                            '${playList.coverImgUrl ?? playList.picUrl ?? ''}?param=400y400',
                            width: 100,
                            height: 100,
                          ).marginOnly(right: AppDimensions.paddingSmall),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // 用户
                                    Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SimpleExtendedImage.avatar(
                                            '${playList.creator?.avatarUrl ?? ''}?param=80y80',
                                            width: 25,
                                          ),
                                          Text(
                                            playList.creator?.nickname ?? '',
                                            style: TextStyle(
                                                color: controller.widgetColor.value,
                                                fontSize: 15
                                            ),
                                          ).marginOnly(left: 10)
                                        ]
                                    ).marginOnly(bottom: 10),
                                    // 歌单描述
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        (playList.description ?? '歌单没介绍，我们直接听吧！').replaceAll('\n', ''),
                                        // overflow: TextOverflow.ellipsis,
                                        // maxLines: 4,
                                        // textAlign: TextAlign.start,
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: controller.widgetColor.value
                                        ),
                                      ),
                                    ),
                                  ]
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // 播放、收藏、评论（高60）
                    Container(
                      height: 60,
                      padding: EdgeInsets.all(AppDimensions.paddingSmall),
                      child: Row(
                        children: [
                          // 播放全部
                          Flexible(
                              child: GestureDetector(
                                onTap: () async {
                                  AppController.to.bottomPanelPageController.jumpToPage(0);
                                  AppController.to.bottomPanelController.open();
                                  // 根据当前播放模式，决定从哪个位置开始播放
                                  int startIndex = AppController.to.curRepeatMode.value == AudioServiceRepeatMode.none
                                      ? Random().nextInt(controller.loadedMediaItemCount.value)
                                      : 0;
                                  await AppController.to.playNewPlayList(controller.mediaItems, startIndex, queueTitle:  controller.playList.name ?? "无名歌单", );
                                },
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(60),
                                    color: controller.widgetColor.value.withOpacity(0.1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        TablerIcons.player_play_filled,
                                        color: controller.widgetColor.value,
                                      ).paddingAll(8),
                                      Text(
                                          '播放全部',
                                          style: context.textTheme.titleMedium?.copyWith(
                                              color: controller.widgetColor.value
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                              )
                          ),
                          const SizedBox(width: AppDimensions.paddingSmall),
                          // 评论、收藏
                          Flexible(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(60),
                                  color: controller.widgetColor.value.withOpacity(0.1),
                                ),
                                child: Obx(() => AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                      //执行缩放动画
                                      return ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child));
                                    },
                                    child: Visibility(
                                      key: ValueKey(controller.curPageIndex.value == 0),
                                      visible: controller.curPageIndex.value == 0,
                                      replacement: MyTabBar(
                                        height: 40,
                                        controller: controller.commentTabController,
                                        tabs: [Text('热门', style: context.textTheme.titleMedium?.copyWith(color: controller.widgetColor.value)), Text("最新", style: context.textTheme.titleMedium?.copyWith(color: controller.widgetColor.value))],
                                      ),
                                      child: GestureDetector(
                                        onTap: (){
                                          if (controller.isMyPlayList) {
                                            controller.pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.linear);
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Offstage(
                                              offstage: controller.isMyPlayList,
                                              child: IconButton(
                                                  onPressed: () => controller.subscribePlayList(),
                                                  icon: Obx(() => Icon(
                                                    controller.isSubscribed.value
                                                        ? TablerIcons.heart_filled
                                                        : TablerIcons.heart,
                                                    color: controller.isSubscribed.value ? Colors.red : controller.widgetColor.value,
                                                  ))
                                              ),
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  controller.pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.linear);
                                                },
                                                icon: Icon(
                                                  TablerIcons.message,
                                                  color: controller.widgetColor.value,
                                                )
                                            ),
                                            Offstage(
                                                offstage: !controller.isMyPlayList,
                                                child: Text(
                                                    "歌单评论",
                                                    style: context.textTheme.titleMedium?.copyWith(
                                                        color: controller.widgetColor.value
                                                    )
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                )),
                              )
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class Header extends StatelessWidget {
  final String title;
  const Header(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.colorScheme.primary,
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

}

/// 单曲
class SongItem extends StatelessWidget {
  final int index;
  final List<MediaItem> playlist;
  final Function()? beforeOnTap;
  final Color? stringColor;
  final bool showPic;

  const SongItem({Key? key, this.beforeOnTap, this.stringColor, this.showPic = true, required this.playlist, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UniversalListTile(
      picUrl: showPic ? (playlist[index].extras?['image']) : null,
      titleString: playlist[index].title,
      subTitleString: playlist[index].artist,
      stringColor: stringColor,
      onTap: () async {
        if (beforeOnTap != null) await beforeOnTap!();
        AppController.to.playNewPlayList(playlist, index);
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
          AppController.to.updateAppBarTitle(title: album.name, subTitle: "专辑", direction: NewAppBarTitleComingDirection.right, willRollBack: true);
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
        AppController.to.updateAppBarTitle(title: artist.name, subTitle: "歌手", direction: NewAppBarTitleComingDirection.right, willRollBack: true);
        context.router.push(const gr.ArtistRouteView().copyWith(queryParams: {'artistId': artist.id}));
      }
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



enum ActionType { next, edit, talk }
