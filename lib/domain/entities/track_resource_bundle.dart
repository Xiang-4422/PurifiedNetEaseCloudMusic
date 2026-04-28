import 'local_resource_entry.dart';

class TrackResourceBundle {
  const TrackResourceBundle({
    this.audio,
    this.artwork,
    this.lyrics,
  });

  final LocalResourceEntry? audio;
  final LocalResourceEntry? artwork;
  final LocalResourceEntry? lyrics;

  bool get hasAnyResource => audio != null || artwork != null || lyrics != null;

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
