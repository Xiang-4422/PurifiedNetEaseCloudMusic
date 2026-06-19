part of '../drift_database.dart';

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
