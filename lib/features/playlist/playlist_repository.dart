import 'package:bujuan/core/state/operation_result.dart';
import 'package:bujuan/features/playback/application/playback_queue_item_mapper.dart';
import 'package:bujuan/features/playlist/playlist_performance_logger.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/app_cache_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/local_library_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/user_scoped_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_playlist_remote_data_source.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/playlist_track_ref.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/music_resource_id.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';

/// 歌单详情数据来源。
enum PlaylistDetailSource {
  /// 本地曲库。
  local,

  /// 远端接口。
  remote,
}

/// 歌单详情数据，包含歌曲队列和当前用户与歌单的关系。
class PlaylistDetailData {
  /// 创建歌单详情数据。
  const PlaylistDetailData({
    required this.songs,
    required this.isSubscribed,
    required this.isMyPlayList,
    required this.source,
    this.expectedTrackCount,
    this.playlistName,
    this.coverUrl,
    this.trackCount,
  });

  /// 歌单内可播放歌曲队列。
  final List<PlaybackQueueItem> songs;

  /// 当前用户是否已收藏歌单。
  final bool isSubscribed;

  /// 歌单是否属于当前用户。
  final bool isMyPlayList;

  /// 歌单声明或推断出的曲目总数。
  final int? expectedTrackCount;

  /// 歌单名称。
  final String? playlistName;

  /// 歌单封面地址。
  final String? coverUrl;

  /// 歌单声明的曲目总数。
  final int? trackCount;

  /// 歌单详情来源。
  final PlaylistDetailSource source;

  /// 当前歌曲列表是否已覆盖预期曲目数量。
  bool get isComplete => expectedTrackCount == null || songs.length >= expectedTrackCount!;

  /// 从本地曲目顺序和兜底数量推断预期曲目数。
  static int? resolveExpectedTrackCount(
    int orderedTrackCount,
    int? fallbackTrackCount,
  ) {
    if (orderedTrackCount > 0) {
      return orderedTrackCount;
    }
    return fallbackTrackCount != null && fallbackTrackCount > 0 ? fallbackTrackCount : null;
  }
}

/// 页面初始化所需的本地歌单元信息和详情。
class PlaylistLocalInitialData {
  /// 创建本地初始化数据。
  const PlaylistLocalInitialData({
    required this.localDetail,
    required this.localPlaylist,
  });

  /// 本地可展示的歌单详情。
  final PlaylistDetailData? localDetail;

  /// 本地保存的歌单元信息。
  final PlaylistEntity? localPlaylist;
}

/// 一次远程歌单索引读取的内存结果，不再作为本地持久化快照。
class PlaylistIndexData {
  /// 创建歌单索引数据。
  const PlaylistIndexData({
    required this.id,
    required this.name,
    required this.trackIds,
    required this.isSubscribed,
    required this.isLikedSongs,
    this.creatorUserId,
    this.coverUrl,
    this.trackCount,
  });

  /// 应用内部歌单 id。
  final String id;

  /// 歌单名称。
  final String name;

  /// 歌单曲目 id，保持歌单顺序并使用应用内部 id。
  final List<String> trackIds;

  /// 当前用户是否已收藏歌单。
  final bool isSubscribed;

  /// 是否为网易云“我喜欢的音乐”特殊歌单。
  final bool isLikedSongs;

  /// 歌单创建者用户 id。
  final String? creatorUserId;

  /// 歌单封面地址。
  final String? coverUrl;

  /// 歌单声明的曲目总数。
  final int? trackCount;

  /// 预期曲目数量。
  int? get expectedTrackCount => PlaylistDetailData.resolveExpectedTrackCount(
        trackIds.length,
        trackCount,
      );
}

