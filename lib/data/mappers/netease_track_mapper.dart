import 'package:bujuan/common/netease_api/src/api/play/bean.dart';
import 'package:bujuan/domain/entities/source_type.dart';
import 'package:bujuan/domain/entities/track.dart';

class NeteaseTrackMapper {
  const NeteaseTrackMapper._();

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
      },
    );
  }

  static List<Track> fromSong2List(List<Song2> songs) {
    return songs.map(fromSong2).toList();
  }
}
