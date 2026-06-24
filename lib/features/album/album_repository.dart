import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/music_resource_id.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/features/playback/application/track_playback_queue_builder.dart';

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
    required MusicDataRepository musicDataRepository,
    required AlbumRemoteDataSource remoteDataSource,
  })  : _musicDataRepository = musicDataRepository,
        _remoteDataSource = remoteDataSource,
        _queueBuilder = TrackPlaybackQueueBuilder(musicDataRepository);

  final MusicDataRepository _musicDataRepository;
  final AlbumRemoteDataSource _remoteDataSource;
  final TrackPlaybackQueueBuilder _queueBuilder;

  /// 加载本地缓存的专辑详情。
  Future<AlbumDetailData?> loadLocalAlbumDetail({
    required String albumId,
    required List<int> likedSongIds,
  }) async {
    final sourceAlbumId = _normalizedAlbumSourceId(albumId);
    if (sourceAlbumId.isEmpty) {
      return null;
    }
    final entityAlbumId = MusicResourceId.toNeteaseEntityId(sourceAlbumId);
    final album = await _musicDataRepository.getAlbum(entityAlbumId);
    if (album == null) {
      return null;
    }
    final tracks = await _musicDataRepository.getTracksByAlbumId(sourceAlbumId);
    return AlbumDetailData(
      album: album,
      albumSongs: await _queueBuilder.build(
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
    final sourceAlbumId = _normalizedAlbumSourceId(albumId);
    if (sourceAlbumId.isEmpty) {
      throw ArgumentError.value(albumId, 'albumId', 'Expected a non-empty netease album id');
    }
    final result = await _remoteDataSource.fetchAlbumDetail(
      albumId: sourceAlbumId,
    );
    final album = result.album;
    final tracks = result.tracks;
    if (album != null) {
      await _musicDataRepository.saveAlbums([album]);
    }
    await _musicDataRepository.saveTracks(
      tracks,
      precacheArtwork: true,
      awaitArtworkPrecache: false,
    );
    return AlbumDetailData(
      album: album!,
      albumSongs: await _queueBuilder.build(
        tracks,
        likedSongIds: likedSongIds,
      ),
    );
  }

  String _normalizedAlbumSourceId(String albumId) {
    final sourceAlbumId = MusicResourceId.toNeteaseSourceId(albumId).trim();
    if (sourceAlbumId.isEmpty || MusicResourceId.hasKnownPrefix(sourceAlbumId)) {
      return '';
    }
    return sourceAlbumId;
  }
}
