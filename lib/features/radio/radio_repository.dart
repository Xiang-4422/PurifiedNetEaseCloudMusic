import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/constants/enmu.dart';
import 'package:bujuan/common/netease_api/src/api/dj/bean.dart';
import 'package:bujuan/common/netease_api/src/dio_ext.dart';
import 'package:bujuan/common/netease_api/src/netease_handler.dart';

class RadioRepository {
  DioMetaData buildSubscribedRadioRequest({
    bool total = true,
    int offset = 0,
    int limit = 30,
  }) {
    return DioMetaData(
      joinUri('/weapi/djradio/get/subed'),
      data: {'total': total, 'limit': limit, 'offset': offset},
      options: joinOptions(),
    );
  }

  DioMetaData buildProgramListRequest(
    String radioId, {
    int offset = 0,
    int limit = 30,
    bool asc = true,
  }) {
    return DioMetaData(
      joinUri('/weapi/dj/program/byradio'),
      data: {'radioId': radioId, 'limit': limit, 'offset': offset, 'asc': asc},
      options: joinOptions(),
    );
  }

  List<MediaItem> mapProgramsToMediaItems(
    List<DjProgram> programs, {
    required List<int> likedSongIds,
  }) {
    return programs
        .map((program) => MediaItem(
              id: '${program.mainTrackId}',
              title: program.mainSong.name ?? '',
              artUri: Uri.parse(program.mainSong.album?.picUrl ?? ''),
              artist: program.dj.nickname,
              album: program.mainSong.album?.name,
              duration: Duration(milliseconds: program.duration ?? 0),
              extras: {
                'type': MediaType.playlist.name,
                'image': program.coverUrl ?? '',
                'liked': likedSongIds.contains(int.tryParse(program.id)),
                'mv': 0,
              },
            ))
        .toList();
  }
}
