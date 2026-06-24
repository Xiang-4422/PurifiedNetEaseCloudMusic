import 'dart:io';

import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalMediaRepository', () {
    late Directory directory;
    late _FakeMusicDataRepository musicDataRepository;
    late _FakeLocalResourceIndexRepository resourceIndexRepository;
    late LocalMediaRepository repository;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('local-media-repository-');
      musicDataRepository = _FakeMusicDataRepository();
      resourceIndexRepository = _FakeLocalResourceIndexRepository();
      repository = LocalMediaRepository(
        musicDataRepository: musicDataRepository,
        resourceIndexRepository: resourceIndexRepository,
      );
    });

    tearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    test('importLocalTrack registers only existing local resources', () async {
      final audioFile = await _writeFile(directory, 'Song.flac');
      final artworkFile = await _writeFile(directory, 'Song.jpg');
      final lyricsFile = await _writeFile(directory, 'Song.lrc');

      final track = await repository.importLocalTrack(
        filePath: audioFile.uri.replace(queryParameters: {'token': 'local'}).toString(),
        title: 'Song',
        localArtworkPath: artworkFile.path,
        localLyricsPath: lyricsFile.path,
      );

      expect(track.id, 'local:${audioFile.path}');
      expect(track.sourceId, audioFile.path);
      expect(musicDataRepository.savedTracks.map((item) => item.id), ['local:${audioFile.path}']);
      expect(resourceIndexRepository.audioPaths, [audioFile.path]);
      expect(resourceIndexRepository.artworkPaths, [artworkFile.path]);
      expect(resourceIndexRepository.lyricsPaths, [lyricsFile.path]);
    });

    test('importLocalTrack rejects remote audio paths before saving', () async {
      await expectLater(
        repository.importLocalTrack(
          filePath: 'https://audio.test/song.mp3',
          title: 'Remote Song',
        ),
        throwsArgumentError,
      );

      expect(musicDataRepository.savedTracks, isEmpty);
      expect(resourceIndexRepository.audioPaths, isEmpty);
    });

    test('importLocalTrack rejects existing non-audio files before saving', () async {
      final textFile = await _writeFile(directory, 'notes.txt');

      await expectLater(
        repository.importLocalTrack(
          filePath: textFile.path,
          title: 'Notes',
        ),
        throwsArgumentError,
      );

      expect(musicDataRepository.savedTracks, isEmpty);
      expect(resourceIndexRepository.audioPaths, isEmpty);
    });

    test('importLocalTracks skips invalid audio and ignores invalid sidecars', () async {
      final audioFile = await _writeFile(directory, 'Valid.mp3');
      final nonAudioFile = await _writeFile(directory, 'Cover.jpg');
      final missingFile = File('${directory.path}/Missing.mp3');

      final imported = await repository.importLocalTracks([
        const LocalTrackImport(
          filePath: 'https://audio.test/remote.mp3',
          title: 'Remote',
        ),
        LocalTrackImport(
          filePath: missingFile.path,
          title: 'Missing',
        ),
        LocalTrackImport(
          filePath: nonAudioFile.path,
          title: 'Cover',
        ),
        LocalTrackImport(
          filePath: audioFile.path,
          title: 'Valid',
          localArtworkPath: 'https://image.test/cover.jpg',
          localLyricsPath: '${directory.path}/missing.lrc',
        ),
      ]);

      expect(imported.map((track) => track.title), ['Valid']);
      expect(musicDataRepository.savedTracks.map((item) => item.title), ['Valid']);
      expect(resourceIndexRepository.audioPaths, [audioFile.path]);
      expect(resourceIndexRepository.artworkPaths, isEmpty);
      expect(resourceIndexRepository.lyricsPaths, isEmpty);
    });
  });
}

Future<File> _writeFile(Directory directory, String name) async {
  final file = File('${directory.path}/$name');
  await file.writeAsString('media');
  return file;
}

class _FakeMusicDataRepository implements MusicDataRepository {
  final List<Track> savedTracks = <Track>[];

  @override
  Future<void> saveTrack(
    Track track, {
    bool precacheArtwork = true,
    bool awaitArtworkPrecache = true,
  }) async {
    savedTracks.add(track);
  }

  @override
  Future<void> saveTracks(
    List<Track> tracks, {
    bool precacheArtwork = true,
    bool awaitArtworkPrecache = true,
  }) async {
    savedTracks.addAll(tracks);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeLocalResourceIndexRepository implements LocalResourceIndexRepository {
  final List<String> audioPaths = <String>[];
  final List<String> artworkPaths = <String>[];
  final List<String> lyricsPaths = <String>[];

  @override
  Future<void> saveAudioResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) async {
    audioPaths.add(path);
  }

  @override
  Future<void> saveArtworkResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) async {
    artworkPaths.add(path);
  }

  @override
  Future<void> saveLyricsResource(
    String trackId, {
    required String path,
    required TrackResourceOrigin origin,
  }) async {
    lyricsPaths.add(path);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
