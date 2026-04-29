import 'dart:io';

import 'package:bujuan/core/database/local_database_config.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'drift_database.g.dart';

/// 播放恢复快照表。
class PlaybackRestoreSnapshots extends Table {
  /// 固定主键。
  IntColumn get id => integer()();

  /// 快照更新时间戳，单位毫秒。
  IntColumn get updatedAtMs => integer()();

  /// 播放模式名称。
  TextColumn get playbackMode => text()();

  /// 重复模式名称。
  TextColumn get repeatMode => text()();

  /// 播放队列 JSON。
  TextColumn get queueJson => text()();

  /// 当前歌曲 id。
  TextColumn get currentSongId => text()();

  /// 当前播放列表名称。
  TextColumn get playlistName => text()();

  /// 当前播放列表头部文案。
  TextColumn get playlistHeader => text()();

  /// 当前播放进度，单位毫秒。
  IntColumn get positionMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// 本地资源索引表。
class LocalResourceEntries extends Table {
  /// 歌曲 id。
  TextColumn get trackId => text()();

  /// 资源类型。
  TextColumn get kind => text()();

  /// 本地文件路径。
  TextColumn get path => text()();

  /// 资源来源。
  TextColumn get origin => text()();

  /// 文件大小，单位字节。
  IntColumn get sizeBytes => integer()();

  /// 创建时间戳，单位毫秒。
  IntColumn get createdAtMs => integer()();

  /// 最近访问时间戳，单位毫秒。
  IntColumn get lastAccessedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {trackId, kind};
}

/// 下载任务表。
class DownloadTasks extends Table {
  /// 歌曲 id。
  TextColumn get trackId => text()();

  /// 下载状态名称。
  TextColumn get status => text()();

  /// 最近更新时间戳，单位毫秒。
  IntColumn get updatedAtMs => integer()();

  /// 下载进度。
  RealColumn get progress => real().nullable()();

  /// 临时文件路径。
  TextColumn get temporaryPath => text().nullable()();

  /// 失败原因。
  TextColumn get failureReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}

/// 应用通用缓存表。
class AppCacheEntries extends Table {
  /// 缓存键。
  TextColumn get cacheKey => text()();

  /// 缓存负载 JSON。
  TextColumn get payloadJson => text()();

  /// 更新时间戳，单位毫秒。
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {cacheKey};
}

/// 曲目表。
class Tracks extends Table {
  /// 曲目 id。
  TextColumn get trackId => text()();

  /// 来源类型。
  TextColumn get sourceType => text()();

  /// 来源侧 id。
  TextColumn get sourceId => text()();

  /// 曲目标题。
  TextColumn get title => text()();

  /// 歌手搜索文本。
  TextColumn get artistSearchText => text()();

  /// 歌手名称 JSON。
  TextColumn get artistNamesJson => text()();

  /// 专辑标题。
  TextColumn get albumTitle => text().nullable()();

  /// 时长，单位毫秒。
  IntColumn get durationMs => integer().nullable()();

  /// 封面地址。
  TextColumn get artworkUrl => text().nullable()();

  /// 远程播放地址。
  TextColumn get remoteUrl => text().nullable()();

  /// 歌词键。
  TextColumn get lyricKey => text().nullable()();

  /// 可用状态。
  TextColumn get availability => text()();

  /// 扩展元数据 JSON。
  TextColumn get metadataJson => text()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}

/// 曲目歌词表。
class TrackLyricsEntries extends Table {
  /// 曲目 id。
  TextColumn get trackId => text()();

  /// 主歌词文本。
  TextColumn get main => text()();

  /// 翻译歌词文本。
  TextColumn get translated => text()();

  @override
  Set<Column<Object>> get primaryKey => {trackId};
}

/// 歌单表。
class Playlists extends Table {
  /// 歌单 id。
  TextColumn get playlistId => text()();

  /// 来源类型。
  TextColumn get sourceType => text()();

  /// 来源侧 id。
  TextColumn get sourceId => text()();

  /// 歌单标题。
  TextColumn get title => text()();

