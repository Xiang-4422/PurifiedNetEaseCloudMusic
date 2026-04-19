abstract class KeyValueStorageAdapter {
  const KeyValueStorageAdapter();

  T? get<T>(String key, {T? defaultValue});

  Future<void> put<T>(String key, T value);
}
