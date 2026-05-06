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
  initialRefresh,
  loadMore,
  completeForPlayback,
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
  static const int _initialPlaylistPageSize = 30;
  static const int _nextPlaylistPageSize = 100;

  final PlaylistPageController _controller = Get.find<FeatureControllerFactory>().playlistPage();
  final PlaylistPlaybackUseCase _playbackUseCase = Get.find<PlaylistPlaybackUseCase>();
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.addListener(_handleScrollNearBottom);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPlaylistData();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScrollNearBottom)
      ..dispose();
    super.dispose();
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
                  onTap: () => _refreshPlaylistData(showLoadingState: true),
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
      onRefresh: () => _refreshPlaylistData(showLoadingState: false),
      child: CustomScrollView(
        controller: _scrollController,
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
        onPressed: _canPlayFullPlaylist
            ? () async {
                await _playFullPlaylist(shuffle: shuffle);
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
      sliver: SliverList.separated(
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.paddingSmall),
        itemBuilder: (context, index) {
          final color = widgetColor.withValues(alpha: 0.12);
          return Row(
            children: [
              Container(
                width: 28,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSmall),
              Expanded(
                child: Column(
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
          );
        },
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
      unawaited(_refreshPlaylistData(showLoadingState: false));
      return;
    }
    await _refreshPlaylistData(showLoadingState: true);
  }

  Future<void> _refreshPlaylistData({required bool showLoadingState}) async {
    if (_fetchKind != _PlaylistFetchKind.none) {
      return;
    }
    if (mounted) {
      setState(() {
        _fetchKind = _PlaylistFetchKind.initialRefresh;
        if (showLoadingState && songs.isEmpty && !_hasPlaylistMetadata) {
          loadState = _PlaylistPageLoadState.loadingInitial;
        } else if (songs.isEmpty && _hasPlaylistMetadata) {
          loadState = _PlaylistPageLoadState.showingMetadataOnly;
        }
      });
    }
    try {
      final data = await _controller.fetchDetail(
        widget.playlistId,
        offset: 0,
        limit: _initialPlaylistPageSize,
      );
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
        ToastService.show('剩余歌曲加载失败');
        setState(() {
          loadState = _PlaylistPageLoadState.loadFailedWithPartial;
        });
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

  bool get _canPlayFullPlaylist => songs.isNotEmpty && loadState != _PlaylistPageLoadState.loadingInitial && loadState != _PlaylistPageLoadState.loadFailedEmpty && _fetchKind == _PlaylistFetchKind.none;

  Color get _playlistActionColor => _canPlayFullPlaylist ? widgetColor : widgetColor.withValues(alpha: 0.35);

  bool get _hasPlaylistMetadata => playlistName.trim().isNotEmpty || coverUrl?.isNotEmpty == true || trackCount != null;

  bool get _isShowingPlaylistSkeleton => songs.isEmpty && _fetchKind == _PlaylistFetchKind.initialRefresh && _hasPlaylistMetadata;

  bool get _isShowingStatusFooter =>
      loadState == _PlaylistPageLoadState.loadFailedWithPartial ||
      (loadState == _PlaylistPageLoadState.loadFailedEmpty && _hasPlaylistMetadata) ||
      _fetchKind == _PlaylistFetchKind.loadMore ||
      _fetchKind == _PlaylistFetchKind.completeForPlayback;

  String get _completionMessage {
    if (loadState == _PlaylistPageLoadState.loadFailedEmpty && _hasPlaylistMetadata) {
      return '歌曲加载失败，下拉可重试';
    }
    if (loadState == _PlaylistPageLoadState.loadFailedWithPartial) {
      return '剩余歌曲加载失败，下拉可重试';
    }
    return _fetchKind == _PlaylistFetchKind.completeForPlayback ? '正在补全播放队列...' : '正在加载剩余歌曲...';
  }

  void _handleScrollNearBottom() {
    if (!_scrollController.hasClients || _scrollController.position.extentAfter > 800) {
      return;
    }
    unawaited(_loadMorePlaylistSongs());
  }

  Future<void> _loadMorePlaylistSongs() async {
    if (!mounted || _fetchKind != _PlaylistFetchKind.none || loadState != _PlaylistPageLoadState.showingPartial) {
      return;
    }
    if (mounted) {
      setState(() {
        _fetchKind = _PlaylistFetchKind.loadMore;
      });
    }
    try {
      final data = await _controller.fetchDetail(
        widget.playlistId,
        offset: songs.length,
        limit: _nextPlaylistPageSize,
      );
      await _applyPlaylistDetail(
        data,
        nextState: data.isComplete ? _PlaylistPageLoadState.showingFull : _PlaylistPageLoadState.showingPartial,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ToastService.show('剩余歌曲加载失败');
      setState(() {
        loadState = _PlaylistPageLoadState.loadFailedWithPartial;
      });
    } finally {
      if (mounted) {
        setState(() {
          _fetchKind = _PlaylistFetchKind.none;
        });
      }
    }
  }

  Future<bool> _ensureFullPlaylistLoaded() async {
    if (loadState == _PlaylistPageLoadState.showingFull) {
      return songs.isNotEmpty;
    }
    if (_fetchKind != _PlaylistFetchKind.none) {
      return false;
    }
    if (mounted) {
      setState(() {
        _fetchKind = _PlaylistFetchKind.completeForPlayback;
      });
    }
    try {
      final data = await _controller.fetchDetail(
        widget.playlistId,
        offset: songs.length,
        limit: -1,
      );
      await _applyPlaylistDetail(
        data,
        nextState: data.isComplete ? _PlaylistPageLoadState.showingFull : _PlaylistPageLoadState.showingPartial,
      );
      return data.songs.isNotEmpty && data.isComplete;
    } catch (_) {
      if (mounted) {
        ToastService.show('补全播放队列失败');
        setState(() {
          loadState = songs.isEmpty ? _PlaylistPageLoadState.loadFailedEmpty : _PlaylistPageLoadState.loadFailedWithPartial;
        });
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _fetchKind = _PlaylistFetchKind.none;
        });
      }
    }
  }

  Future<void> _playFullPlaylist({required bool shuffle}) async {
    final canPlay = await _ensureFullPlaylistLoaded();
    if (!canPlay) {
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