/// 聚合歌单远程数据、曲库和用户订阅状态的仓库。
class PlaylistRepository {
  /// 创建歌单仓库。
  PlaylistRepository({
    required AppCacheDataSource appCacheDataSource,
    required MusicDataRepository musicDataRepository,
    required LocalLibraryDataSource localLibraryDataSource,
    required NeteasePlaylistRemoteDataSource remoteDataSource,
    required PlaylistSubscriptionDataSource playlistSubscriptionDataSource,
  })  : _appCacheDataSource = appCacheDataSource,
        _musicDataRepository = musicDataRepository,
        _localLibraryDataSource = localLibraryDataSource,
        _remoteDataSource = remoteDataSource,
        _playlistSubscriptionDataSource = playlistSubscriptionDataSource;

  final AppCacheDataSource _appCacheDataSource;
  final MusicDataRepository _musicDataRepository;
  final LocalLibraryDataSource _localLibraryDataSource;
  final NeteasePlaylistRemoteDataSource _remoteDataSource;
  final PlaylistSubscriptionDataSource _playlistSubscriptionDataSource;

  /// 拉取歌单索引，并同步歌单基础信息、曲目顺序和订阅状态到本地数据库。
  Future<PlaylistIndexData> fetchPlaylistIndex(
    String playlistId, {
    String? currentUserId,
    List<int> likedSongIds = const [],
  }) {
    return _fetchPlaylistIndexData(
      playlistId,
      currentUserId: currentUserId,
      likedSongIds: likedSongIds,
      persist: true,
    );
  }

  Future<PlaylistIndexData> _fetchPlaylistIndexData(
    String playlistId, {
    String? currentUserId,
    List<int> likedSongIds = const [],
    required bool persist,
  }) async {
    final stopwatch = PlaylistPerformanceLogger.start();
    final sourcePlaylistId = MusicResourceId.toNeteaseSourceId(playlistId);
    final entityPlaylistId = MusicResourceId.toNeteaseEntityId(playlistId);
    final remoteStopwatch = PlaylistPerformanceLogger.start();
    final remoteIndex = await _remoteDataSource.fetchPlaylistIndex(sourcePlaylistId);
    PlaylistPerformanceLogger.elapsed(
      'repo.fetchIndex.remote',
      remoteStopwatch,
      details: 'playlistId=$playlistId trackIds=${remoteIndex.trackIds.length} refs=${remoteIndex.playlist?.trackRefs.length ?? 0}',
    );
    final trackIds = _resolveIndexTrackIds(
      remoteTrackRefs: remoteIndex.playlist?.trackRefs ?? const <PlaylistTrackRef>[],
      remoteTrackIds: remoteIndex.trackIds,
      isLikedSongs: remoteIndex.isLikedSongs,
      likedSongIds: likedSongIds,
    );
    if (persist) {
      final playlist = _playlistEntityFromIndex(
        entityPlaylistId: entityPlaylistId,
        sourcePlaylistId: sourcePlaylistId,
        name: remoteIndex.name,
        coverUrl: remoteIndex.playlist?.coverUrl,
        trackCount: remoteIndex.playlist?.trackCount ?? trackIds.length,
        basePlaylist: remoteIndex.playlist,
        trackIds: trackIds,
      );
      final saveStopwatch = PlaylistPerformanceLogger.start();
      await _localLibraryDataSource.savePlaylists([playlist]);
      PlaylistPerformanceLogger.elapsed(
        'repo.fetchIndex.savePlaylist',
        saveStopwatch,
        details: 'playlistId=$entityPlaylistId trackIds=${trackIds.length}',
      );
      if (currentUserId?.isNotEmpty == true) {
        final subscriptionStopwatch = PlaylistPerformanceLogger.start();
        await _playlistSubscriptionDataSource.savePlaylistSubscriptionState(
          currentUserId!,
          entityPlaylistId,
          remoteIndex.isSubscribed,
        );
        PlaylistPerformanceLogger.elapsed(
          'repo.fetchIndex.saveSubscription',
          subscriptionStopwatch,
          details: 'playlistId=$entityPlaylistId subscribed=${remoteIndex.isSubscribed}',
        );
      }
    }
    PlaylistPerformanceLogger.elapsed(
      'repo.fetchIndex.total',
      stopwatch,
      details: 'playlistId=$playlistId trackIds=${trackIds.length} persist=$persist',
    );
    return PlaylistIndexData(
      id: entityPlaylistId,
      name: remoteIndex.name,
      trackIds: trackIds,
      isSubscribed: remoteIndex.isSubscribed,
      isLikedSongs: remoteIndex.isLikedSongs,
      creatorUserId: remoteIndex.creatorUserId,
      coverUrl: remoteIndex.playlist?.coverUrl,
      trackCount: remoteIndex.playlist?.trackCount ?? trackIds.length,
    );
  }

