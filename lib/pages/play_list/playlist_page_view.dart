import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/common/constants/enmu.dart' as type;
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/pages/play_list/playlist_controller.dart';
import 'package:bujuan/pages/talk/comment_page_view.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/my_get_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../widget/simple_extended_image.dart';
import '../home/home_page_controller.dart';

class PlayListPageView extends GetView<PlayListController> {
  final Color albumColor;
  final Color widgetColor;
  final PlayList playList;

  const PlayListPageView(this.playList, this.albumColor, this.widgetColor, {super.key});

  @override
  Widget build(BuildContext context) {
    controller.playListId = playList.id;
    return MyGetView(
        child: Stack(
          children: [
            Container(
              color: albumColor,
            ),
            Obx(() => Visibility(
                visible: !controller.loading.value,
                replacement: const LoadingView(),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // 歌曲列表、评论
                    PageView(
                      controller: controller.pageController,
                        scrollDirection: Axis.horizontal,
                        children: [
                          // 列表歌曲
                          ListView.builder(
                            padding: EdgeInsets.only(
                              top: 160 + AppDimensions.appBarHeight + context.mediaQueryPadding.top,
                              bottom: AppDimensions.bottomPanelHeaderHeight,
                            ),
                            itemCount: controller.mediaItems.length,
                            // itemExtent: 130.w,
                            itemBuilder: (BuildContext context, int index) => SongItem(
                              index: index,
                              mediaItem: controller.mediaItems[index],
                              onTap: () {
                                String queueTitle = controller.details?.playlist?.name ?? "无名歌单";
                                HomePageController.to.panelPageController.jumpToPage(0);
                                HomePageController.to.panelController.open();
                                HomePageController.to.playNewPlayListByIndex(index, queueTitle, playList: controller.mediaItems);
                              },
                            ),
                          ),
                          CommentWidget(
                            context: context,
                            id: playList.id,
                            idType: 'playlist',
                            commentType: 2,
                            listPaddingTop: 160+ AppDimensions.appBarHeight + context.mediaQueryPadding.top,
                            listPaddingBottom: AppDimensions.bottomPanelHeaderHeight,
                          ).paddingSymmetric(horizontal: 20),
                          CommentWidget(
                            context: context,
                            id: playList.id,
                            idType: 'playlist',
                            commentType: 3,
                            listPaddingTop: 160 + AppDimensions.appBarHeight + context.mediaQueryPadding.top,
                            listPaddingBottom: AppDimensions.bottomPanelHeaderHeight,
                          ).paddingSymmetric(horizontal: 20)
                        ]
                    ),
                    // 歌单信息
                    BlurryContainer(
                      blur: 20,
                      borderRadius: BorderRadius.zero,
                      color: albumColor.withOpacity(0.5),
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + AppDimensions.appBarHeight),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 详情（高100）
                          Container(
                            height: 100,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // 歌单图片
                                SimpleExtendedImage(
                                  '${playList.coverImgUrl ?? ''}?param=400y400',
                                  width: 100,
                                  height: 100,
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // 用户
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                SimpleExtendedImage.avatar(
                                                  '${playList.creator?.avatarUrl ?? ''}?param=80y80',
                                                  width: 20,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    playList.creator?.nickname ?? '',
                                                    style: TextStyle(
                                                        color: widgetColor,
                                                        fontSize: 20.sp
                                                    ),
                                                  ),
                                                ).marginOnly(left: 10),
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
                                                  fontSize: 24.sp,
                                                  height: 1.6,
                                                  color: widgetColor
                                              ),
                                            ),
                                          ),
                                        ]
                                    ),
                                  ).marginOnly(left: 20),
                                )
                              ],
                            ),
                          ),
                          // 播放、收藏、评论（高60）
                          Container(
                            height: 60,
                            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Row(
                              children: [
                                // 播放全部
                                Flexible(
                                    child: GestureDetector(
                                      onTap: () async {
                                        HomePageController.to.panelPageController.jumpToPage(0);
                                        HomePageController.to.panelController.open();
                                        await HomePageController.to.playNewPlayListByIndex(0, 'queueTitle', playList: controller.mediaItems);
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(60),
                                          color: Colors.black.withOpacity(0.1),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              TablerIcons.player_play_filled,
                                              color: widgetColor,
                                            ).paddingAll(8),
                                            Text(
                                                '播放全部',
                                                style: TextStyle(
                                                  color: widgetColor,
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                ),
                                const SizedBox(width: 20),
                                // 评论、收藏
                                Flexible(
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(60),
                                        color: Colors.black.withOpacity(0.1),
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
                                          replacement: SizedBox(
                                            height: 40,
                                            child: TabBar(
                                              controller: controller.commentTabController,
                                              dividerColor: Colors.transparent,
                                              indicatorSize: TabBarIndicatorSize.tab,
                                              indicatorWeight: 0,
                                              indicator: BoxDecoration(
                                                color: widgetColor.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(60),
                                              ),
                                              tabs: [Text('热门'), Text("最新")],
                                            ),
                                          ),
                                          child: GestureDetector(
                                            onTap: (){
                                              if (controller.isMyPlayList.isTrue) {
                                                controller.pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.linear);
                                              }
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Offstage(
                                                  offstage: controller.isMyPlayList.isTrue,
                                                  child: IconButton(
                                                      onPressed: () => controller.subscribePlayList(),
                                                      icon: Obx(() => Icon(
                                                        controller.isSubscribed.value
                                                            ? TablerIcons.heart_filled
                                                            : TablerIcons.heart,
                                                        color: controller.isSubscribed.value ? Colors.red : widgetColor,
                                                      ))
                                                  ),
                                                ),
                                                IconButton(
                                                    onPressed: () {
                                                      controller.pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.linear);
                                                    },
                                                    icon: Icon(
                                                      TablerIcons.message,
                                                      color: widgetColor,
                                                    )
                                                ),
                                                Offstage(
                                                    offstage: controller.isMyPlayList.isFalse,
                                                    child: Text(
                                                        "歌单评论",
                                                        style: TextStyle(
                                                          color: widgetColor,
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
                    )
                  ],
                ),
              )),
          ],
        )
    );
  }
}

