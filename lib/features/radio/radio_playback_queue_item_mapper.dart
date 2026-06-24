import 'package:bujuan/core/entities/liked_song_ids.dart';
import 'package:bujuan/core/entities/music_resource_id.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/radio_data.dart';

/// 电台节目到播放队列项的 mapper。
class RadioPlaybackQueueItemMapper {
  /// 禁止实例化电台播放队列 mapper。
  const RadioPlaybackQueueItemMapper._();

  /// 将电台节目列表转换为播放队列项列表。
  static List<PlaybackQueueItem> fromPrograms(
    List<RadioProgramData> programs, {
    required List<int> likedSongIds,
  }) {
    final likedSongIdSet = normalizeLikedSongIds(likedSongIds).toSet();
    return programs.where((program) => _normalizedQueueItemId(program.mainTrackId).isNotEmpty).map(
      (program) {
        final trackId = _normalizedQueueItemId(program.mainTrackId);
        return PlaybackQueueItem(
          id: trackId,
          sourceId: trackId,
          title: program.title,
          albumTitle: program.albumTitle,
          artistNames: program.artistName.isEmpty ? const [] : [program.artistName],
          artistIds: const [],
          duration: Duration(milliseconds: program.durationMs),
          artworkUrl: null,
          localArtworkPath: null,
          mediaType: MediaType.playlist,
          playbackUrl: null,
          lyricKey: trackId,
          isLiked: _isLikedTrack(trackId, likedSongIdSet),
          isCached: false,
        );
      },
    ).toList();
  }

  static String _normalizedQueueItemId(String id) {
    return id.trim();
  }

  static bool _isLikedTrack(String trackId, Set<int> likedSongIds) {
    final numericSongId = int.tryParse(MusicResourceId.toNeteaseSourceId(trackId));
    return numericSongId != null && likedSongIds.contains(numericSongId);
  }
}
