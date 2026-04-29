import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';

/// 歌词状态和运行时播放状态分开存放，避免歌词解析结果把主播放状态对象变成高频大对象。
class PlaybackLyricState {
  final List<LyricsLineModel> lines;
  final int currentIndex;
  final bool hasTranslatedLyrics;

  const PlaybackLyricState({
    this.lines = const [],
    this.currentIndex = -1,
    this.hasTranslatedLyrics = false,
  });

  PlaybackLyricState copyWith({
    List<LyricsLineModel>? lines,
    int? currentIndex,
    bool? hasTranslatedLyrics,
  }) {
    return PlaybackLyricState(
      lines: lines ?? this.lines,
      currentIndex: currentIndex ?? this.currentIndex,
      hasTranslatedLyrics: hasTranslatedLyrics ?? this.hasTranslatedLyrics,
    );
  }
}
