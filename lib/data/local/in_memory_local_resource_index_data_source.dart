import 'package:bujuan/domain/entities/local_resource_entry.dart';

import 'local_resource_index_data_source.dart';

class InMemoryLocalResourceIndexDataSource
    implements LocalResourceIndexDataSource {
  const InMemoryLocalResourceIndexDataSource();

  static final Map<String, LocalResourceEntry> _entries = {};

  @override
  Future<LocalResourceEntry?> getResource(
    String trackId,
    LocalResourceKind kind,
  ) async {
    return _entries[_buildKey(trackId, kind)];
  }

  @override
  Future<List<LocalResourceEntry>> getTrackResources(String trackId) async {
    return _entries.values
        .where((entry) => entry.trackId == trackId)
        .toList()
      ..sort((left, right) => left.kind.index.compareTo(right.kind.index));
  }

  @override
  Future<void> saveResource(LocalResourceEntry entry) async {
    _entries[_buildKey(entry.trackId, entry.kind)] = entry;
  }

  @override
  Future<void> removeResource(String trackId, LocalResourceKind kind) async {
    _entries.remove(_buildKey(trackId, kind));
  }

  @override
  Future<void> removeTrackResources(String trackId) async {
    _entries.removeWhere((key, _) => key.startsWith('$trackId::'));
  }

  String _buildKey(String trackId, LocalResourceKind kind) {
    return '$trackId::${kind.name}';
  }
}