  /// 歌单描述。
  TextColumn get description => text().nullable()();

  /// 歌单封面地址。
  TextColumn get coverUrl => text().nullable()();

  /// 歌曲数量。
  IntColumn get trackCount => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId};
}

/// 歌单曲目引用表。
class PlaylistTrackRefs extends Table {
  /// 歌单 id。
  TextColumn get playlistId => text()();

  /// 曲目 id。
  TextColumn get trackId => text()();

  /// 歌单内顺序。
  IntColumn get order => integer()();

  /// 添加时间戳，单位毫秒。
  IntColumn get addedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId, trackId};
}

/// 专辑表。
class Albums extends Table {
  /// 专辑 id。
  TextColumn get albumId => text()();

  /// 来源类型。
  TextColumn get sourceType => text()();

  /// 来源侧 id。
  TextColumn get sourceId => text()();

  /// 专辑标题。
  TextColumn get title => text()();

  /// 歌手搜索文本。
  TextColumn get artistSearchText => text()();

  /// 歌手名称 JSON。
  TextColumn get artistNamesJson => text()();

  /// 专辑封面地址。
  TextColumn get artworkUrl => text().nullable()();

  /// 专辑描述。
  TextColumn get description => text().nullable()();

  /// 曲目数量。
  IntColumn get trackCount => integer().nullable()();

  /// 发布时间戳。
  IntColumn get publishTime => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {albumId};
}

/// 歌手表。
class Artists extends Table {
  /// 歌手 id。
  TextColumn get artistId => text()();

  /// 来源类型。
  TextColumn get sourceType => text()();

  /// 来源侧 id。
  TextColumn get sourceId => text()();

  /// 歌手名称。
  TextColumn get name => text()();

  /// 歌手封面地址。
  TextColumn get artworkUrl => text().nullable()();

  /// 歌手描述。
  TextColumn get description => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {artistId};
}

/// 用户资料表。
class UserProfiles extends Table {
  /// 用户 id。
  TextColumn get userId => text()();

  /// 用户昵称。
  TextColumn get nickname => text()();

  /// 用户签名。
  TextColumn get signature => text()();

  /// 关注数。
  IntColumn get follows => integer()();

  /// 粉丝数。
  IntColumn get followeds => integer()();

  /// 歌单数量。
  IntColumn get playlistCount => integer()();

  /// 头像地址。
  TextColumn get avatarUrl => text()();

  /// 更新时间戳，单位毫秒。
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

/// 用户曲目列表引用表。
class UserTrackListRefs extends Table {
  /// 用户 id。
  TextColumn get userId => text()();

  /// 列表类型。
  TextColumn get listKind => text()();

  /// 曲目 id。
  TextColumn get trackId => text()();

  /// 排序值。
  IntColumn get sortOrder => integer()();

  /// 更新时间戳，单位毫秒。
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {userId, listKind, sortOrder};
}

/// 用户歌单列表引用表。
class UserPlaylistListRefs extends Table {
  /// 用户 id。
  TextColumn get userId => text()();

  /// 列表类型。
  TextColumn get listKind => text()();

  /// 歌单 id。
  TextColumn get playlistId => text()();

  /// 排序值。
  IntColumn get sortOrder => integer()();

  /// 更新时间戳，单位毫秒。
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {userId, listKind, playlistId};
}

/// 用户歌单快照表。
class UserPlaylistSnapshots extends Table {
  /// 歌单 id。
  TextColumn get playlistId => text()();

  /// 来源侧 id。
  TextColumn get sourceId => text()();

  /// 歌单标题。
  TextColumn get title => text()();

  /// 歌单封面地址。
  TextColumn get coverUrl => text().nullable()();

  /// 曲目数量。
  IntColumn get trackCount => integer().nullable()();

  /// 歌单描述。
  TextColumn get description => text().nullable()();

  /// 更新时间戳，单位毫秒。
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {playlistId};
}

/// 用户歌单订阅状态表。
class UserPlaylistStates extends Table {
  /// 用户 id。
  TextColumn get userId => text()();

  /// 歌单 id。
  TextColumn get playlistId => text()();

