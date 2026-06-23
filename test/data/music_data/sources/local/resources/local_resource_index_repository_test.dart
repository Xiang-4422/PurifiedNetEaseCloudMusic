import 'dart:io';

import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/local_resource_entry.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_lyrics.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/local_library_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/local_resource_index_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalResourceIndexRepository', () {
    late Directory tempDirectory;
    late _InMemoryResourceIndexDataSource dataSource;
    late LocalResourceIndexRepository repository;

    setUp(() async {
      tempDirectory = await Directory.systemTemp.createTemp('local-resource-index-');
      dataSource = _InMemoryResourceIndexDataSource();
      repository = LocalResourceIndexRepository(
        dataSource: dataSource,
        localLibraryDataSource: _FakeLocalLibraryDataSource(),
      );
    });

    tearDown(() async {
      if (tempDirectory.existsSync()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    test('keeps existing higher priority audio resource when lower priority cache is saved', () async {
      final managedFile = await _writeTempFile(tempDirectory, 'managed.flac');
      final cacheFile = await _writeTempFile(tempDirectory, 'cache.mp3');

      await repository.saveAudioResource(
        'netease:1',
        path: managedFile.path,
        origin: TrackResourceOrigin.managedDownload,
      );
      await repository.saveAudioResource(
        'netease:1',
        path: cacheFile.path,
        origin: TrackResourceOrigin.playbackCache,
      );

      final resource = await repository.getPrimaryAudioResource('netease:1');
      expect(resource?.path, managedFile.path);
      expect(resource?.origin, TrackResourceOrigin.managedDownload);
    });

    test('allows higher priority resource to replace playback cache', () async {
      final cacheFile = await _writeTempFile(tempDirectory, 'cache.mp3');
      final localFile = await _writeTempFile(tempDirectory, 'local.flac');

      await repository.saveAudioResource(
        'netease:1',
        path: cacheFile.path,
        origin: TrackResourceOrigin.playbackCache,
      );
      await repository.saveAudioResource(
        'netease:1',
        path: localFile.path,
        origin: TrackResourceOrigin.localImport,
      );

      final resource = await repository.getPrimaryAudioResource('netease:1');
      expect(resource?.path, localFile.path);
      expect(resource?.origin, TrackResourceOrigin.localImport);
    });

    test('normalizes file uri paths when saving resources', () async {
      final localFile = await _writeTempFile(tempDirectory, 'local with space.flac');

      await repository.saveAudioResource(
        'netease:1',
        path: localFile.uri.replace(queryParameters: {'token': 'local'}).toString(),
        origin: TrackResourceOrigin.localImport,
      );

      final resource = await repository.getPrimaryAudioResource('netease:1');
      expect(resource?.path, localFile.path);
      expect(resource?.sizeBytes, await localFile.length());
      expect(
        (await dataSource.getResource('netease:1', LocalResourceKind.audio))?.path,
        localFile.path,
      );
    });

    test('accepts localhost file uri authority when saving resources', () async {
      final localFile = await _writeTempFile(tempDirectory, 'localhost.flac');

      await repository.saveAudioResource(
        'netease:1',
        path: Uri(
          scheme: 'file',
          host: 'localhost',
          path: localFile.path,
          queryParameters: {'token': 'local'},
        ).toString(),
        origin: TrackResourceOrigin.localImport,
      );

      final resource = await repository.getPrimaryAudioResource('netease:1');
      expect(resource?.path, localFile.path);
    });

    test('rejects non-localhost file uri authority when saving resources', () async {
      final localFile = await _writeTempFile(tempDirectory, 'remote-authority.flac');

      await repository.saveAudioResource(
        'netease:1',
        path: Uri(
          scheme: 'file',
          host: 'media-server',
          path: localFile.path,
        ).toString(),
        origin: TrackResourceOrigin.localImport,
      );

      expect(await repository.getPrimaryAudioResource('netease:1'), isNull);
      expect(
        await dataSource.getResource(
          'netease:1',
          LocalResourceKind.audio,
        ),
        isNull,
      );
    });

    test('allows lower priority cache to replace missing higher priority file', () async {
      final missingManagedFile = File('${tempDirectory.path}/missing.flac');
      final cacheFile = await _writeTempFile(tempDirectory, 'cache.mp3');

      await dataSource.saveResource(
        _resource(
          trackId: 'netease:1',
          path: missingManagedFile.path,
          origin: TrackResourceOrigin.managedDownload,
        ),
      );
      await repository.saveAudioResource(
        'netease:1',
        path: cacheFile.path,
        origin: TrackResourceOrigin.playbackCache,
      );

      final resource = await repository.getPrimaryAudioResource('netease:1');
      expect(resource?.path, cacheFile.path);
      expect(resource?.origin, TrackResourceOrigin.playbackCache);
    });

    test('does not save resource indexes for missing files', () async {
      final missingFile = File('${tempDirectory.path}/missing.mp3');

      await repository.saveAudioResource(
        'netease:1',
        path: missingFile.path,
        origin: TrackResourceOrigin.playbackCache,
      );

      expect(await repository.getPrimaryAudioResource('netease:1'), isNull);
      expect(
        await dataSource.getResource(
          'netease:1',
          LocalResourceKind.audio,
        ),
        isNull,
      );
    });

    test('cleans missing resources when building track bundles', () async {
      final missingAudio = File('${tempDirectory.path}/missing.mp3');
      final lyricsFile = await _writeTempFile(tempDirectory, 'song.lrc');
      await dataSource.saveResource(
        _resource(
          trackId: 'netease:1',
          path: missingAudio.path,
          origin: TrackResourceOrigin.playbackCache,
        ),
      );
      await dataSource.saveResource(
        _resource(
          trackId: 'netease:1',
          kind: LocalResourceKind.lyrics,
          path: lyricsFile.path,
          origin: TrackResourceOrigin.playbackCache,
        ),
      );

      final bundle = await repository.getTrackResourceBundle('netease:1');

      expect(bundle.audio, isNull);
      expect(bundle.lyrics?.path, lyricsFile.path);
      expect(
        await dataSource.getResource(
          'netease:1',
          LocalResourceKind.audio,
        ),
        isNull,
      );
    });

    test('skips local song entries whose audio file is missing', () async {
      final missingAudio = File('${tempDirectory.path}/missing.mp3');
      await dataSource.saveResource(
        _resource(
          trackId: 'netease:1',
          path: missingAudio.path,
          origin: TrackResourceOrigin.managedDownload,
        ),
      );

      final songs = await repository.listLocalSongs();

      expect(songs, isEmpty);
      expect(
        await dataSource.getResource(
          'netease:1',
          LocalResourceKind.audio,
        ),
        isNull,
      );
    });

    test('prunes local song resources when track fact is missing', () async {
      final orphanAudio = await _writeTempFile(tempDirectory, 'orphan.mp3');
      final orphanArtwork = await _writeTempFile(tempDirectory, 'orphan.jpg');
      repository = LocalResourceIndexRepository(
        dataSource: dataSource,
        localLibraryDataSource: _FakeLocalLibraryDataSource(
          missingTrackIds: const {'netease:orphan'},
        ),
      );
      await dataSource.saveResource(
        _resource(
          trackId: 'netease:orphan',
          path: orphanAudio.path,
          origin: TrackResourceOrigin.managedDownload,
        ),
      );
      await dataSource.saveResource(
        _resource(
          trackId: 'netease:orphan',
          kind: LocalResourceKind.artwork,
          path: orphanArtwork.path,
          origin: TrackResourceOrigin.managedDownload,
        ),
      );

      final songs = await repository.listLocalSongs();

      expect(songs, isEmpty);
      expect(
        await dataSource.getResource(
          'netease:orphan',
          LocalResourceKind.audio,
        ),
        isNull,
      );
      expect(
        await dataSource.getResource(
          'netease:orphan',
          LocalResourceKind.artwork,
        ),
        isNull,
      );
    });

    test('lists only usable resources and prunes stale indexes', () async {
      final missingAudio = File('${tempDirectory.path}/missing.mp3');
      final existingAudio = await _writeTempFile(tempDirectory, 'cache.mp3');
      await dataSource.saveResource(
        _resource(
          trackId: 'netease:missing',
          path: missingAudio.path,
          origin: TrackResourceOrigin.playbackCache,
        ),
      );
      await dataSource.saveResource(
        _resource(
          trackId: 'netease:cached',
          path: existingAudio.path,
          origin: TrackResourceOrigin.playbackCache,
        ),
      );

      final resources = await repository.listResources(
        origins: const {TrackResourceOrigin.playbackCache},
        kinds: const {LocalResourceKind.audio},
      );

      expect(resources.map((resource) => resource.trackId), ['netease:cached']);
      expect(
        await dataSource.getResource(
          'netease:missing',
          LocalResourceKind.audio,
        ),
        isNull,
      );
    });

    test('prunes legacy non-localhost file uri resource indexes', () async {
      final existingAudio = await _writeTempFile(tempDirectory, 'legacy-remote-authority.mp3');
      await dataSource.saveResource(
        _resource(
          trackId: 'netease:legacy',
          path: Uri(
            scheme: 'file',
            host: 'media-server',
            path: existingAudio.path,
          ).toString(),
          origin: TrackResourceOrigin.playbackCache,
        ),
      );

      final resources = await repository.listResources(
        origins: const {TrackResourceOrigin.playbackCache},
        kinds: const {LocalResourceKind.audio},
      );

      expect(resources, isEmpty);
      expect(
        await dataSource.getResource(
          'netease:legacy',
          LocalResourceKind.audio,
        ),
        isNull,
      );
    });

    test('normalizes legacy file uri paths when listing resources', () async {
      final existingAudio = await _writeTempFile(tempDirectory, 'legacy with space.mp3');
      await dataSource.saveResource(
        _resource(
          trackId: 'netease:legacy',
          path: existingAudio.uri.replace(queryParameters: {'token': 'legacy'}).toString(),
          origin: TrackResourceOrigin.playbackCache,
        ),
      );

      final resources = await repository.listResources(
        origins: const {TrackResourceOrigin.playbackCache},
        kinds: const {LocalResourceKind.audio},
      );

      expect(resources.single.path, existingAudio.path);
      expect(
        (await dataSource.getResource(
          'netease:legacy',
          LocalResourceKind.audio,
        ))
            ?.path,
        existingAudio.path,
      );
    });
  });
}

