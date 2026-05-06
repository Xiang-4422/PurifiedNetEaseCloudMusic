import 'dart:async';

import 'package:bujuan/app/ui/toast_service.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/app/bootstrap/feature_controller_factory.dart';
import 'package:bujuan/app/theme/image_color_service.dart';
import 'package:bujuan/app/ui/adaptive_layout_metrics.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/features/playlist/application/playlist_artwork_color_service.dart';
import 'package:bujuan/features/playlist/application/playlist_detail_service.dart';
import 'package:bujuan/features/playlist/application/playlist_playback_use_case.dart';
import 'package:bujuan/features/playlist/playlist_page_controller.dart';
import 'package:bujuan/features/playlist/playlist_widgets.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/widget/artwork_path_resolver.dart';
import 'package:bujuan/widget/data_widget.dart';
import 'package:bujuan/widget/simple_extended_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:get/get.dart';

enum _PlaylistPageLoadState {
  loadingInitial,
  showingMetadataOnly,
  showingPartial,
  showingFull,
  loadFailedWithPartial,
  loadFailedEmpty,
}

enum _PlaylistFetchKind {
  none,
  loadingFirstPage,
  loadingRemaining,
  refreshingFull,
}

/// 歌单详情页面，展示歌单元信息和歌曲列表。
class PlayListPageView extends StatefulWidget {
  /// 创建歌单详情页面。
  const PlayListPageView({
    required this.playlistId,
    required this.playlistName,
    this.coverUrl,
    this.trackCount,
    super.key,
  });

  /// 歌单 id。
  final String playlistId;

  /// 歌单名称，用作初始标题和播放队列名。
  final String playlistName;

  /// 歌单封面地址。
  final String? coverUrl;

  /// 歌单歌曲总数。
  final int? trackCount;

  @override
  State<PlayListPageView> createState() => _PlayListPageViewState();
}

class _PlayListPageViewState extends State<PlayListPageView> {
  final PlaylistPageController _controller = Get.find<FeatureControllerFactory>().playlistPage();
  final PlaylistPlaybackUseCase _playbackUseCase = Get.find<PlaylistPlaybackUseCase>();

  String playlistName = '';
  String? coverUrl;
  int? trackCount;
  List<PlaybackQueueItem> songs = <PlaybackQueueItem>[];

  bool isSubscribed = false;
  bool isMyPlayList = false;
  _PlaylistFetchKind _fetchKind = _PlaylistFetchKind.none;
  int _artworkColorRequestId = 0;

  _PlaylistPageLoadState loadState = _PlaylistPageLoadState.loadingInitial;
  final PlaylistArtworkColorService _artworkColorService = PlaylistArtworkColorService();

  Color albumColor = Get.theme.colorScheme.primary;
  Color widgetColor = Get.theme.colorScheme.onPrimary;

