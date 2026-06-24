import 'package:netease_music_api/netease_music_api.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/entities/track.dart';

/// 网易云曲目 mapper。
class NeteaseTrackMapper {
  /// 禁止实例化网易云曲目 mapper。
  const NeteaseTrackMapper._();

  /// 将网易云 `Song` 转换为领域曲目。
  static Track fromSong(Song song) {
    final songId = _normalizedSongId(song.id);
    final entityId = _neteaseEntityId(songId);
    return Track(
      id: entityId,
      sourceType: SourceType.netease,
      sourceId: songId,
      title: song.name ?? '',
      artistNames: (song.artists ?? []).map((artist) => artist.name ?? '').toList(),
      albumTitle: song.album?.name,
      albumId: _stringOrNull(song.album?.id),
      artistIds: (song.artists ?? []).map((artist) => _stringOrNull(artist.id)).whereType<String>().toList(),
      durationMs: song.duration,
      artworkUrl: song.album?.picUrl,
      lyricKey: entityId,
      availability: TrackAvailability.playable,
      metadata: {
        'mv': song.mvid,
        'fee': song.fee,
      },
    );
  }

  /// 将网易云 `Song2` 转换为领域曲目。
  static Track fromSong2(Song2 song) {
    final songId = _normalizedSongId(song.id);
    final entityId = _neteaseEntityId(songId);
    return Track(
      id: entityId,
      sourceType: SourceType.netease,
      sourceId: songId,
      title: song.name ?? '',
      artistNames: (song.ar ?? []).map((artist) => artist.name ?? '').toList(),
      albumTitle: song.al?.name,
      albumId: _stringOrNull(song.al?.id),
      artistIds: (song.ar ?? []).map((artist) => _stringOrNull(artist.id)).whereType<String>().toList(),
      durationMs: song.dt,
      artworkUrl: song.al?.picUrl,
      lyricKey: entityId,
      availability: (song.available ?? true) ? TrackAvailability.playable : TrackAvailability.unavailable,
      metadata: {
        'mv': song.mv,
        'fee': song.fee,
        'publishTime': song.publishTime,
      },
    );
  }

  /// 将网易云 `Song2` 列表转换为领域曲目列表。
  static List<Track> fromSong2List(List<Song2> songs) {
    return songs.where((song) => _normalizedSongId(song.id).isNotEmpty).map(fromSong2).toList();
  }

  /// 将网易云 `Song` 列表转换为领域曲目列表。
  static List<Track> fromSongList(List<Song> songs) {
    return songs.where((song) => _normalizedSongId(song.id).isNotEmpty).map(fromSong).toList();
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
    return songs.where((song) => _normalizedSongId(song.simpleSong.id).isNotEmpty).map(fromCloudSong).toList();
  }

  static String _neteaseEntityId(String songId) {
    return songId.isEmpty ? '' : 'netease:$songId';
  }

  static String _normalizedSongId(String id) {
    return id.trim();
  }

  static String? _stringOrNull(Object? value) {
    if (value == null || '$value'.isEmpty) {
      return null;
    }
    return '$value';
  }
}
