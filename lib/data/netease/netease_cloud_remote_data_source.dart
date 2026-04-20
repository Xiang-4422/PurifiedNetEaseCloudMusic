import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/mappers/netease_media_item_mapper.dart';
import 'package:audio_service/audio_service.dart';

/// 云盘远程访问先集中在 data/netease，避免 feature 继续直接触碰平台 API。
class NeteaseCloudRemoteDataSource {
  const NeteaseCloudRemoteDataSource();

  Future<({List<MediaItem> items, int itemCount})> fetchCloudSongs({
    required int offset,
    required int limit,
    required List<int> likedSongIds,
  }) {
    return NeteaseMusicApi()
        .cloudSong(offset: offset, limit: limit)
        .then((wrap) {
      final songs = wrap.data ?? const [];
      return (
        items: NeteaseMediaItemMapper.fromCloudSongs(
          songs,
          likedSongIds: likedSongIds,
        ),
        itemCount: songs.length,
      );
    });
  }
}
