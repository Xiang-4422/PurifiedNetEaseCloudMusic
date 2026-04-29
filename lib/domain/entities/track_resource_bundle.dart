import 'local_resource_entry.dart';

/// 曲目关联的本地资源包。
class TrackResourceBundle {
  /// 创建曲目资源包。
  const TrackResourceBundle({
    this.audio,
    this.artwork,
    this.lyrics,
  });

  /// 音频资源。
  final LocalResourceEntry? audio;

  /// 封面资源。
  final LocalResourceEntry? artwork;

  /// 歌词资源。
  final LocalResourceEntry? lyrics;

  /// 是否存在任意本地资源。
  bool get hasAnyResource => audio != null || artwork != null || lyrics != null;

  /// 复制曲目资源包并替换指定字段。
  TrackResourceBundle copyWith({
    Object? audio = _unset,
    Object? artwork = _unset,
    Object? lyrics = _unset,
  }) {
    return TrackResourceBundle(
      audio:
          identical(audio, _unset) ? this.audio : audio as LocalResourceEntry?,
      artwork: identical(artwork, _unset)
          ? this.artwork
          : artwork as LocalResourceEntry?,
      lyrics: identical(lyrics, _unset)
          ? this.lyrics
          : lyrics as LocalResourceEntry?,
    );
  }

  static const Object _unset = Object();
}
