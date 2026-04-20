import 'package:audio_service/audio_service.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/common/constants/enmu.dart';

class CloudRepository {
  Future<CloudSongPage> fetchCloudSongs({
    required int offset,
    required int limit,
    required List<int> likedSongIds,
  }) async {
    final wrap =
        await NeteaseMusicApi().cloudSong(offset: offset, limit: limit);
    final songs = wrap.data ?? const <CloudSongItem>[];
    return CloudSongPage(
      items: songs
          .where((song) => song.simpleSong.id.isNotEmpty)
          .map(
            (song) => MediaItem(
              id: song.simpleSong.id,
              duration: Duration(milliseconds: song.simpleSong.dt ?? 0),
              artUri: Uri.parse(
                '${song.simpleSong.al?.picUrl ?? ''}?param=500y500',
              ),
              extras: {
                'url': '',
                'image': song.simpleSong.al?.picUrl ?? '',
                'type': MediaType.playlist.name,
                'liked':
                    likedSongIds.contains(int.tryParse(song.simpleSong.id)),
                'artist': (song.simpleSong.ar ?? [])
                    .map((artist) => artist.name ?? '')
                    .join(' / '),
                'artistNames': (song.simpleSong.ar ?? [])
                    .map((artist) => artist.name ?? '')
                    .toList(),
                'artistIds': (song.simpleSong.ar ?? [])
                    .map((artist) => artist.id)
                    .toList(),
                'albumId': song.simpleSong.al?.id ?? '',
              },
              title: song.simpleSong.name ?? '',
              album: song.simpleSong.al?.name,
              artist: (song.simpleSong.ar ?? [])
                  .map((artist) => artist.name)
                  .join(' / '),
            ),
          )
          .toList(),
      hasMore: songs.length >= limit,
      nextOffset: offset + songs.length,
    );
  }
}

class CloudSongPage {
  const CloudSongPage({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<MediaItem> items;
  final bool hasMore;
  final int nextOffset;
}
