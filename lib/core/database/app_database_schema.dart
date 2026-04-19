import 'database_collection_schema.dart';

class AppDatabaseSchema {
  const AppDatabaseSchema._();

  static const int schemaVersion = 1;

  static const DatabaseCollectionSchema playbackRestoreSnapshots =
      DatabaseCollectionSchema(
    name: 'playback_restore_snapshots',
    version: 1,
    description: '播放恢复快照记录',
  );

  static const DatabaseCollectionSchema localResourceEntries =
      DatabaseCollectionSchema(
    name: 'local_resource_entries',
    version: 1,
    description: '本地资源索引记录',
  );

  static const DatabaseCollectionSchema downloadTasks = DatabaseCollectionSchema(
    name: 'download_tasks',
    version: 1,
    description: '下载任务过程记录',
  );

  static const List<DatabaseCollectionSchema> collections = [
    playbackRestoreSnapshots,
    localResourceEntries,
    downloadTasks,
  ];
}
