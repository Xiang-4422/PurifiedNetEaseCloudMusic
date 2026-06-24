import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/ui/services/image_color_service.dart';
import 'package:bujuan/ui/layout/adaptive_layout_metrics.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/core/util/extensions.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/features/album/album_page_controller.dart';
import 'package:bujuan/features/album/album_page_controller_factory.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import 'package:get/get.dart';

/// 专辑页头部播放按钮提示文案。
@visibleForTesting
String albumPlayButtonTooltip({
  required String title,
  required int songCount,
}) {
  if (songCount <= 0) {
    return '专辑暂无歌曲';
  }
  final resolvedTitle = title.trim().isEmpty ? '当前专辑' : title.trim();
  return '播放专辑：$resolvedTitle';
}

/// 专辑详情页面，展示专辑信息和专辑歌曲。
class AlbumPageView extends StatefulWidget {
  /// 创建专辑详情页面。
  const AlbumPageView({Key? key}) : super(key: key);
  @override
  State<AlbumPageView> createState() => _AlbumPageViewState();
}

class _AlbumPageViewState extends State<AlbumPageView> {
  final AlbumPageController _controller = Get.find<AlbumPageControllerFactory>().create();
  final PlayerController _playerController = Get.find<PlayerController>();
  late String albumId;
  late AlbumEntity album;
  List<PlaybackQueueItem> albumSongs = [];

  bool loading = true;
  bool loadFailed = false;
  bool hasLoadedDetail = false;
  Color albumColor = Get.theme.colorScheme.primary;
  Color onAlbumColor = Get.theme.colorScheme.onPrimary;
  int _detailRefreshGeneration = 0;

  @override
  void initState() {
    super.initState();

    albumId = context.routeData.queryParams.get('albumId');

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final initialDetail = await _controller.loadInitialDetail(albumId);
      final localDetail = initialDetail.localDetail;
      if (initialDetail.hasLocalDetail && localDetail != null) {
        album = localDetail.album;
        albumSongs
          ..clear()
          ..addAll(localDetail.albumSongs);
        if (!mounted) {
          return;
        }
        setState(() {
          loading = false;
          loadFailed = false;
          hasLoadedDetail = true;
        });
        unawaited(_updateAlbumColor(_resolvedArtworkUrl));
        if (initialDetail.shouldRefreshInBackground) {
          unawaited(_refreshAlbumDetail(showLoadingState: false));
        }
        return;
      }
      await _refreshAlbumDetail(showLoadingState: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading && !hasLoadedDetail) {
      return Container(color: albumColor, child: const LoadingView());
    }
    if (loadFailed && !hasLoadedDetail) {
      return Container(
        color: albumColor,
        child: ErrorView(
          message: '专辑加载失败',
          onRetry: () => unawaited(_refreshAlbumDetail(showLoadingState: true)),
        ),
      );
    }
    final layoutMetrics = AdaptiveLayoutMetrics.of(context);
    final canPlayAlbum = albumSongs.isNotEmpty;
    final playTooltip = albumPlayButtonTooltip(
      title: album.title,
      songCount: albumSongs.length,
    );

    return RefreshIndicator(
      onRefresh: () => _refreshAlbumDetail(showLoadingState: false),
      child: Container(
        color: albumColor,
        child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
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
              titlePadding: const EdgeInsets.only(bottom: AppDimensions.paddingMedium, left: AppDimensions.paddingMedium, right: AppDimensions.paddingMedium),
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
                      color: Colors.red.withValues(alpha: canPlayAlbum ? 1 : 0.45),
                      child: IconButton(
                        tooltip: playTooltip,
                        color: Colors.white,
                        disabledColor: Colors.white.withValues(alpha: 0.45),
                        icon: const Icon(TablerIcons.player_play_filled),
                        onPressed: canPlayAlbum
                            ? () => _playerController.playPlaylist(
                                  albumSongs,
                                  0,
                                  playListName: album.title,
                                  playListNameHeader: "专辑",
                                )
                            : null,
                      ),
                    ),
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
          SliverPrototypeExtentList(
            prototypeItem: SongItem(
              item: albumSongs.isEmpty ? const PlaybackQueueItem.empty() : albumSongs.first,
              index: 0,
              playListName: album.title,
              playListHeader: "专辑",
              stringColor: onAlbumColor,
              showPic: false,
              showIndex: true,
            ).paddingSymmetric(horizontal: AppDimensions.paddingMedium),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return SongItem(playlist: albumSongs, index: index, playListName: album.title, playListHeader: "专辑", stringColor: onAlbumColor, showPic: false, showIndex: true, onPlay: _playerController.playPlaylist)
                    .paddingSymmetric(horizontal: AppDimensions.paddingMedium);
              },
              childCount: albumSongs.length,
              addAutomaticKeepAlives: false,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: AppDimensions.bottomPanelHeaderHeight,
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _refreshAlbumDetail({required bool showLoadingState}) async {
    final generation = ++_detailRefreshGeneration;
    if (showLoadingState && mounted) {
      setState(() {
        loading = true;
        loadFailed = false;
      });
    }
    try {
      final albumDetail = await _controller.fetchDetail(albumId);
      if (!mounted || generation != _detailRefreshGeneration) {
        return;
      }
      setState(() {
        album = albumDetail.album;
        albumSongs
          ..clear()
          ..addAll(albumDetail.albumSongs);
        loading = false;
        loadFailed = false;
        hasLoadedDetail = true;
      });
      unawaited(_updateAlbumColor(_resolvedArtworkUrl));
    } catch (_) {
      if (!mounted || generation != _detailRefreshGeneration) {
        return;
      }
      setState(() {
        loading = false;
        loadFailed = !hasLoadedDetail;
      });
    }
  }

  Future<void> _updateAlbumColor(String? artworkPath) async {
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
        album.artworkUrl,
        fallbackItems: albumSongs,
      );
}
