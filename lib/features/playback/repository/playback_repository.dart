import 'package:bujuan/common/netease_api/netease_music_api.dart';

class PlaybackRepository {
  Future<SongLyricWrap> fetchSongLyric(String songId) {
    return NeteaseMusicApi().songLyric(songId);
  }
}
