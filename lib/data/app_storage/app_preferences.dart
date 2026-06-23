import 'app_cache_keys.dart';
import 'app_key_value_store.dart';
import 'hive_key_value_store.dart';

/// 应用轻量偏好存储。
class AppPreferences {
  /// 创建应用轻量偏好存储。
  const AppPreferences({
    AppKeyValueStore keyValueStore = const HiveKeyValueStore(),
  }) : _keyValueStore = keyValueStore;

  final AppKeyValueStore _keyValueStore;

  /// 是否启用渐变背景。
  bool get isGradientBackgroundEnabled => _keyValueStore.get(gradientBackgroundKey, defaultValue: true) == true;

  /// 是否启用圆形专辑封面。
  bool get isRoundAlbumEnabled => _keyValueStore.get(roundAlbumKey, defaultValue: false) == true;

  /// 是否优先使用高音质播放地址。
  bool get isHighSoundQualityEnabled => _keyValueStore.get(highSoundQualityKey, defaultValue: false) == true;

  /// 保存渐变背景开关。
  Future<void> saveGradientBackgroundEnabled(bool value) {
    return _keyValueStore.put(gradientBackgroundKey, value);
  }

  /// 保存圆形专辑封面开关。
  Future<void> saveRoundAlbumEnabled(bool value) {
    return _keyValueStore.put(roundAlbumKey, value);
  }

  /// 保存高音质播放开关。
  Future<void> saveHighSoundQualityEnabled(bool value) {
    return _keyValueStore.put(highSoundQualityKey, value);
  }
}
