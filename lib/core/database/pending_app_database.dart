import 'package:bujuan/core/database/app_database_schema.dart';
import 'package:bujuan/core/database/database_collection_schema.dart';
import 'app_database.dart';
import 'package:bujuan/core/storage/cache_box_storage_adapter.dart';
import 'package:bujuan/core/storage/key_value_storage_adapter.dart';
import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/local_resource_index_data_source.dart';
import 'package:bujuan/data/local/persistent_download_task_data_source.dart';
import 'package:bujuan/data/local/persistent_local_resource_index_data_source.dart';
import 'package:bujuan/data/local/persistent_playback_restore_data_source.dart';
import 'package:bujuan/data/local/playback_restore_data_source.dart';
import 'package:bujuan/data/local/persistent_local_library_data_source.dart';

class PendingAppDatabase implements AppDatabase {
  PendingAppDatabase({required this.databaseName});

  final String databaseName;
  bool _initialized = false;
  late final KeyValueStorageAdapter _storageAdapter;
  late final LocalLibraryDataSource _localLibraryDataSource;
  late final PlaybackRestoreDataSource _playbackRestoreDataSource;
  late final LocalResourceIndexDataSource _localResourceIndexDataSource;
  late final DownloadTaskDataSource _downloadTaskDataSource;

  @override
  Future<void> init() async {
    // 先把数据库生命周期和依赖入口固定下来，后续接入正式引擎时
    // 不需要再反复改应用启动顺序和依赖注册方式。
    _storageAdapter = const CacheBoxStorageAdapter();
    _localLibraryDataSource = PersistentLocalLibraryDataSource(
      storageAdapter: _storageAdapter,
    );
    _playbackRestoreDataSource = PersistentPlaybackRestoreDataSource(
      storageAdapter: _storageAdapter,
    );
    _localResourceIndexDataSource = PersistentLocalResourceIndexDataSource(
      storageAdapter: _storageAdapter,
    );
    _downloadTaskDataSource = PersistentDownloadTaskDataSource(
      storageAdapter: _storageAdapter,
    );
    _initialized = true;
  }

  bool get isInitialized => _initialized;

  @override
  int get schemaVersion => AppDatabaseSchema.schemaVersion;

  @override
  List<DatabaseCollectionSchema> get collections =>
      AppDatabaseSchema.collections;

  @override
  LocalLibraryDataSource get localLibraryDataSource => _localLibraryDataSource;

  @override
  KeyValueStorageAdapter get storageAdapter => _storageAdapter;

  @override
  PlaybackRestoreDataSource get playbackRestoreDataSource =>
      _playbackRestoreDataSource;

  @override
  LocalResourceIndexDataSource get localResourceIndexDataSource =>
      _localResourceIndexDataSource;

  @override
  DownloadTaskDataSource get downloadTaskDataSource => _downloadTaskDataSource;
}
