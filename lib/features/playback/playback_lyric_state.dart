import 'package:bujuan/common/lyric_parser/lyrics_reader_model.dart';

/// 歌词状态和运行时播放状态分开存放，避免歌词解析结果把主播放状态对象变成高频大对象。
class PlaybackLyricState {
  /// 当前歌词行列表。
  final List<LyricsLineModel> lines;

  /// 当前播放进度命中的歌词行索引。
  final int currentIndex;

  /// 歌词是否包含翻译行。
  final bool hasTranslatedLyrics;

  /// 创建歌词状态。
  const PlaybackLyricState({
    this.lines = const [],
    this.currentIndex = -1,
    this.hasTranslatedLyrics = false,
  });

  /// 复制歌词状态并替换指定字段。
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
