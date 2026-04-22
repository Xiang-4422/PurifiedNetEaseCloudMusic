import 'local_resource_entry.dart';
import 'track.dart';
import 'track_resource_bundle.dart';

class LocalSongEntry {
  const LocalSongEntry({
    required this.track,
    required this.resources,
    required this.origin,
    required this.totalSizeBytes,
  });

  final Track track;
  final TrackResourceBundle resources;
  final TrackResourceOrigin origin;
  final int totalSizeBytes;

  LocalResourceEntry? get audioResource => resources.audio;

  LocalResourceEntry? get artworkResource => resources.artwork;

  LocalResourceEntry? get lyricsResource => resources.lyrics;
}