  /// 拉取歌单歌曲，并转换为播放队列项。
  Future<List<PlaybackQueueItem>> fetchPlaylistSongs({
    required String playlistId,
    required List<int> likedSongIds,
    int offset = 0,
    int limit = -1,
    PlaylistIndexData? playlistIndex,
    bool persist = true,
  }) async {
    final stopwatch = PlaylistPerformanceLogger.start();
    playlistIndex ??= await fetchPlaylistIndex(
      playlistId,
      likedSongIds: likedSongIds,
    );
    final songIds = playlistIndex.trackIds.map(MusicResourceId.toNeteaseSourceId).where((id) => id.isNotEmpty).toList();
    if (offset >= songIds.length) {
      PlaylistPerformanceLogger.log('repo.fetchSongs.skip playlistId=$playlistId offset=$offset total=${songIds.length}');
      return const [];
    }
    final tracks = await _fetchRemotePlaylistTracks(
      playlistId: playlistId,
      songIds: songIds,
      offset: offset,
      limit: limit,
    );
    if (persist) {
      await _persistTracksAndRefreshMarker(
        playlistId: playlistId,
        tracks: tracks,
      );
    }
    final items = PlaybackQueueItemMapper.fromTrackList(
      tracks,
      likedSongIds: likedSongIds,
    );
    PlaylistPerformanceLogger.elapsed(
      'repo.fetchSongs.total',
      stopwatch,
      details: 'playlistId=$playlistId offset=$offset limit=$limit items=${items.length} persist=$persist',
    );
    return items;
  }

  /// 判断歌单远程刷新标记是否仍在 TTL 内。
  Future<bool> isCacheFresh(
    String playlistId, {
    required Duration ttl,
  }) {
    return _appCacheDataSource.isFresh(
      _refreshCacheKey(playlistId),
      ttl: ttl,
    );
  }

  /// 从本地曲库组合歌单详情。
  Future<PlaylistDetailData?> loadLocalPlaylistDetail({
    required String playlistId,
    required List<int> likedSongIds,
    required String? currentUserId,
  }) async {
    final initialData = await loadLocalInitialDetail(
      playlistId: playlistId,
      likedSongIds: likedSongIds,
      currentUserId: currentUserId,
    );
    return initialData.localDetail;
  }

