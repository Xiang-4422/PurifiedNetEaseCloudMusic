import 'package:audio_service/audio_service.dart';

abstract class AudioPlayerHandler implements AudioHandler {
  // 添加公共方法

  // 改变播放列表
  Future<void> changePlayList(List<MediaItem> list);

  // 获取歌曲url
  Future<void> playCurIndex();

  // 从下标播放
  Future<void> playIndex(int index);

  // 打乱or恢复播放列表顺序
  Future<void> reorderPlayList({bool shufflePlayList = false});
}
