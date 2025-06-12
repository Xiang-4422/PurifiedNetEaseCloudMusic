import 'package:audio_service/audio_service.dart';

abstract class AudioPlayerHandler implements AudioHandler {
  // 添加公共方法

  // 改变播放列表
  Future<void> changeQueueLists(List<MediaItem> list);

  // 获取歌曲url
  Future<void> readySongUrl();

  // 从下标播放
  Future<void> playIndex(int index);

  // 私人fm
  Future<void> addFmItems(List<MediaItem> mediaItems);
}
