import 'dart:io';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_mode.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/core/entities/playback_restore_state.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_lyrics.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackSourceResolver', () {
    test('treats normal cached audio path as file source', () async {
      final audioFile = await _createTempAudioFile('song.mp3');
      final resolver = PlaybackSourceResolver(
        repository: _FakePlaybackRepository(),
      );

      final source = await resolver.resolve(
        _mediaItem(
          type: MediaType.neteaseCache,
          url: audioFile.path,
        ),
        preferHighQuality: false,
      );

      expect(source.kind, PlaybackResolvedSourceKind.filePath);
      expect(source.url, audioFile.path);
      expect(source.markAsCached, isTrue);
    });

    test('keeps uc cache path on decrypted stream source', () async {
      final audioFile = await _createTempAudioFile('song.mp3.uc!');
      final resolver = PlaybackSourceResolver(
        repository: _FakePlaybackRepository(),
      );

      final source = await resolver.resolve(
        _mediaItem(
          type: MediaType.neteaseCache,
          url: audioFile.path,
        ),
        preferHighQuality: false,
      );

      expect(source.kind, PlaybackResolvedSourceKind.neteaseCacheStream);
      expect(source.url, audioFile.path);
      expect(source.fileType, 'mp3');
    });

    test('treats local file uri as file source', () async {
      final audioFile = await _createTempAudioFile('song with space.mp3');
      final resolver = PlaybackSourceResolver(
        repository: _FakePlaybackRepository(),
      );

      final source = await resolver.resolve(
        _mediaItem(
          sourceType: SourceType.local,
          type: MediaType.local,
          url: audioFile.uri.replace(queryParameters: {'token': 'local'}).toString(),
        ),
        preferHighQuality: false,
      );

      expect(source.kind, PlaybackResolvedSourceKind.filePath);
      expect(source.url, audioFile.path);
      expect(source.markAsCached, isFalse);
    });

    test('accepts localhost file uri authority as file source', () async {
      final audioFile = await _createTempAudioFile('song.mp3');
      final resolver = PlaybackSourceResolver(
        repository: _FakePlaybackRepository(),
      );
      final fileUri = Uri(
        scheme: 'file',
        host: 'localhost',
        path: audioFile.path,
        queryParameters: {'token': 'local'},
      ).toString();

      final source = await resolver.resolve(
        _mediaItem(
          sourceType: SourceType.local,
          type: MediaType.local,
          url: fileUri,
        ),
        preferHighQuality: false,
      );

      expect(source.kind, PlaybackResolvedSourceKind.filePath);
      expect(source.url, audioFile.path);
    });

    test('ignores non-localhost file uri authority for local imports', () async {
      final audioFile = await _createTempAudioFile('song.mp3');
      final resolver = PlaybackSourceResolver(
        repository: _FakePlaybackRepository(),
      );
      final fileUri = Uri(
        scheme: 'file',
        host: 'media-server',
        path: audioFile.path,
      ).toString();

      final source = await resolver.resolve(
        _mediaItem(
          sourceType: SourceType.local,
          type: MediaType.local,
          url: fileUri,
        ),
        preferHighQuality: false,
      );

      expect(source.kind, PlaybackResolvedSourceKind.empty);
    });

    test('returns empty source when local import file no longer exists', () async {
      final repository = _FakePlaybackRepository();
      final resolver = PlaybackSourceResolver(
        repository: repository,
      );

      final source = await resolver.resolve(
        _mediaItem(
          sourceType: SourceType.local,
          type: MediaType.local,
          url: '/missing/audio/song.mp3',
        ),
        preferHighQuality: false,
      );

      expect(source.kind, PlaybackResolvedSourceKind.empty);
      expect(source.isEmpty, isTrue);
      expect(repository.trackResourceLookups, ['netease:1']);
    });

    test('falls back to remote url when downloaded audio file no longer exists', () async {
      final repository = _FakePlaybackRepository(
        playbackUrl: 'https://example.com/fallback.mp3',
      );
      final resolver = PlaybackSourceResolver(repository: repository);

      final source = await resolver.resolve(
        _mediaItem(
          type: MediaType.local,
          url: '/missing/audio/download.mp3',
        ),
        preferHighQuality: true,
      );

      expect(source.kind, PlaybackResolvedSourceKind.url);
      expect(source.url, 'https://example.com/fallback.mp3');
      expect(repository.preferHighQualityValues, [true]);
      expect(repository.forceRefreshValues, [false]);
      expect(repository.trackResourceLookups, ['netease:1']);
    });

    test('falls back to remote url when netease cache file no longer exists', () async {
      final repository = _FakePlaybackRepository(
        playbackUrl: 'https://example.com/cache-fallback.mp3',
      );
      final resolver = PlaybackSourceResolver(repository: repository);

      final source = await resolver.resolve(
        _mediaItem(
          type: MediaType.neteaseCache,
          url: '/missing/audio/song.mp3.uc!',
        ),
        preferHighQuality: false,
      );

      expect(source.kind, PlaybackResolvedSourceKind.url);
      expect(source.url, 'https://example.com/cache-fallback.mp3');
      expect(repository.preferHighQualityValues, [false]);
      expect(repository.forceRefreshValues, [false]);
      expect(repository.trackResourceLookups, ['netease:1']);
    });

    test('returns empty source when local import is marked as netease cache but file is missing', () async {
      final resolver = PlaybackSourceResolver(
        repository: _FakePlaybackRepository(),
      );

      final source = await resolver.resolve(
        _mediaItem(
          sourceType: SourceType.local,
          type: MediaType.neteaseCache,
          url: '/missing/audio/song.mp3.uc!',
        ),
        preferHighQuality: false,
      );

      expect(source.kind, PlaybackResolvedSourceKind.empty);
      expect(source.isEmpty, isTrue);
    });

    test('keeps remote playback url query parameters intact', () async {
      final resolver = PlaybackSourceResolver(
        repository: _FakePlaybackRepository(
          playbackUrl: 'https://example.com/song.mp3?auth=temp&expires=1',
        ),
      );

      final source = await resolver.resolveRemote(
        _mediaItem(
          type: MediaType.playlist,
          url: '',
        ),
        preferHighQuality: true,
      );

      expect(source.kind, PlaybackResolvedSourceKind.url);
      expect(source.url, 'https://example.com/song.mp3?auth=temp&expires=1');
      expect(source.markAsCached, isFalse);
    });

    test('strips query only when resolving an existing local file path', () async {
      final directory = await Directory.systemTemp.createTemp('playback-source-resolver-');
      addTearDown(() async {
        if (directory.existsSync()) {
          await directory.delete(recursive: true);
        }
      });
      final audioFile = File('${directory.path}/song.mp3');
      await audioFile.writeAsString('audio');
      final resolver = PlaybackSourceResolver(
        repository: _FakePlaybackRepository(
          playbackUrl: '${audioFile.path}?token=local',
        ),
      );

      final source = await resolver.resolveRemote(
        _mediaItem(
          type: MediaType.playlist,
          url: '',
        ),
        preferHighQuality: false,
      );

      expect(source.kind, PlaybackResolvedSourceKind.filePath);
      expect(source.url, audioFile.path);
      expect(source.markAsCached, isTrue);
    });

    test('forwards force refresh when resolving remote playback url', () async {
      final repository = _FakePlaybackRepository();
      final resolver = PlaybackSourceResolver(repository: repository);

      await resolver.resolveRemote(
        _mediaItem(
          type: MediaType.playlist,
          url: '',
        ),
        preferHighQuality: true,
        forceRefresh: true,
      );

      expect(repository.forceRefreshValues, [true]);
      expect(repository.preferHighQualityValues, [true]);
    });
  });
}

