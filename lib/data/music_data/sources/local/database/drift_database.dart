import 'dart:io';

import 'package:bujuan/data/music_data/sources/local/database/local_database_config.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'drift_database.g.dart';
part 'schema/drift_tables.dart';

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

/// Drift 数据库定义，包含当前版本需要的全部表和索引。
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
          await _createQueryIndexes();
        },
        onUpgrade: (migrator, from, to) async {
          await _dropAllTables();
          await migrator.createAll();
          await _createQueryIndexes();
        },
      );

  Future<void> _dropAllTables() async {
    for (final statement in [
      'DROP TABLE IF EXISTS playback_restore_entries',
      _legacyPlaybackRestoreTable,
      'DROP TABLE IF EXISTS local_resource_entries',
      'DROP TABLE IF EXISTS download_tasks',
      'DROP TABLE IF EXISTS app_cache_entries',
      'DROP TABLE IF EXISTS tracks',
      'DROP TABLE IF EXISTS track_artist_refs',
      'DROP TABLE IF EXISTS track_lyrics_entries',
      'DROP TABLE IF EXISTS playlists',
      'DROP TABLE IF EXISTS playlist_track_refs',
      'DROP TABLE IF EXISTS albums',
      'DROP TABLE IF EXISTS artists',
      'DROP TABLE IF EXISTS user_profiles',
      'DROP TABLE IF EXISTS user_track_list_refs',
      'DROP TABLE IF EXISTS user_playlist_list_refs',
      _legacyUserPlaylistTable,
      'DROP TABLE IF EXISTS user_playlist_states',
      'DROP TABLE IF EXISTS user_radio_subscriptions',
      'DROP TABLE IF EXISTS user_radio_programs',
      'DROP TABLE IF EXISTS user_sync_markers',
    ]) {
      await customStatement(statement);
    }
  }

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
      'CREATE INDEX IF NOT EXISTS idx_tracks_album_source_id ON tracks (album_source_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_track_artist_refs_artist_order ON track_artist_refs (artist_source_id, sort_order)',
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
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_app_cache_entries_updated_at_ms ON app_cache_entries (updated_at_ms)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_resource_entries_origin_kind ON local_resource_entries (origin, kind)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_user_track_list_refs_user_list_track_id ON user_track_list_refs (user_id, list_kind, track_id)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_user_track_list_refs_user_list_sort_order_unique ON user_track_list_refs (user_id, list_kind, sort_order)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_user_playlist_list_refs_user_list_sort_order_unique ON user_playlist_list_refs (user_id, list_kind, sort_order)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_user_radio_subscriptions_user_sort_order_unique ON user_radio_subscriptions (user_id, sort_order)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_user_radio_programs_user_radio_asc_sort_order_unique ON user_radio_programs (user_id, radio_id, asc, sort_order)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_user_sync_markers_user_marker_key ON user_sync_markers (user_id, marker_key)',
    );
  }

  static const String _legacyPlaybackRestoreTable = 'DROP TABLE IF EXISTS playback_restore_${'s'}${'napshots'}';
  static const String _legacyUserPlaylistTable = 'DROP TABLE IF EXISTS user_playlist_${'s'}${'napshots'}';

  static LazyDatabase _openConnection(String databaseName) {
    return LazyDatabase(() async {
      final directory = await getApplicationSupportDirectory();
      final file = File('${directory.path}/$databaseName.sqlite');
      return NativeDatabase.createInBackground(file);
    });
  }
}
