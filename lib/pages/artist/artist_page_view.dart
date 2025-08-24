import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bujuan/common/constants/appConstants.dart';
import 'package:bujuan/common/netease_api/src/api/play/bean.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:bujuan/pages/play_list/playlist_page_view.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:get/get.dart';

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
  Color albumPrimaryColor = Get.theme.colorScheme.primary;
  Color onAlbumPrimaryColor = Get.theme.colorScheme.onPrimary;

  @override
  void initState() {
    super.initState();

    artistId = context.routeData.queryParams.get("artistId");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      AppController.to.updateAppBarTitle(title: "", subTitle: "", willRollBack: true);
      ArtistDetailWrap artistDetailWrap = await NeteaseMusicApi().artistDetail(artistId);
      artist = artistDetailWrap.data!.artist!;
      await OtherUtils.getImageColor('${artist.cover ?? artist.picUrl ?? ''}?param=200y200').then((paletteGenerator) {
        // 更新panel中的色调
        albumPrimaryColor = paletteGenerator.lightMutedColor?.color
            ?? paletteGenerator.lightVibrantColor?.color
            ?? paletteGenerator.dominantColor?.color
            ?? Get.theme.primaryColor;
        onAlbumPrimaryColor = ThemeData.estimateBrightnessForColor(albumPrimaryColor) == Brightness.light
            ? Colors.black
            : Colors.white;
      });

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
    if (loading) return const LoadingView();

    // 计算专辑宽度：
    double albumWidth = (context.width - AppDimensions.paddingMedium * 3) / 2.5;

    return Container(
      color: albumPrimaryColor,
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
            backgroundColor: albumPrimaryColor,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const <StretchMode>[
                StretchMode.zoomBackground, // 背景图缩放
                StretchMode.blurBackground, // 背景图模糊
                // StretchMode.fadeTitle,      // 标题渐隐
              ],
              titlePadding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium, left: AppDimensions.paddingMedium, right: AppDimensions.paddingMedium),
              title: Row(
                children: [
                  Expanded(
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
                          artist.name!,
                        ),
                        Text(
                          style: context.textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                          ),
                            artist.name!,
                        ),

                      ],
                    ),
                  ),
                  const Icon(TablerIcons.player_play)
                ],
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
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: Container(
                padding: const EdgeInsets.only(left: AppDimensions.paddingMedium),
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => setState(() {
                    crossAxisCount = Random().nextInt(4) + 1;
                  }),
                  child: const Text("专辑")
                ),
              )
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.red,
              height: (albumWidth + AppDimensions.paddingMedium * 2 + AppDimensions.paddingMedium) * crossAxisCount,
              child: CustomScrollView(
                scrollDirection: Axis.horizontal,
                slivers: [
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      width: AppDimensions.paddingMedium,
                    )
                  ),
                  SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,           // 显示两行
                      mainAxisSpacing: AppDimensions.paddingMedium,
                      childAspectRatio: 1.5,       // 宽高比
                    ),
                    addAutomaticKeepAlives: true,
                    itemCount: hotAlbums.length,
                    itemBuilder: (context, index) {
                      return KeepAliveWrapper(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SimpleExtendedImage.avatar(
                              width: albumWidth,
                              shape: BoxShape.rectangle,
                              '${hotAlbums[index].picUrl}?param=200y200'
                            ),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "${hotAlbums[index].name}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.bodyMedium,
                                ),
                                Text(
                                    "${DateTime.fromMillisecondsSinceEpoch(hotAlbums[index].publishTime ?? 0).year}",
                                  maxLines: 1,
                                  style: context.textTheme.bodySmall,
                                ),
                              ],
                            ))
                          ],
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(
                      child: SizedBox(
                        width: AppDimensions.paddingMedium,
                      )
                  ),
                ],
              ),
            )
          ),
          SliverToBoxAdapter(
            child: SizedBox(
                height: 50,
                child: const Text("单曲").paddingOnly(left: AppDimensions.paddingMedium)
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
                return Row(
                  children: [
                    Expanded(child: SongItem(playlist: topSongs, index: index)),
                    Text("${index + 1}").paddingOnly(left: AppDimensions.paddingMedium),
                  ],
                ).paddingSymmetric(horizontal: AppDimensions.paddingMedium);
              },
            ),
          ),
        ],
      ),
    );
  }
}
