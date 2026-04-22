import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
import 'package:bujuan/data/netease/mappers/netease_track_mapper.dart';
import 'package:bujuan/domain/entities/track.dart';

/// 云盘远程访问先集中在 data/netease，避免 feature 继续直接触碰平台 API。
class NeteaseCloudRemoteDataSource {
  const NeteaseCloudRemoteDataSource();

  Future<({List<Track> tracks, List<MediaItem> items, int itemCount})>
      fetchCloudSongs({
    required int offset,
    required int limit,
    required List<int> likedSongIds,
  }) {
    return NeteaseMusicApi()
        .cloudSong(offset: offset, limit: limit)
        .then((wrap) {
      final songs = wrap.data ?? const [];
      final tracks = NeteaseTrackMapper.fromCloudSongList(songs);
      return (
        tracks: tracks,
        items: MediaItemMapper.fromTrackList(
          tracks,
          likedSongIds: likedSongIds,
        ),
        itemCount: songs.length,
      );
    });
  }
}
