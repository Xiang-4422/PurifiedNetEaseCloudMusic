/// 数据库集合的版本和职责说明。
class DatabaseCollectionSchema {
  /// 创建数据库集合说明。
  const DatabaseCollectionSchema({
    required this.name,
    required this.version,
    required this.description,
  });

  /// 集合或表组名称。
  final String name;

  /// 集合版本。
  final int version;

  /// 集合职责描述。
  final String description;
}
