import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/user_session_data.dart';
import 'package:bujuan/data/app_storage/app_key_value_store.dart';
import 'package:bujuan/features/user/recommendation_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:bujuan/features/user/user_session_controller.dart';
import 'package:bujuan/features/user/user_session_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecommendationController', () {
    test('keeps local home data visible when library refresh fails', () async {
      final sessionController = _buildSessionController('user-1');
      final libraryController = _FakeUserLibraryController(
        refreshError: Exception('offline'),
      );
      final controller = RecommendationController(
        repository: _FakeUserRepository(),
        sessionController: sessionController,
        libraryController: libraryController,
      );
      addTearDown(controller.onClose);
      controller.recoPlayLists.add(
        const PlaylistSummaryData(id: 'playlist-1', title: 'Playlist 1'),
      );
      controller.todayRecommendSongs.add(_song('today-1'));
      controller.fmSongs.add(_song('fm-1'));

      await controller.updateData();

      expect(controller.dateLoaded.value, isTrue);
      expect(controller.hasLocalData, isTrue);
      expect(controller.recoPlayLists.map((playlist) => playlist.id), ['playlist-1']);
      expect(controller.todayRecommendSongs.map((song) => song.id), ['today-1']);
      expect(controller.fmSongs.map((song) => song.id), ['fm-1']);
    });
  });
}

UserSessionController _buildSessionController(String userId) {
  final controller = UserSessionController(
    repository: _FakeUserRepository(),
    sessionStore: UserSessionStore(keyValueStore: _MemoryKeyValueStore()),
    saveLoginFlag: (_) async {},
  );
  controller.userInfo.value = UserSessionData(
    userId: userId,
    nickname: 'User $userId',
    avatarUrl: '',
  );
  return controller;
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

class _FakeUserLibraryController extends UserLibraryController {
  _FakeUserLibraryController({this.refreshError})
      : super(
          repository: _FakeUserRepository(),
          sessionController: _buildSessionController('user-1'),
        );

  final Object? refreshError;

  @override
  Future<void> refreshUserLibrary() async {
    final error = refreshError;
    if (error != null) {
      throw error;
    }
  }
}

class _FakeUserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _MemoryKeyValueStore implements AppKeyValueStore {
  final Map<String, Object?> values = <String, Object?>{};

  @override
  Object? get(String key, {Object? defaultValue}) {
    return values.containsKey(key) ? values[key] : defaultValue;
  }

  @override
  Future<void> put(String key, Object? value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}
