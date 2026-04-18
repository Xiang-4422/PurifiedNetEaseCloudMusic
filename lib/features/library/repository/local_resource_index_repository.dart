import 'package:bujuan/domain/entities/local_resource_entry.dart';
import 'package:bujuan/domain/entities/track.dart';

import 'local_resource_index_store.dart';

class LocalResourceIndexRepository {
  const LocalResourceIndexRepository({
    LocalResourceIndexStore store = const LocalResourceIndexStore(),
  }) : _store = store;

  final LocalResourceIndexStore _store;

  Future<LocalResourceEntry?> getAudioResource(String trackId) {
    return _store.getResource(trackId, LocalResourceKind.audio);
  }

  Future<LocalResourceEntry?> getArtworkResource(String trackId) {
    return _store.getResource(trackId, LocalResourceKind.artwork);
  }

  Future<LocalResourceEntry?> getLyricsResource(String trackId) {
    return _store.getResource(trackId, LocalResourceKind.lyrics);
  }

  Future<List<LocalResourceEntry>> getTrackResources(String trackId) {
    return _store.getTrackResources(trackId);
  }

  Future<void> saveAudioResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) {
    return _store.saveResource(
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
    return _store.saveResource(
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
    return _store.saveResource(
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
    return _store.removeTrackResources(trackId);
  }
}