  /// 是否已订阅。
  BoolColumn get isSubscribed => boolean()();

  /// 更新时间戳，单位毫秒。
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {userId, playlistId};
}

/// 用户电台订阅表。
class UserRadioSubscriptions extends Table {
  /// 用户 id。
  TextColumn get userId => text()();

  /// 电台 id。
  TextColumn get radioId => text()();

  /// 排序值。
  IntColumn get sortOrder => integer()();

  /// 电台名称。
  TextColumn get name => text()();

  /// 电台封面地址。
  TextColumn get coverUrl => text()();

  /// 最近节目名称。
  TextColumn get lastProgramName => text()();

  /// 更新时间戳，单位毫秒。
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {userId, radioId};
}

/// 用户电台节目表。
class UserRadioPrograms extends Table {
  /// 用户 id。
  TextColumn get userId => text()();

  /// 电台 id。
  TextColumn get radioId => text()();

  /// 是否升序排列。
  BoolColumn get asc => boolean()();

  /// 节目 id。
  TextColumn get programId => text()();

  /// 排序值。
  IntColumn get sortOrder => integer()();

  /// 主曲目 id。
  TextColumn get mainTrackId => text()();

  /// 节目标题。
  TextColumn get title => text()();

  /// 节目封面地址。
  TextColumn get coverUrl => text()();

  /// 歌手名称。
  TextColumn get artistName => text()();

  /// 专辑标题。
  TextColumn get albumTitle => text()();

  /// 时长，单位毫秒。
  IntColumn get durationMs => integer()();

  /// 更新时间戳，单位毫秒。
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {userId, radioId, asc, programId};
}

/// 用户同步标记表。
class UserSyncMarkers extends Table {
  /// 用户 id。
  TextColumn get userId => text()();

  /// 标记键。
  TextColumn get markerKey => text()();

  /// 更新时间戳，单位毫秒。
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {userId, markerKey};
}

@DriftDatabase(
  tables: [
    PlaybackRestoreSnapshots,
    LocalResourceEntries,
    DownloadTasks,
    AppCacheEntries,
    Tracks,
    TrackLyricsEntries,
    Playlists,
    PlaylistTrackRefs,
    Albums,
    Artists,
    UserProfiles,
    UserTrackListRefs,
    UserPlaylistListRefs,
    UserPlaylistSnapshots,
    UserPlaylistStates,
    UserRadioSubscriptions,
    UserRadioPrograms,
    UserSyncMarkers,
  ],
)

/// Drift 数据库定义，包含当前版本需要的全部表和索引。
class BujuanDriftDatabase extends _$BujuanDriftDatabase {
  /// 创建 Bujuan Drift 数据库。
  BujuanDriftDatabase({required this.databaseName})
      : super(_openConnection(databaseName));

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
    for (final statement in const [
      'DROP TABLE IF EXISTS playback_restore_snapshots',
      'DROP TABLE IF EXISTS local_resource_entries',
      'DROP TABLE IF EXISTS download_tasks',
      'DROP TABLE IF EXISTS app_cache_entries',
      'DROP TABLE IF EXISTS tracks',
      'DROP TABLE IF EXISTS track_lyrics_entries',
      'DROP TABLE IF EXISTS playlists',
      'DROP TABLE IF EXISTS playlist_track_refs',
      'DROP TABLE IF EXISTS albums',
      'DROP TABLE IF EXISTS artists',
      'DROP TABLE IF EXISTS user_profiles',
      'DROP TABLE IF EXISTS user_track_list_refs',
      'DROP TABLE IF EXISTS user_playlist_list_refs',
      'DROP TABLE IF EXISTS user_playlist_snapshots',
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
      'CREATE INDEX IF NOT EXISTS idx_user_playlist_snapshots_title ON user_playlist_snapshots (title)',
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

  static LazyDatabase _openConnection(String databaseName) {
    return LazyDatabase(() async {
      final directory = await getApplicationSupportDirectory();
      final file = File('${directory.path}/$databaseName.sqlite');
      return NativeDatabase.createInBackground(file);
    });
  }
}
