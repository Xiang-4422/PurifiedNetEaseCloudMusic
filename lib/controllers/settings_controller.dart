import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  final Box box = CacheBox.instance;

  RxBool isGradientBackground = false.obs;
  RxBool isRoundAlbumOpen = false.obs;
  RxBool isCacheOpen = false.obs;
  RxBool isHighSoundQualityOpen = false.obs;
  Rx<Color> albumColor = Colors.white.obs;
  Rx<Color> panelWidgetColor = Colors.white.obs;

  @override
  void onInit() {
    super.onInit();
    _initAppSetting();
  }

  void _initAppSetting() {
    isCacheOpen.value = box.get(cacheSp, defaultValue: false);
    isGradientBackground.value =
        box.get(gradientBackgroundSp, defaultValue: true);
    isHighSoundQualityOpen.value = box.get(highSong, defaultValue: false);
    isRoundAlbumOpen.value = box.get(roundAlbumSp, defaultValue: false);
  }

  Future<void> toggleGradientBackground() async {
    await _updateBoolSetting(
      target: isGradientBackground,
      key: gradientBackgroundSp,
    );
  }

  Future<void> toggleRoundAlbumOpen() async {
    await _updateBoolSetting(
      target: isRoundAlbumOpen,
      key: roundAlbumSp,
    );
  }

  Future<void> toggleHighSoundQualityOpen() async {
    await _updateBoolSetting(
      target: isHighSoundQualityOpen,
      key: highSong,
    );
  }

  Future<void> toggleCacheOpen() async {
    await _updateBoolSetting(
      target: isCacheOpen,
      key: cacheSp,
    );
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
