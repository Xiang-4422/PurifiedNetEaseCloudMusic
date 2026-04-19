import 'package:bujuan/core/storage/cache_box.dart';

import 'key_value_storage_adapter.dart';

class CacheBoxStorageAdapter implements KeyValueStorageAdapter {
  const CacheBoxStorageAdapter();

  @override
  T? get<T>(String key, {T? defaultValue}) {
    return CacheBox.instance.get(key, defaultValue: defaultValue) as T?;
  }

  @override
  Future<void> put<T>(String key, T value) {
    return CacheBox.instance.put(key, value);
  }
}
