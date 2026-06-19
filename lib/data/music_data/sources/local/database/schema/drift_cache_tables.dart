part of '../drift_database.dart';

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
