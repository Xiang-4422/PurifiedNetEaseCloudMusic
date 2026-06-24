import 'package:netease_music_api/netease_music_api.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/playlist_track_ref.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/data/music_data/sources/netease/netease_song_detail_batch_planner.dart';

/// 网易云歌单 mapper。
class NeteasePlaylistMapper {
  /// 禁止实例化网易云歌单 mapper。
  const NeteasePlaylistMapper._();

  /// 将网易云歌单模型转换为领域歌单实体。
  static PlaylistEntity fromPlaylist(PlayList playlist) {
    final playlistId = _normalizedPlaylistId(playlist.id);
    return PlaylistEntity(
      id: _neteasePlaylistEntityId(playlistId),
      sourceType: SourceType.netease,
      sourceId: playlistId,
      title: playlist.name ?? '',
      description: playlist.description,
      coverUrl: playlist.coverImgUrl ?? playlist.picUrl,
      trackCount: playlist.trackCount,
      trackRefs: _trackRefsFromPlaylist(playlist),
    );
  }

  /// 将网易云歌单列表转换为领域歌单实体列表。
  static List<PlaylistEntity> fromPlaylistList(List<PlayList> playlists) {
    return playlists.where((playlist) => _normalizedPlaylistId(playlist.id).isNotEmpty).map(fromPlaylist).toList();
  }

  static List<PlaylistTrackRef> _trackRefsFromPlaylist(PlayList playlist) {
    final trackIds = normalizeNeteaseSongIds((playlist.trackIds ?? const []).map((track) => track.id));
    return trackIds
        .asMap()
        .entries
        .map(
          (entry) => PlaylistTrackRef(
            trackId: _neteaseSongEntityId(entry.value),
            order: entry.key,
          ),
        )
        .toList();
  }

  static String _neteasePlaylistEntityId(String playlistId) {
    return playlistId.isEmpty ? '' : 'netease:$playlistId';
  }

  static String _neteaseSongEntityId(String songId) {
    return songId.isEmpty ? '' : 'netease:$songId';
  }

  static String _normalizedPlaylistId(String id) {
    return id.trim();
  }
}
