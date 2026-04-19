import 'package:bujuan/data/local/local_resource_index_data_source.dart';
import 'package:bujuan/domain/entities/local_resource_entry.dart';
import 'package:bujuan/data/local/persistent_local_resource_index_data_source.dart';
import 'package:get_it/get_it.dart';

class LocalResourceIndexStore {
  LocalResourceIndexStore({
    LocalResourceIndexDataSource? dataSource,
  }) : _dataSource = dataSource ??
            (GetIt.instance.isRegistered<LocalResourceIndexDataSource>()
                ? GetIt.instance<LocalResourceIndexDataSource>()
                : const PersistentLocalResourceIndexDataSource());

  final LocalResourceIndexDataSource _dataSource;

  Future<LocalResourceEntry?> getResource(
    String trackId,
    LocalResourceKind kind,
  ) async {
    return _dataSource.getResource(trackId, kind);
  }

  Future<List<LocalResourceEntry>> getTrackResources(String trackId) async {
    return _dataSource.getTrackResources(trackId);
  }

  Future<void> saveResource(LocalResourceEntry entry) {
    return _dataSource.saveResource(entry);
  }

  Future<void> removeResource(String trackId, LocalResourceKind kind) {
    return _dataSource.removeResource(trackId, kind);
  }

  Future<void> removeTrackResources(String trackId) {
    return _dataSource.removeTrackResources(trackId);
  }
}