Future<File> _writeTempFile(Directory directory, String name) async {
  final file = File('${directory.path}/$name');
  await file.writeAsString('audio');
  return file;
}

LocalResourceEntry _resource({
  required String trackId,
  LocalResourceKind kind = LocalResourceKind.audio,
  required String path,
  required TrackResourceOrigin origin,
}) {
  final now = DateTime(2026);
  return LocalResourceEntry(
    trackId: trackId,
    kind: kind,
    path: path,
    origin: origin,
    sizeBytes: 0,
    createdAt: now,
    lastAccessedAt: now,
  );
}

class _InMemoryResourceIndexDataSource implements LocalResourceIndexDataSource {
  final Map<String, LocalResourceEntry> _resources = {};

  @override
  Future<LocalResourceEntry?> getResource(String trackId, LocalResourceKind kind) async {
    return _resources[_key(trackId, kind)];
  }

  @override
  Future<List<LocalResourceEntry>> getTrackResources(String trackId) async {
    return _resources.values.where((resource) => resource.trackId == trackId).toList();
  }

  @override
  Future<Map<String, List<LocalResourceEntry>>> getTrackResourcesByIds(Iterable<String> trackIds) async {
    final ids = trackIds.toSet();
    final result = <String, List<LocalResourceEntry>>{};
    for (final resource in _resources.values.where((resource) => ids.contains(resource.trackId))) {
      result.putIfAbsent(resource.trackId, () => <LocalResourceEntry>[]).add(resource);
    }
    return result;
  }

