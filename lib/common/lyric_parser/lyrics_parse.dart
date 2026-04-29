import 'lyrics_reader_model.dart';

/// 歌词解析器基类，约束不同歌词格式的解析入口。
abstract class LyricsParse {
  /// 待解析的歌词原始文本。
  String lyric;

  /// 创建歌词解析器并保存原始歌词文本。
  LyricsParse(this.lyric);

  /// 将原始歌词解析为按时间排序的歌词行。
  List<LyricsLineModel> parseLines({bool isMain = true});

  /// 判断当前解析器是否适用于 [lyric]。
  bool isOK() => true;
}
