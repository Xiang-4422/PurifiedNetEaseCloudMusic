import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/netease_api/netease_music_api.dart';
import 'package:bujuan/pages/play_list/playlist_page_view.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:get/get.dart';

import '../../common/constants/appConstants.dart';
import '../../common/constants/other.dart';
import '../../controllers/app_controller.dart';
import '../../widget/simple_extended_image.dart';
import 'controller.dart';



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
  Color albumPrimaryColor = Get.theme.colorScheme.primary;
  Color onAlbumPrimaryColor = Get.theme.colorScheme.onPrimary;

  @override
  void initState() {
    super.initState();

    albumId = context.routeData.queryParams.get('albumId');

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      AlbumDetailWrap albumDetailWrap = await NeteaseMusicApi().albumDetail(albumId);
      album = albumDetailWrap.album!;
      albumSongs.addAll(AppController.to.song2ToMedia(albumDetailWrap.songs ?? []));

      await OtherUtils.getImageColor('${album.picUrl}?param=500y500').then((paletteGenerator) {
        // 更新panel中的色调
        albumPrimaryColor = paletteGenerator.lightMutedColor?.color
            ?? paletteGenerator.lightVibrantColor?.color
            ?? paletteGenerator.dominantColor?.color
            ?? Get.theme.primaryColor;
        onAlbumPrimaryColor = ThemeData.estimateBrightnessForColor(albumPrimaryColor) == Brightness.light
            ? Colors.black
            : Colors.white;
      });

      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        color: albumPrimaryColor,
        child: const LoadingView()
       );
    }

    return CustomScrollView(
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
            backgroundColor: albumPrimaryColor,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const <StretchMode>[
                StretchMode.zoomBackground, // 背景图缩放
                StretchMode.blurBackground, // 背景图模糊
                // StretchMode.fadeTitle,      // 标题渐隐
              ],
              titlePadding: EdgeInsets.only(bottom: AppDimensions.paddingMedium, left: AppDimensions.paddingMedium, right: AppDimensions.paddingMedium),
              title: Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Text(
                          style: context.textTheme.titleLarge!.copyWith(
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 4
                              ..color = Colors.black,
                          ),
                          album.name!,
                        ),
                        Text(
                          style: context.textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                          ),
                          album.name!,
                        ),
                      ],
                    ),
                  ),
                  Icon(TablerIcons.player_play)
                ],
              ),
              // centerTitle: true,
              expandedTitleScale: 1.5,
              background: SimpleExtendedImage(
                width: context.width,
                height: context.width,
                '${album.picUrl ?? ''}',
              ),
            ),
            // bottom:
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: albumSongs.length + 1,
                  (BuildContext context, int index) {
                if (index == albumSongs.length) {
                  return SizedBox(
                    height: AppDimensions.bottomPanelHeaderHeight,
                  );
                }
                return Row(
                  children: [
                    Expanded(child: SongItem(playlist: albumSongs, index: index, showPic: false,)),
                    Text("${index + 1}").paddingOnly(left: AppDimensions.paddingMedium),
                  ],
                ).paddingSymmetric(horizontal: AppDimensions.paddingMedium);
              },
            ),
          ),
        ]
    );
  }
}
