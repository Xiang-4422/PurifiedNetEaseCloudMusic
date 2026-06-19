part of '../drift_database.dart';

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
