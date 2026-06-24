import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/features/playlist/playlist_detail_data.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';

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

/// 歌单页可变数据状态。
class PlaylistPageStateModel {
  /// 创建歌单页可变数据状态。
  const PlaylistPageStateModel({
    required this.playlistName,
    required this.coverUrl,
    required this.trackCount,
    required this.songs,
    required this.isSubscribed,
    required this.isMyPlaylist,
    required this.loadState,
    required this.fetchKind,
  });

  /// 根据路由参数创建初始状态。
  factory PlaylistPageStateModel.initial({
    required String playlistName,
    required String? coverUrl,
    required int? trackCount,
  }) {
    final model = PlaylistPageStateModel(
      playlistName: playlistName,
      coverUrl: coverUrl,
      trackCount: trackCount,
      songs: const <PlaybackQueueItem>[],
      isSubscribed: false,
      isMyPlaylist: false,
      loadState: PlaylistPageLoadState.loadingInitial,
      fetchKind: PlaylistFetchKind.none,
    );
    return model.copyWith(
      loadState: model.hasPlaylistMetadata ? PlaylistPageLoadState.showingMetadataOnly : PlaylistPageLoadState.loadingInitial,
    );
  }

  /// 歌单标题。
  final String playlistName;

  /// 歌单封面。
  final String? coverUrl;

  /// 歌曲总数。
  final int? trackCount;

  /// 已加载歌曲。
  final List<PlaybackQueueItem> songs;

  /// 当前账号是否已收藏。
  final bool isSubscribed;

  /// 是否为当前账号自己的歌单。
  final bool isMyPlaylist;

  /// 当前加载状态。
  final PlaylistPageLoadState loadState;

  /// 当前请求类型。
  final PlaylistFetchKind fetchKind;

  /// 是否已有可展示的歌单元信息。
  bool get hasPlaylistMetadata => PlaylistPagePresentation.hasMetadata(
        playlistName: playlistName,
        coverUrl: coverUrl,
        trackCount: trackCount,
      );

  /// 已解析的歌单封面。
  String? get resolvedCoverUrl => ArtworkPathResolver.resolveExplicitArtwork(
        coverUrl,
        fallbackItems: songs,
      );

  /// 展示层派生状态。
  PlaylistPagePresentation get presentation => PlaylistPagePresentation(
        loadState: loadState,
        fetchKind: fetchKind,
        hasPlaylistMetadata: hasPlaylistMetadata,
        songCount: songs.length,
      );

  /// 复制并替换部分字段。
  PlaylistPageStateModel copyWith({
    String? playlistName,
    String? coverUrl,
    int? trackCount,
    List<PlaybackQueueItem>? songs,
    bool? isSubscribed,
    bool? isMyPlaylist,
    PlaylistPageLoadState? loadState,
    PlaylistFetchKind? fetchKind,
  }) {
    return PlaylistPageStateModel(
      playlistName: playlistName ?? this.playlistName,
      coverUrl: coverUrl ?? this.coverUrl,
      trackCount: trackCount ?? this.trackCount,
      songs: songs ?? this.songs,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      isMyPlaylist: isMyPlaylist ?? this.isMyPlaylist,
      loadState: loadState ?? this.loadState,
      fetchKind: fetchKind ?? this.fetchKind,
    );
  }

  /// 应用本地歌单元信息。
  PlaylistPageStateModel applyLocalPlaylist(PlaylistEntity playlist) {
    final next = copyWith(
      playlistName: playlist.title,
      coverUrl: playlist.coverUrl ?? coverUrl,
      trackCount: playlist.trackCount ?? trackCount,
    );
    if (next.songs.isEmpty && next.loadState == PlaylistPageLoadState.loadingInitial && next.hasPlaylistMetadata) {
      return next.copyWith(loadState: PlaylistPageLoadState.showingMetadataOnly);
    }
    return next;
  }

  /// 应用歌单详情。
  PlaylistPageStateModel applyDetail(
    PlaylistDetailData data, {
    required PlaylistPageLoadState nextState,
  }) {
    return copyWith(
      songs: data.songs,
      playlistName: data.playlistName ?? playlistName,
      coverUrl: data.coverUrl ?? coverUrl,
      trackCount: data.expectedTrackCount ?? trackCount,
      isSubscribed: data.isSubscribed,
      isMyPlaylist: data.isMyPlayList,
      loadState: nextState,
    );
  }

  /// 进入首屏歌曲加载状态。
  PlaylistPageStateModel beginFirstPageLoad({required bool showLoadingState}) {
    var nextLoadState = loadState;
    if (showLoadingState && songs.isEmpty && !hasPlaylistMetadata) {
      nextLoadState = PlaylistPageLoadState.loadingInitial;
    } else if (songs.isEmpty && hasPlaylistMetadata) {
      nextLoadState = PlaylistPageLoadState.showingMetadataOnly;
    }
    return copyWith(
      fetchKind: PlaylistFetchKind.loadingFirstPage,
      loadState: nextLoadState,
    );
  }

  /// 进入剩余歌曲加载状态。
  PlaylistPageStateModel beginRemainingLoad() {
    return copyWith(fetchKind: PlaylistFetchKind.loadingRemaining);
  }

  /// 进入完整刷新状态。
  PlaylistPageStateModel beginFullRefresh() {
    return copyWith(fetchKind: PlaylistFetchKind.refreshingFull);
  }

  /// 结束当前请求。
  PlaylistPageStateModel endFetch() {
    return copyWith(fetchKind: PlaylistFetchKind.none);
  }

  /// 应用首屏或完整刷新失败。
  PlaylistPageStateModel failPrimaryLoad() {
    if (songs.isNotEmpty) {
      return this;
    }
    return copyWith(loadState: PlaylistPageLoadState.loadFailedEmpty);
  }

  /// 应用剩余歌曲加载失败。
  PlaylistPageStateModel failRemainingLoad() {
    return copyWith(
      loadState: songs.isEmpty ? PlaylistPageLoadState.loadFailedEmpty : PlaylistPageLoadState.loadFailedWithPartial,
    );
  }

  /// 切换收藏状态。
  PlaylistPageStateModel toggleSubscription() {
    return copyWith(isSubscribed: !isSubscribed);
  }
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
