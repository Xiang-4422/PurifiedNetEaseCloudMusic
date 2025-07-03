
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
import 'package:bujuan/widget/my_get_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../widget/simple_extended_image.dart';
import '../home/app_controller.dart';

class PlayListPageView extends GetView<PlayListController> {
  final PlayList playList;

  const PlayListPageView(this.playList, {super.key});

  @override
  Widget build(BuildContext context) {
    controller.playList = playList;
    return MyGetView(
      child: Stack(
        children: [
          // 背景
          Container(
            color: Theme.of(context).colorScheme.primary,
            child: Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                color: controller.albumColor.value,
              )),
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
                    Obx(() => ListView.builder(
                      padding: EdgeInsets.only(
                        top: 160 + AppDimensions.appBarHeight + context.mediaQueryPadding.top,
                        bottom: AppDimensions.bottomPanelHeaderHeight,
                      ),
                      itemCount: controller.loadedMediaItemCount.value,
                      itemBuilder: (BuildContext context, int index) => SongItem(
                        index: index,
                        mediaItem: controller.mediaItems[index],
                        widgetColor: controller.widgetColor.value,
                        onTap: () {
                          String queueTitle = controller.details?.playlist?.name ?? "无名歌单";
                          AppController.to.panelPageController.jumpToPage(0);
                          AppController.to.panelController.open();
                          AppController.to.playNewPlayList(controller.mediaItems, index, queueTitle: queueTitle );
                        },
                      ),
                    )),
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
                  color: controller.albumColor.value.withOpacity(0.5),
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + AppDimensions.appBarHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 详情（高100）
                      Container(
                        height: 100,
                        width: context.width,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            // 歌单图片
                            SimpleExtendedImage(
                              '${playList.coverImgUrl ?? ''}?param=400y400',
                              width: 100,
                              height: 100,
                            ).marginOnly(right: 20),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // 用户
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            SimpleExtendedImage.avatar(
                                              '${playList.creator?.avatarUrl ?? ''}?param=80y80',
                                              width: 20,
                                            ),
                                            Text(
                                              playList.creator?.nickname ?? '',
                                              style: TextStyle(
                                                  color: controller.widgetColor.value,
                                                  fontSize: 20.sp
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
                                              fontSize: 24.sp,
                                              height: 1.6,
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
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Row(
                          children: [
                            // 播放全部
                            Flexible(
                                child: GestureDetector(
                                  onTap: () async {
                                    AppController.to.panelPageController.jumpToPage(0);
                                    AppController.to.panelController.open();
                                    await AppController.to.playNewPlayList(controller.mediaItems, 0, queueTitle:  controller.playList.name ?? "无名歌单", );
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
                                          color: controller.widgetColor.value,
                                        ).paddingAll(8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '播放全部',
                                              style: context.textTheme.titleMedium?.copyWith(
                                                color: controller.widgetColor.value
                                              )
                                            ),
                                            Text(
                                                "${playList.trackCount ?? 0}首",
                                                style: context.textTheme.titleSmall?.copyWith(
                                                    color: controller.widgetColor.value
                                                )
                                            ),
                                          ],
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
                                            color: controller.widgetColor.value.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(60),
                                          ),
                                          tabs: [Text('热门', style: context.textTheme.titleMedium?.copyWith(color: controller.widgetColor.value)), Text("最新", style: context.textTheme.titleMedium?.copyWith(color: controller.widgetColor.value))],
                                        ),
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
                )
              ],
            ),
          )),
        ],
      )
    );
  }
}

class Header extends StatelessWidget {
  final String title;
  const Header(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(5)
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

}

/// 单曲
class SongItem extends StatelessWidget {
  final int index;
  final MediaItem mediaItem;
  final VoidCallback onTap;
  final Color widgetColor;

  const SongItem({Key? key, required this.index, required this.mediaItem, required this.onTap, this.widgetColor = Colors.transparent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color widgetColor = context.theme.colorScheme.onPrimary;
    if (this.widgetColor != Colors.transparent) {
      widgetColor = this.widgetColor;
    }
    List<SheetAction<ActionType>> sheet = [const SheetAction<ActionType>(label: '下一首播放', icon: TablerIcons.player_play, key: ActionType.next)];
    if (mediaItem.extras?['type'] == type.MediaType.local.name) {
      sheet.add(const SheetAction<ActionType>(label: '修改歌曲标签', icon: TablerIcons.edit, key: ActionType.edit));
    } else {
      sheet.add(const SheetAction<ActionType>(label: '查看歌曲评论', icon: TablerIcons.message_2, key: ActionType.talk));
    }
    return ListTile(
      onTap: onTap,
      onLongPress: () {
        showModalActionSheet(
          context: context,
          title: mediaItem.title,
          message: mediaItem.artist,
          actions: sheet,
        ).then((value) {
          if (value != null) {
            switch (value) {
              case ActionType.next:
                if (AppController.to.audioHandler.playbackState.value.queueIndex != 0) {
                  AppController.to.audioHandler.insertQueueItem(AppController.to.audioHandler.playbackState.value.queueIndex! + 1, mediaItem);
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
      visualDensity: VisualDensity.comfortable,
      leading: SimpleExtendedImage(
        '${mediaItem.extras?['image'] ?? ''}?param=200y200',
        width: 100.w,
        height: 100.w,
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(
        mediaItem.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: context.textTheme.titleMedium?.copyWith(
          color: widgetColor,
        ),
      ),
      subtitle: Text(
        mediaItem.artist ?? '',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: context.textTheme.titleSmall?.copyWith(
          color: widgetColor,
        ),
      ),
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

  const PlayListItem(this.play, {Key? key}) : super(key: key);

  @override
  build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.comfortable,
      onTap: () {
        AppController.to.changeAppBarTitle(title: play.name ?? "", direction: NewAppBarTitleComingDirection.right, willRollBack: true);
        context.router.push(gr.PlayListRouteView(playList: play));
        },
      leading: SimpleExtendedImage(
        '${play.coverImgUrl ?? play.picUrl ?? ''}?param=200y200',
        borderRadius: BorderRadius.circular(10.w),
      ),
      title: Text(
        play.name ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: play.trackCount != 0
          ? Text(
            '${play.trackCount}首',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          )
          : null
    );
  }
}
/// 专辑
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
/// 歌手
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
