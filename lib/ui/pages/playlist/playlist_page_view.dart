import 'dart:async';
import 'dart:math';

import 'package:bujuan/core/diagnostics/performance_metric.dart';
import 'package:bujuan/ui/services/toast_service.dart';
import 'package:bujuan/ui/services/image_color_service.dart';
import 'package:bujuan/core/util/extensions.dart';
import 'package:bujuan/features/playlist/playlist_performance_logger.dart';
import 'package:bujuan/core/entities/playback_order_mode.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/playlist/playlist_detail_data.dart';
import 'package:bujuan/features/playlist/playlist_page_controller.dart';
import 'package:bujuan/features/playlist/playlist_page_controller_factory.dart';
import 'package:bujuan/features/playlist/playlist_artwork_color_service.dart';
import 'package:bujuan/features/shell/shell_controller.dart';
import 'package:bujuan/ui/pages/playlist/playlist_page_state.dart';
import 'package:bujuan/ui/pages/playlist/widgets/playlist_content_scroll_view.dart';
import 'package:bujuan/ui/widgets/common/feedback/status_views.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

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
  late final PlaylistPageController _controller;
  final PlayerController _playerController = Get.find<PlayerController>();
  final ShellController _shellController = Get.find<ShellController>();
  final Random _random = Random();
  late final PlaylistArtworkColorService _artworkColorService;

  late PlaylistPageStateModel _playlistState;
  int _artworkColorRequestId = 0;
  bool _animateArtworkColor = true;

  Color albumColor = Colors.black;
  Color widgetColor = Colors.white;

  @override
  void initState() {
    super.initState();
    final controllerFactory = Get.find<PlaylistPageControllerFactory>();
    _controller = controllerFactory.create();
    _artworkColorService = controllerFactory.createArtworkColorService();
    _playlistState = PlaylistPageStateModel.initial(
      playlistName: widget.playlistName,
      coverUrl: widget.coverUrl,
      trackCount: widget.trackCount,
    );
    _applyCachedArtworkColor(_playlistState.resolvedCoverUrl, notify: false);
    PlaylistPerformanceLogger.log(
      'page.init playlistId=${widget.playlistId} routeName=${widget.playlistName.isNotEmpty} routeCover=${widget.coverUrl?.isNotEmpty == true} routeTrackCount=${widget.trackCount}',
    );
    unawaited(_updateArtworkColors(_playlistState.resolvedCoverUrl));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadPlaylistData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final presentation = _playlistState.presentation;
    return AnimatedContainer(
      duration: _animateArtworkColor ? const Duration(milliseconds: 300) : Duration.zero,
      color: albumColor,
      child: presentation.showInitialLoading
          ? const LoadingView()
          : presentation.showEmptyError
              ? ErrorView(
                  onRetry: () => unawaited(
                    _loadFirstPageAndRemaining(showLoadingState: true),
                  ),
                )
              : PlaylistContentScrollView(
                  playlistName: _playlistState.playlistName,
                  coverUrl: _playlistState.resolvedCoverUrl,
                  trackCount: _playlistState.trackCount,
                  loadedTrackCount: _playlistState.songs.length,
                  songs: _playlistState.songs,
                  albumColor: albumColor,
                  foregroundColor: widgetColor,
                  isSubscribed: _playlistState.isSubscribed,
                  isMyPlaylist: _playlistState.isMyPlaylist,
                  canPlayLoadedPlaylist: presentation.canPlayLoadedPlaylist,
                  isShowingPlaylistSkeleton: presentation.isShowingPlaylistSkeleton,
                  isShowingStatusFooter: presentation.isShowingStatusFooter,
                  completionMessage: presentation.completionMessage,
                  onRefresh: _refreshFullPlaylist,
                  onPlaySequential: () => _playLoadedPlaylist(shuffle: false),
                  onPlayShuffle: () => _playLoadedPlaylist(shuffle: true),
                  onToggleSubscribe: _subscribePlayList,
                  onTapSong: _playSongAt,
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
        nextState: initialDetail.localState == PlaylistLocalDetailState.complete ? PlaylistPageLoadState.showingFull : PlaylistPageLoadState.showingPartial,
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
        details: cachedPlaylistOpenLocalMetricDetails(
          state: initialDetail.localState,
          songs: _playlistState.songs.length,
        ),
      );
      return;
    }
    await _loadFirstPageAndRemaining(showLoadingState: true);
    PlaylistPerformanceLogger.elapsedMetric(
      AppPerformanceMetrics.cachedPlaylistOpen,
      stopwatch,
      details: cachedPlaylistOpenRemoteMetricDetails(
        songs: _playlistState.songs.length,
        state: _playlistState.loadState,
      ),
    );
  }

  Future<void> _loadFirstPageAndRemaining({required bool showLoadingState}) async {
    if (_playlistState.fetchKind != PlaylistFetchKind.none) {
      PlaylistPerformanceLogger.log('page.firstPage.skip fetchKind=${_playlistState.fetchKind.name}');
      return;
    }
    final stopwatch = PlaylistPerformanceLogger.start();
    PlaylistPerformanceLogger.log('page.firstPage.start playlistId=${widget.playlistId} showLoading=$showLoadingState');
    if (mounted) {
      setState(() {
        _playlistState = _playlistState.beginFirstPageLoad(
          showLoadingState: showLoadingState,
        );
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
        nextState: data.isComplete ? PlaylistPageLoadState.showingFull : PlaylistPageLoadState.showingPartial,
      );
      if (!data.isComplete) {
        await _loadRemainingPlaylistSongs(offset: data.songs.length);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (_playlistState.songs.isNotEmpty) {
        ToastService.show('歌单刷新失败');
        return;
      }
      setState(() {
        _playlistState = _playlistState.failPrimaryLoad();
      });
    } finally {
      if (mounted) {
        setState(() {
          _playlistState = _playlistState.endFetch();
        });
      }
      PlaylistPerformanceLogger.elapsed(
        'page.firstPage.total',
        stopwatch,
        details: 'songs=${_playlistState.songs.length} state=${_playlistState.loadState.name}',
      );
    }
  }

  Future<void> _refreshFullPlaylist() async {
    if (_playlistState.fetchKind != PlaylistFetchKind.none) {
      PlaylistPerformanceLogger.log('page.refreshFull.skip fetchKind=${_playlistState.fetchKind.name}');
      ToastService.show('歌单正在加载中');
      return;
    }
    final stopwatch = PlaylistPerformanceLogger.start();
    PlaylistPerformanceLogger.log('page.refreshFull.start playlistId=${widget.playlistId}');
    setState(() {
      _playlistState = _playlistState.beginFullRefresh();
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
        nextState: data.isComplete ? PlaylistPageLoadState.showingFull : PlaylistPageLoadState.showingPartial,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      if (_playlistState.songs.isNotEmpty) {
        ToastService.show('歌单刷新失败');
        return;
      }
      setState(() {
        _playlistState = _playlistState.failPrimaryLoad();
      });
    } finally {
      if (mounted) {
        setState(() {
          _playlistState = _playlistState.endFetch();
        });
      }
      PlaylistPerformanceLogger.elapsed(
        'page.refreshFull.total',
        stopwatch,
        details: 'songs=${_playlistState.songs.length} state=${_playlistState.loadState.name}',
      );
    }
  }

  void _applyLocalPlaylist(PlaylistEntity playlist) {
    if (!mounted) {
      return;
    }
    final previousCoverUrl = _playlistState.coverUrl;
    setState(() {
      _playlistState = _playlistState.applyLocalPlaylist(playlist);
    });
    if (_playlistState.coverUrl != previousCoverUrl) {
      unawaited(_updateArtworkColors(_playlistState.resolvedCoverUrl));
    }
  }

  Future<void> _applyPlaylistDetail(
    PlaylistDetailData data, {
    required PlaylistPageLoadState nextState,
  }) async {
    if (!mounted) {
      return;
    }
    final stopwatch = PlaylistPerformanceLogger.start();
    setState(() {
      _playlistState = _playlistState.applyDetail(
        data,
        nextState: nextState,
      );
    });
    PlaylistPerformanceLogger.elapsed(
      'page.applyDetail.setState',
      stopwatch,
      details: 'songs=${data.songs.length} expected=${data.expectedTrackCount} source=${data.source.name} nextState=${nextState.name}',
    );
    unawaited(_updateArtworkColors(_playlistState.resolvedCoverUrl));
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

  bool get _canPlayLoadedPlaylist => _playlistState.presentation.canPlayLoadedPlaylist;

  Future<void> _loadRemainingPlaylistSongs({required int offset}) async {
    if (!mounted || offset <= 0) {
      return;
    }
    final stopwatch = PlaylistPerformanceLogger.start();
    PlaylistPerformanceLogger.log('page.remaining.start playlistId=${widget.playlistId} offset=$offset currentSongs=${_playlistState.songs.length}');
    setState(() {
      _playlistState = _playlistState.beginRemainingLoad();
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
        nextState: data.isComplete ? PlaylistPageLoadState.showingFull : PlaylistPageLoadState.showingPartial,
      );
    } catch (_) {
      if (mounted) {
        ToastService.show('剩余歌曲加载失败');
        setState(() {
          _playlistState = _playlistState.failRemainingLoad();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _playlistState = _playlistState.endFetch();
        });
      }
      PlaylistPerformanceLogger.elapsed(
        'page.remaining.total',
        stopwatch,
        details: 'offset=$offset songs=${_playlistState.songs.length} state=${_playlistState.loadState.name}',
      );
    }
  }

  Future<void> _playLoadedPlaylist({required bool shuffle}) async {
    if (!_canPlayLoadedPlaylist) {
      return;
    }
    _openPlaybackPanel();
    if (shuffle) {
      await _playerController.setOrderMode(PlaybackOrderMode.shuffle);
      await _playerController.setRepeatMode(PlaybackRepeatMode.all);
      await _playerController.playPlaylist(
        _playlistState.songs,
        _random.nextInt(_playlistState.songs.length),
        playListName: _playlistState.playlistName,
        playListNameHeader: "歌单",
      );
      return;
    }
    await _playerController.setOrderMode(PlaybackOrderMode.sequential);
    await _playerController.setRepeatMode(PlaybackRepeatMode.all);
    await _playerController.playPlaylist(
      _playlistState.songs,
      0,
      playListName: _playlistState.playlistName,
      playListNameHeader: "歌单",
    );
  }

  Future<void> _playSongAt(int index) async {
    _openPlaybackPanel();
    await _playerController.playPlaylist(
      _playlistState.songs,
      index,
      playListName: _playlistState.playlistName,
      playListNameHeader: '歌单',
    );
  }

  void _openPlaybackPanel() {
    _shellController.jumpBottomPanelToPage(0);
    _shellController.openBottomPanel();
  }

  Future<void> _subscribePlayList() async {
    final value = await _controller.toggleSubscription(
      widget.playlistId,
      subscribe: !_playlistState.isSubscribed,
    );
    if (value.success && mounted) {
      setState(() {
        _playlistState = _playlistState.toggleSubscription();
      });
    }
  }
}

/// 生成本地优先展示的缓存歌单打开指标详情。
@visibleForTesting
String cachedPlaylistOpenLocalMetricDetails({
  required PlaylistLocalDetailState state,
  required int songs,
}) {
  return 'source=local state=${state.name} songs=$songs';
}

/// 生成远程兜底展示的缓存歌单打开指标详情。
@visibleForTesting
String cachedPlaylistOpenRemoteMetricDetails({
  required int songs,
  required PlaylistPageLoadState state,
}) {
  return 'source=remote songs=$songs state=${state.name}';
}
