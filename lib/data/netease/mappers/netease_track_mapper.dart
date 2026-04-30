import 'package:bujuan/data/netease/api/models/play/bean.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';

/// 网易云曲目 mapper。
class NeteaseTrackMapper {
  /// 禁止实例化网易云曲目 mapper。
  const NeteaseTrackMapper._();

  /// 将网易云 `Song` 转换为领域曲目。
  static Track fromSong(Song song) {
    return Track(
      id: 'netease:${song.id}',
      sourceType: SourceType.netease,
      sourceId: song.id,
      title: song.name ?? '',
      artistNames:
          (song.artists ?? []).map((artist) => artist.name ?? '').toList(),
      albumTitle: song.album?.name,
      durationMs: song.duration,
      artworkUrl: song.album?.picUrl,
      lyricKey: 'netease:${song.id}',
      availability: TrackAvailability.playable,
      metadata: {
        'mv': song.mvid,
        'fee': song.fee,
        'albumId': song.album?.id,
        'artistIds': (song.artists ?? []).map((artist) => artist.id).toList(),
      },
    );
  }

  /// 将网易云 `Song2` 转换为领域曲目。
  static Track fromSong2(Song2 song) {
    return Track(
      id: 'netease:${song.id}',
      sourceType: SourceType.netease,
      sourceId: song.id,
      title: song.name ?? '',
      artistNames: (song.ar ?? []).map((artist) => artist.name ?? '').toList(),
      albumTitle: song.al?.name,
      durationMs: song.dt,
      artworkUrl: song.al?.picUrl,
      lyricKey: 'netease:${song.id}',
      availability: (song.available ?? true)
          ? TrackAvailability.playable
          : TrackAvailability.unavailable,
      metadata: {
        'mv': song.mv,
        'fee': song.fee,
        'publishTime': song.publishTime,
        'albumId': song.al?.id,
        'artistIds': (song.ar ?? []).map((artist) => artist.id).toList(),
      },
    );
  }

  /// 将网易云 `Song2` 列表转换为领域曲目列表。
  static List<Track> fromSong2List(List<Song2> songs) {
    return songs.map(fromSong2).toList();
  }

  /// 将网易云 `Song` 列表转换为领域曲目列表。
  static List<Track> fromSongList(List<Song> songs) {
    return songs.map(fromSong).toList();
  }

  /// 将网易云云盘歌曲转换为领域曲目。
  static Track fromCloudSong(CloudSongItem song) {
    final track = fromSong2(song.simpleSong);
    return track.copyWith(
      metadata: {
        ...track.metadata,
        'cloudSongId': song.songId,
        'cloudFileName': song.fileName,
        'cloudAddTime': song.addTime,
      },
    );
  }

  /// 将网易云云盘歌曲列表转换为领域曲目列表。
  static List<Track> fromCloudSongList(List<CloudSongItem> songs) {
    return songs.map(fromCloudSong).toList();
  }
}