  @override
  void initState() {
    super.initState();
    playlistName = widget.playlistName;
    coverUrl = widget.coverUrl;
    trackCount = widget.trackCount;
    loadState = _hasPlaylistMetadata ? _PlaylistPageLoadState.showingMetadataOnly : _PlaylistPageLoadState.loadingInitial;
    unawaited(_updateArtworkColors(_resolvedCoverUrl));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPlaylistData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final layoutMetrics = AdaptiveLayoutMetrics.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      color: albumColor,
      child: loadState == _PlaylistPageLoadState.loadingInitial && !_hasPlaylistMetadata
          ? const LoadingView()
          : loadState == _PlaylistPageLoadState.loadFailedEmpty && !_hasPlaylistMetadata
              ? GestureDetector(
                  onTap: () => _loadFirstPageAndRemaining(showLoadingState: true),
                  child: const ErrorView(),
                )
              : _buildPlaylistContent(context, layoutMetrics),
    );
  }

  Widget _buildPlaylistContent(
    BuildContext context,
    AdaptiveLayoutMetrics layoutMetrics,
  ) {
    return RefreshIndicator(
      onRefresh: _refreshFullPlaylist,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildPlaylistAppBar(context, layoutMetrics),
          if (_isShowingPlaylistSkeleton)
            _buildPlaylistSkeletonSliver(context)
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return SongItem(
                      index: index,
                      playlist: songs,
                      playListName: playlistName,
                      playListHeader: "歌单",
                      stringColor: widgetColor,
                      beforeOnTap: () {
                        ShellController.to.jumpBottomPanelToPage(0);
                        ShellController.to.openBottomPanel();
                      },
                      onPlay: _playbackUseCase.playAt,
                    );
                  },
                  childCount: songs.length,
                ),
              ),
            ),
          if (_isShowingStatusFooter) _buildCompletionFooter(context),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: AppDimensions.bottomPanelHeaderHeight,
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildPlaylistAppBar(
    BuildContext context,
    AdaptiveLayoutMetrics layoutMetrics,
  ) {
    return SliverAppBar(
      toolbarHeight: AppDimensions.appBarHeight,
      expandedHeight: layoutMetrics.heroExtent,
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: true,
      foregroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      backgroundColor: albumColor,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const <StretchMode>[
          StretchMode.zoomBackground,
        ],
        collapseMode: CollapseMode.pin,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              playlistName,
              style: context.textTheme.titleLarge?.copyWith(
                color: widgetColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "歌单·${trackCount ?? songs.length}首",
              style: context.textTheme.titleSmall?.copyWith(
                color: widgetColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        expandedTitleScale: 1.5,
        titlePadding: EdgeInsets.only(bottom: 60 + AppDimensions.paddingSmall, top: context.mediaQueryPadding.top, left: AppDimensions.paddingSmall, right: AppDimensions.paddingSmall),
        background: SimpleExtendedImage(
          width: context.width,
          height: layoutMetrics.heroExtent,
          _resolvedCoverUrl ?? '',
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Row(
          spacing: AppDimensions.paddingSmall,
          children: [
            Flexible(
              child: _buildPlaylistActionButton(
                context,
                icon: TablerIcons.repeat,
                label: '顺序播放',
                shuffle: false,
              ),
            ),
            _buildSubscribeButton(),
            Flexible(
              child: _buildPlaylistActionButton(
                context,
                icon: TablerIcons.arrows_shuffle,
                label: '随机播放',
                shuffle: true,
              ),
            ),
          ],
        ).paddingAll(AppDimensions.paddingSmall),
      ),
    );
  }

  Widget _buildPlaylistActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool shuffle,
  }) {
    return BlurryContainer(
      borderRadius: BorderRadius.circular(60),
      padding: EdgeInsets.zero,
      color: widgetColor.withValues(alpha: 0.05),
      child: IconButton(
        onPressed: _canPlayLoadedPlaylist
            ? () async {
                await _playLoadedPlaylist(shuffle: shuffle);
              }
            : null,
        icon: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              icon,
              color: _playlistActionColor,
            ),
            Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(color: _playlistActionColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Offstage(
      offstage: isMyPlayList,
      child: BlurryContainer(
        borderRadius: BorderRadius.circular(60),
        padding: EdgeInsets.zero,
        color: widgetColor.withValues(alpha: 0.05),
        child: IconButton(
          color: Colors.red,
          padding: EdgeInsets.zero,
          onPressed: () => _subscribePlayList(),
          icon: Icon(
            isSubscribed ? TablerIcons.heart_filled : TablerIcons.heart,
            color: isSubscribed ? Colors.red : widgetColor,
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCompletionFooter(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingMedium,
        ),
        child: Center(
          child: Text(
            _completionMessage,
            style: context.textTheme.titleSmall?.copyWith(
              color: widgetColor.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }

  SliverPadding _buildPlaylistSkeletonSliver(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final color = widgetColor.withValues(alpha: 0.12);
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final thumbnailSize = (44 * textScale).clamp(40.0, 52.0);
            final verticalPadding = (6 * textScale).clamp(6.0, 10.0);
            return ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: verticalPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox.square(
                      dimension: thumbnailSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingSmall),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FractionallySizedBox(
                            widthFactor: 0.55,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: 8,
        ),
      ),
    );
  }

  Future<void> _loadPlaylistData() async {
    final initialDetail = await _controller.loadInitialDetail(widget.playlistId);
    if (!mounted) {
      return;
    }
    if (initialDetail.localPlaylist != null) {
      _applyLocalPlaylist(initialDetail.localPlaylist!);
    }
    if (initialDetail.localState != PlaylistLocalDetailState.empty && initialDetail.localDetail != null) {
      await _applyPlaylistDetail(
        initialDetail.localDetail!,
        nextState: initialDetail.localState == PlaylistLocalDetailState.complete ? _PlaylistPageLoadState.showingFull : _PlaylistPageLoadState.showingPartial,
      );
      if (initialDetail.localState == PlaylistLocalDetailState.partial) {
        unawaited(_loadRemainingPlaylistSongs(offset: initialDetail.localDetail!.songs.length));
      }
      return;
    }
    await _loadFirstPageAndRemaining(showLoadingState: true);
  }

  Future<void> _loadFirstPageAndRemaining({required bool showLoadingState}) async {
    if (_fetchKind != _PlaylistFetchKind.none) {
      return;
    }
    if (mounted) {
      setState(() {
        _fetchKind = _PlaylistFetchKind.loadingFirstPage;
        if (showLoadingState && songs.isEmpty && !_hasPlaylistMetadata) {
          loadState = _PlaylistPageLoadState.loadingInitial;
        } else if (songs.isEmpty && _hasPlaylistMetadata) {
          loadState = _PlaylistPageLoadState.showingMetadataOnly;
        }
      });
    }
    try {
      final data = await _controller.fetchFirstPage(widget.playlistId);
      if (!mounted) {
        return;
      }
      await _applyPlaylistDetail(
        data,
        nextState: data.isComplete ? _PlaylistPageLoadState.showingFull : _PlaylistPageLoadState.showingPartial,
      );
      if (!data.isComplete) {
        await _loadRemainingPlaylistSongs(offset: data.songs.length);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (songs.isNotEmpty) {
        ToastService.show('歌单刷新失败');
        return;
      }
      setState(() {
        loadState = _PlaylistPageLoadState.loadFailedEmpty;
      });
    } finally {
      if (mounted) {
        setState(() {
          _fetchKind = _PlaylistFetchKind.none;
        });
      }
    }
  }

  Future<void> _refreshFullPlaylist() async {
    if (_fetchKind != _PlaylistFetchKind.none) {
      return;
    }
    setState(() {
      _fetchKind = _PlaylistFetchKind.refreshingFull;
    });
    try {
      final data = await _controller.refreshFull(widget.playlistId);
      if (!mounted) {
        return;
      }
      await _applyPlaylistDetail(
        data,
        nextState: data.isComplete ? _PlaylistPageLoadState.showingFull : _PlaylistPageLoadState.showingPartial,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (songs.isNotEmpty) {
        ToastService.show('歌单刷新失败');
        return;
      }
      setState(() {
        loadState = _PlaylistPageLoadState.loadFailedEmpty;
      });
    } finally {
      if (mounted) {
        setState(() {
          _fetchKind = _PlaylistFetchKind.none;
        });
      }
    }
  }

  void _applyLocalPlaylist(PlaylistEntity playlist) {
    if (!mounted) {
      return;
    }
    setState(() {
      playlistName = playlist.title;
      coverUrl = playlist.coverUrl ?? coverUrl;
      trackCount = playlist.trackCount ?? trackCount;
      if (songs.isEmpty && loadState == _PlaylistPageLoadState.loadingInitial && _hasPlaylistMetadata) {
        loadState = _PlaylistPageLoadState.showingMetadataOnly;
      }
    });
  }

  Future<void> _applyPlaylistDetail(
    PlaylistDetailData data, {
    required _PlaylistPageLoadState nextState,
  }) async {
    if (!mounted) {
      return;
    }
    setState(() {
      songs = data.songs;
      playlistName = data.playlistName ?? playlistName;
      coverUrl = data.coverUrl ?? coverUrl;
      trackCount = data.expectedTrackCount ?? trackCount;
      isSubscribed = data.isSubscribed;
      isMyPlayList = data.isMyPlayList;
      loadState = nextState;
    });
    unawaited(_updateArtworkColors(_resolvedCoverUrl));
  }

  Future<void> _updateArtworkColors(String? artworkPath) async {
    final requestId = ++_artworkColorRequestId;
    final colorPath = await _artworkColorService.resolveColorPath(artworkPath);
    if (!mounted || requestId != _artworkColorRequestId) {
      return;
    }
    final color = await ImageColorService.dominantColor(colorPath);
    if (!mounted || requestId != _artworkColorRequestId) {
      return;
    }
    setState(() {
      albumColor = color;
      widgetColor = color.invertedColor;
    });
  }

  String? get _resolvedCoverUrl => ArtworkPathResolver.resolveExplicitArtwork(
        coverUrl,
        fallbackItems: songs,
      );

  bool get _canPlayLoadedPlaylist => songs.isNotEmpty && loadState != _PlaylistPageLoadState.loadingInitial && loadState != _PlaylistPageLoadState.loadFailedEmpty && _fetchKind == _PlaylistFetchKind.none;

  Color get _playlistActionColor => _canPlayLoadedPlaylist ? widgetColor : widgetColor.withValues(alpha: 0.35);

  bool get _hasPlaylistMetadata => playlistName.trim().isNotEmpty || coverUrl?.isNotEmpty == true || trackCount != null;

  bool get _isShowingPlaylistSkeleton => songs.isEmpty && _fetchKind == _PlaylistFetchKind.loadingFirstPage && _hasPlaylistMetadata;

  bool get _isShowingStatusFooter => loadState == _PlaylistPageLoadState.loadFailedWithPartial || (loadState == _PlaylistPageLoadState.loadFailedEmpty && _hasPlaylistMetadata) || _fetchKind == _PlaylistFetchKind.loadingRemaining;

  String get _completionMessage {
    if (loadState == _PlaylistPageLoadState.loadFailedEmpty && _hasPlaylistMetadata) {
      return '歌曲加载失败，下拉可重试';
    }
    if (loadState == _PlaylistPageLoadState.loadFailedWithPartial) {
      return '剩余歌曲加载失败，下拉可重试';
    }
    return '正在加载剩余歌曲...';
  }

  Future<void> _loadRemainingPlaylistSongs({required int offset}) async {
    if (!mounted || offset <= 0) {
      return;
    }
    setState(() {
      _fetchKind = _PlaylistFetchKind.loadingRemaining;
    });
    try {
      final data = await _controller.fetchRemaining(
        widget.playlistId,
        offset: offset,
      );
      await _applyPlaylistDetail(
        data,
        nextState: data.isComplete ? _PlaylistPageLoadState.showingFull : _PlaylistPageLoadState.showingPartial,
      );
    } catch (_) {
      if (mounted) {
        ToastService.show('剩余歌曲加载失败');
        setState(() {
          loadState = songs.isEmpty ? _PlaylistPageLoadState.loadFailedEmpty : _PlaylistPageLoadState.loadFailedWithPartial;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _fetchKind = _PlaylistFetchKind.none;
        });
      }
    }
  }

  Future<void> _playLoadedPlaylist({required bool shuffle}) async {
    if (!_canPlayLoadedPlaylist) {
      return;
    }
    ShellController.to.jumpBottomPanelToPage(0);
    ShellController.to.openBottomPanel();
    if (shuffle) {
      await _playbackUseCase.playShuffle(
        songs,
        playListName: playlistName,
        playListNameHeader: "歌单",
      );
      return;
    }
    await _playbackUseCase.playSequential(
      songs,
      playListName: playlistName,
      playListNameHeader: "歌单",
    );
  }

  Future<void> _subscribePlayList() async {
    final value = await _controller.toggleSubscription(
      widget.playlistId,
      subscribe: !isSubscribed,
    );
    if (value.success && mounted) {
      setState(() {
        isSubscribed = !isSubscribed;
      });
    }
  }
}
