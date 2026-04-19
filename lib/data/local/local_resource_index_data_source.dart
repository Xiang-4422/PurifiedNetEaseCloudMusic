import 'package:bujuan/domain/entities/local_resource_entry.dart';

abstract class LocalResourceIndexDataSource {
  Future<LocalResourceEntry?> getResource(
    String trackId,
    LocalResourceKind kind,
  );

  Future<List<LocalResourceEntry>> getTrackResources(String trackId);

  Future<void> saveResource(LocalResourceEntry entry);

  Future<void> removeResource(String trackId, LocalResourceKind kind);

  Future<void> removeTrackResources(String trackId);
}
