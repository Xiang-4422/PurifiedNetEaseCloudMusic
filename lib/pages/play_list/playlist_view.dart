import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/appConstants.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/pages/play_list/playlist_controller.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;
import 'package:bujuan/widget/custom_filed.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/my_get_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

import '../../widget/simple_extended_image.dart';
import 'package:bujuan/common/constants/enmu.dart' as type;
import '../home/home_page_controller.dart';

class PlayListView extends GetView<PlayListController> {
  const PlayListView({super.key});


  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return MyGetView(
          child: Obx(() => Visibility(
            visible: !controller.loading.value,
            replacement: const LoadingView(),
            child: CustomScrollView(
              slivers: [
                SliverPadding(padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + AppDimensions.appBarHeight,),),
                _buildTopItem(context),
                Obx(() => SliverFixedExtentList(
                      delegate: SliverChildBuilderDelegate(
                          (context, index) => SongItem(
                                index: index,
                                mediaItem: controller.isSearch.value ? controller.searchItems[index] : controller.mediaItems[index],
                                onTap: () {
                                  if (controller.isSearch.value) {
                                    index = controller.mediaItems.indexOf(controller.searchItems[index]);
                                  }
                                  HomePageController.to.playByIndex(index, 'queueTitle', playList: controller.mediaItems);
                                },
                              ),
                          childCount: controller.isSearch.value ? controller.searchItems.length : controller.mediaItems.length,
                          addAutomaticKeepAlives: false,
                          addRepaintBoundaries: false),
                      itemExtent: 130.w,
                    )),
                SliverPadding(padding: EdgeInsets.only(bottom: HomePageController.to.panelHeaderHeight),),
              ],
            ),
          ),)
        );
  }

  Widget _buildTopItem(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(10.w),
        padding: EdgeInsets.all(10.w),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: SimpleExtendedImage.avatar(
                      '${(context.routeData.args as Play).creator?.avatarUrl ?? ''}?param=80y80',
                      width: 80.w,
                    )),
                Expanded(
                  child: Text(
                    (context.routeData.args as Play).creator?.nickname ?? '',
                    style: TextStyle(fontSize: 28.sp),
                  ),
                ),
                IconButton(onPressed: () => controller.subscribePlayList(), icon: Obx(() => Icon(controller.sub.value ? TablerIcons.hearts : TablerIcons.heart))),
                IconButton(
                    onPressed: () {
                      context.router.push(const gr.TalkView()
                          .copyWith(queryParams: {'id': (context.routeData.args as Play).id, 'type': 'playlist', 'name': (context.routeData.args as Play).name}));
                    },
                    icon: const Icon(TablerIcons.message_2)),
              ],
            ),
            (context.routeData.args as Play).description == null
                ? Container()
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      ((context.routeData.args as Play).description ?? '').replaceAll('\n', ''),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 24.sp, height: 1.6, color: Theme.of(context).cardColor.withOpacity(.6)),
                    ),
                ),
          ],
        ),
      ),
    );
  }
}

class SongItem extends StatelessWidget {
  final int index;
  final MediaItem mediaItem;
  final VoidCallback? onTap;

  const SongItem({Key? key, required this.index, required this.mediaItem, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<SheetAction<ActionType>> sheet = [const SheetAction<ActionType>(label: '下一首播放', icon: TablerIcons.player_play, key: ActionType.next)];
    if (mediaItem.extras?['type'] == type.MediaType.local.name) {
      sheet.add(const SheetAction<ActionType>(label: '修改歌曲标签', icon: TablerIcons.edit, key: ActionType.edit));
    } else {
      sheet.add(const SheetAction<ActionType>(label: '查看歌曲评论', icon: TablerIcons.message_2, key: ActionType.talk));
    }
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Text('${index + 1}'),
      horizontalTitleGap: 0.w,
      title: Text(
        mediaItem.title,
        maxLines: 1,
      ),
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
                    context.router.push(const gr.TalkView().copyWith(queryParams: {'id': mediaItem.id, 'type': 'song', 'name': mediaItem.title}));
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
                    context.router.push(const gr.TalkView().copyWith(queryParams: {'id': mediaItem.id, 'type': 'song', 'name': mediaItem.title}));
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

/// 歌单列表子项
class PlayListItem extends StatelessWidget {
  final Play play;

  const PlayListItem({Key? key, required this.play}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
      leading: SimpleExtendedImage.avatar(
        '${play.coverImgUrl ?? ''}?param=300y300',
        width: 85.w,
        height: 85.w,
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
      onTap: () {
        HomePageController.to.changeAppBarTitle(title: play.name ?? "", direction: NewAppBarTitleComingDirection.right, willRollBack: true);

        context.router.push(const gr.PlayListView().copyWith(args: play));
      },
    );
  }
}

// Artists
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
