/// 本地数据库配置。
class LocalDatabaseConfig {
  /// 禁止实例化数据库配置类。
  const LocalDatabaseConfig._();

  /// 数据库文件名。
  static const String databaseName = 'bujuan_library';

  /// 当前数据库 schema 版本。
  static const int schemaVersion = 5;
}
