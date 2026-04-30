import 'package:bujuan/core/playback/playback_queue_item_mapper.dart';
import 'package:bujuan/data/netease/remote/netease_artist_remote_data_source.dart';
import 'package:bujuan/domain/entities/album_entity.dart';
import 'package:bujuan/domain/entities/artist_entity.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';

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
    required LibraryRepository libraryRepository,
    NeteaseArtistRemoteDataSource? remoteDataSource,
  })  : _libraryRepository = libraryRepository,
        _remoteDataSource = remoteDataSource ?? NeteaseArtistRemoteDataSource();

  final LibraryRepository _libraryRepository;
  final NeteaseArtistRemoteDataSource _remoteDataSource;

  /// 加载本地缓存的歌手详情。
  Future<ArtistDetailData?> loadLocalArtistDetail({
    required String artistId,
    required List<int> likedSongIds,
  }) async {
    final artist = await _libraryRepository.getArtist('netease:$artistId');
    if (artist == null) {
      return null;
    }
    final topTracks = await _libraryRepository.getTracksByArtistId(artistId);
    final hotAlbums = await _libraryRepository.searchLocalAlbums(artist.name);
    return ArtistDetailData(
      artist: artist,
      topSongs: _mapTracksToPlaybackQueueItems(
        topTracks,
        likedSongIds: likedSongIds,
      ),
      hotAlbums: hotAlbums
          .where((album) => album.artistNames.contains(artist.name))
          .toList(),
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
      await _libraryRepository.saveArtists([artist]);
    }
    await _libraryRepository.saveTracks(tracks);
    await _libraryRepository.saveAlbums(albums);

    return ArtistDetailData(
      artist: artist!,
      topSongs: _mapTracksToPlaybackQueueItems(
        tracks,
        likedSongIds: likedSongIds,
      ),
      hotAlbums: albums,
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
