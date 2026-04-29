import 'database_collection_schema.dart';

/// 应用数据库 schema 描述，记录当前版本和集合归属。
class AppDatabaseSchema {
  /// 禁止实例化 schema 描述类。
  const AppDatabaseSchema._();

  /// 当前数据库 schema 版本。
  static const int schemaVersion = 5;

  /// 播放恢复快照集合说明。
  static const DatabaseCollectionSchema playbackRestoreSnapshots =
      DatabaseCollectionSchema(
    name: 'playback_restore_snapshots',
    version: 1,
    description: '播放恢复快照记录',
  );

  /// 本地资源索引集合说明。
  static const DatabaseCollectionSchema localResourceEntries =
      DatabaseCollectionSchema(
    name: 'local_resource_entries',
    version: 2,
    description: '本地资源索引记录',
  );

  /// 下载任务集合说明。
  static const DatabaseCollectionSchema downloadTasks =
      DatabaseCollectionSchema(
    name: 'download_tasks',
    version: 2,
    description: '下载任务过程记录',
  );

  /// 用户作用域缓存集合说明。
  static const DatabaseCollectionSchema userScopedCache =
      DatabaseCollectionSchema(
    name: 'user_scoped_cache',
    version: 1,
    description: '用户作用域的关系与快照缓存',
  );

  /// 应用通用缓存集合说明。
  static const DatabaseCollectionSchema appCacheEntries =
      DatabaseCollectionSchema(
    name: 'app_cache_entries',
    version: 1,
    description: '通用业务缓存 JSON 记录',
  );

  /// 当前数据库包含的集合说明列表。
  static const List<DatabaseCollectionSchema> collections = [
    playbackRestoreSnapshots,
    localResourceEntries,
    downloadTasks,
    userScopedCache,
    appCacheEntries,
  ];
}
