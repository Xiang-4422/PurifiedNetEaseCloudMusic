///lyric model
class LyricsReaderModel {
  /// lyrics。
  List<LyricsLineModel> lyrics = [];

  /// getCurrentLine。
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

///lyric line model
class LyricsLineModel {
  /// mainText。
  String? mainText;

  /// extText。
  String? extText;

  /// startTime。
  int? startTime;

  /// endTime。
  int? endTime;

  /// spanList。
  List<LyricSpanInfo>? spanList;

  // 歌词布局缓存只保留纯数值，具体绘制对象留在 presentation 层。
  /// drawInfo。
  LyricDrawInfo? drawInfo;

  /// hasExt。
  bool get hasExt => extText?.isNotEmpty == true;

  /// hasMain。
  bool get hasMain => mainText?.isNotEmpty == true;

  List<LyricSpanInfo>? _defaultSpanList;

  /// defaultSpanList。
  get defaultSpanList => _defaultSpanList ??= [
        LyricSpanInfo()
          ..duration = (endTime ?? 0) - (startTime ?? 0)
          ..start = startTime ?? 0
          ..length = mainText?.length ?? 0
          ..raw = mainText ?? ""
      ];
}

///lyric draw model
class LyricDrawInfo {
  /// otherMainTextHeight。
  double otherMainTextHeight = 0;

  /// otherExtTextHeight。
  double otherExtTextHeight = 0;

  /// playingMainTextHeight。
  double playingMainTextHeight = 0;

  /// playingExtTextHeight。
  double playingExtTextHeight = 0;

  /// inlineDrawList。
  List<LyricInlineDrawInfo> inlineDrawList = [];
}

/// LyricInlineDrawInfo。
class LyricInlineDrawInfo {
  /// number。
  int number = 0;

  /// raw。
  String raw = "";

  /// width。
  double width = 0;

  /// height。
  double height = 0;

  /// offsetX。
  double offsetX = 0;

  /// offsetY。
  double offsetY = 0;
}

/// LyricSpanInfo。
class LyricSpanInfo {
  /// index。
  int index = 0;

  /// length。
  int length = 0;

  /// duration。
  int duration = 0;

  /// start。
  int start = 0;

  /// raw。
  String raw = "";

  /// drawWidth。
  double drawWidth = 0;

  /// drawHeight。
  double drawHeight = 0;

  /// end。
  int get end => start + duration;

  /// endIndex。
  int get endIndex => index + length;
}

/// LyricsReaderModelExt。
extension LyricsReaderModelExt on LyricsReaderModel? {
  /// isNullOrEmpty。
  get isNullOrEmpty => this?.lyrics == null || this!.lyrics.isEmpty;
}
