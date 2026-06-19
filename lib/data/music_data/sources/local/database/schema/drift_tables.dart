part of '../drift_database.dart';

/// 播放恢复状态表。
@DataClassName('PlaybackRestoreEntry')
class PlaybackRestoreEntries extends Table {
  /// 固定主键。
  IntColumn get id => integer()();

  /// 恢复状态更新时间戳，单位毫秒。
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

  /// 专辑来源侧 id，用于专辑详情本地查询。
  TextColumn get albumSourceId => text().nullable()();

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

/// 曲目歌手关系表，用于按歌手来源 id 查询本地曲目。
class TrackArtistRefs extends Table {
  /// 曲目 id。
  TextColumn get trackId => text()();

  /// 歌手来源侧 id。
  TextColumn get artistSourceId => text()();

  /// 歌手在曲目中的顺序。
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {trackId, artistSourceId};
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
