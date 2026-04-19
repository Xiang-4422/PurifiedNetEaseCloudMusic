import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/local_resource_index_data_source.dart';
import 'package:bujuan/data/local/playback_restore_data_source.dart';
import 'package:bujuan/core/database/database_collection_schema.dart';
import 'package:bujuan/core/storage/key_value_storage_adapter.dart';

abstract class AppDatabase {
  Future<void> init();

  int get schemaVersion;

  List<DatabaseCollectionSchema> get collections;

  KeyValueStorageAdapter get storageAdapter;

  LocalLibraryDataSource get localLibraryDataSource;

  PlaybackRestoreDataSource get playbackRestoreDataSource;

  LocalResourceIndexDataSource get localResourceIndexDataSource;

  DownloadTaskDataSource get downloadTaskDataSource;
}
