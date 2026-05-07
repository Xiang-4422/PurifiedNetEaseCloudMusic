import 'package:bujuan/data/app_storage/app_preferences.dart';

/// 持久化应用设置和轻量偏好，避免控制器直接触碰 Hive/CacheBox。
class SettingsRepository {
  /// 创建设置仓库。
  const SettingsRepository({required AppPreferences preferences}) : _preferences = preferences;

  final AppPreferences _preferences;

  /// 是否启用渐变背景。
  bool get isGradientBackgroundEnabled => _preferences.isGradientBackgroundEnabled;

  /// 是否启用圆形专辑封面。
  bool get isRoundAlbumEnabled => _preferences.isRoundAlbumEnabled;

  /// 是否优先使用高音质播放地址。
  bool get isHighSoundQualityEnabled => _preferences.isHighSoundQualityEnabled;

  /// 保存渐变背景开关。
  Future<void> saveGradientBackgroundEnabled(bool value) {
    return _preferences.saveGradientBackgroundEnabled(value);
  }

  /// 保存圆形专辑封面开关。
  Future<void> saveRoundAlbumEnabled(bool value) {
    return _preferences.saveRoundAlbumEnabled(value);
  }

  /// 保存高音质播放开关。
  Future<void> saveHighSoundQualityEnabled(bool value) {
    return _preferences.saveHighSoundQualityEnabled(value);
  }
}
