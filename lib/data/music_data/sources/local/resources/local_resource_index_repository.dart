import 'dart:io';

import 'package:bujuan/data/music_data/sources/local/database/data_sources/local_resource_index_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/local_library_data_source.dart';
import 'package:bujuan/core/entities/local_song_entry.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';
import 'package:bujuan/core/util/track_resource_availability.dart';

/// 管理曲目本地音频、封面和歌词资源索引。
class LocalResourceIndexRepository {
  /// 创建本地资源索引仓库。
  LocalResourceIndexRepository({
    required LocalResourceIndexDataSource dataSource,
    required LocalLibraryDataSource localLibraryDataSource,
  })  : _dataSource = dataSource,
        _localLibraryDataSource = localLibraryDataSource;

  final LocalResourceIndexDataSource _dataSource;
  final LocalLibraryDataSource _localLibraryDataSource;

  /// 读取曲目的主音频资源。
  Future<LocalResourceEntry?> getPrimaryAudioResource(String trackId) {
    return _loadUsableResource(_normalizedTrackId(trackId), LocalResourceKind.audio);
  }

  /// 读取曲目的封面资源。
  Future<LocalResourceEntry?> getArtworkResource(String trackId) {
    return _loadUsableResource(_normalizedTrackId(trackId), LocalResourceKind.artwork);
  }

  /// 读取曲目的歌词资源。
  Future<LocalResourceEntry?> getLyricsResource(String trackId) {
    return _loadUsableResource(_normalizedTrackId(trackId), LocalResourceKind.lyrics);
  }