class SongItemShowImage extends StatelessWidget {
  final int index;
  final MediaItem mediaItem;
  final VoidCallback? onTap;

  const SongItemShowImage({Key? key, required this.index, required this.mediaItem, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<SheetAction<ActionType>> sheet = [const SheetAction<ActionType>(label: '下一首播放', icon: TablerIcons.player_play, key: ActionType.next)];
    if (mediaItem.extras?['type'] == type.MediaType.local.name) {
      sheet.add(const SheetAction<ActionType>(label: '修改歌曲标签', icon: TablerIcons.edit, key: ActionType.edit));
    } else {
      sheet.add(const SheetAction<ActionType>(label: '查看歌曲评论', icon: TablerIcons.message_2, key: ActionType.talk));
    }
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
      leading: SimpleExtendedImage.avatar(
        '${mediaItem.extras?['image'] ?? ''}?param=120y120',
        width: 85.w,
        height: 85.w,
        fit: BoxFit.cover,
      ),
      title: RichText(
          text: TextSpan(text: mediaItem.title, style: TextStyle(fontSize: 30.sp, color: Theme.of(context).cardColor), children: [
        TextSpan(text: mediaItem.extras?['fee'] == 1 ? '   vip' : '', style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(.9), fontSize: 26.sp)),
      ])),
      subtitle: Text(
        mediaItem.artist ?? '',
        maxLines: 1,
      ),
      trailing: IconButton(
          onPressed: () {
            showModalActionSheet(
              context: context,
              title: mediaItem.title,
              message: mediaItem.artist,
              actions: sheet,
            ).then((value) {
              if (value != null) {
                switch (value) {
                  case ActionType.next:
                    if (HomePageController.to.audioServeHandler.playbackState.value.queueIndex != 0) {
                      HomePageController.to.audioServeHandler.insertQueueItem(HomePageController.to.audioServeHandler.playbackState.value.queueIndex! + 1, mediaItem);
                      WidgetUtil.showToast('已添加到下一曲');
                    } else {
                      WidgetUtil.showToast('未知错误');
                    }
                    break;
                  case ActionType.edit:
                    break;
                  case ActionType.talk:
                    context.router.push(gr.CommentRouteView().copyWith(queryParams: {'id': mediaItem.id, 'type': 'song', 'name': mediaItem.title}));
                    break;
                }
              }
            });
          },
          icon: const Icon(
            TablerIcons.dots_vertical,
          )),
      onTap: () => onTap?.call(),
    );
  }
}
class SongItem extends StatelessWidget {
  final int index;
  final MediaItem mediaItem;
  final VoidCallback onTap;

