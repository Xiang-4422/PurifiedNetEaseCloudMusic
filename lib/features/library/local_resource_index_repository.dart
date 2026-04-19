import 'package:bujuan/data/local/in_memory_local_resource_index_data_source.dart';
import 'package:bujuan/data/local/local_resource_index_data_source.dart';
import 'package:bujuan/domain/entities/local_resource_entry.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:get_it/get_it.dart';

class LocalResourceIndexRepository {
  LocalResourceIndexRepository({
    LocalResourceIndexDataSource? dataSource,
  }) : _dataSource = dataSource ??
            (GetIt.instance.isRegistered<LocalResourceIndexDataSource>()
                ? GetIt.instance<LocalResourceIndexDataSource>()
                : const InMemoryLocalResourceIndexDataSource());

  final LocalResourceIndexDataSource _dataSource;

  Future<LocalResourceEntry?> getAudioResource(String trackId) {
    return _dataSource.getResource(trackId, LocalResourceKind.audio);
  }

  Future<LocalResourceEntry?> getArtworkResource(String trackId) {
    return _dataSource.getResource(trackId, LocalResourceKind.artwork);
  }

  Future<LocalResourceEntry?> getLyricsResource(String trackId) {
    return _dataSource.getResource(trackId, LocalResourceKind.lyrics);
  }

  Future<List<LocalResourceEntry>> getTrackResources(String trackId) {
    return _dataSource.getTrackResources(trackId);
  }

  Future<void> saveAudioResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) {
    return _dataSource.saveResource(
      LocalResourceEntry(
        trackId: trackId,
        kind: LocalResourceKind.audio,
        path: path,
        origin: origin,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> saveArtworkResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) {
    return _dataSource.saveResource(
      LocalResourceEntry(
        trackId: trackId,
        kind: LocalResourceKind.artwork,
        path: path,
        origin: origin,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> saveLyricsResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) {
    return _dataSource.saveResource(
      LocalResourceEntry(
        trackId: trackId,
        kind: LocalResourceKind.lyrics,
        path: path,
        origin: origin,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> removeTrackResources(String trackId) {
    return _dataSource.removeTrackResources(trackId);
  }
}
