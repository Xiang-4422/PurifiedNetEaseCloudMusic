import 'lyrics_reader_model.dart';

/// 歌词布局计算辅助方法。
class LyricHelper {
  /// 计算歌词列表在当前播放行下的整体布局高度。
  static double getLyricHeight(
      List<LyricsLineModel>? lyrics, int playingIndex) {
    if (lyrics == null) {
      return 0;
    }
    double sum = lyrics.fold(0.0, (previousValue, element) {
          var isPlayLine = lyrics.indexOf(element) == playingIndex;
          double mainTextHeight = 0;
          if (element.hasMain) {
            if (isPlayLine) {
              mainTextHeight = (element.drawInfo?.playingMainTextHeight ?? 0);
            } else {
              mainTextHeight = (element.drawInfo?.otherMainTextHeight ?? 0);
            }
          }
          double extTextHeight = 0;
          if (element.hasExt) {
            if (isPlayLine) {
              extTextHeight = (element.drawInfo?.playingExtTextHeight ?? 0);
            } else {
              extTextHeight = (element.drawInfo?.otherExtTextHeight ?? 0);
            }
          }
          return (previousValue ?? 0) + mainTextHeight + extTextHeight;
        }) ??
        0;
    return sum;
  }
}
