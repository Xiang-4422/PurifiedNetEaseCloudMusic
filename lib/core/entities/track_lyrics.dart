/// 曲目歌词数据。
class TrackLyrics {
  /// 创建曲目歌词数据。
  const TrackLyrics({
    this.main = '',
    this.translated = '',
  });

  /// 主歌词文本。
  final String main;

  /// 翻译歌词文本。
  final String translated;
}
