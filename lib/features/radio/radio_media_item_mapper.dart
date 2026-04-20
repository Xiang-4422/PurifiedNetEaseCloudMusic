import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/features/radio/radio_data.dart';

class RadioMediaItemMapper {
  const RadioMediaItemMapper._();

  static List<MediaItem> fromPrograms(
    List<RadioProgramData> programs, {
    required List<int> likedSongIds,
  }) {
    return programs
        .map(
          (program) => MediaItem(
            id: program.mainTrackId,
            title: program.title,
            artUri: Uri.tryParse(program.coverUrl),
            artist: program.artistName,
            album: program.albumTitle,
            duration: Duration(milliseconds: program.durationMs),
            extras: {
              'type': MediaType.playlist.name,
              'image': program.coverUrl,
              'liked': likedSongIds.contains(int.tryParse(program.id)),
              'mv': 0,
            },
          ),
        )
        .toList();
  }
}