  /// 从本地数据库组合页面初始化所需的歌单元信息和歌曲详情。
  Future<PlaylistLocalInitialData> loadLocalInitialDetail({
    required String playlistId,
    required List<int> likedSongIds,
    required String? currentUserId,
  }) async {
    final stopwatch = PlaylistPerformanceLogger.start();
    final entityPlaylistId = MusicResourceId.toNeteaseEntityId(playlistId);
    final playlistStopwatch = PlaylistPerformanceLogger.start();
    final localPlaylist = await _localLibraryDataSource.getPlaylist(entityPlaylistId);
    PlaylistPerformanceLogger.elapsed(
      'repo.loadLocal.playlist',
      playlistStopwatch,
      details: 'playlistId=$entityPlaylistId found=${localPlaylist != null} refs=${localPlaylist?.trackRefs.length ?? 0}',
    );
    if (localPlaylist == null) {
      PlaylistPerformanceLogger.elapsed(
        'repo.loadLocal.total',
        stopwatch,
        details: 'playlistId=$entityPlaylistId found=false',
      );
      return const PlaylistLocalInitialData(
        localDetail: null,
        localPlaylist: null,
      );
    }
    final trackIds = _trackIdsFromPlaylist(localPlaylist);
    final songsStopwatch = PlaylistPerformanceLogger.start();
    final songs = await _loadLocalSongs(trackIds, likedSongIds: likedSongIds);
    PlaylistPerformanceLogger.elapsed(
      'repo.loadLocal.songs',
      songsStopwatch,
      details: 'playlistId=$entityPlaylistId trackIds=${trackIds.length} songs=${songs.length}',
    );
    final subscriptionStopwatch = PlaylistPerformanceLogger.start();
    final isSubscribed = await _loadSubscriptionState(
      currentUserId,
      entityPlaylistId,
    );
    PlaylistPerformanceLogger.elapsed(
      'repo.loadLocal.subscription',
      subscriptionStopwatch,
      details: 'playlistId=$entityPlaylistId subscribed=$isSubscribed',
    );
    final detail = PlaylistDetailData(
      songs: songs,
      isSubscribed: isSubscribed,
      isMyPlayList: false,
      expectedTrackCount: PlaylistDetailData.resolveExpectedTrackCount(
        trackIds.length,
        localPlaylist.trackCount,
      ),
      playlistName: localPlaylist.title,
      coverUrl: localPlaylist.coverUrl,
      trackCount: localPlaylist.trackCount,
      source: PlaylistDetailSource.local,
    );
    PlaylistPerformanceLogger.elapsed(
      'repo.loadLocal.total',
      stopwatch,
      details: 'playlistId=$entityPlaylistId trackIds=${trackIds.length} songs=${songs.length} expected=${detail.expectedTrackCount}',
    );
    return PlaylistLocalInitialData(
      localDetail: detail,
      localPlaylist: localPlaylist,
    );
  }

  /// 拉取歌单详情并刷新本地曲库。
  Future<PlaylistDetailData> fetchPlaylistDetail({
    required String playlistId,
    required List<int> likedSongIds,
    required String? currentUserId,
    int offset = 0,
    int limit = -1,
  }) async {
    if (offset == 0 && limit == -1) {
      return refreshFullPlaylistDetail(
        playlistId: playlistId,
        likedSongIds: likedSongIds,
        currentUserId: currentUserId,
      );
    }
    if (offset == 0 && limit > 0) {
      return fetchPlaylistFirstPagePreview(
        playlistId: playlistId,
        likedSongIds: likedSongIds,
        currentUserId: currentUserId,
        limit: limit,
      );
    }
    if (offset > 0 && limit == -1) {
      return refreshFullPlaylistDetail(
        playlistId: playlistId,
        likedSongIds: likedSongIds,
        currentUserId: currentUserId,
      );
    }
    final stopwatch = PlaylistPerformanceLogger.start();
    PlaylistPerformanceLogger.log('repo.fetchDetail.start playlistId=$playlistId offset=$offset limit=$limit');
    final indexStopwatch = PlaylistPerformanceLogger.start();
    final index = offset > 0
        ? await _loadLocalPlaylistIndex(
              playlistId: playlistId,
              currentUserId: currentUserId,
            ) ??
            await fetchPlaylistIndex(
              playlistId,
              currentUserId: currentUserId,
              likedSongIds: likedSongIds,
            )
        : await fetchPlaylistIndex(
            playlistId,
            currentUserId: currentUserId,
            likedSongIds: likedSongIds,
          );
    PlaylistPerformanceLogger.elapsed(
      'repo.fetchDetail.index',
      indexStopwatch,
      details: 'playlistId=$playlistId offset=$offset limit=$limit trackIds=${index.trackIds.length}',
    );
    final songsStopwatch = PlaylistPerformanceLogger.start();
    await fetchPlaylistSongs(
      playlistId: playlistId,
      likedSongIds: likedSongIds,
      playlistIndex: index,
      offset: offset,
      limit: limit,
    );
    PlaylistPerformanceLogger.elapsed(
      'repo.fetchDetail.fetchSongs',
      songsStopwatch,
      details: 'playlistId=$playlistId offset=$offset limit=$limit',
    );
    final buildStopwatch = PlaylistPerformanceLogger.start();
    final detail = await _buildDetailFromIndex(
      index,
      likedSongIds: likedSongIds,
      currentUserId: currentUserId,
      source: PlaylistDetailSource.remote,
    );
    PlaylistPerformanceLogger.elapsed(
      'repo.fetchDetail.buildDetail',
      buildStopwatch,
      details: 'playlistId=$playlistId songs=${detail.songs.length} expected=${detail.expectedTrackCount}',
    );
    PlaylistPerformanceLogger.elapsed(
      'repo.fetchDetail.total',
      stopwatch,
      details: 'playlistId=$playlistId offset=$offset limit=$limit songs=${detail.songs.length}',
    );
    return detail;
  }

