import 'package:bujuan/core/entities/playback_mode.dart';
import 'package:bujuan/core/entities/playback_repeat_mode.dart';
import 'package:bujuan/features/playback/application/playback_queue_store.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackQueueStore', () {
    test('saveCurrentSong updates restore state and records recent playback', () async {
      final repository = _FakePlaybackRepository();
      final store = PlaybackQueueStore(repository: repository);

      await store.saveCurrentSong('netease:1');

      expect(repository.savedCurrentSongIds, ['netease:1']);
      expect(repository.recordedTrackIds, ['netease:1']);
    });
  });
}

class _FakePlaybackRepository implements PlaybackRepository {
  final List<String> savedCurrentSongIds = <String>[];
  final List<String> recordedTrackIds = <String>[];

  @override
  Future<void> updateRestoreState({
    PlaybackMode? playbackMode,
    PlaybackRepeatMode? repeatMode,
    List<String>? queue,
    String? currentSongId,
    String? playlistName,
    String? playlistHeader,
    Duration? position,
  }) async {
    if (currentSongId != null) {
      savedCurrentSongIds.add(currentSongId);
    }
  }

  @override
  Future<void> recordPlayedTrack(
    String trackId, {
    DateTime? playedAt,
  }) async {
    recordedTrackIds.add(trackId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