  const SongItem({Key? key, required this.index, required this.mediaItem, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<SheetAction<ActionType>> sheet = [const SheetAction<ActionType>(label: '下一首播放', icon: TablerIcons.player_play, key: ActionType.next)];
    if (mediaItem.extras?['type'] == type.MediaType.local.name) {
      sheet.add(const SheetAction<ActionType>(label: '修改歌曲标签', icon: TablerIcons.edit, key: ActionType.edit));
    } else {
      sheet.add(const SheetAction<ActionType>(label: '查看歌曲评论', icon: TablerIcons.message_2, key: ActionType.talk));
    }

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      ),
      child: Row(
        children: [
          SimpleExtendedImage(
            '${mediaItem.extras?['image'] ?? ''}?param=200y200',
            width: 100.w,
            height: 100.w,
            borderRadius: BorderRadius.circular(10),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mediaItem.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  mediaItem.artist ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          IconButton(
              onPressed: () {
                showModalActionSheet(
                  context: context,
                  title: mediaItem.title,
                  message: mediaItem.artist,
                  actions: sheet,
                ).then((value) {
                  if (value != null) {
                    switch (value) {
                      case ActionType.next:
                        if (HomePageController.to.audioServeHandler.playbackState.value.queueIndex != 0) {
                          HomePageController.to.audioServeHandler.insertQueueItem(HomePageController.to.audioServeHandler.playbackState.value.queueIndex! + 1, mediaItem);
                          WidgetUtil.showToast('已添加到下一曲');
                        } else {
                          WidgetUtil.showToast('未知错误');
                        }
                        break;
                      case ActionType.edit:
                        break;
                      case ActionType.talk:
                        context.router.push(gr.CommentRouteView().copyWith(queryParams: {'id': mediaItem.id, 'type': 'song', 'name': mediaItem.title}));
                        break;
                    }
                  }
                });
              },
              icon: const Icon(
                TablerIcons.dots_vertical,
              )),
        ]
      )
    );
  }

  getSongFeeType(int fee) {
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
class AlbumItem extends StatelessWidget {
  final int index;
  final Album album;

  const AlbumItem({Key? key, required this.index, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
      leading: SimpleExtendedImage.avatar(
        '${album.picUrl ?? ''}?param=100y100',
        width: 85.w,
        height: 85.w,
      ),
      title: Text(
        album.name ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${album.size}首',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        context.router.push(const gr.AlbumDetails().copyWith(queryParams: {'album': album}));
      },
    );
  }
}
class PlayListItem extends StatelessWidget {
  final PlayList play;

  const PlayListItem({Key? key, required this.play}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
      onTap: () {
        HomePageController.to.changeAppBarTitle(title: play.name ?? "", direction: NewAppBarTitleComingDirection.right, willRollBack: true);
        OtherUtils.getImageColor('${play.coverImgUrl ?? ''}?param=500y500').then((paletteGenerator) {
          Color albumColor = context.isDarkMode
              ? paletteGenerator.lightMutedColor?.color
              ?? paletteGenerator.lightVibrantColor?.color
              ?? Colors.white
              : paletteGenerator.darkMutedColor?.color
              ?? paletteGenerator.darkVibrantColor?.color
              ?? Colors.black;
          Color widgetColor = ThemeData.estimateBrightnessForColor(albumColor) == Brightness.light
              ? Colors.black
              : Colors.white;
          context.router.push(gr.PlayListRouteView(
            playList: play,
            albumColor: albumColor,
            widgetColor: widgetColor,
          ));
        });
      },
      leading: SimpleExtendedImage(
        '${play.coverImgUrl ?? ''}?param=200y200',
        width: 100.w,
        height: 100.w,
        borderRadius: BorderRadius.circular(10.w),
      ),
      title: Text(
        play.name ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${play.trackCount}首',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
class ArtistsItem extends StatelessWidget {
  final int index;
  final Artists artists;

  const ArtistsItem({Key? key, required this.index, required this.artists}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
      leading: SimpleExtendedImage.avatar(
        '${artists.picUrl ?? ''}?param=100y100',
        width: 85.w,
        height: 85.w,
      ),
      title: Text(
        artists.name ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${artists.albumSize ?? 0} 专辑',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        context.router.push(const gr.ArtistsView().copyWith(args: artists));
      },
    );
  }
}

enum ActionType { next, edit, talk }
