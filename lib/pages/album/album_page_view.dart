import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/pages/play_list/playlist_page_view.dart';
import 'package:bujuan/widget/custom_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:get/get.dart';

import '../../common/constants/appConstants.dart';
import '../../common/constants/other.dart';
import '../../controllers/app_controller.dart';
import '../../widget/simple_extended_image.dart';



class AlbumPageView extends StatefulWidget {
  const AlbumPageView({Key? key}) : super(key: key);
  @override
  State<AlbumPageView> createState() => _AlbumPageViewState();
}

class _AlbumPageViewState extends State<AlbumPageView> {

  late String albumId;
  late Album album;
  List<MediaItem> albumSongs = [];

  bool loading = true;
  Color albumColor = Get.theme.colorScheme.primary;
  Color onAlbumColor = Get.theme.colorScheme.onPrimary;

  @override
  void initState() {
    super.initState();

    albumId = context.routeData.queryParams.get('albumId');

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      AlbumDetailWrap albumDetailWrap = await NeteaseMusicApi().albumDetail(albumId);
      album = albumDetailWrap.album!;
      albumSongs.addAll(AppController.to.song2ToMedia(albumDetailWrap.songs ?? []));

      albumColor = await OtherUtils.getImageColor(album.picUrl);
      onAlbumColor = albumColor.invertedColor;

      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        color: albumColor,
        child: const LoadingView()
       );
    }

    return Container(
      color: albumColor,
      child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              toolbarHeight: AppDimensions.appBarHeight - context.mediaQueryPadding.top + AppDimensions.paddingLarge,
              collapsedHeight: AppDimensions.appBarHeight - context.mediaQueryPadding.top + AppDimensions.paddingLarge,
              expandedHeight: context.width - context.mediaQueryPadding.top,
              pinned: true,
              stretch: true,
              automaticallyImplyLeading: false,
              foregroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const <StretchMode>[
                  StretchMode.zoomBackground, // 背景图缩放
                  // StretchMode.blurBackground, // 背景图模糊
                  // StretchMode.fadeTitle,      // 标题渐隐
                ],
                titlePadding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium, left: AppDimensions.paddingMedium, right: AppDimensions.paddingMedium),
                title: BlurryContainer(
                  padding: EdgeInsetsGeometry.zero,
                  borderRadius: BorderRadius.circular(9999),
                  color: Colors.white.withOpacity(0.5),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Text(
                                "  " + album.name!,
                                maxLines: 1,
                                style: context.textTheme.titleLarge!.copyWith(
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 2
                                    ..color = Colors.black,
                                ),
                              ),
                              Text(
                                "  " + album.name!,
                                maxLines: 1,
                                style: context.textTheme.titleLarge!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      BlurryContainer(
                        padding: EdgeInsetsGeometry.zero,
                        borderRadius: BorderRadius.circular(9999),
                        color: Colors.red,
                        child: IconButton(
                            icon: Icon(
                              TablerIcons.player_play_filled,
                              color: Colors.white,
                            ),
                            onPressed: () => AppController.to.playNewPlayList(albumSongs, 0, playListName: album.name ?? '无名专辑', playListNameHeader: "专辑")
                        ),
                      )
                    ],
                  ),
                ),
                // centerTitle: true,
                expandedTitleScale: 1.5,
                background: SimpleExtendedImage(
                  width: context.width,
                  height: context.width,
                  album.picUrl ?? '',
                ),
              ),
              // bottom:
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                childCount: albumSongs.length + 1,
                    (BuildContext context, int index) {
                  if (index == albumSongs.length) {
                    return const SizedBox(
                      height: AppDimensions.bottomPanelHeaderHeight,
                    );
                  }
                  return SongItem(playlist: albumSongs, index: index, playListName: album.name ?? '无名专辑', playListHeader: "专辑", stringColor: onAlbumColor, showPic: false, showIndex: true).paddingSymmetric(horizontal: AppDimensions.paddingMedium);
                },
              ),
            ),
          ]
      ),
    );
  }
}
