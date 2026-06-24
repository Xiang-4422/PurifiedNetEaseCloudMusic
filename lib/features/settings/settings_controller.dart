import 'package:bujuan/features/settings/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 管理应用设置和轻量 UI 偏好状态。
class SettingsController extends GetxController {
  /// 创建设置控制器。
  SettingsController({required SettingsRepository repository}) : _repository = repository;

  final SettingsRepository _repository;

  /// 是否启用渐变背景。
  RxBool isGradientBackground = false.obs;

  /// 是否启用圆形专辑封面。
  RxBool isRoundAlbumOpen = false.obs;

  /// 是否优先使用高音质播放地址。
  RxBool isHighSoundQualityOpen = false.obs;

  /// 当前专辑封面主色。
  Rx<Color> albumColor = Colors.white.obs;

  /// 当前播放面板派生颜色。
  Rx<Color> panelWidgetColor = Colors.white.obs;

  @override
  void onInit() {
    super.onInit();
    _initAppSetting();
  }

  void _initAppSetting() {
    isGradientBackground.value = _repository.isGradientBackgroundEnabled;
    isHighSoundQualityOpen.value = _repository.isHighSoundQualityEnabled;
    isRoundAlbumOpen.value = _repository.isRoundAlbumEnabled;
  }

  /// 切换渐变背景设置。
  Future<void> toggleGradientBackground() async {
    final nextValue = !isGradientBackground.value;
    isGradientBackground.value = nextValue;
    await _repository.saveGradientBackgroundEnabled(nextValue);
  }

  /// 切换圆形专辑封面设置。
  Future<void> toggleRoundAlbumOpen() async {
    final nextValue = !isRoundAlbumOpen.value;
    isRoundAlbumOpen.value = nextValue;
    await _repository.saveRoundAlbumEnabled(nextValue);
  }

  /// 切换高音质播放设置。
  Future<void> toggleHighSoundQualityOpen() async {
    final nextValue = !isHighSoundQualityOpen.value;
    isHighSoundQualityOpen.value = nextValue;
    await _repository.saveHighSoundQualityEnabled(nextValue);
  }
}