  /// 拉取首屏预览数据，不写入正式本地数据库。
  Future<PlaylistDetailData> fetchPlaylistFirstPagePreview({
    required String playlistId,
    required List<int> likedSongIds,
    required String? currentUserId,
    required int limit,
  }) async {
    final stopwatch = PlaylistPerformanceLogger.start();
    PlaylistPerformanceLogger.log('repo.fetchFirstPagePreview.start playlistId=$playlistId limit=$limit');
    final index = await _fetchPlaylistIndexData(
      playlistId,
      currentUserId: currentUserId,
      likedSongIds: likedSongIds,
      persist: false,
    );
    final songIds = index.trackIds.map(MusicResourceId.toNeteaseSourceId).where((id) => id.isNotEmpty).toList();
    final tracks = await _fetchRemotePlaylistTracks(
      playlistId: playlistId,
      songIds: songIds,
      offset: 0,
      limit: limit,
    );
    final detail = _buildDetailFromRemoteTracks(
      index,
      tracks,
      likedSongIds: likedSongIds,
      currentUserId: currentUserId,
      expectedTrackCount: index.expectedTrackCount,
      trackCount: index.trackCount,
    );
    PlaylistPerformanceLogger.elapsed(
      'repo.fetchFirstPagePreview.total',
      stopwatch,
      details: 'playlistId=$playlistId songs=${detail.songs.length} expected=${detail.expectedTrackCount}',
    );
    return detail;
  }

  /// 拉取完整远程歌单，远程完成后再把本次返回的歌曲作为完整本地歌单保存。
  Future<PlaylistDetailData> refreshFullPlaylistDetail({
    required String playlistId,
    required List<int> likedSongIds,
    required String? currentUserId,
  }) async {
    final stopwatch = PlaylistPerformanceLogger.start();
    PlaylistPerformanceLogger.log('repo.refreshFull.start playlistId=$playlistId');
    final index = await _fetchPlaylistIndexData(
      playlistId,
      currentUserId: currentUserId,
      likedSongIds: likedSongIds,
      persist: false,
    );
    final songIds = index.trackIds.map(MusicResourceId.toNeteaseSourceId).where((id) => id.isNotEmpty).toList();
    final tracks = await _fetchRemotePlaylistTracks(
      playlistId: playlistId,
      songIds: songIds,
      offset: 0,
      limit: -1,
    );
    final persistedIndex = await _persistCompletedRemoteDetail(
      playlistId: playlistId,
      index: index,
      tracks: tracks,
      currentUserId: currentUserId,
    );
    final detail = await _buildDetailFromIndex(
      persistedIndex,
      likedSongIds: likedSongIds,
      currentUserId: currentUserId,
      source: PlaylistDetailSource.remote,
    );
    PlaylistPerformanceLogger.elapsed(
      'repo.refreshFull.total',
      stopwatch,
      details: 'playlistId=$playlistId remoteTracks=${tracks.length} savedTracks=${persistedIndex.trackIds.length} detailSongs=${detail.songs.length}',
    );
    return detail;
  }

