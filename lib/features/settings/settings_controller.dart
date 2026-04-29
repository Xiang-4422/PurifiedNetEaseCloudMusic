import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:bujuan/features/library/library_preference_store.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

/// SettingsController。
class SettingsController extends GetxController {
  /// to。
  static SettingsController get to => Get.find();

  /// box。
  final Box box = CacheBox.instance;
  final LibraryPreferenceStore _libraryPreferenceStore =
      const LibraryPreferenceStore();

  /// isGradientBackground。
  RxBool isGradientBackground = false.obs;

  /// isRoundAlbumOpen。
  RxBool isRoundAlbumOpen = false.obs;

  /// isHighSoundQualityOpen。
  RxBool isHighSoundQualityOpen = false.obs;

  /// isOfflineModeEnabled。
  RxBool isOfflineModeEnabled = false.obs;

  /// albumColor。
  Rx<Color> albumColor = Colors.white.obs;

  /// panelWidgetColor。
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

  /// toggleGradientBackground。
  Future<void> toggleGradientBackground() async {
    await _updateBoolSetting(
      target: isGradientBackground,
      key: gradientBackgroundSp,
    );
  }

  /// toggleRoundAlbumOpen。
  Future<void> toggleRoundAlbumOpen() async {
    await _updateBoolSetting(
      target: isRoundAlbumOpen,
      key: roundAlbumSp,
    );
  }

  /// toggleHighSoundQualityOpen。
  Future<void> toggleHighSoundQualityOpen() async {
    await _updateBoolSetting(
      target: isHighSoundQualityOpen,
      key: highSong,
    );
  }

  /// toggleOfflineMode。
  Future<void> toggleOfflineMode() async {
    final nextValue = !isOfflineModeEnabled.value;
    isOfflineModeEnabled.value = nextValue;
    await _libraryPreferenceStore.saveOfflineMode(nextValue);
  }

  /// updateLoginStatus。
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
