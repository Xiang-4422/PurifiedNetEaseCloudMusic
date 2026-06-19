/// 应用轻量 key-value 存储边界。
abstract interface class AppKeyValueStore {
  /// 读取指定 key。
  Object? get(String key, {Object? defaultValue});

  /// 写入指定 key。
  Future<void> put(String key, Object? value);

  /// 删除指定 key。
  Future<void> delete(String key);
}