  /// 切换当前用户对歌单的收藏状态。
  Future<OperationResult> toggleSubscription(
    String playlistId, {
    required bool subscribe,
    String? currentUserId,
  }) async {
    final result = await _remoteDataSource.toggleSubscription(
      playlistId,
      subscribe: subscribe,
    );
    if (result.success && currentUserId?.isNotEmpty == true) {
      await _playlistSubscriptionDataSource.savePlaylistSubscriptionState(
        currentUserId!,
        MusicResourceId.toNeteaseEntityId(playlistId),
        subscribe,
      );
    }
    return OperationResult(
      success: result.success,
      message: result.message,
    );
  }

  /// 添加或移除歌单歌曲，成功后失效本地歌单索引和刷新标记。
  Future<OperationResult> manipulateTracks(
    String playlistId,
    String songId, {
    required bool add,
  }) async {
    final result = await _remoteDataSource.manipulateTracks(
      playlistId,
      songId,
      add: add,
    );
    if (result.success) {
      final entityPlaylistId = MusicResourceId.toNeteaseEntityId(playlistId);
      await _appCacheDataSource.delete(_refreshCacheKey(playlistId));
      await _localLibraryDataSource.clearPlaylistTrackRefs(entityPlaylistId);
    }
    return OperationResult(
      success: result.success,
      message: result.message,
    );
  }

  Future<PlaylistDetailData> _buildDetailFromIndex(
    PlaylistIndexData index, {
    required List<int> likedSongIds,
    required String? currentUserId,
    required PlaylistDetailSource source,
  }) async {
    final stopwatch = PlaylistPerformanceLogger.start();
    final songs = await _loadLocalSongs(index.trackIds, likedSongIds: likedSongIds);
    final detail = PlaylistDetailData(
      songs: songs,
      isSubscribed: index.isSubscribed,
      isMyPlayList: index.creatorUserId != null && index.creatorUserId == currentUserId,
      expectedTrackCount: index.expectedTrackCount,
      playlistName: index.name,
      coverUrl: index.coverUrl,
      trackCount: index.trackCount,
      source: source,
    );
    PlaylistPerformanceLogger.elapsed(
      'repo.buildDetailFromIndex.total',
      stopwatch,
      details: 'playlistId=${index.id} trackIds=${index.trackIds.length} songs=${songs.length} source=${source.name}',
    );
    return detail;
  }

  PlaylistDetailData _buildDetailFromRemoteTracks(
    PlaylistIndexData index,
    List<Track> tracks, {
    required List<int> likedSongIds,
    required String? currentUserId,
    required int? expectedTrackCount,
    required int? trackCount,
  }) {
    return PlaylistDetailData(
      songs: PlaybackQueueItemMapper.fromTrackList(
        tracks,
        likedSongIds: likedSongIds,
      ),
      isSubscribed: index.isSubscribed,
      isMyPlayList: index.creatorUserId != null && index.creatorUserId == currentUserId,
      expectedTrackCount: expectedTrackCount,
      playlistName: index.name,
      coverUrl: index.coverUrl,
      trackCount: trackCount,
      source: PlaylistDetailSource.remote,
    );
  }

  Future<List<Track>> _fetchRemotePlaylistTracks({
    required String playlistId,
    required List<String> songIds,
    required int offset,
    required int limit,
  }) async {
    final remoteStopwatch = PlaylistPerformanceLogger.start();
    final tracks = await _remoteDataSource.fetchPlaylistSongs(
      songIds: songIds,
      offset: offset,
      limit: limit,
    );
    PlaylistPerformanceLogger.elapsed(
      'repo.fetchSongs.remote',
      remoteStopwatch,
      details: 'playlistId=$playlistId offset=$offset limit=$limit requestedTotal=${songIds.length} tracks=${tracks.length}',
    );
    return tracks;
  }

  Future<void> _persistTracksAndRefreshMarker({
    required String playlistId,
    required List<Track> tracks,
  }) async {
    final saveStopwatch = PlaylistPerformanceLogger.start();
    await _localLibraryDataSource.saveTracks(tracks);
    PlaylistPerformanceLogger.elapsed(
      'repo.fetchSongs.saveTracks',
      saveStopwatch,
      details: 'playlistId=$playlistId tracks=${tracks.length}',
    );
    if (tracks.isEmpty) {
      return;
    }
    final touchStopwatch = PlaylistPerformanceLogger.start();
    await _touchRefresh(playlistId);
    PlaylistPerformanceLogger.elapsed(
      'repo.fetchSongs.touchRefresh',
      touchStopwatch,
      details: 'playlistId=$playlistId',
    );
  }

