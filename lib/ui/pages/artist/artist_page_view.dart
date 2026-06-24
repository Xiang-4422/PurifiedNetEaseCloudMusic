import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/ui/services/image_color_service.dart';
import 'package:bujuan/ui/layout/adaptive_layout_metrics.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/core/util/extensions.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/artist/artist_page_controller.dart';
import 'package:bujuan/features/music_detail/music_detail_controller_bundle.dart';
import 'package:bujuan/app/routing/router.gr.dart' as gr;
import 'package:bujuan/ui/pages/music_detail/local_first_detail_page_mixin.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:bujuan/ui/widgets/common/layout/keep_alive_wrapper.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:bujuan/ui/widgets/common/layout/scroll_helpers.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:get/get.dart';

/// 歌手页热门专辑横向列表的预渲染范围。
@visibleForTesting
const double artistHotAlbumCacheExtent = 360;

/// 歌手页头部播放按钮提示文案。
@visibleForTesting
String artistPlayButtonTooltip({
  required String name,
  required int songCount,
}) {
  if (songCount <= 0) {
    return '歌手暂无歌曲';
  }
  final resolvedName = name.trim().isEmpty ? '当前歌手' : name.trim();
  return '播放歌手热门歌曲：$resolvedName';
}

/// 歌手页热门专辑年份展示文案。
@visibleForTesting
String artistHotAlbumYearLabel(int? publishTime) {
  if (publishTime == null || publishTime <= 0) {
    return '未知年份';
  }
  return DateTime.fromMillisecondsSinceEpoch(publishTime).year.toString();
}

/// 歌手页热门专辑卡片辅助语义标签。
@visibleForTesting
String artistHotAlbumTileSemanticsLabel({
  required String title,
  required int? publishTime,
}) {
  final resolvedTitle = title.trim().isEmpty ? '未知专辑' : title.trim();
  return '打开专辑：$resolvedTitle - ${artistHotAlbumYearLabel(publishTime)}';
}

/// 歌手详情页面，展示热门歌曲和专辑。
class ArtistPageView extends StatefulWidget {
  /// 创建歌手详情页面。
  const ArtistPageView({Key? key}) : super(key: key);

  @override
  State<ArtistPageView> createState() => _ArtistPageViewState();
}

class _ArtistPageViewState extends State<ArtistPageView> with LocalFirstDetailPageMixin<ArtistPageView> {
  late final MusicDetailControllerBundle _controllers = Get.find<MusicDetailControllerBundle>();
  late final ArtistPageController _controller = _controllers.artistControllerFactory.create();
  late String artistId;
  late ArtistEntity artist;

  final List<PlaybackQueueItem> topSongs = [];
  final List<AlbumEntity> hotAlbums = [];

  Color albumColor = Get.theme.colorScheme.primary;
  Color onAlbumColor = Get.theme.colorScheme.onPrimary;

