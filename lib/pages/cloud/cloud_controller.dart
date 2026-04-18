import 'package:audio_service/audio_service.dart';
import 'package:bujuan/controllers/app_controller.dart';
import 'package:get/get.dart';

import '../../common/netease_api/src/api/play/bean.dart';
import '../../common/netease_api/src/dio_ext.dart';
import '../../features/cloud/repository/cloud_repository.dart';
import '../../shared/mappers/media_item_mapper.dart';


class CloudController extends GetxController {
  final CloudRepository _repository = CloudRepository();
  final List<MediaItem> mediaItems = [];

  DioMetaData cloudSongDioMetaData({int offset = 0, int limit = 30}) {
    return _repository.cloudSongDioMetaData(offset: offset, limit: limit);
  }

  void updateMediaItems(List<CloudSongItem> songs) {
    mediaItems
      ..clear()
      ..addAll(
        MediaItemMapper.fromCloudSongItemList(
          songs,
          likedSongIds: AppController.to.likedSongIds.toList(),
        ),
      );
  }
}
