import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/playback/media_item_mapper.dart';
import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/data/netease/netease_cloud_remote_data_source.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:get_it/get_it.dart';

class CloudRepository {
  CloudRepository({
    LibraryRepository? libraryRepository,
    UserScopedDataSource? userScopedDataSource,
    NeteaseCloudRemoteDataSource? remoteDataSource,
  })  : _remoteDataSource =
            remoteDataSource ?? const NeteaseCloudRemoteDataSource(),
        _libraryRepository = libraryRepository ??
            (GetIt.instance.isRegistered<LibraryRepository>()
                ? GetIt.instance<LibraryRepository>()
                : LibraryRepository()),
        _userScopedDataSource = userScopedDataSource ??
            (GetIt.instance.isRegistered<UserScopedDataSource>()
                ? GetIt.instance<UserScopedDataSource>()
                : (throw StateError('UserScopedDataSource is not registered')));

  final NeteaseCloudRemoteDataSource _remoteDataSource;
  final LibraryRepository _libraryRepository;
  final UserScopedDataSource _userScopedDataSource;

  Future<List<MediaItem>> loadCachedSongs({
    required String userId,
    required List<int> likedSongIds,
  }) async {
    final trackIds = await _userScopedDataSource.loadTrackIds(
      userId,
      UserTrackListKind.cloud,
    );
    if (trackIds.isEmpty) {
      return const [];
    }
    final tracks = await _libraryRepository.getTracksByIds(trackIds);
    if (tracks.isEmpty) {
      return const [];
    }
    final tracksById = {for (final track in tracks) track.id: track};
    final orderedTracks = trackIds
        .map((trackId) => tracksById[trackId])
        .whereType<Track>()
        .toList();
    return MediaItemMapper.fromTrackList(
      orderedTracks,
      likedSongIds: likedSongIds,
    );
  }

  Future<CloudSongPage> fetchCloudSongs({
    required String userId,
    required int offset,
    required int limit,
    required List<int> likedSongIds,
  }) async {
    final result = await _remoteDataSource.fetchCloudSongs(
      offset: offset,
      limit: limit,
      likedSongIds: likedSongIds,
    );
    await _libraryRepository.saveTracks(result.tracks);
    final trackIds = result.tracks.map((track) => track.id).toList();
    if (offset == 0) {
      await _userScopedDataSource.replaceTrackList(
        userId,
        UserTrackListKind.cloud,
        trackIds,
      );
    } else {
      await _userScopedDataSource.appendTrackList(
        userId,
        UserTrackListKind.cloud,
        trackIds,
        startOrder: offset,
      );
    }
    return CloudSongPage(
      items: result.items,
      hasMore: result.itemCount >= limit,
      nextOffset: offset + result.itemCount,
    );
  }
}

class CloudSongPage {
  const CloudSongPage({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
  });

  final List<MediaItem> items;
  final bool hasMore;
  final int nextOffset;
}
