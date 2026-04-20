import 'package:bujuan/core/database/app_database.dart';
import 'package:bujuan/core/database/app_database_schema.dart';
import 'package:bujuan/core/database/database_collection_schema.dart';
import 'package:bujuan/core/database/isar_local_resource_entity.dart';
import 'package:bujuan/core/database/isar_playback_restore_snapshot_entity.dart';
import 'package:bujuan/data/local/download_task_data_source.dart';
import 'package:bujuan/data/local/isar_local_resource_index_data_source.dart';
import 'package:bujuan/data/local/isar_playback_restore_data_source.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/local_resource_index_data_source.dart';
import 'package:bujuan/data/local/persistent_download_task_data_source.dart';
import 'package:bujuan/data/local/persistent_local_library_data_source.dart';
import 'package:bujuan/data/local/playback_restore_data_source.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarAppDatabase implements AppDatabase {
  IsarAppDatabase({required this.databaseName});

  final String databaseName;
  late final Isar _isar;
  late final LocalLibraryDataSource _localLibraryDataSource;
  late final PlaybackRestoreDataSource _playbackRestoreDataSource;
  late final LocalResourceIndexDataSource _localResourceIndexDataSource;
  late final DownloadTaskDataSource _downloadTaskDataSource;

  @override
  Future<void> init() async {
    final directory = await getApplicationSupportDirectory();
    _isar = await Isar.open(
      [
        IsarPlaybackRestoreSnapshotEntitySchema,
        IsarLocalResourceEntitySchema,
      ],
      name: databaseName,
      directory: directory.path,
    );
    _localLibraryDataSource = const PersistentLocalLibraryDataSource();
    _playbackRestoreDataSource = IsarPlaybackRestoreDataSource(isar: _isar);
    _localResourceIndexDataSource =
        IsarLocalResourceIndexDataSource(isar: _isar);
    _downloadTaskDataSource = const PersistentDownloadTaskDataSource();
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
}
