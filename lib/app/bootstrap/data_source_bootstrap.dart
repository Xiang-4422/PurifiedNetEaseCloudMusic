import 'package:bujuan/data/music_data/sources/local/database/app_database.dart';
import 'package:bujuan/data/music_data/sources/local/local_music_source.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/data/music_data/sources/netease/netease_music_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_album_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_artist_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_auth_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_cloud_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_comment_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_explore_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_playlist_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_radio_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_search_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_user_remote_data_source.dart';
import 'package:bujuan/features/comment/comment_cache_store.dart';
import 'package:bujuan/features/explore/explore_cache_store.dart';
import 'package:bujuan/features/search/search_cache_store.dart';
import 'package:netease_music_api/netease_music_api.dart';

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
    required this.neteaseMusicSource,
    required this.authRemoteDataSource,
    required this.userRemoteDataSource,
    required this.playlistRemoteDataSource,
    required this.albumRemoteDataSource,
    required this.artistRemoteDataSource,
    required this.cloudRemoteDataSource,
    required this.radioRemoteDataSource,
    required this.searchRemoteDataSource,
    required this.commentRemoteDataSource,
    required this.exploreRemoteDataSource,
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

  /// 网易云音乐来源门面。
  final NeteaseMusicSource neteaseMusicSource;

  /// 网易云登录远程数据源。
  final AuthRemoteDataSource authRemoteDataSource;

  /// 网易云用户远程数据源。
  final UserRemoteDataSource userRemoteDataSource;

  /// 网易云歌单远程数据源。
  final PlaylistRemoteDataSource playlistRemoteDataSource;

  /// 网易云专辑远程数据源。
  final AlbumRemoteDataSource albumRemoteDataSource;

  /// 网易云歌手远程数据源。
  final ArtistRemoteDataSource artistRemoteDataSource;

  /// 网易云云盘远程数据源。
  final CloudRemoteDataSource cloudRemoteDataSource;

  /// 网易云电台远程数据源。
  final RadioRemoteDataSource radioRemoteDataSource;

  /// 网易云搜索远程数据源。
  final SearchRemoteDataSource searchRemoteDataSource;

  /// 网易云评论远程数据源。
  final CommentRemoteDataSource commentRemoteDataSource;

  /// 网易云探索页远程数据源。
  final ExploreRemoteDataSource exploreRemoteDataSource;
}

/// 从已初始化的数据库门面创建数据源和轻量 cache store。
AppDataSourceBootstrapResult initializeDataSourceInfrastructure({
  required AppDatabase appDatabase,
  required NeteaseMusicApi neteaseApi,
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
    neteaseMusicSource: NeteaseMusicSource(api: neteaseApi),
    authRemoteDataSource: NeteaseAuthRemoteDataSource(api: neteaseApi),
    userRemoteDataSource: NeteaseUserRemoteDataSource(api: neteaseApi),
    playlistRemoteDataSource: NeteasePlaylistRemoteDataSource(api: neteaseApi),
    albumRemoteDataSource: NeteaseAlbumRemoteDataSource(api: neteaseApi),
    artistRemoteDataSource: NeteaseArtistRemoteDataSource(api: neteaseApi),
    cloudRemoteDataSource: NeteaseCloudRemoteDataSource(api: neteaseApi),
    radioRemoteDataSource: NeteaseRadioRemoteDataSource(api: neteaseApi),
    searchRemoteDataSource: NeteaseSearchRemoteDataSource(api: neteaseApi),
    commentRemoteDataSource: NeteaseCommentRemoteDataSource(api: neteaseApi),
    exploreRemoteDataSource: NeteaseExploreRemoteDataSource(api: neteaseApi),
  );
}
