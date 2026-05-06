import 'dart:async';

import 'package:bujuan/app/ui/toast_service.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:bujuan/app/bootstrap/feature_controller_factory.dart';
import 'package:bujuan/app/theme/image_color_service.dart';
import 'package:bujuan/app/ui/adaptive_layout_metrics.dart';
import 'package:bujuan/common/constants/app_constants.dart';
import 'package:bujuan/common/constants/extensions.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
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
  showingPartial,
  showingFull,
  loadFailedWithPartial,
  loadFailedEmpty,
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
  static const int _playlistPageSize = 30;

  final PlaylistPageController _controller = Get.find<FeatureControllerFactory>().playlistPage();
  final PlaylistPlaybackUseCase _playbackUseCase = Get.find<PlaylistPlaybackUseCase>();
  final ScrollController _scrollController = ScrollController();

  String playlistName = '';
  String? coverUrl;
  int? trackCount;
  List<PlaybackQueueItem> songs = <PlaybackQueueItem>[];
  int loadedSongCount = 0;

  bool isSubscribed = false;
  bool isMyPlayList = false;
  bool loadingMoreSongs = false;
  bool completingFullPlaylist = false;

  _PlaylistPageLoadState loadState = _PlaylistPageLoadState.loadingInitial;

  Color albumColor = Get.theme.colorScheme.primary;
  Color widgetColor = Get.theme.colorScheme.onPrimary;

  @override
  void initState() {
    super.initState();
    playlistName = widget.playlistName;
    coverUrl = widget.coverUrl;
    trackCount = widget.trackCount;
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
      child: loadState == _PlaylistPageLoadState.loadingInitial
          ? const LoadingView()
          : loadState == _PlaylistPageLoadState.loadFailedEmpty
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
        slivers: [
          _buildPlaylistAppBar(context, layoutMetrics),
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
                childCount: loadedSongCount,
              ),
            ),
          ),
          if (_isCompletingPlaylist) _buildCompletionFooter(context),
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
              "歌单·${trackCount ?? loadedSongCount}首",
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

  Future<void> _loadPlaylistData() async {
    final localDetail = await _controller.loadLocalDetail(widget.playlistId);
    final cachedSnapshot = await _controller.loadCachedSnapshot(widget.playlistId);
    if (!mounted) {
      return;
    }
    if (cachedSnapshot != null) {
      playlistName = cachedSnapshot.name;
      coverUrl = cachedSnapshot.coverUrl ?? coverUrl;
      trackCount = cachedSnapshot.trackCount ?? trackCount;
    }
    final localState = _controller.resolveLocalDetailState(localDetail);
    if (localState != PlaylistLocalDetailState.empty && localDetail != null) {
      await _applyPlaylistDetail(
        localDetail,
        nextState: localState == PlaylistLocalDetailState.complete ? _PlaylistPageLoadState.showingFull : _PlaylistPageLoadState.showingPartial,
      );
      unawaited(_refreshPlaylistData(showLoadingState: false));
      return;
    }
    await _refreshPlaylistData(showLoadingState: true);
  }

  Future<void> _refreshPlaylistData({required bool showLoadingState}) async {
    if (showLoadingState && mounted) {
      setState(() {
        loadState = _PlaylistPageLoadState.loadingInitial;
      });
    }
    try {
      final data = await _controller.fetchDetail(
        widget.playlistId,
        offset: 0,
        limit: _playlistPageSize,
      );
      final snapshot = await _controller.loadCachedSnapshot(widget.playlistId);
      if (!mounted) {
        return;
      }
      if (snapshot != null) {
        playlistName = snapshot.name;
        coverUrl = snapshot.coverUrl ?? coverUrl;
        trackCount = snapshot.trackCount ?? trackCount;
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
    }
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
      loadedSongCount = songs.length;
      trackCount = data.expectedTrackCount ?? trackCount;
      isSubscribed = data.isSubscribed;
      isMyPlayList = data.isMyPlayList;
      loadState = nextState;
    });
    unawaited(_updateArtworkColors(_resolvedCoverUrl));
  }

  Future<void> _updateArtworkColors(String? artworkPath) async {
    final color = await ImageColorService.dominantColor(artworkPath);
    if (!mounted) {
      return;
    }
    setState(() {
      albumColor = color;
      widgetColor = color.invertedColor;
    });
  }

  String? get _resolvedCoverUrl => ArtworkPathResolver.resolvePreferredArtwork(
        coverUrl,
        fallbackItems: songs,
      );

  bool get _canPlayFullPlaylist => songs.isNotEmpty && loadState != _PlaylistPageLoadState.loadingInitial && loadState != _PlaylistPageLoadState.loadFailedEmpty && !loadingMoreSongs && !completingFullPlaylist;

  Color get _playlistActionColor => _canPlayFullPlaylist ? widgetColor : widgetColor.withValues(alpha: 0.35);

  bool get _isCompletingPlaylist => loadState == _PlaylistPageLoadState.loadFailedWithPartial || loadingMoreSongs || completingFullPlaylist;

  String get _completionMessage {
    if (loadState == _PlaylistPageLoadState.loadFailedWithPartial) {
      return '剩余歌曲加载失败，下拉可重试';
    }
    return completingFullPlaylist ? '正在补全播放队列...' : '正在加载剩余歌曲...';
  }

  void _handleScrollNearBottom() {
    if (!_scrollController.hasClients || _scrollController.position.extentAfter > 800) {
      return;
    }
    unawaited(_loadMorePlaylistSongs());
  }

  Future<void> _loadMorePlaylistSongs() async {
    if (!mounted || loadingMoreSongs || completingFullPlaylist || loadState != _PlaylistPageLoadState.showingPartial) {
      return;
    }
    loadingMoreSongs = true;
    if (mounted) {
      setState(() {});
    }
    try {
      final data = await _controller.fetchDetail(
        widget.playlistId,
        offset: loadedSongCount,
        limit: _playlistPageSize,
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
      loadingMoreSongs = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<bool> _ensureFullPlaylistLoaded() async {
    if (loadState == _PlaylistPageLoadState.showingFull) {
      return songs.isNotEmpty;
    }
    if (completingFullPlaylist) {
      return false;
    }
    completingFullPlaylist = true;
    if (mounted) {
      setState(() {});
    }
    try {
      final data = await _controller.fetchDetail(
        widget.playlistId,
        offset: loadedSongCount,
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
      completingFullPlaylist = false;
      if (mounted) {
        setState(() {});
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