Future<File> _createTempAudioFile(String name) async {
  final directory = await Directory.systemTemp.createTemp('playback-source-resolver-');
  addTearDown(() async {
    if (directory.existsSync()) {
      await directory.delete(recursive: true);
    }
  });
  final audioFile = File('${directory.path}/$name');
  await audioFile.writeAsString('audio');
  return audioFile;
}

PlaybackQueueItem _mediaItem({
  SourceType sourceType = SourceType.netease,
  required MediaType type,
  required String url,
}) {
  return PlaybackQueueItem(
    id: 'netease:1',
    sourceId: 'netease:1',
    sourceType: sourceType,
    title: 'Track',
    albumTitle: null,
    artistNames: const [],
    artistIds: const [],
    duration: null,
    artworkUrl: null,
    localArtworkPath: null,
    mediaType: type,
    playbackUrl: url,
    lyricKey: null,
    isLiked: false,
    isCached: false,
  );
}

class _FakePlaybackRepository implements PlaybackRepository {
  _FakePlaybackRepository({
    this.playbackUrl = 'https://example.com/song.mp3',
  });

  final String playbackUrl;
  final List<bool> forceRefreshValues = <bool>[];
  final List<bool> preferHighQualityValues = <bool>[];
  final List<String> trackResourceLookups = <String>[];

  @override
  Stream<void> get recentPlaybackUpdates => const Stream<void>.empty();

  @override
  Future<String?> fetchPlaybackUrl(
    String trackId, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) async {
    preferHighQualityValues.add(preferHighQuality);
    forceRefreshValues.add(forceRefresh);
    return playbackUrl;
  }

  @override
  Future<PlaybackRestoreState> getRestoreState() async {
    return const PlaybackRestoreState();
  }

  @override
  Future<Track?> getTrack(String trackId) async {
    return null;
  }

  @override
  Future<TrackWithResources?> getTrackWithResources(String trackId) async {
    trackResourceLookups.add(trackId);
    return null;
  }

  @override
  Future<List<TrackWithResources>> loadRecentPlayedTracks({int limit = 20}) async {
    return const [];
  }

  @override
  Future<TrackLyrics?> fetchSongLyrics(String trackId) async {
    return null;
  }

  @override
  Future<void> recordPlayedTrack(
    String trackId, {
    DateTime? playedAt,
  }) async {}

  @override
  Future<void> saveSongLyrics(String trackId, TrackLyrics lyrics) async {}

  @override
  Future<void> updateRestoreState({
    PlaybackMode? playbackMode,
    PlaybackRepeatMode? repeatMode,
    List<String>? queue,
    String? currentSongId,
    String? playlistName,
    String? playlistHeader,
    Duration? position,
  }) async {}

  @override
  Future<void> updateRestorePosition(Duration position) async {}
}
