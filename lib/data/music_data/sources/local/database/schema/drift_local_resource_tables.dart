part of '../drift_database.dart';

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
