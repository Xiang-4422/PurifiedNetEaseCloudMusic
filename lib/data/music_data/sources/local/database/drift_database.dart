import 'dart:io';

import 'package:bujuan/data/music_data/sources/local/database/local_database_config.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'drift_database.g.dart';
part 'schema/drift_cache_tables.dart';
part 'schema/drift_download_tables.dart';
part 'schema/drift_library_tables.dart';
part 'schema/drift_local_resource_tables.dart';
part 'schema/drift_playback_tables.dart';
part 'schema/drift_playlist_tables.dart';
part 'schema/drift_schema_maintenance.dart';
part 'schema/drift_user_tables.dart';

@DriftDatabase(
  tables: [
    PlaybackRestoreEntries,
    LocalResourceEntries,
    DownloadTasks,
    AppCacheEntries,
    Tracks,
    TrackArtistRefs,
    TrackLyricsEntries,
    Playlists,
    PlaylistTrackRefs,
    Albums,
    Artists,
    UserProfiles,
    UserTrackListRefs,
    UserPlaylistListRefs,
    UserPlaylistStates,
    UserRadioSubscriptions,
    UserRadioPrograms,
    UserSyncMarkers,
  ],
)

/// Drift 数据库入口，组合表定义、迁移策略和连接创建。
class BujuanDriftDatabase extends _$BujuanDriftDatabase {
  /// 创建 Bujuan Drift 数据库。
  BujuanDriftDatabase({required this.databaseName}) : super(_openConnection(databaseName));

  /// 使用指定 executor 创建数据库，供测试和受控运行环境使用。
  BujuanDriftDatabase.connect(QueryExecutor executor)
      : databaseName = ':memory:',
        super(executor);

  /// 数据库文件名。
  final String databaseName;

  @override
  int get schemaVersion => LocalDatabaseConfig.schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
          await createQueryIndexes();
        },
        onUpgrade: (migrator, from, to) async {
          await dropAllTablesForMigration();
          await migrator.createAll();
          await createQueryIndexes();
        },
      );

  static LazyDatabase _openConnection(String databaseName) {
    return LazyDatabase(() async {
      final directory = await getApplicationSupportDirectory();
      final file = File('${directory.path}/$databaseName.sqlite');
      return NativeDatabase.createInBackground(file);
    });
  }
}
