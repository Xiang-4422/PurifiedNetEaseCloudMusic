import 'package:bujuan/common/constants/key.dart';
import 'package:bujuan/core/storage/cache_box_storage_adapter.dart';
import 'package:bujuan/core/storage/key_value_storage_adapter.dart';
import 'package:get_it/get_it.dart';

class LibraryPreferenceStore {
  LibraryPreferenceStore({
    KeyValueStorageAdapter? storageAdapter,
  }) : _storageAdapter = storageAdapter ??
            (GetIt.instance.isRegistered<KeyValueStorageAdapter>()
                ? GetIt.instance<KeyValueStorageAdapter>()
                : const CacheBoxStorageAdapter());

  final KeyValueStorageAdapter _storageAdapter;

  bool get isOfflineModeEnabled =>
      _storageAdapter.get<bool>(offlineModeSp, defaultValue: false) ?? false;

  Future<void> saveOfflineMode(bool value) {
    return _storageAdapter.put(offlineModeSp, value);
  }
}
