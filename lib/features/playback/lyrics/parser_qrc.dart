import 'lyrics_parse.dart';
import 'lyrics_reader_model.dart';

/// QRC 逐字歌词格式解析器。
class ParserQrc extends LyricsParse {
  /// 匹配 QRC 行级时间标签的正则。
  RegExp advancedPattern = RegExp(r"""\[\d+,\d+]""");

  /// 匹配 QRC 字级时间片段的正则。
  RegExp qrcPattern = RegExp(r"""\((\d+,\d+)\)""");

  /// 提取 QRC 行级时间值的正则。
  RegExp advancedValuePattern = RegExp(r"\[(\d*,\d*)\]");

  /// 创建 QRC 歌词解析器。
  ParserQrc(String lyric) : super(lyric);

  @override
  List<LyricsLineModel> parseLines({bool isMain = true}) {
    lyric = RegExp(r"""LyricContent="([\s\S]*)">""").firstMatch(lyric)?.group(1) ?? lyric;
    //读每一行
    var lines = lyric.split("\n");
    if (lines.isEmpty) {
      // LyricsLog.logD("未解析到歌词");
      return [];
    }
    List<LyricsLineModel> lineList = [];
    for (var line in lines) {
      //匹配time
      var time = advancedPattern.stringMatch(line);
      if (time == null) {
        //没有匹配到直接返回
        //TODO 歌曲相关信息暂不处理
        // LyricsLog.logD("忽略未匹配到Time：$line");
        continue;
      }
      //转时间戳
      var ts = int.parse(advancedValuePattern.firstMatch(time)?.group(1)?.split(",")[0] ?? "0");
      //移除time，拿到真实歌词
      var realLyrics = line.replaceFirst(advancedPattern, "");
      // LyricsLog.logD("匹配time:$time($ts) 真实歌词：$realLyrics");

      List<LyricSpanInfo> spanList = getSpanList(realLyrics);
      final text = realLyrics.replaceAll(qrcPattern, "");

      var lineModel = LyricsLineModel()..startTime = ts;
      if (isMain) {
        lineModel
          ..mainText = text
          ..spanList = spanList;
      } else {
        lineModel.extText = text;
      }
      lineList.add(lineModel);
    }
    return lineList;
  }

  /// 从单行 QRC 歌词中提取逐字时间片段。
  List<LyricSpanInfo> getSpanList(String realLyrics) {
    final matches = qrcPattern.allMatches(realLyrics).toList(growable: false);
    var textIndex = 0;
    var spanList = <LyricSpanInfo>[];
    for (var index = 0; index < matches.length; index++) {
      final element = matches[index];
      final nextStart = index + 1 < matches.length ? matches[index + 1].start : realLyrics.length;
      final raw = realLyrics.substring(element.end, nextStart);
      var span = LyricSpanInfo();

      span.raw = raw;
      span.index = textIndex;
      span.length = raw.length;
      textIndex += raw.length;

      var time = (element.group(1)?.split(",") ?? ["0", "0"]);
      span.start = int.parse(time[0]);
      span.duration = int.parse(time[1]);
      spanList.add(span);
    }
    return spanList;
  }

  @override
  bool isOK() {
    return lyric.contains("LyricContent=") || advancedPattern.stringMatch(lyric) != null;
  }
}
