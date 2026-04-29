///lyric model
class LyricsReaderModel {
  List<LyricsLineModel> lyrics = [];

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
  String? mainText;
  String? extText;
  int? startTime;
  int? endTime;
  List<LyricSpanInfo>? spanList;

  // 歌词布局缓存只保留纯数值，具体绘制对象留在 presentation 层。
  LyricDrawInfo? drawInfo;

  bool get hasExt => extText?.isNotEmpty == true;

  bool get hasMain => mainText?.isNotEmpty == true;

  List<LyricSpanInfo>? _defaultSpanList;

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
  double otherMainTextHeight = 0;
  double otherExtTextHeight = 0;
  double playingMainTextHeight = 0;
  double playingExtTextHeight = 0;
  List<LyricInlineDrawInfo> inlineDrawList = [];
}

class LyricInlineDrawInfo {
  int number = 0;
  String raw = "";
  double width = 0;
  double height = 0;
  double offsetX = 0;
  double offsetY = 0;
}

class LyricSpanInfo {
  int index = 0;
  int length = 0;
  int duration = 0;
  int start = 0;
  String raw = "";

  double drawWidth = 0;
  double drawHeight = 0;

  int get end => start + duration;

  int get endIndex => index + length;
}

extension LyricsReaderModelExt on LyricsReaderModel? {
  get isNullOrEmpty => this?.lyrics == null || this!.lyrics.isEmpty;
}