  @override
  Future<List<LocalResourceEntry>> listAudioResources({Set<TrackResourceOrigin>? origins}) async {
    return _resources.values
        .where(
          (resource) => resource.kind == LocalResourceKind.audio && (origins == null || origins.isEmpty || origins.contains(resource.origin)),
        )
        .toList();
  }

  @override
  Future<List<LocalResourceEntry>> listResources({
    Set<TrackResourceOrigin>? origins,
    Set<LocalResourceKind>? kinds,
  }) async {
    return _resources.values
        .where(
          (resource) => (origins == null || origins.isEmpty || origins.contains(resource.origin)) && (kinds == null || kinds.isEmpty || kinds.contains(resource.kind)),
        )
        .toList();
  }

  @override
  Future<void> saveResource(LocalResourceEntry entry) async {
    _resources[_key(entry.trackId, entry.kind)] = entry;
  }

  @override
  Future<void> touchResource(String trackId, LocalResourceKind kind, {required DateTime accessedAt}) async {
    final key = _key(trackId, kind);
    final existing = _resources[key];
    if (existing != null) {
      _resources[key] = existing.copyWith(lastAccessedAt: accessedAt);
    }
  }

  @override
  Future<void> removeResource(String trackId, LocalResourceKind kind) async {
    _resources.remove(_key(trackId, kind));
  }