  Future<PlaylistIndexData> _persistCompletedRemoteDetail({
    required String playlistId,
    required PlaylistIndexData index,
    required List<Track> tracks,
    required String? currentUserId,
  }) async {
    final sourcePlaylistId = MusicResourceId.toNeteaseSourceId(playlistId);
    final returnedTrackIds = tracks.map((track) => MusicResourceId.toNeteaseEntityId(track.id)).where((id) => id.isNotEmpty).toSet();
    final savedTrackIds = index.trackIds.where(returnedTrackIds.contains).toList();
    final persistStopwatch = PlaylistPerformanceLogger.start();
    await _persistTracksAndRefreshMarker(
      playlistId: playlistId,
      tracks: tracks,
    );
    final playlist = _playlistEntityFromIndex(
      entityPlaylistId: index.id,
      sourcePlaylistId: sourcePlaylistId,
      name: index.name,
      coverUrl: index.coverUrl,
      trackCount: savedTrackIds.length,
      trackIds: savedTrackIds,
    );
    await _localLibraryDataSource.savePlaylists([playlist]);
    if (currentUserId?.isNotEmpty == true) {
      await _playlistSubscriptionDataSource.savePlaylistSubscriptionState(
        currentUserId!,
        index.id,
        index.isSubscribed,
      );
    }
    PlaylistPerformanceLogger.elapsed(
      'repo.persistCompletedRemote.total',
      persistStopwatch,
      details: 'playlistId=${index.id} remoteTrackIds=${index.trackIds.length} returnedTracks=${tracks.length} savedTrackIds=${savedTrackIds.length}',
    );
    return PlaylistIndexData(
      id: index.id,
      name: index.name,
      trackIds: savedTrackIds,
      isSubscribed: index.isSubscribed,
      isLikedSongs: index.isLikedSongs,
      creatorUserId: index.creatorUserId,
      coverUrl: index.coverUrl,
      trackCount: savedTrackIds.length,
    );
  }

  Future<PlaylistIndexData?> _loadLocalPlaylistIndex({
    required String playlistId,
    required String? currentUserId,
  }) async {
    final stopwatch = PlaylistPerformanceLogger.start();
    final entityPlaylistId = MusicResourceId.toNeteaseEntityId(playlistId);
    final playlist = await _localLibraryDataSource.getPlaylist(entityPlaylistId);
    if (playlist == null) {
      PlaylistPerformanceLogger.elapsed(
        'repo.loadLocalIndex.total',
        stopwatch,
        details: 'playlistId=$entityPlaylistId found=false',
      );
      return null;
    }
    final index = PlaylistIndexData(
      id: playlist.id,
      name: playlist.title,
      trackIds: _trackIdsFromPlaylist(playlist),
      isSubscribed: await _loadSubscriptionState(currentUserId, entityPlaylistId),
      isLikedSongs: false,
      coverUrl: playlist.coverUrl,
      trackCount: playlist.trackCount,
    );
    PlaylistPerformanceLogger.elapsed(
      'repo.loadLocalIndex.total',
      stopwatch,
      details: 'playlistId=$entityPlaylistId found=true trackIds=${index.trackIds.length}',
    );
    return index;
  }

  PlaylistEntity _playlistEntityFromIndex({
    required String entityPlaylistId,
    required String sourcePlaylistId,
    required String name,
    required int? trackCount,
    required List<String> trackIds,
    PlaylistEntity? basePlaylist,
    String? coverUrl,
  }) {
    final trackRefs = trackIds
        .asMap()
        .entries
        .map(
          (entry) => PlaylistTrackRef(
            trackId: entry.value,
            order: entry.key,
          ),
        )
        .toList();
    return (basePlaylist ??
            PlaylistEntity(
              id: entityPlaylistId,
              sourceType: SourceType.netease,
              sourceId: sourcePlaylistId,
              title: name,
              coverUrl: coverUrl,
              trackCount: trackCount,
            ))
        .copyWith(
      id: entityPlaylistId,
      sourceId: sourcePlaylistId,
      title: name,
      coverUrl: coverUrl ?? basePlaylist?.coverUrl,
      trackCount: trackCount,
      trackRefs: trackRefs,
    );
  }