  /// 读取曲目的所有本地资源。
  Future<List<LocalResourceEntry>> getTrackResources(String trackId) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return const [];
    }
    return _filterUsableResources(await _dataSource.getTrackResources(normalizedTrackId));
  }

  /// 读取曲目的本地资源集合。
  Future<TrackResourceBundle> getTrackResourceBundle(String trackId) async {
    final resources = await getTrackResources(trackId);
    return _toBundle(resources);
  }

  /// 批量读取多个曲目的本地资源集合。
  Future<Map<String, TrackResourceBundle>> getTrackResourceBundles(
    Iterable<String> trackIds,
  ) async {
    final candidateTrackIds = _candidateTrackIds(trackIds);
    if (candidateTrackIds.isEmpty) {
      return const {};
    }
    final resourcesByTrackId = await _dataSource.getTrackResourcesByIds(candidateTrackIds);
    final result = <String, TrackResourceBundle>{};
    for (final entry in resourcesByTrackId.entries) {
      result[entry.key] = _toBundle(
        await _filterUsableResources(entry.value),
      );
    }
    return result;
  }

  /// 列出已登记音频资源的本地歌曲。
  Future<List<LocalSongEntry>> listLocalSongs({
    Set<TrackResourceOrigin>? origins,
  }) async {
    final audioResources = await _filterUsableResources(
      await _dataSource.listAudioResources(origins: origins),
    );
    if (audioResources.isEmpty) {
      return const [];
    }
    final trackIds = audioResources.map((item) => item.trackId).toList();
    final tracks = await _localLibraryDataSource.getTracksByIds(trackIds);
    final tracksById = {
      for (final track in tracks) track.id: track,
    };
    final missingTrackIds = trackIds.where((trackId) => !tracksById.containsKey(trackId)).toSet();
    for (final trackId in missingTrackIds) {
      await _dataSource.removeTrackResources(trackId);
    }
    final existingTrackIds = trackIds.where((trackId) => tracksById.containsKey(trackId)).toList();
    if (existingTrackIds.isEmpty) {
      return const [];
    }
    final resourcesByTrackId = await getTrackResourceBundles(existingTrackIds);
    final entries = <LocalSongEntry>[];
    for (final audioResource in audioResources) {
      final track = tracksById[audioResource.trackId];
      if (track == null) {
        continue;
      }
      final bundle = resourcesByTrackId[audioResource.trackId] ?? const TrackResourceBundle();
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

  /// 列出仍可用的本地资源，可按来源和类型过滤。
  Future<List<LocalResourceEntry>> listResources({
    Set<TrackResourceOrigin>? origins,
    Set<LocalResourceKind>? kinds,
  }) async {
    return _filterUsableResources(
      await _dataSource.listResources(origins: origins, kinds: kinds),
    );
  }

  /// 保存曲目的音频资源索引。
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

  /// 保存曲目的封面资源索引。
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

  /// 保存曲目的歌词资源索引。
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

  /// 刷新资源的最近访问时间。
  Future<void> touchResource(String trackId, LocalResourceKind kind) {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return Future<void>.value();
    }
    return _dataSource.touchResource(
      normalizedTrackId,
      kind,
      accessedAt: DateTime.now(),
    );
  }

  /// 删除指定曲目的全部资源索引。
  Future<void> removeTrackResources(String trackId) {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return Future<void>.value();
    }
    return _dataSource.removeTrackResources(normalizedTrackId);
  }

  /// 删除指定曲目的指定资源索引。
  Future<void> removeResource(String trackId, LocalResourceKind kind) {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return Future<void>.value();
    }
    return _dataSource.removeResource(normalizedTrackId, kind);
  }

  /// 删除指定来源的全部资源索引。
  Future<void> removeResourcesByOrigin(TrackResourceOrigin origin) {
    return _dataSource.removeResourcesByOrigin(origin);
  }

  Future<void> _saveResource(
    String trackId, {
    required LocalResourceKind kind,
    required String path,
    required TrackResourceOrigin origin,
  }) async {
    final normalizedTrackId = _normalizedTrackId(trackId);
    if (_isBlankTrackId(normalizedTrackId)) {
      return;
    }
    final file = _resourceFile(path);
    if (file == null || !file.existsSync()) {
      return;
    }
    final now = DateTime.now();
    final existing = await _dataSource.getResource(normalizedTrackId, kind);
    if (_shouldKeepExistingResource(existing, origin)) {
      return;
    }
    final sizeBytes = await file.length();
    await _dataSource.saveResource(
      LocalResourceEntry(
        trackId: normalizedTrackId,
        kind: kind,
        path: file.path,
        origin: origin,
        sizeBytes: sizeBytes,
        createdAt: existing?.createdAt ?? now,
        lastAccessedAt: now,
      ),
    );
  }

  bool _shouldKeepExistingResource(
    LocalResourceEntry? existing,
    TrackResourceOrigin newOrigin,
  ) {
    return TrackResourceAvailability.shouldKeepExistingResource(
      existing,
      newOrigin: newOrigin,
    );
  }

  Future<LocalResourceEntry?> _loadUsableResource(
    String trackId,
    LocalResourceKind kind,
  ) async {
    if (_isBlankTrackId(trackId)) {
      return null;
    }
    final resource = await _dataSource.getResource(trackId, kind);
    if (resource == null) {
      return null;
    }
    final usable = await _usableResource(resource);
    if (usable != null) {
      return usable;
    }
    await _dataSource.removeResource(resource.trackId, resource.kind);
    return null;
  }

  Future<List<LocalResourceEntry>> _filterUsableResources(
    List<LocalResourceEntry> resources,
  ) async {
    final usable = <LocalResourceEntry>[];
    for (final resource in resources) {
      final normalized = await _usableResource(resource);
      if (normalized != null) {
        usable.add(normalized);
        continue;
      }
      await _dataSource.removeResource(resource.trackId, resource.kind);
    }
    return usable;
  }

  Future<LocalResourceEntry?> _usableResource(LocalResourceEntry resource) async {
    if (_isBlankTrackId(resource.trackId)) {
      return null;
    }
    final file = _resourceFile(resource.path);
    if (file == null || !file.existsSync()) {
      return null;
    }
    if (file.path == resource.path) {
      return resource;
    }
    final normalized = resource.copyWith(
      path: file.path,
      sizeBytes: await file.length(),
    );
    await _dataSource.saveResource(normalized);
    return normalized;
  }

  File? _resourceFile(String rawPath) {
    final path = _resourceFilePath(rawPath);
    return path.isEmpty ? null : File(path);
  }

  String _resourceFilePath(String rawPath) {
    return LocalFilePathNormalizer.normalize(rawPath);
  }

  List<String> _candidateTrackIds(Iterable<String> trackIds) {
    final seen = <String>{};
    final result = <String>[];
    for (final trackId in trackIds) {
      final normalizedTrackId = _normalizedTrackId(trackId);
      if (_isBlankTrackId(normalizedTrackId) || !seen.add(normalizedTrackId)) {
        continue;
      }
      result.add(normalizedTrackId);
    }
    return result;
  }

  String _normalizedTrackId(String trackId) {
    return trackId.trim();
  }

  bool _isBlankTrackId(String trackId) {
    return trackId.trim().isEmpty;
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
