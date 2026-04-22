import 'database_collection_schema.dart';

class AppDatabaseSchema {
  const AppDatabaseSchema._();

  static const int schemaVersion = 4;

  static const DatabaseCollectionSchema playbackRestoreSnapshots =
      DatabaseCollectionSchema(
    name: 'playback_restore_snapshots',
    version: 1,
    description: '播放恢复快照记录',
  );

  static const DatabaseCollectionSchema localResourceEntries =
      DatabaseCollectionSchema(
    name: 'local_resource_entries',
    version: 2,
    description: '本地资源索引记录',
  );

  static const DatabaseCollectionSchema downloadTasks =
      DatabaseCollectionSchema(
    name: 'download_tasks',
    version: 2,
    description: '下载任务过程记录',
  );

  static const DatabaseCollectionSchema userScopedCache =
      DatabaseCollectionSchema(
    name: 'user_scoped_cache',
    version: 1,
    description: '用户作用域的关系与快照缓存',
  );

  static const List<DatabaseCollectionSchema> collections = [
    playbackRestoreSnapshots,
    localResourceEntries,
    downloadTasks,
    userScopedCache,
  ];
}