  @override
  Future<void> removeTrackResources(String trackId) async {
    _resources.removeWhere((_, resource) => resource.trackId == trackId);
  }

  @override
  Future<void> removeResourcesByOrigin(TrackResourceOrigin origin) async {
    _resources.removeWhere((_, resource) => resource.origin == origin);
  }

  String _key(String trackId, LocalResourceKind kind) => '$trackId|${kind.name}';
}

class _FakeLocalLibraryDataSource implements LocalLibraryDataSource {
  _FakeLocalLibraryDataSource({
    this.missingTrackIds = const <String>{},
  });

  final Set<String> missingTrackIds;

  @override
  Future<List<Track>> getTracksByIds(Iterable<String> trackIds) async {
    return trackIds
        .where((trackId) => !missingTrackIds.contains(trackId))
        .map(
          (trackId) => Track(
            id: trackId,
            sourceType: SourceType.netease,
            sourceId: trackId,
            title: trackId,
          ),
        )
        .toList();
  }

  @override
  Future<List<AlbumEntity>> searchAlbums(String keyword) async => const [];

  @override
  Future<List<ArtistEntity>> searchArtists(String keyword) async => const [];

  @override
  Future<List<PlaylistEntity>> searchPlaylists(String keyword) async => const [];

  @override
  Future<List<Track>> searchTracks(String keyword) async => const [];

  @override
  Future<AlbumEntity?> getAlbum(String albumId) async => null;

  @override
  Future<ArtistEntity?> getArtist(String artistId) async => null;

  @override
  Future<PlaylistEntity?> getPlaylist(String playlistId) async => null;

  @override
  Future<Track?> getTrack(String trackId) async => null;

  @override
  Future<List<Track>> getTracksByAlbumId(String albumSourceId) async => const [];

  @override
  Future<List<Track>> getTracksByArtistId(String artistSourceId) async => const [];

  @override
  Future<TrackLyrics?> getLyrics(String trackId) async => null;

  @override
  Future<void> saveAlbums(List<AlbumEntity> albums) async {}

  @override
  Future<void> saveArtists(List<ArtistEntity> artists) async {}

  @override
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) async {}

  @override
  Future<void> savePlaylists(List<PlaylistEntity> playlists) async {}

  @override
  Future<void> saveTracks(List<Track> tracks) async {}

  @override
  Future<void> removeLyrics(String trackId) async {}

  @override
  Future<void> removeTrack(String trackId) async {}

  @override
  Future<void> clearPlaylistTrackRefs(String playlistId) async {}
}
