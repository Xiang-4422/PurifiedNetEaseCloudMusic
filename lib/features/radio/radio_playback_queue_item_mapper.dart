import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/radio_data.dart';

/// 电台节目到播放队列项的 mapper。
class RadioPlaybackQueueItemMapper {
  /// 禁止实例化电台播放队列 mapper。
  const RadioPlaybackQueueItemMapper._();

  /// 将电台节目列表转换为播放队列项列表。
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
