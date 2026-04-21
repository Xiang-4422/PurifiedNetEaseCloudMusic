import 'cache_box.dart';

class CacheTimestampStore {
  const CacheTimestampStore();

  DateTime? load(String key) {
    final raw = CacheBox.instance.get(key);
    if (raw is! int || raw <= 0) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }

  bool isFresh(
    String key, {
    required Duration ttl,
  }) {
    final updatedAt = load(key);
    if (updatedAt == null) {
      return false;
    }
    return DateTime.now().difference(updatedAt) < ttl;
  }

  Future<void> markUpdated(String key) {
    return CacheBox.instance.put(
      key,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> clear(String key) {
    return CacheBox.instance.delete(key);
  }
}
