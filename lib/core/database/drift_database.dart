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
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text()();
  TextColumn get title => text()();
  TextColumn get artistSearchText => text()();
  TextColumn get artistNamesJson => text()();
  TextColumn get albumTitle => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get artworkUrl => text().nullable()();
  TextColumn get remoteUrl => text().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get localArtworkPath => text().nullable()();
  TextColumn get localLyricsPath => text().nullable()();
  TextColumn get lyricKey => text().nullable()();
  TextColumn get availability => text()();
  TextColumn get downloadState => text()();
  TextColumn get resourceOrigin => text()();
  RealColumn get downloadProgress => real().nullable()();
  TextColumn get downloadFailureReason => text().nullable()();
  TextColumn get metadataJson => text()();

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
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get coverUrl => text().nullable()();
  IntColumn get trackCount => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId};
}

class PlaylistTrackRefs extends Table {
  TextColumn get playlistId => text()();
  TextColumn get trackId => text()();
  IntColumn get order => integer()();
  IntColumn get addedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, trackId};
}

class Albums extends Table {
  TextColumn get albumId => text()();
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text()();
  TextColumn get title => text()();
  TextColumn get artistSearchText => text()();
  TextColumn get artistNamesJson => text()();
  TextColumn get artworkUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get trackCount => integer().nullable()();
  IntColumn get publishTime => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {albumId};
}

class Artists extends Table {
  TextColumn get artistId => text()();
  TextColumn get sourceType => text()();
  TextColumn get sourceId => text()();
  TextColumn get name => text()();
  TextColumn get artworkUrl => text().nullable()();
  TextColumn get description => text().nullable()();

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
    PlaylistTrackRefs,
    Albums,
    Artists,
  ],
)
class BujuanDriftDatabase extends _$BujuanDriftDatabase {
  BujuanDriftDatabase({required this.databaseName})
      : super(_openConnection(databaseName));

  final String databaseName;

  @override
  int get schemaVersion => LocalDatabaseConfig.schemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
          await _createQueryIndexes();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await _createQueryIndexes();
          }
        },
      );

  Future<void> _createQueryIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_title ON tracks (title)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_artist_search_text ON tracks (artist_search_text)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_album_title ON tracks (album_title)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tracks_download_state ON tracks (download_state)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_playlists_title ON playlists (title)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_playlist_track_refs_playlist_order ON playlist_track_refs (playlist_id, "order")',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_albums_title ON albums (title)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_albums_artist_search_text ON albums (artist_search_text)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_artists_name ON artists (name)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_download_tasks_status_updated_at_ms ON download_tasks (status, updated_at_ms)',
    );
  }

  static LazyDatabase _openConnection(String databaseName) {
    return LazyDatabase(() async {
      final directory = await getApplicationSupportDirectory();
      final file = File('${directory.path}/$databaseName.sqlite');
      return NativeDatabase.createInBackground(file);
    });
  }
}
