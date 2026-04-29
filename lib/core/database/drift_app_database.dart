import 'package:bujuan/core/database/app_database.dart';
import 'package:bujuan/core/database/app_database_schema.dart';
import 'package:bujuan/core/database/database_collection_schema.dart';
import 'package:bujuan/core/database/drift_database.dart';
import 'package:bujuan/data/local/app_cache_data_source.dart';
import 'package:bujuan/data/local/dao/cache_dao.dart';
import 'package:bujuan/data/local/dao/download_task_dao.dart';
import 'package:bujuan/data/local/dao/resource_dao.dart';
import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/data/local/drift_app_cache_data_source.dart';
import 'package:bujuan/data/local/drift_download_task_data_source.dart';
import 'package:bujuan/data/local/drift_local_library_data_source.dart';
import 'package:bujuan/data/local/drift_local_resource_index_data_source.dart';
import 'package:bujuan/data/local/drift_playback_restore_data_source.dart';
import 'package:bujuan/data/local/drift_user_scoped_data_source.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/local_resource_index_data_source.dart';
import 'package:bujuan/data/local/playback_restore_data_source.dart';
import 'package:bujuan/data/local/user_scoped_data_source.dart';

class DriftAppDatabase implements AppDatabase {
  DriftAppDatabase({required this.databaseName});

  final String databaseName;
  late final BujuanDriftDatabase _database;
  late final LocalLibraryDataSource _localLibraryDataSource;
  late final PlaybackRestoreDataSource _playbackRestoreDataSource;
  late final LocalResourceIndexDataSource _localResourceIndexDataSource;
  late final DownloadTaskDataSource _downloadTaskDataSource;
  late final AppCacheDataSource _appCacheDataSource;
  late final UserScopedDataSource _userScopedDataSource;

  @override
  Future<void> init() async {
    _database = BujuanDriftDatabase(databaseName: databaseName);
    _localLibraryDataSource = DriftLocalLibraryDataSource(database: _database);
    _playbackRestoreDataSource =
        DriftPlaybackRestoreDataSource(database: _database);
    _localResourceIndexDataSource =
        DriftLocalResourceIndexDataSource(
      dao: ResourceDao(database: _database),
    );
    _downloadTaskDataSource = DriftDownloadTaskDataSource(
      dao: DownloadTaskDao(database: _database),
    );
    _appCacheDataSource = DriftAppCacheDataSource(
      dao: CacheDao(database: _database),
    );
    _userScopedDataSource = DriftUserScopedDataSource(database: _database);
  }

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

  @override
  AppCacheDataSource get appCacheDataSource => _appCacheDataSource;

  @override
  UserScopedDataSource get userScopedDataSource => _userScopedDataSource;
}
