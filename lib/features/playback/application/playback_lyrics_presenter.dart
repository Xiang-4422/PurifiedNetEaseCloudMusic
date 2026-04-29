import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';
import 'package:bujuan/common/lyric_parser/parser_lrc.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/features/playback/playback_lyric_state.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

/// 负责把歌曲歌词解析成播放器 UI 可消费的展示状态。
class PlaybackLyricsPresenter {
  /// 创建 PlaybackLyricsPresenter。
  PlaybackLyricsPresenter({required PlaybackRepository repository})
      : _repository = repository;

  final PlaybackRepository _repository;

  /// loadLyrics。
  Future<PlaybackLyricState> loadLyrics(PlaybackQueueItem currentSong) async {
    if (currentSong.id.isEmpty) {
      return _emptyLyricsState();
    }

    final lyrics = await _repository.fetchSongLyrics(currentSong.id) ??
        const TrackLyrics();
    final lyric = lyrics.main;
    final lyricTran = lyrics.translated;
    if (lyric.isEmpty) {
      return _emptyLyricsState();
    }

    final mainLyricsLineModels = ParserLrc(lyric).parseLines();
    if (lyricTran.isNotEmpty) {
      final extLyricsLineModels = ParserLrc(lyricTran).parseLines();
      for (final lyricsLineModel in extLyricsLineModels) {
        final index = mainLyricsLineModels.indexWhere(
          (element) => element.startTime == lyricsLineModel.startTime,
        );
        if (index != -1) {
          mainLyricsLineModels[index].extText = lyricsLineModel.mainText;
        }
      }
    }

    return PlaybackLyricState(
      lines: mainLyricsLineModels,
      currentIndex: -1,
      hasTranslatedLyrics: lyricTran.isNotEmpty,
    );
  }

  PlaybackLyricState _emptyLyricsState() {
    return PlaybackLyricState(
      lines: [
        LyricsLineModel()
          ..mainText = "没歌词哦～"
          ..startTime = 0,
      ],
      currentIndex: -1,
      hasTranslatedLyrics: false,
    );
  }
}
