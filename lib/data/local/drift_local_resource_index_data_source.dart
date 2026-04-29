import 'package:bujuan/domain/entities/local_resource_entry.dart';
import 'package:bujuan/domain/entities/track.dart';

import 'dao/resource_dao.dart';
import 'local_resource_index_data_source.dart';

class DriftLocalResourceIndexDataSource
    implements LocalResourceIndexDataSource {
  DriftLocalResourceIndexDataSource({required ResourceDao dao}) : _dao = dao;

  final ResourceDao _dao;

  @override
  Future<LocalResourceEntry?> getResource(
    String trackId,
    LocalResourceKind kind,
  ) {
    return _dao.getResource(trackId, kind);
  }

  @override
  Future<List<LocalResourceEntry>> getTrackResources(String trackId) {
    return _dao.getTrackResources(trackId);
  }

  @override
  Future<Map<String, List<LocalResourceEntry>>> getTrackResourcesByIds(
    Iterable<String> trackIds,
  ) {
    return _dao.getTrackResourcesByIds(trackIds);
  }

  @override
  Future<List<LocalResourceEntry>> listAudioResources({
    Set<TrackResourceOrigin>? origins,
  }) {
    return _dao.listAudioResources(origins: origins);
  }

  @override
  Future<void> saveResource(LocalResourceEntry entry) {
    return _dao.saveResource(entry);
  }

  @override
  Future<void> touchResource(
    String trackId,
    LocalResourceKind kind, {
    required DateTime accessedAt,
  }) {
    return _dao.touchResource(trackId, kind, accessedAt: accessedAt);
  }

  @override
  Future<void> removeResource(String trackId, LocalResourceKind kind) {
    return _dao.removeResource(trackId, kind);
  }

  @override
  Future<void> removeTrackResources(String trackId) {
    return _dao.removeTrackResources(trackId);
  }

  @override
  Future<void> removeResourcesByOrigin(TrackResourceOrigin origin) {
    return _dao.removeResourcesByOrigin(origin);
  }
}
