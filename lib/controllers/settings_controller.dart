import 'package:bujuan/common/constants/key.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/adapters.dart';

/// 设置控制器
/// 负责管理应用的所有持久化设置项
class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  Box box = GetIt.instance<Box>();

  /// 是否渐变播放背景
  RxBool isGradientBackground = false.obs;

  /// 是否开启圆形专辑
  RxBool isRoundAlbumOpen = false.obs;

  /// 是否开启缓存
  RxBool isCacheOpen = false.obs;

  /// 是否开启高音质
  RxBool isHighSoundQualityOpen = false.obs;

  /// 专辑背景颜色
  Rx<Color> albumColor = Colors.white.obs;

  /// 面板组件颜色（用于适配深色/浅色专辑背景）
  Rx<Color> panelWidgetColor = Colors.white.obs;

  @override
  void onInit() {
    super.onInit();
    _initAppSetting();
  }

  /// 初始化设置
  void _initAppSetting() {
    isCacheOpen.value = box.get(cacheSp, defaultValue: false);
    isGradientBackground.value =
        box.get(gradientBackgroundSp, defaultValue: true);
    isHighSoundQualityOpen.value = box.get(highSong, defaultValue: false);
    isRoundAlbumOpen.value = box.get(roundAlbumSp, defaultValue: false);
  }
}
