import 'dart:async';
import 'dart:math';

import 'package:bujuan/core/diagnostics/performance_metric.dart';
import 'package:bujuan/ui/services/toast_service.dart';
import 'package:bujuan/ui/services/image_color_service.dart';
import 'package:bujuan/ui/layout/adaptive_layout_metrics.dart';
import 'package:bujuan/ui/theme/app_constants.dart';
import 'package:bujuan/core/util/extensions.dart';
import 'package:bujuan/features/playlist/playlist_performance_logger.dart';
import 'package:bujuan/core/entities/playback_order_mode.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_page_controller.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/playlist/playlist_artwork_color_service.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/ui/pages/playlist/widgets/playlist_header_sliver.dart';
import 'package:bujuan/ui/pages/playlist/widgets/playlist_status_slivers.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:flutter/material.dart';

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
  final PlaylistPageController _controller = PlaylistPageController(
    repository: Get.find<PlaylistRepository>(),
    likedSongIds: () => Get.find<UserLibraryController>().likedSongIds.toList(),
    currentUserId: () => Get.find<UserSessionController>().userInfo.value.userId,
  );
  final PlayerController _playerController = Get.find<PlayerController>();
  final Random _random = Random();

  String playlistName = '';
  String? coverUrl;
  int? trackCount;
  List<PlaybackQueueItem> songs = <PlaybackQueueItem>[];

  bool isSubscribed = false;
  bool isMyPlayList = false;
  _PlaylistFetchKind _fetchKind = _PlaylistFetchKind.none;
  int _artworkColorRequestId = 0;
  bool _animateArtworkColor = true;

  _PlaylistPageLoadState loadState = _PlaylistPageLoadState.loadingInitial;
  final PlaylistArtworkColorService _artworkColorService = PlaylistArtworkColorService();

  Color albumColor = Colors.black;
  Color widgetColor = Colors.white;

  @override
  void initState() {
    super.initState();
    playlistName = widget.playlistName;
    coverUrl = widget.coverUrl;
    trackCount = widget.trackCount;
    _applyCachedArtworkColor(_resolvedCoverUrl, notify: false);
    PlaylistPerformanceLogger.log(
      'page.init playlistId=${widget.playlistId} routeName=${widget.playlistName.isNotEmpty} routeCover=${widget.coverUrl?.isNotEmpty == true} routeTrackCount=${widget.trackCount}',
    );
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
      duration: _animateArtworkColor ? const Duration(milliseconds: 300) : Duration.zero,
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
          PlaylistHeaderSliver(
            playlistName: playlistName,
            coverUrl: _resolvedCoverUrl,
            trackCount: trackCount,
            loadedTrackCount: songs.length,
            heroExtent: layoutMetrics.heroExtent,
            albumColor: albumColor,
            widgetColor: widgetColor,
            isSubscribed: isSubscribed,
            isMyPlaylist: isMyPlayList,
            canPlayLoadedPlaylist: _canPlayLoadedPlaylist,
            onPlaySequential: () => _playLoadedPlaylist(shuffle: false),
            onPlayShuffle: () => _playLoadedPlaylist(shuffle: true),
            onToggleSubscribe: _subscribePlayList,
          ),
          if (_isShowingPlaylistSkeleton)
            PlaylistSkeletonSliver(foregroundColor: widgetColor)
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingSmall),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    final song = songs[index];
                    return SongItem(
                      item: song,
                      index: index,
                      playListName: playlistName,
                      playListHeader: "歌单",
                      stringColor: widgetColor,
                      beforeOnTap: () {
                        ShellController.to.jumpBottomPanelToPage(0);
                        ShellController.to.openBottomPanel();
                      },
                      onTap: () => _playerController.playPlaylist(
                        songs,
                        index,
                        playListName: playlistName,
                        playListNameHeader: "歌单",
                      ),
                    );
                  },
                  childCount: songs.length,
                ),
              ),
            ),
          if (_isShowingStatusFooter)
            PlaylistStatusFooterSliver(
              message: _completionMessage,
              foregroundColor: widgetColor,
            ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: AppDimensions.bottomPanelHeaderHeight,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPlaylistData() async {
    final stopwatch = PlaylistPerformanceLogger.start();
    PlaylistPerformanceLogger.log('page.loadInitial.start playlistId=${widget.playlistId}');
    final localStopwatch = PlaylistPerformanceLogger.start();
    final initialDetail = await _controller.loadInitialDetail(widget.playlistId);
    PlaylistPerformanceLogger.elapsed(
      'page.loadInitial.localRead',
      localStopwatch,
      details: 'state=${initialDetail.localState.name} songs=${initialDetail.localDetail?.songs.length ?? 0} expected=${initialDetail.localDetail?.expectedTrackCount} hasPlaylist=${initialDetail.localPlaylist != null}',
    );
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
        PlaylistPerformanceLogger.log(
          'page.loadInitial.partialAutoComplete offset=${initialDetail.localDetail!.songs.length} expected=${initialDetail.localDetail!.expectedTrackCount}',
        );
        unawaited(_loadRemainingPlaylistSongs(offset: initialDetail.localDetail!.songs.length));
      }
      PlaylistPerformanceLogger.elapsedMetric(
        AppPerformanceMetrics.cachedPlaylistOpen,
        stopwatch,
        details: 'source=local state=${initialDetail.localState.name} songs=${songs.length}',
      );
      return;
    }
    await _loadFirstPageAndRemaining(showLoadingState: true);
    PlaylistPerformanceLogger.elapsedMetric(
      AppPerformanceMetrics.cachedPlaylistOpen,
      stopwatch,
      details: 'source=remote songs=${songs.length} state=${loadState.name}',
    );
  }

  Future<void> _loadFirstPageAndRemaining({required bool showLoadingState}) async {
    if (_fetchKind != _PlaylistFetchKind.none) {
      PlaylistPerformanceLogger.log('page.firstPage.skip fetchKind=${_fetchKind.name}');
      return;
    }
    final stopwatch = PlaylistPerformanceLogger.start();
    PlaylistPerformanceLogger.log('page.firstPage.start playlistId=${widget.playlistId} showLoading=$showLoadingState');
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
      final firstPageStopwatch = PlaylistPerformanceLogger.start();
      final data = await _controller.fetchFirstPage(widget.playlistId);
      PlaylistPerformanceLogger.elapsed(
        'page.firstPage.fetch',
        firstPageStopwatch,
        details: 'songs=${data.songs.length} expected=${data.expectedTrackCount} complete=${data.isComplete}',
      );
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
      PlaylistPerformanceLogger.elapsed(
        'page.firstPage.total',
        stopwatch,
        details: 'songs=${songs.length} state=${loadState.name}',
      );
    }
  }

  Future<void> _refreshFullPlaylist() async {
    if (_fetchKind != _PlaylistFetchKind.none) {
      PlaylistPerformanceLogger.log('page.refreshFull.skip fetchKind=${_fetchKind.name}');
      ToastService.show('歌单正在加载中');
      return;
    }
    final stopwatch = PlaylistPerformanceLogger.start();
    PlaylistPerformanceLogger.log('page.refreshFull.start playlistId=${widget.playlistId}');
    setState(() {
      _fetchKind = _PlaylistFetchKind.refreshingFull;
    });
    try {
      final fetchStopwatch = PlaylistPerformanceLogger.start();
      final data = await _controller.refreshFull(widget.playlistId);
      PlaylistPerformanceLogger.elapsed(
        'page.refreshFull.fetch',
        fetchStopwatch,
        details: 'songs=${data.songs.length} expected=${data.expectedTrackCount} complete=${data.isComplete}',
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
      PlaylistPerformanceLogger.elapsed(
        'page.refreshFull.total',
        stopwatch,
        details: 'songs=${songs.length} state=${loadState.name}',
      );
    }
  }

  void _applyLocalPlaylist(PlaylistEntity playlist) {
    if (!mounted) {
      return;
    }
    final previousCoverUrl = coverUrl;
    setState(() {
      playlistName = playlist.title;
      coverUrl = playlist.coverUrl ?? coverUrl;
      trackCount = playlist.trackCount ?? trackCount;
      if (songs.isEmpty && loadState == _PlaylistPageLoadState.loadingInitial && _hasPlaylistMetadata) {
        loadState = _PlaylistPageLoadState.showingMetadataOnly;
      }
    });
    if (coverUrl != previousCoverUrl) {
      unawaited(_updateArtworkColors(_resolvedCoverUrl));
    }
  }

  Future<void> _applyPlaylistDetail(
    PlaylistDetailData data, {
    required _PlaylistPageLoadState nextState,
  }) async {
    if (!mounted) {
      return;
    }
    final stopwatch = PlaylistPerformanceLogger.start();
    setState(() {
      songs = data.songs;
      playlistName = data.playlistName ?? playlistName;
      coverUrl = data.coverUrl ?? coverUrl;
      trackCount = data.expectedTrackCount ?? trackCount;
      isSubscribed = data.isSubscribed;
      isMyPlayList = data.isMyPlayList;
      loadState = nextState;
    });
    PlaylistPerformanceLogger.elapsed(
      'page.applyDetail.setState',
      stopwatch,
      details: 'songs=${data.songs.length} expected=${data.expectedTrackCount} source=${data.source.name} nextState=${nextState.name}',
    );
    unawaited(_updateArtworkColors(_resolvedCoverUrl));
  }

  Future<void> _updateArtworkColors(String? artworkPath) async {
    final requestId = ++_artworkColorRequestId;
    final stopwatch = PlaylistPerformanceLogger.start();
    if (_applyCachedArtworkColor(artworkPath)) {
      PlaylistPerformanceLogger.elapsed(
        'page.artworkColor.cacheHit',
        stopwatch,
        details: 'hasArtwork=${artworkPath?.isNotEmpty == true}',
      );
      return;
    }
    final colorPath = await _artworkColorService.resolveColorPath(artworkPath);
    if (!mounted || requestId != _artworkColorRequestId) {
      return;
    }
    final cachedColor = ImageColorService.peekCachedColor(colorPath);
    if (cachedColor != null) {
      _applyArtworkColor(cachedColor, animate: false);
      PlaylistPerformanceLogger.elapsed(
        'page.artworkColor.cacheHit',
        stopwatch,
        details: 'hasArtwork=${artworkPath?.isNotEmpty == true} hasColorPath=${colorPath?.isNotEmpty == true}',
      );
      return;
    }
    final color = await ImageColorService.dominantColor(colorPath);
    if (!mounted || requestId != _artworkColorRequestId) {
      return;
    }
    _applyArtworkColor(color, animate: true);
    PlaylistPerformanceLogger.elapsed(
      'page.artworkColor.update',
      stopwatch,
      details: 'hasArtwork=${artworkPath?.isNotEmpty == true} hasColorPath=${colorPath?.isNotEmpty == true}',
    );
  }

  bool _applyCachedArtworkColor(String? artworkPath, {bool notify = true}) {
    final colorPath = _artworkColorService.peekColorPath(artworkPath);
    final cachedColor = ImageColorService.peekCachedColor(colorPath);
    if (cachedColor == null) {
      return false;
    }
    _applyArtworkColor(
      cachedColor,
      animate: false,
      notify: notify,
    );
    return true;
  }

  void _applyArtworkColor(
    Color color, {
    required bool animate,
    bool notify = true,
  }) {
    void updateColor() {
      albumColor = color;
      widgetColor = color.invertedColor;
      _animateArtworkColor = animate;
    }

    if (!notify) {
      updateColor();
      return;
    }
    setState(updateColor);
  }

  String? get _resolvedCoverUrl => ArtworkPathResolver.resolveExplicitArtwork(
        coverUrl,
        fallbackItems: songs,
      );

  bool get _canPlayLoadedPlaylist => songs.isNotEmpty && loadState != _PlaylistPageLoadState.loadingInitial && loadState != _PlaylistPageLoadState.loadFailedEmpty && _fetchKind == _PlaylistFetchKind.none;

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
    final stopwatch = PlaylistPerformanceLogger.start();
    PlaylistPerformanceLogger.log('page.remaining.start playlistId=${widget.playlistId} offset=$offset currentSongs=${songs.length}');
    setState(() {
      _fetchKind = _PlaylistFetchKind.loadingRemaining;
    });
    try {
      final fetchStopwatch = PlaylistPerformanceLogger.start();
      final data = await _controller.fetchRemaining(
        widget.playlistId,
        offset: offset,
      );
      PlaylistPerformanceLogger.elapsed(
        'page.remaining.fetch',
        fetchStopwatch,
        details: 'offset=$offset songs=${data.songs.length} expected=${data.expectedTrackCount} complete=${data.isComplete}',
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
      PlaylistPerformanceLogger.elapsed(
        'page.remaining.total',
        stopwatch,
        details: 'offset=$offset songs=${songs.length} state=${loadState.name}',
      );
    }
  }

  Future<void> _playLoadedPlaylist({required bool shuffle}) async {
    if (!_canPlayLoadedPlaylist) {
      return;
    }
    ShellController.to.jumpBottomPanelToPage(0);
    ShellController.to.openBottomPanel();
    if (shuffle) {
      await _playerController.setOrderMode(PlaybackOrderMode.shuffle);
      await _playerController.setRepeatMode(PlaybackRepeatMode.all);
      await _playerController.playPlaylist(
        songs,
        _random.nextInt(songs.length),
        playListName: playlistName,
        playListNameHeader: "歌单",
      );
      return;
    }
    await _playerController.setOrderMode(PlaybackOrderMode.sequential);
    await _playerController.setRepeatMode(PlaybackRepeatMode.all);
    await _playerController.playPlaylist(
      songs,
      0,
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
