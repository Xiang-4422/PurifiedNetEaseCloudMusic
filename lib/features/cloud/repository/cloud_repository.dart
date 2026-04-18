import 'package:audio_service/audio_service.dart';
import 'package:bujuan/common/netease_api/src/api/play/bean.dart';
import 'package:bujuan/common/netease_api/src/dio_ext.dart';
import 'package:bujuan/common/netease_api/src/netease_handler.dart';
import 'package:bujuan/shared/mappers/media_item_mapper.dart';

class CloudRepository {
  DioMetaData buildCloudSongRequest({int offset = 0, int limit = 30}) {
    final params = {'limit': limit, 'offset': offset};
    return DioMetaData(
      joinUri('/weapi/v1/cloud/get'),
      data: params,
      options: joinOptions(),
    );
  }

  List<MediaItem> mapCloudSongs(
    List<CloudSongItem> songs, {
    required List<int> likedSongIds,
  }) {
    return MediaItemMapper.fromCloudSongItemList(
      songs,
      likedSongIds: likedSongIds,
    );
  }
}
