import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/data/local/app_cache_data_source.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/local_resource_index_data_source.dart';
import 'package:bujuan/data/local/playback_restore_data_source.dart';
import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/core/database/database_collection_schema.dart';

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
}
