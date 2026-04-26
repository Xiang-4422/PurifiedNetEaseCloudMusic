import 'dart:async';

//

import 'package:audio_service/audio_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/shell/app_controller.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/data_widget.dart';
//
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:bujuan/routes/router.gr.dart' as gr;

import 'package:get/get.dart';

import '../../common/constants/other.dart';
import '../../widget/keep_alive_wrapper.dart';
import '../../widget/scroll_helpers.dart';
import '../../widget/simple_extended_image.dart';

class ArtistPageView extends StatefulWidget {
  const ArtistPageView({Key? key}) : super(key: key);

  @override
  State<ArtistPageView> createState() => _ArtistPageViewState();
}

class _ArtistPageViewState extends State<ArtistPageView> {
  final ArtistRepository _repository = ArtistRepository();
  late String artistId;
  late ArtistEntity artist;

  final List<MediaItem> topSongs = [];
  final List<AlbumEntity> hotAlbums = [];

  bool loading = true;
  Color albumColor = Get.theme.colorScheme.primary;
  Color onAlbumColor = Get.theme.colorScheme.onPrimary;

  @override
  void initState() {
    super.initState();

    artistId = context.routeData.queryParams.get("artistId");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final localDetail = await _repository.loadLocalArtistDetail(
        artistId: artistId,
        likedSongIds: AppController.to.likedSongIds.toList(),
      );
      if (localDetail != null) {
        artist = localDetail.artist;
        topSongs
          ..clear()
          ..addAll(localDetail.topSongs);
        hotAlbums
          ..clear()
          ..addAll(localDetail.hotAlbums);
        await _updateArtistColor(_resolvedArtworkUrl);
        if (!mounted) {
          return;
        }
        setState(() {
          loading = false;
        });
        unawaited(_refreshArtistDetail(showLoadingState: false));
        return;
      }
      await _refreshArtistDetail(showLoadingState: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(color: albumColor, child: const LoadingView());
    }

    // 计算专辑宽度：
    double albumWidth = (context.width - AppDimensions.paddingMedium * 3) / 2.5;

    return RefreshIndicator(
      onRefresh: () => _refreshArtistDetail(showLoadingState: false),
      child: Container(
        color: albumColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(), // 关键：允许弹性滚动
          controller: ScrollController(),
          slivers: [
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
                titlePadding: const EdgeInsets.all(AppDimensions.paddingMedium),
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
                                style: context.textTheme.titleLarge!.copyWith(
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 2
                                    ..color = Colors.black,
                                ),
                                maxLines: 1,
                                "  ${artist.name}",
                              ),
                              Text(
                                style: context.textTheme.titleLarge!.copyWith(
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                "  ${artist.name}",
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
                                  topSongs,
                                  0,
                                  playListName: artist.name,
                                  playListNameHeader: "歌手",
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
                  _resolvedArtworkUrl ?? '',
                ),
              ),
              // bottom:
            ),
            // 专辑
            SliverToBoxAdapter(
              child: SizedBox(
                  height: 50,
                  child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "专辑",
                        style: TextStyle(
                            color: onAlbumColor, fontWeight: FontWeight.bold),
                      ).paddingOnly(left: AppDimensions.paddingMedium))),
            ),
            SliverToBoxAdapter(
                child: SizedBox(
              height: albumWidth * 1.35,
              child: ListView.builder(
                addAutomaticKeepAlives: true,
                itemCount: hotAlbums.length,
                scrollDirection: Axis.horizontal,
                physics: SnappingScrollPhysics(
                    itemExtent: albumWidth + AppDimensions.paddingMedium),
                itemBuilder: (context, index) {
                  double marginLeft =
                      index == 0 ? AppDimensions.paddingMedium : 0;
                  return KeepAliveWrapper(
                    child: GestureDetector(
                      onTap: () => context.router.push(const gr.AlbumRouteView()
                          .copyWith(queryParams: {
                        'albumId': hotAlbums[index].sourceId
                      })),
                      child: SizedBox(
                        height: albumWidth * 1.35,
                        width: albumWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SimpleExtendedImage.avatar(
                                width: albumWidth,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.paddingMedium),
                                ArtworkPathResolver.resolvePreferredArtwork(
                                      hotAlbums[index].artworkUrl,
                                    ) ??
                                    ''),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  hotAlbums[index].title,
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
                            ))
                          ],
                        ),
                      ),
                    ),
                  ).marginOnly(
                      left: marginLeft, right: AppDimensions.paddingMedium);
                },
              ),
            )),
            // 单曲
            SliverToBoxAdapter(
              child: SizedBox(
                  height: 50,
                  child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "单曲",
                        style: TextStyle(
                            color: onAlbumColor, fontWeight: FontWeight.bold),
                      ).paddingOnly(left: AppDimensions.paddingMedium))),
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
                  return SongItem(
                          playlist: topSongs,
                          index: index,
                          playListName: artist.name,
                          playListHeader: "歌手",
                          stringColor: onAlbumColor,
                          showIndex: true)
                      .paddingSymmetric(
                          horizontal: AppDimensions.paddingMedium);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshArtistDetail({required bool showLoadingState}) async {
    if (showLoadingState && mounted) {
      setState(() {
        loading = true;
      });
    }
    final artistDetail = await _repository.fetchArtistDetail(
      artistId: artistId,
      likedSongIds: AppController.to.likedSongIds.toList(),
    );
    artist = artistDetail.artist;
    topSongs
      ..clear()
      ..addAll(artistDetail.topSongs);
    hotAlbums
      ..clear()
      ..addAll(artistDetail.hotAlbums);
    await _updateArtistColor(_resolvedArtworkUrl);
    if (!mounted) {
      return;
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> _updateArtistColor(String? artworkPath) async {
    albumColor = await OtherUtils.getImageColor(artworkPath);
    onAlbumColor = albumColor.invertedColor;
  }

  String? get _resolvedArtworkUrl =>
      ArtworkPathResolver.resolvePreferredArtwork(
        artist.artworkUrl,
        fallbackItems: topSongs,
      );
}
