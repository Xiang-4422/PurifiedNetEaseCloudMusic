import 'package:audio_service/audio_service.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';

class CloudRepository {
  Future<CloudSongPage> fetchCloudSongs({
    required int offset,
    required int limit,
  }) async {
    final wrap =
        await NeteaseMusicApi().cloudSong(offset: offset, limit: limit);
    final songs = wrap.data ?? const <CloudSongItem>[];
    return CloudSongPage(
      items: songs,
      hasMore: songs.length >= limit,
      nextOffset: offset + songs.length,
    );
  }

  List<MediaItem> mapCloudSongs(
    List<CloudSongItem> songs, {
    required List<int> likedSongIds,
  }) {
    return MediaItemMapper.fromCloudSongItemList(
      songs,
      likedSongIds: likedSongIds,
    );
  }
}

class CloudSongPage {
  const CloudSongPage({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<CloudSongItem> items;
  final bool hasMore;
  final int nextOffset;
}
