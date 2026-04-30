import 'package:bujuan/data/local/playback_restore_data_source.dart';
import 'package:bujuan/domain/entities/playback_restore_state.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackRepository', () {
    test('coalesces concurrent restore state writes', () async {
      final dataSource = _FakePlaybackRestoreDataSource(
        saveDelay: const Duration(milliseconds: 30),
      );
      final repository = PlaybackRepository(
        libraryRepository: _FakeLibraryRepository(),
        playbackRestoreDataSource: dataSource,
      );

      await repository.getRestoreState();
      final writes = List.generate(
        50,
        (index) => repository.updateRestoreState(
          position: Duration(seconds: index),
        ),
      );
      await Future.wait(writes);

      expect(dataSource.loadCount, 1);
      expect(dataSource.savedStates.length, lessThan(50));
      expect(dataSource.savedStates.last.position, const Duration(seconds: 49));
    });
  });
}

class _FakePlaybackRestoreDataSource implements PlaybackRestoreDataSource {
  _FakePlaybackRestoreDataSource({
    this.saveDelay = Duration.zero,
  });

  final Duration saveDelay;
  final List<PlaybackRestoreState> savedStates = <PlaybackRestoreState>[];
  int loadCount = 0;

  @override
  Future<PlaybackRestoreState?> getRestoreState() async {
    loadCount++;
    return const PlaybackRestoreState();
  }

  @override
  Future<void> saveRestoreState(PlaybackRestoreState state) async {
    if (saveDelay > Duration.zero) {
      await Future<void>.delayed(saveDelay);
    }
    savedStates.add(state);
  }
}

class _FakeLibraryRepository implements LibraryRepository {
  @override
  Future<String?> getPlaybackUrlWithQuality(
    String trackId, {
    String? qualityLevel,
  }) async {
    return null;
  }

  @override
  Future<TrackLyrics?> getLyrics(String trackId) async {
    return null;
  }

  @override
  Future<Track?> getTrack(String trackId) async {
    return null;
  }

  @override
  Future<TrackWithResources?> getTrackWithResources(String trackId) async {
    return null;
  }

  @override
  Future<void> saveLyrics(String trackId, TrackLyrics lyrics) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
