import 'package:bujuan/data/music_data/sources/local/database/data_sources/download_task_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/app_cache_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/local_library_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/local_resource_index_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/playback_restore_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/user_scoped_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/schema/database_collection_schema.dart';

export 'data_sources/app_cache_data_source.dart';
export 'data_sources/download_task_data_source.dart';
export 'data_sources/local_library_data_source.dart';
export 'data_sources/local_resource_index_data_source.dart';
export 'data_sources/playback_restore_data_source.dart';
export 'data_sources/user_scoped_data_source.dart';

/// 应用数据库抽象，向装配层暴露当前数据库能力和数据源入口。
abstract class AppDatabase {
  /// 初始化数据库连接和所有本地数据源。
  Future<void> init();

  /// 当前数据库 schema 版本。
  int get schemaVersion;

  /// 当前数据库集合说明。
  List<DatabaseCollectionSchema> get collections;

  /// 本地曲库数据源。
  LocalLibraryDataSource get localLibraryDataSource;

  /// 播放恢复快照数据源。
  PlaybackRestoreDataSource get playbackRestoreDataSource;

  /// 本地资源索引数据源。
  LocalResourceIndexDataSource get localResourceIndexDataSource;

  /// 下载任务数据源。
  DownloadTaskDataSource get downloadTaskDataSource;

  /// 通用应用缓存数据源。
  AppCacheDataSource get appCacheDataSource;

  /// 用户作用域数据源。
  UserScopedDataSource get userScopedDataSource;

  /// 用户资料数据源。
  UserProfileDataSource get userProfileDataSource;

  /// 用户曲目列表数据源。
  UserTrackListDataSource get userTrackListDataSource;

  /// 用户歌单列表数据源。
  UserPlaylistListDataSource get userPlaylistListDataSource;

  /// 用户歌单订阅状态数据源。
  PlaylistSubscriptionDataSource get playlistSubscriptionDataSource;

  /// 用户电台数据源。
  UserRadioDataSource get userRadioDataSource;

  /// 用户同步标记数据源。
  UserSyncMarkerDataSource get userSyncMarkerDataSource;
}
