import 'package:audio_service/audio_service.dart';
import 'package:bujuan/core/playback/audio_service_handler.dart';
import 'package:get/get.dart';

/// 统一持有音频服务实例，避免控制器和页面各自初始化底层播放器。
///
/// 当前仍处在迁移期，`AudioServiceHandler` 还承载了恢复、通知栏和队列兼容逻辑。
/// 先把实例生命周期收口到 service，后续才能继续拆分队列编排和模式切换，而不用
/// 让 `PlayerController` 继续直接持有底层 handler。
class PlaybackService extends GetxService {
  AudioServiceHandler? _handler;

  AudioServiceHandler get handler {
    final handler = _handler;
    if (handler == null) {
      throw StateError('PlaybackService has not been initialized.');
    }
    return handler;
  }

  Stream<List<MediaItem>> get queueStream => handler.queue;

  Stream<MediaItem?> get mediaItemStream => handler.mediaItem;

  Stream<PlaybackState> get playbackStateStream => handler.playbackState;

  Future<AudioServiceHandler> ensureInitialized() async {
    if (_handler != null) {
      return _handler!;
    }
    _handler = await AudioService.init(
      builder: () => AudioServiceHandler(),
      config: const AudioServiceConfig(
        androidStopForegroundOnPause: false,
        androidNotificationChannelId: 'com.yu4422.purrr.channel.audio',
        androidNotificationChannelName: 'Music playback',
        androidNotificationIcon: 'drawable/audio_service_like',
      ),
    );
    return _handler!;
  }

  Future<void> restoreLastPlayState() => handler.restoreLastPlayState();

  Future<void> play() => handler.play();

  Future<void> pause() => handler.pause();

  Future<void> changePlayList(
    List<MediaItem> playList, {
    int index = 0,
    bool needStore = true,
    required String playListName,
    String playListNameHeader = "",
    required bool changePlayerSource,
    required bool playNow,
  }) {
    return handler.changePlayList(
      playList,
      index: index,
      needStore: needStore,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
      changePlayerSource: changePlayerSource,
      playNow: playNow,
    );
  }

  Future<void> playIndex({
    required int audioSourceIndex,
    required bool playNow,
  }) {
    return handler.playIndex(
        audioSourceIndex: audioSourceIndex, playNow: playNow);
  }

  Future<void> seek(Duration position) => handler.seek(position);

  Future<void> skipToPrevious() => handler.skipToPrevious();

  Future<void> skipToNext() => handler.skipToNext();

  Future<void> changeRepeatMode({AudioServiceRepeatMode? newRepeatMode}) {
    return handler.changeRepeatMode(newRepeatMode: newRepeatMode);
  }

  Future<void> updateMediaItem(MediaItem mediaItem) {
    return handler.updateMediaItem(mediaItem);
  }

  /// 队列切换和播放源更新先统一收口在 service，避免控制器继续直接编排底层 handler。
  Future<void> playPlaylist(
    List<MediaItem> playList,
    int index, {
    required String playListName,
    String playListNameHeader = "",
    bool playNow = true,
    bool changePlayerSource = true,
    bool needStore = true,
  }) {
    return changePlayList(
      playList,
      index: index,
      playListName: playListName,
      playListNameHeader: playListNameHeader,
      playNow: playNow,
      changePlayerSource: changePlayerSource,
      needStore: needStore,
    );
  }

  /// 漫游模式的续队列需要和当前队列裁剪、自动切歌一起生效，留在 service 里更容易保证行为一致。
  Future<void> appendRoamingSongs({
    required List<MediaItem> currentQueue,
    required List<MediaItem> incomingSongs,
    required String currentSongId,
    required bool shouldAutoPlayNext,
    required int fallbackIndex,
  }) async {
    if (incomingSongs.isEmpty) {
      return;
    }

    final existingIds = currentQueue.map((item) => item.id).toSet();
    final filteredSongs =
        incomingSongs.where((item) => !existingIds.contains(item.id)).toList();
    if (filteredSongs.isEmpty) {
      return;
    }

    final combined = [...currentQueue, ...filteredSongs];
    if (combined.length > 200) {
      combined.removeRange(0, combined.length - 150);
    }

    final updatedIndex =
        combined.indexWhere((element) => element.id == currentSongId);
    final nextIndex = updatedIndex != -1 ? updatedIndex : fallbackIndex;

    await changePlayList(
      combined,
      index: nextIndex,
      playListName: '漫游模式',
      playListNameHeader: '漫游',
      playNow: false,
      changePlayerSource: false,
      needStore: false,
    );

    if (shouldAutoPlayNext) {
      final autoPlayIndex = nextIndex + 1;
      if (autoPlayIndex < combined.length) {
        await playIndex(audioSourceIndex: autoPlayIndex, playNow: true);
      }
    }
  }

  Future<void> playLikedSongs({
    required List<MediaItem> likedSongs,
    required List<int> likedSongIds,
    required MediaItem currentSong,
  }) async {
    int playIndex;
    final playList = [...likedSongs];
    if (likedSongIds.contains(int.parse(currentSong.id))) {
      playIndex = likedSongs.indexWhere((song) => song.id == currentSong.id);
    } else {
      playIndex = 0;
      playList.insert(0, currentSong);
    }

    await changePlayList(
      playList,
      index: playIndex,
      playListName: '喜欢的音乐',
      playNow: false,
      changePlayerSource: false,
    );
  }

  Future<bool> startRoamingMode({
    required List<MediaItem> fmSongs,
    required AudioServiceRepeatMode currentRepeatMode,
  }) async {
    if (fmSongs.isEmpty) {
      return false;
    }

    await changePlayList(
      fmSongs,
      index: 0,
      playListName: '漫游模式',
      playListNameHeader: '漫游',
      playNow: true,
      changePlayerSource: true,
      needStore: false,
    );

    if (currentRepeatMode == AudioServiceRepeatMode.one) {
      await changeRepeatMode(newRepeatMode: AudioServiceRepeatMode.all);
    }
    return true;
  }

  Future<bool> startHeartBeatMode({
    required List<MediaItem> songs,
    required AudioServiceRepeatMode currentRepeatMode,
  }) async {
    if (songs.isEmpty) {
      return false;
    }

    await changePlayList(
      songs,
      index: 0,
      playListName: '心动模式',
      playListNameHeader: '心动',
      playNow: true,
      changePlayerSource: true,
      needStore: false,
    );

    if (currentRepeatMode == AudioServiceRepeatMode.one) {
      await changeRepeatMode(newRepeatMode: AudioServiceRepeatMode.all);
    }
    return true;
  }
}
