import 'app_cache_keys.dart';
import 'cache_box.dart';

/// 应用轻量偏好存储。
class AppPreferences {
  /// 创建应用轻量偏好存储。
  const AppPreferences();

  /// 是否启用渐变背景。
  bool get isGradientBackgroundEnabled => CacheBox.instance.get(gradientBackgroundSp, defaultValue: true) ?? true;

  /// 是否启用圆形专辑封面。
  bool get isRoundAlbumEnabled => CacheBox.instance.get(roundAlbumSp, defaultValue: false) ?? false;

  /// 是否优先使用高音质播放地址。
  bool get isHighSoundQualityEnabled => CacheBox.instance.get(highSong, defaultValue: false) ?? false;

  /// 保存渐变背景开关。
  Future<void> saveGradientBackgroundEnabled(bool value) {
    return CacheBox.instance.put(gradientBackgroundSp, value);
  }

  /// 保存圆形专辑封面开关。
  Future<void> saveRoundAlbumEnabled(bool value) {
    return CacheBox.instance.put(roundAlbumSp, value);
  }

  /// 保存高音质播放开关。
  Future<void> saveHighSoundQualityEnabled(bool value) {
    return CacheBox.instance.put(highSong, value);
  }
}
