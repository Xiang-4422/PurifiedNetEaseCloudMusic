import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/radio_data.dart';

class RadioPlaybackQueueItemMapper {
  const RadioPlaybackQueueItemMapper._();

  static List<PlaybackQueueItem> fromPrograms(
    List<RadioProgramData> programs, {
    required List<int> likedSongIds,
  }) {
    return programs
        .map(
          (program) => PlaybackQueueItem(
            id: program.mainTrackId,
            sourceId: program.mainTrackId,
            title: program.title,
            albumTitle: program.albumTitle,
            artistNames:
                program.artistName.isEmpty ? const [] : [program.artistName],
            artistIds: const [],
            duration: Duration(milliseconds: program.durationMs),
            artworkUrl: null,
            localArtworkPath: null,
            mediaType: MediaType.playlist,
            playbackUrl: null,
            lyricKey: program.mainTrackId,
            isLiked: likedSongIds.contains(int.tryParse(program.mainTrackId)),
            isCached: false,
            metadata: const {'mv': 0},
          ),
        )
        .toList();
  }
}
