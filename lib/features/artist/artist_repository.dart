import 'package:bujuan/features/playback/application/playback_queue_item_mapper.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';

/// 歌手详情数据。
class ArtistDetailData {
  /// 创建歌手详情数据。
  const ArtistDetailData({
    required this.artist,
    required this.topSongs,
    required this.hotAlbums,
  });

  /// 歌手实体。
  final ArtistEntity artist;

  /// 热门歌曲播放队列项。
  final List<PlaybackQueueItem> topSongs;

  /// 热门专辑列表。
  final List<AlbumEntity> hotAlbums;
}

/// 歌手仓库，聚合本地曲库和网易云歌手远程数据。
class ArtistRepository {
  /// 创建歌手仓库。
  ArtistRepository({
    required MusicDataRepository musicDataRepository,
    required ArtistRemoteDataSource remoteDataSource,
  })  : _musicDataRepository = musicDataRepository,
        _remoteDataSource = remoteDataSource;

  final MusicDataRepository _musicDataRepository;
  final ArtistRemoteDataSource _remoteDataSource;

  /// 加载本地缓存的歌手详情。
  Future<ArtistDetailData?> loadLocalArtistDetail({
    required String artistId,
    required List<int> likedSongIds,
  }) async {
    final artist = await _musicDataRepository.getArtist('netease:$artistId');
    if (artist == null) {
      return null;
    }
    final topTracks = await _musicDataRepository.getTracksByArtistId(artistId);
    final hotAlbums = await _musicDataRepository.searchLocalAlbums(artist.name);
    return ArtistDetailData(
      artist: artist,
      topSongs: await _mapTracksToPlaybackQueueItems(
        topTracks,
        likedSongIds: likedSongIds,
      ),
      hotAlbums: hotAlbums.where((album) => album.artistNames.contains(artist.name)).toList(),
    );
  }

  /// 从远程获取歌手详情并写入本地曲库。
  Future<ArtistDetailData> fetchArtistDetail({
    required String artistId,
    required List<int> likedSongIds,
  }) async {
    final result = await _remoteDataSource.fetchArtistDetail(
      artistId: artistId,
    );
    final artist = result.artist;
    final tracks = result.topTracks;
    final albums = result.hotAlbums;
    if (artist != null) {
      await _musicDataRepository.saveArtists([artist]);
    }
    await _musicDataRepository.saveTracks(tracks, precacheArtwork: true);
    await _musicDataRepository.saveAlbums(albums);

    return ArtistDetailData(
      artist: artist!,
      topSongs: await _mapTracksToPlaybackQueueItems(
        tracks,
        likedSongIds: likedSongIds,
      ),
      hotAlbums: albums,
    );
  }

  Future<List<PlaybackQueueItem>> _mapTracksToPlaybackQueueItems(
    List<Track> tracks, {
    required List<int> likedSongIds,
  }) async {
    if (tracks.isEmpty) {
      return const [];
    }
    final tracksWithResources = await _musicDataRepository.getTracksWithResources(
      tracks.map((track) => track.id),
    );
    final resourcesByTrackId = {
      for (final item in tracksWithResources) item.track.id: item.resources,
    };
    return PlaybackQueueItemMapper.fromTrackWithResourcesList(
      [
        for (final track in tracks)
          TrackWithResources(
            track: track,
            resources: resourcesByTrackId[track.id] ?? const TrackResourceBundle(),
          ),
      ],
      likedSongIds: likedSongIds,
    );
  }
}
