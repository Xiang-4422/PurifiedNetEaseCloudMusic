part of '../drift_database.dart';

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
