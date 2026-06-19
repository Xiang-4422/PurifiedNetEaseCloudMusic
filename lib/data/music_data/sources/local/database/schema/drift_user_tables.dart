part of '../drift_database.dart';

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