  @override
  void initState() {
    super.initState();

    artistId = context.routeData.queryParams.get("artistId");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await loadInitialLocalFirstDetail<ArtistDetailData>(
        loadInitialDetail: () => _controller.loadInitialDetail(artistId),
        applyDetail: _applyArtistDetail,
        refreshDetail: _refreshArtistDetail,
        afterApply: (_) => _updateArtistColor(_resolvedArtworkUrl),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (detailLoading && !hasLoadedDetail) {
      return Container(color: albumColor, child: const LoadingView());
    }
    if (detailLoadFailed && !hasLoadedDetail) {
      return Container(
        color: albumColor,
        child: ErrorView(
          message: '歌手加载失败',
          onRetry: () => unawaited(_refreshArtistDetail(showLoadingState: true)),
        ),
      );
    }

    final layoutMetrics = AdaptiveLayoutMetrics.of(context);
    // 计算专辑宽度：
    double albumWidth = (context.width - AppDimensions.paddingMedium * 3) / 2.5;
    final canPlayArtist = topSongs.isNotEmpty;
    final playTooltip = artistPlayButtonTooltip(
      name: artist.name,
      songCount: topSongs.length,
    );

    return RefreshIndicator(
      onRefresh: () => _refreshArtistDetail(showLoadingState: false),
      child: Container(
        color: albumColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(), // 关键：允许弹性滚动
          slivers: [
            SliverAppBar(
              toolbarHeight: AppDimensions.appBarHeight - context.mediaQueryPadding.top + AppDimensions.paddingLarge,
              collapsedHeight: AppDimensions.appBarHeight - context.mediaQueryPadding.top + AppDimensions.paddingLarge,
              expandedHeight: layoutMetrics.heroExtent,
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
                        color: Colors.red.withValues(alpha: canPlayArtist ? 1 : 0.45),
                        child: IconButton(
                          tooltip: playTooltip,
                          color: Colors.white,
                          disabledColor: Colors.white.withValues(alpha: 0.45),
                          icon: const Icon(TablerIcons.player_play_filled),
                          onPressed: canPlayArtist
                              ? () => _controllers.playbackActions.playPlaylist(
                                    topSongs,
                                    0,
                                    playListName: artist.name,
                                    playListNameHeader: "歌手",
                                  )
                              : null,
                        ),
                      )
                    ],
                  ),
                ),
                // centerTitle: true,
                expandedTitleScale: 1.5,
                background: SimpleExtendedImage(
                  width: context.width,
                  height: layoutMetrics.heroExtent,
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
                        style: TextStyle(color: onAlbumColor, fontWeight: FontWeight.bold),
                      ).paddingOnly(left: AppDimensions.paddingMedium))),
            ),
            SliverToBoxAdapter(
                child: SizedBox(
              height: albumWidth * 1.35,
              child: ListView.builder(
                addAutomaticKeepAlives: true,
                cacheExtent: artistHotAlbumCacheExtent,
                itemCount: hotAlbums.length,
                scrollDirection: Axis.horizontal,
                physics: SnappingScrollPhysics(itemExtent: albumWidth + AppDimensions.paddingMedium),
                itemBuilder: (context, index) {
                  final album = hotAlbums[index];
                  final marginLeft = index == 0 ? AppDimensions.paddingMedium : 0.0;
                  final yearLabel = artistHotAlbumYearLabel(album.publishTime);
                  final label = artistHotAlbumTileSemanticsLabel(
                    title: album.title,
                    publishTime: album.publishTime,
                  );
                  return KeepAliveWrapper(
                    child: Tooltip(
                      message: label,
                      child: Semantics(
                        button: true,
                        label: label,
                        child: ExcludeSemantics(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => context.router.push(const gr.AlbumRouteView().copyWith(queryParams: {'albumId': album.sourceId})),
                            child: SizedBox(
                              height: albumWidth * 1.35,
                              width: albumWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SimpleExtendedImage.avatar(
                                    width: albumWidth,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(AppDimensions.paddingMedium),
                                    ArtworkPathResolver.resolvePreferredArtwork(
                                          album.artworkUrl,
                                        ) ??
                                        '',
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          album.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: context.textTheme.bodyMedium?.copyWith(
                                            color: onAlbumColor,
                                          ),
                                        ),
                                        Text(
                                          yearLabel,
                                          maxLines: 1,
                                          style: context.textTheme.bodySmall?.copyWith(
                                            color: onAlbumColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).marginOnly(left: marginLeft, right: AppDimensions.paddingMedium);
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
                        style: TextStyle(color: onAlbumColor, fontWeight: FontWeight.bold),
                      ).paddingOnly(left: AppDimensions.paddingMedium))),
            ),
            SliverPrototypeExtentList(
              prototypeItem: SongItem(
                item: topSongs.isEmpty ? const PlaybackQueueItem.empty() : topSongs.first,
                index: 0,
                playListName: artist.name,
                playListHeader: "歌手",
                stringColor: onAlbumColor,
                showIndex: true,
              ).paddingSymmetric(horizontal: AppDimensions.paddingMedium),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return SongItem(playlist: topSongs, index: index, playListName: artist.name, playListHeader: "歌手", stringColor: onAlbumColor, showIndex: true, onPlay: _controllers.playbackActions.playPlaylist)
                      .paddingSymmetric(horizontal: AppDimensions.paddingMedium);
                },
                childCount: topSongs.length,
                addAutomaticKeepAlives: false,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: AppDimensions.bottomPanelHeaderHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshArtistDetail({required bool showLoadingState}) async {
    return refreshLocalFirstDetail<ArtistDetailData>(
      showLoadingState: showLoadingState,
      fetchDetail: () => _controller.fetchDetail(artistId),
      applyDetail: _applyArtistDetail,
      afterApply: (_) => _updateArtistColor(_resolvedArtworkUrl),
    );
  }

  void _applyArtistDetail(ArtistDetailData detail) {
    artist = detail.artist;
    topSongs
      ..clear()
      ..addAll(detail.topSongs);
    hotAlbums
      ..clear()
      ..addAll(detail.hotAlbums);
  }

  Future<void> _updateArtistColor(String? artworkPath) async {
    final color = await ImageColorService.dominantColor(artworkPath);
    if (!mounted) {
      return;
    }
    setState(() {
      albumColor = color;
      onAlbumColor = color.invertedColor;
    });
  }

  String? get _resolvedArtworkUrl => ArtworkPathResolver.resolvePreferredArtwork(
        artist.artworkUrl,
        fallbackItems: topSongs,
      );
}
