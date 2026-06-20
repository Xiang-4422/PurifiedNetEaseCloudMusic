import 'package:bujuan/data/music_data/sources/local/database/app_database.dart';
import 'package:bujuan/data/music_data/sources/local/local_music_source.dart';
import 'package:bujuan/features/comment/comment_cache_store.dart';
import 'package:bujuan/features/explore/explore_cache_store.dart';
import 'package:bujuan/features/search/search_cache_store.dart';

/// 已从本地存储门面拆出的数据源和轻量 cache store。
class AppDataSourceBootstrapResult {
  /// 创建数据源启动结果。
  const AppDataSourceBootstrapResult({
    required this.localLibraryDataSource,
    required this.localResourceIndexDataSource,
    required this.userProfileDataSource,
    required this.userTrackListDataSource,
    required this.userPlaylistListDataSource,
    required this.playlistSubscriptionDataSource,
    required this.userRadioDataSource,
    required this.userSyncMarkerDataSource,
    required this.downloadTaskDataSource,
    required this.playbackRestoreDataSource,
    required this.playbackHistoryDataSource,
    required this.appCacheDataSource,
    required this.commentCacheStore,
    required this.searchCacheStore,
    required this.exploreCacheStore,
    required this.localMusicSource,
  });

  /// 本地曲库数据源。
  final LocalLibraryDataSource localLibraryDataSource;

  /// 本地资源索引数据源。
  final LocalResourceIndexDataSource localResourceIndexDataSource;

  /// 用户资料数据源。
  final UserProfileDataSource userProfileDataSource;

  /// 用户曲目列表数据源。
  final UserTrackListDataSource userTrackListDataSource;

  /// 用户歌单列表数据源。
  final UserPlaylistListDataSource userPlaylistListDataSource;

  /// 歌单订阅数据源。
  final PlaylistSubscriptionDataSource playlistSubscriptionDataSource;

  /// 用户电台数据源。
  final UserRadioDataSource userRadioDataSource;

  /// 用户同步标记数据源。
  final UserSyncMarkerDataSource userSyncMarkerDataSource;

  /// 下载任务数据源。
  final DownloadTaskDataSource downloadTaskDataSource;

  /// 播放恢复数据源。
  final PlaybackRestoreDataSource playbackRestoreDataSource;

  /// 播放历史数据源。
  final PlaybackHistoryDataSource playbackHistoryDataSource;

  /// 通用短期缓存数据源。
  final AppCacheDataSource appCacheDataSource;

  /// 评论缓存 store。
  final CommentCacheStore commentCacheStore;

  /// 搜索缓存 store。
  final SearchCacheStore searchCacheStore;

  /// 探索页缓存 store。
  final ExploreCacheStore exploreCacheStore;

  /// 本地音乐来源门面。
  final LocalMusicSource localMusicSource;
}

/// 从已初始化的数据库门面创建数据源和轻量 cache store。
AppDataSourceBootstrapResult initializeDataSourceInfrastructure({
  required AppDatabase appDatabase,
}) {
  final appCacheDataSource = appDatabase.appCacheDataSource;
  final localLibraryDataSource = appDatabase.localLibraryDataSource;
  return AppDataSourceBootstrapResult(
    localLibraryDataSource: localLibraryDataSource,
    localResourceIndexDataSource: appDatabase.localResourceIndexDataSource,
    userProfileDataSource: appDatabase.userProfileDataSource,
    userTrackListDataSource: appDatabase.userTrackListDataSource,
    userPlaylistListDataSource: appDatabase.userPlaylistListDataSource,
    playlistSubscriptionDataSource: appDatabase.playlistSubscriptionDataSource,
    userRadioDataSource: appDatabase.userRadioDataSource,
    userSyncMarkerDataSource: appDatabase.userSyncMarkerDataSource,
    downloadTaskDataSource: appDatabase.downloadTaskDataSource,
    playbackRestoreDataSource: appDatabase.playbackRestoreDataSource,
    playbackHistoryDataSource: appDatabase.playbackHistoryDataSource,
    appCacheDataSource: appCacheDataSource,
    commentCacheStore: CommentCacheStore(cacheDataSource: appCacheDataSource),
    searchCacheStore: SearchCacheStore(cacheDataSource: appCacheDataSource),
    exploreCacheStore: ExploreCacheStore(cacheDataSource: appCacheDataSource),
    localMusicSource: LocalMusicSource(localDataSource: localLibraryDataSource),
  );
}
