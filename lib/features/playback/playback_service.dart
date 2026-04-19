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
}
