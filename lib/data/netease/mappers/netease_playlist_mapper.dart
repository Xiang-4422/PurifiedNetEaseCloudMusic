import 'package:bujuan/data/netease/api/src/api/play/bean.dart';
import 'package:bujuan/domain/entities/playlist_entity.dart';
import 'package:bujuan/domain/entities/playlist_track_ref.dart';
import 'package:bujuan/domain/entities/source_type.dart';

/// 网易云歌单 mapper。
class NeteasePlaylistMapper {
  /// 禁止实例化网易云歌单 mapper。
  const NeteasePlaylistMapper._();

  /// 将网易云歌单模型转换为领域歌单实体。
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

  /// 将网易云歌单列表转换为领域歌单实体列表。
  static List<PlaylistEntity> fromPlaylistList(List<PlayList> playlists) {
    return playlists.map(fromPlaylist).toList();
  }
}
