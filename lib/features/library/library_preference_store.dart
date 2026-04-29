import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';

/// LibraryPreferenceStore。
class LibraryPreferenceStore {
  /// 创建 LibraryPreferenceStore。
  const LibraryPreferenceStore();

  /// isOfflineModeEnabled。
  bool get isOfflineModeEnabled =>
      CacheBox.instance.get(offlineModeSp, defaultValue: false) ?? false;

  /// saveOfflineMode。
  Future<void> saveOfflineMode(bool value) {
    return CacheBox.instance.put(offlineModeSp, value);
  }
}
