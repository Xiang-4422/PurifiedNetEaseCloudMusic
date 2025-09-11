import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/common/netease_api/src/api/play/bean.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/pages/play_list/playlist_page_view.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/my_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;

import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

import '../../common/constants/other.dart';
import '../../common/netease_api/src/netease_api.dart';
import '../../widget/keep_alive_wrapper.dart';
import '../../widget/simple_extended_image.dart';

class ArtistPageView extends StatefulWidget {
  const ArtistPageView({Key? key}) : super(key: key);

  @override
  State<ArtistPageView> createState() => _ArtistPageViewState();
}

class _ArtistPageViewState extends State<ArtistPageView> {
  late String artistId;
  late Artist artist;

  final List<MediaItem> topSongs = [];
  final List<Album> hotAlbums = [];

  int crossAxisCount = 1;
  bool loading = true;
  Color albumColor = Get.theme.colorScheme.primary;
  Color onAlbumColor = Get.theme.colorScheme.onPrimary;

  @override
  void initState() {
    super.initState();

    artistId = context.routeData.queryParams.get("artistId");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ArtistDetailWrap artistDetailWrap = await NeteaseMusicApi().artistDetail(artistId);
      artist = artistDetailWrap.data!.artist!;

      albumColor = await OtherUtils.getImageColor(artist.cover ?? artist.picUrl);
      onAlbumColor = albumColor.invertedColor;

      ArtistSongListWrap artistSongListWrap = await NeteaseMusicApi().artistTopSongList(artistId);
      topSongs.addAll(AppController.to.song2ToMedia(artistSongListWrap.songs ?? []));

      ArtistAlbumListWrap artistAlbumListWrap = await NeteaseMusicApi().artistAlbumList(artistId);
      hotAlbums.addAll(artistAlbumListWrap.hotAlbums ?? []);

      setState(() {
        loading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {

    if (loading) {
      return Container(color:albumColor, child: const LoadingView());
    }

    // 计算专辑宽度：
    double albumWidth = (context.width - AppDimensions.paddingMedium * 3) / 2.5;

    return Container(
      color: albumColor,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(), // 关键：允许弹性滚动
        controller: ScrollController(),
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
              titlePadding: const EdgeInsets.all(AppDimensions.paddingMedium),
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
                              style: context.textTheme.titleLarge!.copyWith(
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 2
                                  ..color = Colors.black,
                              ),
                              maxLines: 1,
                              "  " + artist.name!,
                            ),
                            Text(
                              style: context.textTheme.titleLarge!.copyWith(
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              "  " + artist.name!,
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
                        onPressed: () => AppController.to.playNewPlayList(topSongs, 0, playListName: artist.name ?? "未知歌手", playListNameHeader: "歌手")
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
                artist.cover ?? artist.picUrl ?? '',
              ),
            ),
            // bottom:
          ),
          // 专辑
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppDimensions.paddingMedium * 4,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => setState(() {
                    crossAxisCount = Random().nextInt(hotAlbums.length ~/ 3) + 1;
                  }),
                  child: Row(
                    children: [
                      Text("专辑", style: TextStyle(color: onAlbumColor, fontWeight: FontWeight.bold),),
                    ],
                  )
                ),
              )
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: (albumWidth * 1.35) * crossAxisCount,
              child: CustomScrollView(
                scrollDirection: Axis.horizontal,
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium),
                    sliver: SliverGrid.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: AppDimensions.paddingMedium,
                        // crossAxisSpacing: AppDimensions.paddingMedium,
                        childAspectRatio: 1.35,       // 宽高比
                      ),
                      addAutomaticKeepAlives: true,
                      itemCount: hotAlbums.length,
                      itemBuilder: (context, index) {
                        return KeepAliveWrapper(
                          child: GestureDetector(
                            onTap: () => context.router.push(const gr.AlbumRouteView().copyWith(queryParams: {'albumId': hotAlbums[index].id})),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SimpleExtendedImage.avatar(
                                    width: albumWidth,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(AppDimensions.paddingMedium),
                                    '${hotAlbums[index].picUrl}?param=200y200'
                                ),
                                Expanded(child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${hotAlbums[index].name}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.textTheme.bodyMedium?.copyWith(
                                          color: onAlbumColor,
                                        ),
                                      ),
                                      Text(
                                        "${DateTime.fromMillisecondsSinceEpoch(hotAlbums[index].publishTime ?? 0).year}",
                                        maxLines: 1,
                                        style: context.textTheme.bodySmall?.copyWith(
                                          color: onAlbumColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ),
          // 单曲
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text("单曲", style: TextStyle(color: onAlbumColor, fontWeight: FontWeight.bold),).paddingOnly(left: AppDimensions.paddingMedium)
              )
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: topSongs.length + 1,
              (BuildContext context, int index) {
                if (index == topSongs.length) {
                  return const SizedBox(
                    height: AppDimensions.bottomPanelHeaderHeight,
                  );
                }
                return SongItem(playlist: topSongs, index: index, playListName: artist.name ?? "未知歌手", playListHeader: "歌手", stringColor: onAlbumColor, showIndex: true).paddingSymmetric(horizontal: AppDimensions.paddingMedium);
              },
            ),
          ),
        ],
      ),
    );
  }
}
