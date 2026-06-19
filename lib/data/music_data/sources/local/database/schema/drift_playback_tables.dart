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