  List<String> _resolveIndexTrackIds({
    required List<PlaylistTrackRef> remoteTrackRefs,
    required List<String> remoteTrackIds,
    required bool isLikedSongs,
    required List<int> likedSongIds,
  }) {
    final trackIds = remoteTrackRefs.map((item) => item.trackId).toList();
    if (trackIds.isEmpty && remoteTrackIds.isNotEmpty) {
      trackIds.addAll(remoteTrackIds);
    }
    if (isLikedSongs && likedSongIds.isNotEmpty) {
      final likedTrackIds = likedSongIds.map((id) => 'netease:$id').toList();
      if (likedTrackIds.length > trackIds.length) {
        trackIds
          ..clear()
          ..addAll(likedTrackIds);
      }
    }
    return trackIds.map(MusicResourceId.toNeteaseEntityId).where((id) => id.isNotEmpty).toList();
  }

  List<String> _trackIdsFromPlaylist(PlaylistEntity playlist) {
    return playlist.trackRefs.map((item) => MusicResourceId.toNeteaseEntityId(item.trackId)).where((id) => id.isNotEmpty).toList();
  }

  Future<List<PlaybackQueueItem>> _loadLocalSongs(
    List<String> trackIds, {
    required List<int> likedSongIds,
  }) async {
    final stopwatch = PlaylistPerformanceLogger.start();
    if (trackIds.isEmpty) {
      PlaylistPerformanceLogger.elapsed(
        'repo.loadLocalSongs.total',
        stopwatch,
        details: 'trackIds=0 songs=0',
      );
      return const [];
    }
    final loadStopwatch = PlaylistPerformanceLogger.start();
    final tracks = await _musicDataRepository.getTracksWithResources(trackIds);
    PlaylistPerformanceLogger.elapsed(
      'repo.loadLocalSongs.getTracksWithResources',
      loadStopwatch,
      details: 'trackIds=${trackIds.length} tracks=${tracks.length}',
    );
    if (tracks.isEmpty) {
      PlaylistPerformanceLogger.elapsed(
        'repo.loadLocalSongs.total',
        stopwatch,
        details: 'trackIds=${trackIds.length} songs=0',
      );
      return const [];
    }
    final mapStopwatch = PlaylistPerformanceLogger.start();
    final items = PlaybackQueueItemMapper.fromTrackWithResourcesList(
      tracks,
      likedSongIds: likedSongIds,
    );
    PlaylistPerformanceLogger.elapsed(
      'repo.loadLocalSongs.map',
      mapStopwatch,
      details: 'tracks=${tracks.length} items=${items.length}',
    );
    PlaylistPerformanceLogger.elapsed(
      'repo.loadLocalSongs.total',
      stopwatch,
      details: 'trackIds=${trackIds.length} songs=${items.length}',
    );
    return items;
  }

  Future<void> _touchRefresh(String playlistId) {
    return _appCacheDataSource.save(
      cacheKey: _refreshCacheKey(playlistId),
      payloadJson: '{}',
    );
  }

  String _refreshCacheKey(String playlistId) => 'PLAYLIST_CACHE_LAST_REFRESH_${MusicResourceId.toNeteaseSourceId(playlistId)}';

  Future<bool> _loadSubscriptionState(
    String? currentUserId,
    String playlistId,
  ) async {
    if (currentUserId?.isNotEmpty != true) {
      return false;
    }
    return await _playlistSubscriptionDataSource.loadPlaylistSubscriptionState(
          currentUserId!,
          playlistId,
        ) ??
        false;
  }
}
