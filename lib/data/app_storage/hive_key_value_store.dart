import 'app_key_value_store.dart';
import 'cache_box.dart';

/// 基于 Hive `CacheBox` 的轻量 key-value 存储实现。
class HiveKeyValueStore implements AppKeyValueStore {
  /// 创建 Hive key-value 存储。
  const HiveKeyValueStore();

  @override
  Object? get(String key, {Object? defaultValue}) {
    return CacheBox.instance.get(key, defaultValue: defaultValue);
  }

  @override
  Future<void> put(String key, Object? value) {
    return CacheBox.instance.put(key, value);
  }

  @override
  Future<void> delete(String key) {
    return CacheBox.instance.delete(key);
  }
}
