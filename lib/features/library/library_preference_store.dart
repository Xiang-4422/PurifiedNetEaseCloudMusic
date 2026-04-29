import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';

/// 保存资料库相关轻量偏好。
class LibraryPreferenceStore {
  /// 创建资料库偏好存储。
  const LibraryPreferenceStore();

  /// 是否启用离线模式。
  bool get isOfflineModeEnabled =>
      CacheBox.instance.get(offlineModeSp, defaultValue: false) ?? false;

  /// 保存离线模式开关。
  Future<void> saveOfflineMode(bool value) {
    return CacheBox.instance.put(offlineModeSp, value);
  }
}
