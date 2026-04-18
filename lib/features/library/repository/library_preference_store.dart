import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box.dart';

class LibraryPreferenceStore {
  const LibraryPreferenceStore();

  bool get isOfflineModeEnabled =>
      CacheBox.instance.get(offlineModeSp, defaultValue: false) ?? false;

  Future<void> saveOfflineMode(bool value) {
    return CacheBox.instance.put(offlineModeSp, value);
  }
}
