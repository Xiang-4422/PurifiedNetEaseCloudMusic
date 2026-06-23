/// 歌单页当前加载状态。
enum PlaylistPageLoadState {
  /// 初始加载中，且还没有可展示元信息。
  loadingInitial,

  /// 仅展示路由或本地缓存中的歌单元信息。
  showingMetadataOnly,

  /// 已展示部分歌曲，剩余歌曲可能继续加载。
  showingPartial,

  /// 已展示完整歌曲列表。
  showingFull,

  /// 已有部分歌曲，但剩余歌曲加载失败。
  loadFailedWithPartial,

  /// 没有可展示歌曲，首屏或刷新加载失败。
  loadFailedEmpty,
}

/// 歌单页当前网络请求类型。
enum PlaylistFetchKind {
  /// 没有进行中的歌单请求。
  none,

  /// 正在加载首批歌曲。
  loadingFirstPage,

  /// 正在补全剩余歌曲。
  loadingRemaining,

  /// 正在刷新完整歌单。
  refreshingFull,
}

/// 歌单页展示层所需的派生状态。
class PlaylistPagePresentation {
  /// 创建歌单页派生展示状态。
  const PlaylistPagePresentation({
    required this.loadState,
    required this.fetchKind,
    required this.hasPlaylistMetadata,
    required this.songCount,
  });

  /// 当前加载状态。
  final PlaylistPageLoadState loadState;

  /// 当前请求类型。
  final PlaylistFetchKind fetchKind;

  /// 是否已有可展示的歌单元信息。
  final bool hasPlaylistMetadata;

  /// 当前已加载歌曲数量。
  final int songCount;

  /// 是否展示全页初始加载态。
  bool get showInitialLoading => loadState == PlaylistPageLoadState.loadingInitial && !hasPlaylistMetadata;

  /// 是否展示全页空错误态。
  bool get showEmptyError => loadState == PlaylistPageLoadState.loadFailedEmpty && !hasPlaylistMetadata;

  /// 当前歌曲列表是否可以立即播放。
  bool get canPlayLoadedPlaylist => songCount > 0 && loadState != PlaylistPageLoadState.loadingInitial && loadState != PlaylistPageLoadState.loadFailedEmpty && fetchKind == PlaylistFetchKind.none;

  /// 是否展示歌曲列表骨架屏。
  bool get isShowingPlaylistSkeleton => songCount == 0 && fetchKind == PlaylistFetchKind.loadingFirstPage && hasPlaylistMetadata;

  /// 是否展示底部状态信息。
  bool get isShowingStatusFooter => loadState == PlaylistPageLoadState.loadFailedWithPartial || (loadState == PlaylistPageLoadState.loadFailedEmpty && hasPlaylistMetadata) || fetchKind == PlaylistFetchKind.loadingRemaining;

  /// 底部状态文案。
  String get completionMessage {
    if (loadState == PlaylistPageLoadState.loadFailedEmpty && hasPlaylistMetadata) {
      return '歌曲加载失败，下拉可重试';
    }
    if (loadState == PlaylistPageLoadState.loadFailedWithPartial) {
      return '剩余歌曲加载失败，下拉可重试';
    }
    return '正在加载剩余歌曲...';
  }

  /// 由歌单基础字段判断是否已有可展示元信息。
  static bool hasMetadata({
    required String playlistName,
    required String? coverUrl,
    required int? trackCount,
  }) {
    return playlistName.trim().isNotEmpty || coverUrl?.isNotEmpty == true || trackCount != null;
  }
}
