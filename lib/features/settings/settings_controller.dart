import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/features/library/library_preference_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

/// 管理应用设置和轻量 UI 偏好状态。
class SettingsController extends GetxController {
  /// 当前设置控制器实例。
  static SettingsController get to => Get.find();

  /// 轻量设置持久化 box。
  final Box box = CacheBox.instance;
  final LibraryPreferenceStore _libraryPreferenceStore =
      const LibraryPreferenceStore();

  /// 是否启用渐变背景。
  RxBool isGradientBackground = false.obs;

  /// 是否启用圆形专辑封面。
  RxBool isRoundAlbumOpen = false.obs;

  /// 是否优先使用高音质播放地址。
  RxBool isHighSoundQualityOpen = false.obs;

  /// 是否启用离线模式。
  RxBool isOfflineModeEnabled = false.obs;

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
    isGradientBackground.value =
        box.get(gradientBackgroundSp, defaultValue: true);
    isHighSoundQualityOpen.value = box.get(highSong, defaultValue: false);
    isRoundAlbumOpen.value = box.get(roundAlbumSp, defaultValue: false);
    isOfflineModeEnabled.value = _libraryPreferenceStore.isOfflineModeEnabled;
  }

  /// 切换渐变背景设置。
  Future<void> toggleGradientBackground() async {
    await _updateBoolSetting(
      target: isGradientBackground,
      key: gradientBackgroundSp,
    );
  }

  /// 切换圆形专辑封面设置。
  Future<void> toggleRoundAlbumOpen() async {
    await _updateBoolSetting(
      target: isRoundAlbumOpen,
      key: roundAlbumSp,
    );
  }

  /// 切换高音质播放设置。
  Future<void> toggleHighSoundQualityOpen() async {
    await _updateBoolSetting(
      target: isHighSoundQualityOpen,
      key: highSong,
    );
  }

  /// 切换离线模式。
  Future<void> toggleOfflineMode() async {
    final nextValue = !isOfflineModeEnabled.value;
    isOfflineModeEnabled.value = nextValue;
    await _libraryPreferenceStore.saveOfflineMode(nextValue);
  }

  /// 更新本地登录状态标记。
  Future<void> updateLoginStatus(bool value) async {
    await box.put(isLoginSP, value);
  }

  Future<void> _updateBoolSetting({
    required RxBool target,
    required String key,
  }) async {
    final nextValue = !target.value;
    target.value = nextValue;
    await box.put(key, nextValue);
  }
}
