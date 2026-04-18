import 'package:bujuan/common/netease_api/src/api/play/bean.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/playlist_track_ref.dart';
import 'package:bujuan/domain/entities/source_type.dart';

class NeteasePlaylistMapper {
  const NeteasePlaylistMapper._();

  static PlaylistEntity fromPlaylist(PlayList playlist) {
    return PlaylistEntity(
      id: 'netease:${playlist.id}',
      sourceType: SourceType.netease,
      sourceId: playlist.id,
      title: playlist.name ?? '',
      description: playlist.description,
      coverUrl: playlist.coverImgUrl ?? playlist.picUrl,
      trackCount: playlist.trackCount,
      trackRefs: (playlist.trackIds ?? [])
          .asMap()
          .entries
          .map(
            (entry) => PlaylistTrackRef(
              trackId: 'netease:${entry.value.id}',
              order: entry.key,
            ),
          )
          .toList(),
    );
  }

  static List<PlaylistEntity> fromPlaylistList(List<PlayList> playlists) {
    return playlists.map(fromPlaylist).toList();
  }
}
