import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/features/playback/application/playback_lyrics_presenter.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackLyricsPresenter', () {
    test('returns empty lyric state when repository throws', () async {
      final presenter = PlaybackLyricsPresenter(
        repository: _ThrowingPlaybackRepository(),
      );

      final state = await presenter.loadLyrics(_item('1'));

      expect(state.lines.single.mainText, '没歌词哦～');
      expect(state.currentIndex, -1);
      expect(state.hasTranslatedLyrics, isFalse);
    });
  });
}

PlaybackQueueItem _item(String id) {
  return PlaybackQueueItem(
    id: id,
    sourceId: id,
    title: 'Track $id',
    albumTitle: null,
    artistNames: const [],
    artistIds: const [],
    duration: null,
    artworkUrl: null,
    localArtworkPath: null,
    mediaType: MediaType.playlist,
    playbackUrl: null,
    lyricKey: null,
    isLiked: false,
    isCached: false,
  );
}

class _ThrowingPlaybackRepository implements PlaybackRepository {
  @override
  Future<TrackLyrics?> fetchSongLyrics(String trackId) {
    return Future<TrackLyrics?>.error(Exception('lyric timeout'));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
