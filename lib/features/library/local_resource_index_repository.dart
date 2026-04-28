import 'dart:io';

import 'package:bujuan/data/local/local_resource_index_data_source.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/domain/entities/local_song_entry.dart';
import 'package:bujuan/domain/entities/local_resource_entry.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_resource_bundle.dart';
import 'package:get_it/get_it.dart';

class LocalResourceIndexRepository {
  LocalResourceIndexRepository({
    LocalResourceIndexDataSource? dataSource,
    LocalLibraryDataSource? localLibraryDataSource,
  }) : _dataSource = dataSource ??
            (GetIt.instance.isRegistered<LocalResourceIndexDataSource>()
                ? GetIt.instance<LocalResourceIndexDataSource>()
                : (throw StateError(
                    'LocalResourceIndexDataSource is not registered',
                  ))),
        _localLibraryDataSource =
            localLibraryDataSource ??
            (GetIt.instance.isRegistered<LocalLibraryDataSource>()
                ? GetIt.instance<LocalLibraryDataSource>()
                : (throw StateError(
                    'LocalLibraryDataSource is not registered',
                  )));

  final LocalResourceIndexDataSource _dataSource;
  final LocalLibraryDataSource _localLibraryDataSource;

  Future<LocalResourceEntry?> getPrimaryAudioResource(String trackId) {
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

  Future<TrackResourceBundle> getTrackResourceBundle(String trackId) async {
    final resources = await _dataSource.getTrackResources(trackId);
    return _toBundle(resources);
  }

  Future<Map<String, TrackResourceBundle>> getTrackResourceBundles(
    Iterable<String> trackIds,
  ) async {
    final resourcesByTrackId = await _dataSource.getTrackResourcesByIds(trackIds);
    return resourcesByTrackId.map(
      (trackId, resources) => MapEntry(trackId, _toBundle(resources)),
    );
  }

  Future<List<LocalSongEntry>> listLocalSongs({
    Set<TrackResourceOrigin>? origins,
  }) async {
    final audioResources = await _dataSource.listAudioResources(origins: origins);
    if (audioResources.isEmpty) {
      return const [];
    }
    final trackIds = audioResources.map((item) => item.trackId).toList();
    final tracks = await _localLibraryDataSource.getTracksByIds(trackIds);
    if (tracks.isEmpty) {
      return const [];
    }
    final tracksById = {
      for (final track in tracks) track.id: track,
    };
    final resourcesByTrackId = await getTrackResourceBundles(trackIds);
    final entries = <LocalSongEntry>[];
    for (final audioResource in audioResources) {
      final track = tracksById[audioResource.trackId];
      if (track == null) {
        continue;
      }
      final bundle =
          resourcesByTrackId[audioResource.trackId] ?? const TrackResourceBundle();
      final totalSizeBytes = [
        bundle.audio?.sizeBytes ?? 0,
        bundle.artwork?.sizeBytes ?? 0,
        bundle.lyrics?.sizeBytes ?? 0,
      ].fold<int>(0, (sum, value) => sum + value);
      entries.add(
        LocalSongEntry(
          track: track,
          resources: bundle,
          origin: audioResource.origin,
          totalSizeBytes: totalSizeBytes,
        ),
      );
    }
    entries.sort(
      (left, right) => left.track.title.toLowerCase().compareTo(
            right.track.title.toLowerCase(),
          ),
    );
    return entries;
  }

  Future<void> saveAudioResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) {
    return _saveResource(
      trackId,
      kind: LocalResourceKind.audio,
      path: path,
      origin: origin,
    );
  }

  Future<void> saveArtworkResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) {
    return _saveResource(
      trackId,
      kind: LocalResourceKind.artwork,
      path: path,
      origin: origin,
    );
  }

  Future<void> saveLyricsResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) {
    return _saveResource(
      trackId,
      kind: LocalResourceKind.lyrics,
      path: path,
      origin: origin,
    );
  }

  Future<void> touchResource(String trackId, LocalResourceKind kind) {
    return _dataSource.touchResource(
      trackId,
      kind,
      accessedAt: DateTime.now(),
    );
  }

  Future<void> removeTrackResources(String trackId) {
    return _dataSource.removeTrackResources(trackId);
  }

  Future<void> removeResourcesByOrigin(TrackResourceOrigin origin) {
    return _dataSource.removeResourcesByOrigin(origin);
  }

  Future<void> _saveResource(
    String trackId, {
    required LocalResourceKind kind,
    required String path,
    required TrackResourceOrigin origin,
  }) async {
    final now = DateTime.now();
    final existing = await _dataSource.getResource(trackId, kind);
    final file = File(path);
    final sizeBytes = file.existsSync() ? await file.length() : 0;
    await _dataSource.saveResource(
      LocalResourceEntry(
        trackId: trackId,
        kind: kind,
        path: path,
        origin: origin,
        sizeBytes: sizeBytes,
        createdAt: existing?.createdAt ?? now,
        lastAccessedAt: now,
      ),
    );
  }

  TrackResourceBundle _toBundle(List<LocalResourceEntry> resources) {
    LocalResourceEntry? audio;
    LocalResourceEntry? artwork;
    LocalResourceEntry? lyrics;
    for (final resource in resources) {
      switch (resource.kind) {
        case LocalResourceKind.audio:
          audio = resource;
          break;
        case LocalResourceKind.artwork:
          artwork = resource;
          break;
        case LocalResourceKind.lyrics:
          lyrics = resource;
          break;
      }
    }
    return TrackResourceBundle(
      audio: audio,
      artwork: artwork,
      lyrics: lyrics,
    );
  }
}
