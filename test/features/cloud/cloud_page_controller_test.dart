import 'dart:async';

import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/user_scoped_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_cloud_remote_data_source.dart';
import 'package:bujuan/features/cloud/cloud_page_controller.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CloudPageController', () {
    test('keeps cached songs when background refresh fails', () async {
      final refresh = Completer<CloudSongPage>();
      final error = Exception('offline');
      final repository = _FakeCloudRepository(
        cachedSongs: [_song('cached')],
        fetchCloudSongs: () => refresh.future,
      );
      final controller = _buildController(repository);

      await controller.loadInitial();
      expect(controller.state.value.items.map((item) => item.id), ['cached']);
      expect(controller.state.value.refreshing, isTrue);

      refresh.completeError(error, StackTrace.current);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.value.items.map((item) => item.id), ['cached']);
      expect(controller.state.value.refreshing, isFalse);
      expect(controller.state.value.error, same(error));
      expect(controller.state.value.hasInitialError, isFalse);
    });

    test('uses initial error when no cached songs exist', () async {
      final error = Exception('offline');
      final repository = _FakeCloudRepository(
        fetchCloudSongs: () => Future<CloudSongPage>.error(error),
      );
      final controller = _buildController(repository);

      await controller.loadInitial();

      expect(controller.state.value.items, isEmpty);
      expect(controller.state.value.error, same(error));
      expect(controller.state.value.hasInitialError, isTrue);
    });
  });
}

CloudPageController _buildController(_FakeCloudRepository repository) {
  return CloudPageController(
    repository: repository,
    userId: 'user-1',
    likedSongIds: const [],
  );
}

PlaybackQueueItem _song(String id) {
  return PlaybackQueueItem(
    id: id,
    sourceId: id,
    title: 'Song $id',
    albumTitle: 'Album',
    artistNames: const ['Artist'],
    artistIds: const ['artist-1'],
    duration: const Duration(minutes: 3),
    artworkUrl: null,
    localArtworkPath: null,
    mediaType: MediaType.playlist,
    playbackUrl: null,
    lyricKey: null,
    isLiked: false,
    isCached: false,
  );
}

class _FakeCloudRepository extends CloudRepository {
  _FakeCloudRepository({
    this.cachedSongs = const [],
    required Future<CloudSongPage> Function() fetchCloudSongs,
  })  : _fetchCloudSongs = fetchCloudSongs,
        super(
          musicDataRepository: _UnusedMusicDataRepository(),
          userTrackListDataSource: _UnusedUserTrackListDataSource(),
          remoteDataSource: _UnusedNeteaseCloudRemoteDataSource(),
        );

  final List<PlaybackQueueItem> cachedSongs;
  final Future<CloudSongPage> Function() _fetchCloudSongs;

  @override
  Future<List<PlaybackQueueItem>> loadCachedSongs({
    required String userId,
    required List<int> likedSongIds,
  }) async {
    return cachedSongs;
  }

  @override
  Future<CloudSongPage> fetchCloudSongs({
    required String userId,
    required int offset,
    required int limit,
    required List<int> likedSongIds,
  }) {
    return _fetchCloudSongs();
  }
}

class _UnusedMusicDataRepository implements MusicDataRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _UnusedUserTrackListDataSource implements UserTrackListDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _UnusedNeteaseCloudRemoteDataSource implements NeteaseCloudRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
