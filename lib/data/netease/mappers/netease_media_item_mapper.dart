import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/constants/other.dart';
import 'package:bujuan/data/netease/api/src/api/play/bean.dart';

class NeteaseMediaItemMapper {
  const NeteaseMediaItemMapper._();

  static List<MediaItem> fromCloudSongs(
    List<CloudSongItem> songs, {
    required List<int> likedSongIds,
  }) {
    return songs
        .where((song) => song.simpleSong.id.isNotEmpty)
        .map(
          (song) => MediaItem(
            id: song.simpleSong.id,
            duration: Duration(milliseconds: song.simpleSong.dt ?? 0),
            artUri: Uri.tryParse(
              OtherUtils.normalizeImageUrl(song.simpleSong.al?.picUrl),
            ),
            extras: {
              'url': '',
              'image': OtherUtils.normalizeImageUrl(song.simpleSong.al?.picUrl),
              'type': MediaType.playlist.name,
              'liked': likedSongIds.contains(int.tryParse(song.simpleSong.id)),
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
        .toList();
  }

  static List<MediaItem> fromFmSongs(
    List<Song> songs, {
    required List<int> likedSongIds,
  }) {
    return songs
        .map(
          (song) => MediaItem(
            id: song.id,
            duration: Duration(milliseconds: song.duration ?? 0),
            artUri: Uri.tryParse(
              OtherUtils.normalizeImageUrl(song.album?.picUrl),
            ),
            extras: {
              'image': OtherUtils.normalizeImageUrl(song.album?.picUrl),
              'liked': likedSongIds.contains(int.tryParse(song.id)),
              'artist':
                  (song.artists ?? []).map((artist) => artist.name).join(' / '),
              'artistNames': (song.artists ?? [])
                  .map((artist) => artist.name ?? '')
                  .toList(),
              'artistIds':
                  (song.artists ?? []).map((artist) => artist.id).toList(),
              'albumId': song.album?.id ?? '',
              'type': MediaType.fm.name,
              'size': '',
            },
            title: song.name ?? '',
            album: song.album?.name ?? '',
            artist:
                (song.artists ?? []).map((artist) => artist.name).join(' / '),
          ),
        )
        .toList();
  }
}
