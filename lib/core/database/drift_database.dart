import 'dart:io';

import 'package:bujuan/core/database/local_database_config.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'drift_database.g.dart';

class PlaybackRestoreSnapshots extends Table {
  IntColumn get id => integer()();
  IntColumn get updatedAtMs => integer()();
  TextColumn get playbackMode => text()();
  TextColumn get repeatMode => text()();
  TextColumn get queueJson => text()();
  TextColumn get currentSongId => text()();
  TextColumn get playlistName => text()();
  TextColumn get playlistHeader => text()();
  IntColumn get positionMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalResourceEntries extends Table {
  TextColumn get trackId => text()();
  TextColumn get kind => text()();
  TextColumn get path => text()();
  TextColumn get origin => text()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {trackId, kind};
}

class DownloadTasks extends Table {
  TextColumn get trackId => text()();
  TextColumn get status => text()();
  IntColumn get updatedAtMs => integer()();
  RealColumn get progress => real().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get artworkPath => text().nullable()();
  TextColumn get lyricsPath => text().nullable()();
  TextColumn get failureReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}

class Tracks extends Table {
  TextColumn get trackId => text()();
  TextColumn get title => text()();
  TextColumn get artistSearchText => text()();
  TextColumn get albumTitle => text().nullable()();
  TextColumn get payloadJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}

class TrackLyricsEntries extends Table {
  TextColumn get trackId => text()();
  TextColumn get main => text()();
  TextColumn get translated => text()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}

class Playlists extends Table {
  TextColumn get playlistId => text()();
  TextColumn get title => text()();
  TextColumn get payloadJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId};
}

class Albums extends Table {
  TextColumn get albumId => text()();
  TextColumn get title => text()();
  TextColumn get artistSearchText => text()();
  TextColumn get payloadJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {albumId};
}

class Artists extends Table {
  TextColumn get artistId => text()();
  TextColumn get name => text()();
  TextColumn get payloadJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {artistId};
}

@DriftDatabase(
  tables: [
    PlaybackRestoreSnapshots,
    LocalResourceEntries,
    DownloadTasks,
    Tracks,
    TrackLyricsEntries,
    Playlists,
    Albums,
    Artists,
  ],
)
class BujuanDriftDatabase extends _$BujuanDriftDatabase {
  BujuanDriftDatabase({required this.databaseName}) : super(_openConnection(databaseName));

  final String databaseName;

  @override
  int get schemaVersion => LocalDatabaseConfig.schemaVersion;

  static LazyDatabase _openConnection(String databaseName) {
    return LazyDatabase(() async {
      final directory = await getApplicationSupportDirectory();
      final file = File('${directory.path}/$databaseName.sqlite');
      return NativeDatabase.createInBackground(file);
    });
  }
}
