import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/shell/app_controller.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:get/get.dart';

import '../../common/constants/appConstants.dart';
import '../../common/constants/other.dart';
import '../../widget/simple_extended_image.dart';

class AlbumPageView extends StatefulWidget {
  const AlbumPageView({Key? key}) : super(key: key);
  @override
  State<AlbumPageView> createState() => _AlbumPageViewState();
}

class _AlbumPageViewState extends State<AlbumPageView> {
  final AlbumRepository _repository = AlbumRepository();
  late String albumId;
  late AlbumEntity album;
  List<MediaItem> albumSongs = [];

  bool loading = true;
  Color albumColor = Get.theme.colorScheme.primary;
  Color onAlbumColor = Get.theme.colorScheme.onPrimary;

  @override
  void initState() {
    super.initState();

    albumId = context.routeData.queryParams.get('albumId');

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final albumDetail = await _repository.fetchAlbumDetail(
        albumId: albumId,
        likedSongIds: AppController.to.likedSongIds.toList(),
      );
      album = albumDetail.album;
      albumSongs.addAll(albumDetail.albumSongs);

      albumColor = await OtherUtils.getImageColor(album.artworkUrl);
      onAlbumColor = albumColor.invertedColor;

      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(color: albumColor, child: const LoadingView());
    }

    return Container(
      color: albumColor,
      child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
        SliverAppBar(
          toolbarHeight: AppDimensions.appBarHeight -
              context.mediaQueryPadding.top +
              AppDimensions.paddingLarge,
          collapsedHeight: AppDimensions.appBarHeight -
              context.mediaQueryPadding.top +
              AppDimensions.paddingLarge,
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
            titlePadding: const EdgeInsets.only(
                bottom: AppDimensions.paddingMedium,
                left: AppDimensions.paddingMedium,
                right: AppDimensions.paddingMedium),
            title: BlurryContainer(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(9999),
              color: Colors.white.withValues(alpha: 0.5),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Text(
                            "  ${album.title}",
                            maxLines: 1,
                            style: context.textTheme.titleLarge!.copyWith(
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 2
                                ..color = Colors.black,
                            ),
                          ),
                          Text(
                            "  ${album.title}",
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
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(9999),
                    color: Colors.red,
                    child: IconButton(
                        icon: const Icon(
                          TablerIcons.player_play_filled,
                          color: Colors.white,
                        ),
                        onPressed: () => PlayerController.to.playPlaylist(
                              albumSongs,
                              0,
                              playListName: album.title,
                              playListNameHeader: "专辑",
                            )),
                  )
                ],
              ),
            ),
            // centerTitle: true,
            expandedTitleScale: 1.5,
            background: SimpleExtendedImage(
              width: context.width,
              height: context.width,
              album.artworkUrl ?? '',
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
              return SongItem(
                      playlist: albumSongs,
                      index: index,
                      playListName: album.title,
                      playListHeader: "专辑",
                      stringColor: onAlbumColor,
                      showPic: false,
                      showIndex: true)
                  .paddingSymmetric(horizontal: AppDimensions.paddingMedium);
            },
          ),
        ),
      ]),
    );
  }
}
