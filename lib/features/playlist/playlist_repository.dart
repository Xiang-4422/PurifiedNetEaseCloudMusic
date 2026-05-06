import 'package:bujuan/core/network/operation_result.dart';
import 'package:bujuan/core/playback/playback_queue_item_mapper.dart';
import 'package:bujuan/data/local/app_cache_data_source.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_playlist_remote_data_source.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/playlist_track_ref.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
import 'package:bujuan/features/library/library_repository.dart';

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
    required LibraryRepository libraryRepository,
    required LocalLibraryDataSource localLibraryDataSource,
    NeteasePlaylistRemoteDataSource? remoteDataSource,
    required UserScopedDataSource userScopedDataSource,
  })  : _appCacheDataSource = appCacheDataSource,
        _libraryRepository = libraryRepository,
        _localLibraryDataSource = localLibraryDataSource,
        _remoteDataSource = remoteDataSource ?? NeteasePlaylistRemoteDataSource(),
        _userScopedDataSource = userScopedDataSource;

  final AppCacheDataSource _appCacheDataSource;
  final LibraryRepository _libraryRepository;
  final LocalLibraryDataSource _localLibraryDataSource;
  final NeteasePlaylistRemoteDataSource _remoteDataSource;
  final UserScopedDataSource _userScopedDataSource;

  /// 拉取歌单索引，并同步歌单基础信息、曲目顺序和订阅状态到本地数据库。
  Future<PlaylistIndexData> fetchPlaylistIndex(
    String playlistId, {
    String? currentUserId,
    List<int> likedSongIds = const [],
  }) async {
    final sourcePlaylistId = _toSourcePlaylistId(playlistId);
    final entityPlaylistId = _toEntityPlaylistId(playlistId);
    final remoteIndex = await _remoteDataSource.fetchPlaylistIndex(sourcePlaylistId);
    final trackIds = _resolveIndexTrackIds(
      remoteTrackRefs: remoteIndex.playlist?.trackRefs ?? const <PlaylistTrackRef>[],
      remoteTrackIds: remoteIndex.trackIds,
      isLikedSongs: remoteIndex.isLikedSongs,
      likedSongIds: likedSongIds,
    );
    final playlist = _playlistEntityFromIndex(
      entityPlaylistId: entityPlaylistId,
      sourcePlaylistId: sourcePlaylistId,
      name: remoteIndex.name,
      coverUrl: remoteIndex.playlist?.coverUrl,
      trackCount: remoteIndex.playlist?.trackCount ?? trackIds.length,
      basePlaylist: remoteIndex.playlist,
      trackIds: trackIds,
    );
    await _localLibraryDataSource.savePlaylists([playlist]);
    if (currentUserId?.isNotEmpty == true) {
      await _userScopedDataSource.savePlaylistSubscriptionState(
        currentUserId!,
        entityPlaylistId,
        remoteIndex.isSubscribed,
      );
    }
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
  }) async {
    playlistIndex ??= await fetchPlaylistIndex(
      playlistId,
      likedSongIds: likedSongIds,
    );
    final songIds = playlistIndex.trackIds.map(_toSourceTrackId).where((id) => id.isNotEmpty).toList();
    if (offset >= songIds.length) {
      return const [];
    }
    final tracks = await _remoteDataSource.fetchPlaylistSongs(
      songIds: songIds,
      offset: offset,
      limit: limit,
    );
    await _libraryRepository.saveTracks(tracks);
    if (tracks.isNotEmpty) {
      await _touchRefresh(playlistId);
    }
    return PlaybackQueueItemMapper.fromTrackList(
      tracks,
      likedSongIds: likedSongIds,
    );
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
    final entityPlaylistId = _toEntityPlaylistId(playlistId);
    final localPlaylist = await _localLibraryDataSource.getPlaylist(entityPlaylistId);
    if (localPlaylist == null) {
      return const PlaylistLocalInitialData(
        localDetail: null,
        localPlaylist: null,
      );
    }
    final trackIds = _trackIdsFromPlaylist(localPlaylist);
    final songs = await _loadLocalSongs(trackIds, likedSongIds: likedSongIds);
    return PlaylistLocalInitialData(
      localDetail: PlaylistDetailData(
        songs: songs,
        isSubscribed: await _loadSubscriptionState(
          currentUserId,
          entityPlaylistId,
        ),
        isMyPlayList: false,
        expectedTrackCount: PlaylistDetailData.resolveExpectedTrackCount(
          trackIds.length,
          localPlaylist.trackCount,
        ),
        playlistName: localPlaylist.title,
        coverUrl: localPlaylist.coverUrl,
        trackCount: localPlaylist.trackCount,
        source: PlaylistDetailSource.local,
      ),
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
    await fetchPlaylistSongs(
      playlistId: playlistId,
      likedSongIds: likedSongIds,
      playlistIndex: index,
      offset: offset,
      limit: limit,
    );
    return _buildDetailFromIndex(
      index,
      likedSongIds: likedSongIds,
      currentUserId: currentUserId,
      source: PlaylistDetailSource.remote,
    );
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
      await _userScopedDataSource.savePlaylistSubscriptionState(
        currentUserId!,
        _toEntityPlaylistId(playlistId),
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
      final entityPlaylistId = _toEntityPlaylistId(playlistId);
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
    final songs = await _loadLocalSongs(index.trackIds, likedSongIds: likedSongIds);
    return PlaylistDetailData(
      songs: songs,
      isSubscribed: index.isSubscribed,
      isMyPlayList: index.creatorUserId != null && index.creatorUserId == currentUserId,
      expectedTrackCount: index.expectedTrackCount,
      playlistName: index.name,
      coverUrl: index.coverUrl,
      trackCount: index.trackCount,
      source: source,
    );
  }

  Future<PlaylistIndexData?> _loadLocalPlaylistIndex({
    required String playlistId,
    required String? currentUserId,
  }) async {
    final entityPlaylistId = _toEntityPlaylistId(playlistId);
    final playlist = await _localLibraryDataSource.getPlaylist(entityPlaylistId);
    if (playlist == null) {
      return null;
    }
    return PlaylistIndexData(
      id: playlist.id,
      name: playlist.title,
      trackIds: _trackIdsFromPlaylist(playlist),
      isSubscribed: await _loadSubscriptionState(currentUserId, entityPlaylistId),
      isLikedSongs: false,
      coverUrl: playlist.coverUrl,
      trackCount: playlist.trackCount,
    );
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
    return trackIds.map(_toEntityTrackId).where((id) => id.isNotEmpty).toList();
  }

  List<String> _trackIdsFromPlaylist(PlaylistEntity playlist) {
    return playlist.trackRefs.map((item) => _toEntityTrackId(item.trackId)).where((id) => id.isNotEmpty).toList();
  }

  Future<List<PlaybackQueueItem>> _loadLocalSongs(
    List<String> trackIds, {
    required List<int> likedSongIds,
  }) async {
    if (trackIds.isEmpty) {
      return const [];
    }
    final tracks = await _libraryRepository.getTracksWithResources(trackIds);
    if (tracks.isEmpty) {
      return const [];
    }
    final tracksById = <String, TrackWithResources>{
      for (final track in tracks) track.track.id: track,
    };
    final orderedTracks = trackIds.map((trackId) => tracksById[trackId]).whereType<TrackWithResources>().toList();
    if (orderedTracks.isEmpty) {
      return const [];
    }
    return PlaybackQueueItemMapper.fromTrackWithResourcesList(
      orderedTracks,
      likedSongIds: likedSongIds,
    );
  }

  Future<void> _touchRefresh(String playlistId) {
    return _appCacheDataSource.save(
      cacheKey: _refreshCacheKey(playlistId),
      payloadJson: '{}',
    );
  }

  String _refreshCacheKey(String playlistId) => 'PLAYLIST_CACHE_LAST_REFRESH_${_toSourcePlaylistId(playlistId)}';

  String _toEntityPlaylistId(String playlistId) {
    if (playlistId.startsWith('netease:') || playlistId.startsWith('local:')) {
      return playlistId;
    }
    return 'netease:$playlistId';
  }

  String _toSourcePlaylistId(String playlistId) {
    if (playlistId.startsWith('netease:')) {
      return playlistId.substring('netease:'.length);
    }
    return playlistId;
  }

  String _toSourceTrackId(String trackId) {
    if (trackId.startsWith('netease:')) {
      return trackId.substring('netease:'.length);
    }
    return trackId;
  }

  String _toEntityTrackId(String trackId) {
    if (trackId.isEmpty || trackId.startsWith('netease:') || trackId.startsWith('local:')) {
      return trackId;
    }
    return 'netease:$trackId';
  }

  Future<bool> _loadSubscriptionState(
    String? currentUserId,
    String playlistId,
  ) async {
    if (currentUserId?.isNotEmpty != true) {
      return false;
    }
    return await _userScopedDataSource.loadPlaylistSubscriptionState(
          currentUserId!,
          playlistId,
        ) ??
        false;
  }
}
