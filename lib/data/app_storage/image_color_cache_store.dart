import 'dart:async';

import 'app_key_value_store.dart';
import 'hive_key_value_store.dart';

/// 图片主色缓存存储。
class ImageColorCacheStore {
  /// 创建图片主色缓存存储。
  const ImageColorCacheStore({
    AppKeyValueStore keyValueStore = const HiveKeyValueStore(),
  }) : _keyValueStore = keyValueStore;

  final AppKeyValueStore _keyValueStore;

  /// 读取图片主色缓存。
  int? load({
    required String imageUrl,
    required bool getLightColor,
  }) {
    final raw = _keyValueStore.get(_colorKey(
      imageUrl: imageUrl,
      getLightColor: getLightColor,
    ));
    if (raw is! int) {
      return null;
    }
    _touchAccessAfterLoad(imageUrl);
    return raw;
  }

  /// 保存图片主色缓存。
  Future<void> save({
    required String imageUrl,
    required bool getLightColor,
    required int argb32,
  }) async {
    await _keyValueStore.put(
      _colorKey(
        imageUrl: imageUrl,
        getLightColor: getLightColor,
      ),
      argb32,
    );
    await _touchAccess(imageUrl);
    await _pruneCaches();
  }

  /// 清理指定图片的主色缓存。
  Future<void> clear(String imageUrl) async {
    await _keyValueStore.delete(
      _colorKey(imageUrl: imageUrl, getLightColor: true),
    );
    await _keyValueStore.delete(
      _colorKey(imageUrl: imageUrl, getLightColor: false),
    );
    await _deleteAccess(imageUrl);
  }

  String _colorKey({
    required String imageUrl,
    required bool getLightColor,
  }) {
    final tone = getLightColor ? 'LIGHT' : 'DARK';
    return 'IMAGE_COLOR_${tone}_${Uri.encodeComponent(imageUrl)}';
  }

  Future<void> _touchAccess(String imageUrl) async {
    final raw = _keyValueStore.get(_accessKey);
    final accessMap = <String, int>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        accessMap['${entry.key}'] = entry.value is int ? entry.value as int : 0;
      }
    }
    accessMap[imageUrl] = DateTime.now().millisecondsSinceEpoch;
    await _keyValueStore.put(_accessKey, accessMap);
  }

  void _touchAccessAfterLoad(String imageUrl) {
    unawaited(
      _touchAccess(imageUrl).catchError((_) {
        // 读取命中后刷新 LRU 失败不能影响已命中的颜色值。
      }),
    );
  }

  Future<void> _deleteAccess(String imageUrl) async {
    final raw = _keyValueStore.get(_accessKey);
    if (raw is! Map || !raw.containsKey(imageUrl)) {
      return;
    }
    final accessMap = <String, int>{};
    for (final entry in raw.entries) {
      final key = '${entry.key}';
      if (key == imageUrl) {
        continue;
      }
      accessMap[key] = entry.value is int ? entry.value as int : 0;
    }
    if (accessMap.isEmpty) {
      await _keyValueStore.delete(_accessKey);
      return;
    }
    await _keyValueStore.put(_accessKey, accessMap);
  }

  Future<void> _pruneCaches() async {
    final raw = _keyValueStore.get(_accessKey);
    if (raw is! Map) {
      return;
    }
    final accessEntries = raw.entries
        .map(
          (entry) => MapEntry(
            '${entry.key}',
            entry.value is int ? entry.value as int : 0,
          ),
        )
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    if (accessEntries.length <= _maxImageColorCacheCount) {
      return;
    }
    final removeCount = accessEntries.length - _maxImageColorCacheCount;
    final nextMap = <String, int>{};
    for (final entry in accessEntries.skip(removeCount)) {
      nextMap[entry.key] = entry.value;
    }
    for (final entry in accessEntries.take(removeCount)) {
      await clear(entry.key);
    }
    await _keyValueStore.put(_accessKey, nextMap);
  }

  static const String _accessKey = 'IMAGE_COLOR_CACHE_LAST_ACCESS';
  static const int _maxImageColorCacheCount = 300;
}
