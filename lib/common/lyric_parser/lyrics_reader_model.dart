/// 歌词读取器的整体模型，持有按时间排序的歌词行。
class LyricsReaderModel {
  /// 当前歌曲的歌词行列表。
  List<LyricsLineModel> lyrics = [];

  /// 根据播放进度查找当前命中的歌词行索引。
  getCurrentLine(int progress) {
    var lastEndTime = 0;
    for (var i = 0; i < lyrics.length; i++) {
      var element = lyrics[i];
      if (progress >= (element.startTime ?? 0) &&
          progress < (element.endTime ?? 0)) {
        return i;
      }
      lastEndTime = element.endTime ?? 0;
    }
    if (progress > lastEndTime) {
      return lyrics.length - 1;
    } else {
      return 0;
    }
  }
}

/// 单行歌词模型，包含主歌词、翻译和逐字时间片段。
class LyricsLineModel {
  /// 主歌词文本。
  String? mainText;

  /// 翻译或扩展歌词文本。
  String? extText;

  /// 本行开始时间，单位为毫秒。
  int? startTime;

  /// 本行结束时间，单位为毫秒。
  int? endTime;

  /// 本行逐字歌词片段列表。
  List<LyricSpanInfo>? spanList;

  // 歌词布局缓存只保留纯数值，具体绘制对象留在 presentation 层。
  /// 本行歌词的布局缓存。
  LyricDrawInfo? drawInfo;

  /// 当前行是否包含扩展歌词。
  bool get hasExt => extText?.isNotEmpty == true;

  /// 当前行是否包含主歌词。
  bool get hasMain => mainText?.isNotEmpty == true;

  List<LyricSpanInfo>? _defaultSpanList;

  /// 无逐字歌词时根据整行文本生成的默认片段。
  get defaultSpanList => _defaultSpanList ??= [
        LyricSpanInfo()
          ..duration = (endTime ?? 0) - (startTime ?? 0)
          ..start = startTime ?? 0
          ..length = mainText?.length ?? 0
          ..raw = mainText ?? ""
      ];
}

/// 单行歌词在不同播放状态下的布局尺寸缓存。
class LyricDrawInfo {
  /// 非播放行主歌词高度。
  double otherMainTextHeight = 0;

  /// 非播放行扩展歌词高度。
  double otherExtTextHeight = 0;

  /// 播放中行主歌词高度。
  double playingMainTextHeight = 0;

  /// 播放中行扩展歌词高度。
  double playingExtTextHeight = 0;

  /// 逐字歌词片段的布局信息。
  List<LyricInlineDrawInfo> inlineDrawList = [];
}

/// 逐字歌词片段的绘制尺寸与偏移信息。
class LyricInlineDrawInfo {
  /// 片段序号。
  int number = 0;

  /// 片段原始文本。
  String raw = "";

  /// 片段绘制宽度。
  double width = 0;

  /// 片段绘制高度。
  double height = 0;

  /// 片段相对行起点的水平偏移。
  double offsetX = 0;

  /// 片段相对行起点的垂直偏移。
  double offsetY = 0;
}

/// 逐字歌词的时间和文本范围信息。
class LyricSpanInfo {
  /// 片段在主歌词文本中的起始索引。
  int index = 0;

  /// 片段覆盖的文本长度。
  int length = 0;

  /// 片段持续时间，单位为毫秒。
  int duration = 0;

  /// 片段开始时间，单位为毫秒。
  int start = 0;

  /// 片段原始文本。
  String raw = "";

  /// 片段绘制宽度。
  double drawWidth = 0;

  /// 片段绘制高度。
  double drawHeight = 0;

  /// 片段结束时间，单位为毫秒。
  int get end => start + duration;

  /// 片段在主歌词文本中的结束索引。
  int get endIndex => index + length;
}

/// 可空歌词模型的判空辅助能力。
extension LyricsReaderModelExt on LyricsReaderModel? {
  /// 当前歌词模型是否为空或没有歌词行。
  get isNullOrEmpty => this?.lyrics == null || this!.lyrics.isEmpty;
}
