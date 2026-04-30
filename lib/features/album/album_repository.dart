import 'package:bujuan/core/playback/playback_queue_item_mapper.dart';
import 'package:bujuan/data/netease/remote/netease_album_remote_data_source.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';

/// 专辑详情数据。
class AlbumDetailData {
  /// 创建专辑详情数据。
  const AlbumDetailData({
    required this.album,
    required this.albumSongs,
  });

  /// 专辑实体。
  final AlbumEntity album;

  /// 专辑歌曲播放队列项。
  final List<PlaybackQueueItem> albumSongs;
}

/// 专辑仓库，聚合本地曲库和网易云专辑远程数据。
class AlbumRepository {
  /// 创建专辑仓库。
  AlbumRepository({
    required LibraryRepository libraryRepository,
    NeteaseAlbumRemoteDataSource? remoteDataSource,
  })  : _libraryRepository = libraryRepository,
        _remoteDataSource = remoteDataSource ?? NeteaseAlbumRemoteDataSource();

  final LibraryRepository _libraryRepository;
  final NeteaseAlbumRemoteDataSource _remoteDataSource;

  /// 加载本地缓存的专辑详情。
  Future<AlbumDetailData?> loadLocalAlbumDetail({
    required String albumId,
    required List<int> likedSongIds,
  }) async {
    final album = await _libraryRepository.getAlbum('netease:$albumId');
    if (album == null) {
      return null;
    }
    final tracks = await _libraryRepository.getTracksByAlbumId(albumId);
    return AlbumDetailData(
      album: album,
      albumSongs: _mapTracksToPlaybackQueueItems(
        tracks,
        likedSongIds: likedSongIds,
      ),
    );
  }

  /// 从远程获取专辑详情并写入本地曲库。
  Future<AlbumDetailData> fetchAlbumDetail({
    required String albumId,
    required List<int> likedSongIds,
  }) async {
    final result = await _remoteDataSource.fetchAlbumDetail(
      albumId: albumId,
    );
    final album = result.album;
    final tracks = result.tracks;
    if (album != null) {
      await _libraryRepository.saveAlbums([album]);
    }
    await _libraryRepository.saveTracks(tracks);
    return AlbumDetailData(
      album: album!,
      albumSongs: _mapTracksToPlaybackQueueItems(
        tracks,
        likedSongIds: likedSongIds,
      ),
    );
  }

  List<PlaybackQueueItem> _mapTracksToPlaybackQueueItems(
    List<Track> tracks, {
    required List<int> likedSongIds,
  }) {
    if (tracks.isEmpty) {
      return const [];
    }
    return PlaybackQueueItemMapper.fromTrackList(
      tracks,
      likedSongIds: likedSongIds,
    );
  }
}
