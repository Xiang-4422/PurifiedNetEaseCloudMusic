import 'package:flutter/material.dart';

import 'cache_box.dart';

/// 图片主色缓存存储。
class ImageColorCacheStore {
  /// 创建图片主色缓存存储。
  const ImageColorCacheStore();

  /// 读取图片主色缓存。
  Color? load({
    required String imageUrl,
    required bool getLightColor,
  }) {
    final raw = CacheBox.instance.get(_colorKey(
      imageUrl: imageUrl,
      getLightColor: getLightColor,
    ));
    if (raw is! int) {
      return null;
    }
    return Color(raw);
  }

  /// 保存图片主色缓存。
  Future<void> save({
    required String imageUrl,
    required bool getLightColor,
    required Color color,
  }) async {
    await CacheBox.instance.put(
      _colorKey(
        imageUrl: imageUrl,
        getLightColor: getLightColor,
      ),
      color.toARGB32(),
    );
    await _touchAccess(imageUrl);
    await _pruneCaches();
  }

  /// 清理指定图片的主色缓存。
  Future<void> clear(String imageUrl) async {
    await CacheBox.instance.delete(
      _colorKey(imageUrl: imageUrl, getLightColor: true),
    );
    await CacheBox.instance.delete(
      _colorKey(imageUrl: imageUrl, getLightColor: false),
    );
  }

  String _colorKey({
    required String imageUrl,
    required bool getLightColor,
  }) {
    final tone = getLightColor ? 'LIGHT' : 'DARK';
    return 'IMAGE_COLOR_${tone}_${Uri.encodeComponent(imageUrl)}';
  }

  Future<void> _touchAccess(String imageUrl) async {
    final raw = CacheBox.instance.get(_accessKey);
    final accessMap = <String, int>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        accessMap['${entry.key}'] = entry.value is int ? entry.value as int : 0;
      }
    }
    accessMap[imageUrl] = DateTime.now().millisecondsSinceEpoch;
    await CacheBox.instance.put(_accessKey, accessMap);
  }

  Future<void> _pruneCaches() async {
    final raw = CacheBox.instance.get(_accessKey);
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
    await CacheBox.instance.put(_accessKey, nextMap);
  }

  static const String _accessKey = 'IMAGE_COLOR_CACHE_LAST_ACCESS';
  static const int _maxImageColorCacheCount = 300;
}
