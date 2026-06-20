import 'package:bujuan/features/playback/lyrics/lyrics_reader_model.dart';
import 'package:bujuan/features/playback/lyrics/parser_lrc.dart';
import 'package:bujuan/features/playback/lyrics/parser_qrc.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/track_lyrics.dart';
import 'package:bujuan/features/playback/playback_lyric_state.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

/// 负责把歌曲歌词解析成播放器 UI 可消费的展示状态。
class PlaybackLyricsPresenter {
  /// 创建歌词展示状态组装器。
  PlaybackLyricsPresenter({required PlaybackRepository repository}) : _repository = repository;

  final PlaybackRepository _repository;

  /// 加载并解析当前歌曲歌词。
  Future<PlaybackLyricState> loadLyrics(PlaybackQueueItem currentSong) async {
    if (currentSong.id.isEmpty) {
      return _emptyLyricsState();
    }

    try {
      final lyrics = await _repository.fetchSongLyrics(currentSong.id) ?? const TrackLyrics();
      final lyric = lyrics.main;
      final lyricTran = lyrics.translated;
      if (lyric.isEmpty) {
        return _emptyLyricsState();
      }

      final mainLyricsLineModels = _parseLyricsLines(lyric);
      if (lyricTran.isNotEmpty) {
        final extLyricsLineModels = _parseLyricsLines(lyricTran, isMain: false);
        for (final lyricsLineModel in extLyricsLineModels) {
          final index = mainLyricsLineModels.indexWhere(
            (element) => element.startTime == lyricsLineModel.startTime,
          );
          if (index != -1) {
            mainLyricsLineModels[index].extText = lyricsLineModel.extText ?? lyricsLineModel.mainText;
          }
        }
      }

      return PlaybackLyricState(
        lines: mainLyricsLineModels,
        currentIndex: -1,
        hasTranslatedLyrics: lyricTran.isNotEmpty,
      );
    } catch (_) {
      return _emptyLyricsState();
    }
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

  List<LyricsLineModel> _parseLyricsLines(String lyric, {bool isMain = true}) {
    final qrc = ParserQrc(lyric);
    if (qrc.isOK()) {
      return qrc.parseLines(isMain: isMain);
    }
    return ParserLrc(lyric).parseLines(isMain: isMain);
  }
}
