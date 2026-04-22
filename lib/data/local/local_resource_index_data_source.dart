import 'package:bujuan/domain/entities/track.dart';

import 'package:bujuan/domain/entities/local_resource_entry.dart';

abstract class LocalResourceIndexDataSource {
  Future<LocalResourceEntry?> getResource(
    String trackId,
    LocalResourceKind kind,
  );

  Future<List<LocalResourceEntry>> getTrackResources(String trackId);

  Future<Map<String, List<LocalResourceEntry>>> getTrackResourcesByIds(
    Iterable<String> trackIds,
  );

  Future<List<LocalResourceEntry>> listAudioResources({
    Set<TrackResourceOrigin>? origins,
  });

  Future<void> saveResource(LocalResourceEntry entry);

  Future<void> touchResource(
    String trackId,
    LocalResourceKind kind, {
    required DateTime accessedAt,
  });

  Future<void> removeResource(String trackId, LocalResourceKind kind);

  Future<void> removeTrackResources(String trackId);

  Future<void> removeResourcesByOrigin(TrackResourceOrigin origin);
}
