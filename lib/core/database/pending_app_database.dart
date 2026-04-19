import 'package:bujuan/core/database/app_database_schema.dart';
import 'package:bujuan/core/database/database_collection_schema.dart';
import 'app_database.dart';
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
  final LocalLibraryDataSource _localLibraryDataSource =
      const PersistentLocalLibraryDataSource();
  final PlaybackRestoreDataSource _playbackRestoreDataSource =
      const PersistentPlaybackRestoreDataSource();
  final LocalResourceIndexDataSource _localResourceIndexDataSource =
      const PersistentLocalResourceIndexDataSource();
  final DownloadTaskDataSource _downloadTaskDataSource =
      const PersistentDownloadTaskDataSource();

  @override
  Future<void> init() async {
    // 先把数据库生命周期和依赖入口固定下来，后续接入正式引擎时
    // 不需要再反复改应用启动顺序和依赖注册方式。
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
  PlaybackRestoreDataSource get playbackRestoreDataSource =>
      _playbackRestoreDataSource;

  @override
  LocalResourceIndexDataSource get localResourceIndexDataSource =>
      _localResourceIndexDataSource;

  @override
  DownloadTaskDataSource get downloadTaskDataSource => _downloadTaskDataSource;
}
