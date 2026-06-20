import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/track_lyrics.dart';
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

    test('parses QRC main lyrics and merges translated LRC lines', () async {
      final presenter = PlaybackLyricsPresenter(
        repository: const _LyricsPlaybackRepository(
          TrackLyrics(
            main: '[1000,1200](1000,300)你(1300,300)好\n[2500,800](2500,400)世(2900,400)界',
            translated: '[00:01.000]Hello\n[00:02.500]World',
          ),
        ),
      );

      final state = await presenter.loadLyrics(_item('1'));

      expect(state.currentIndex, -1);
      expect(state.hasTranslatedLyrics, isTrue);
      expect(state.lines.map((line) => line.mainText), ['你好', '世界']);
      expect(state.lines.map((line) => line.extText), ['Hello', 'World']);
      expect(state.lines.first.startTime, 1000);
      expect(state.lines.first.spanList?.map((span) => span.raw), ['你', '好']);
      expect(state.lines.first.spanList?.map((span) => span.index), [0, 1]);
      expect(state.lines.first.spanList?.map((span) => span.length), [1, 1]);
      expect(state.lines.first.spanList?.map((span) => span.start), [1000, 1300]);
      expect(state.lines.first.spanList?.map((span) => span.duration), [300, 300]);
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

class _LyricsPlaybackRepository implements PlaybackRepository {
  const _LyricsPlaybackRepository(this.lyrics);

  final TrackLyrics lyrics;

  @override
  Future<TrackLyrics?> fetchSongLyrics(String trackId) async {
    return lyrics;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
