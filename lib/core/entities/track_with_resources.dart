import 'track.dart';
import 'track_resource_bundle.dart';

/// 曲目和本地资源的聚合数据。
class TrackWithResources {
  /// 创建曲目资源聚合数据。
  const TrackWithResources({
    required this.track,
    required this.resources,
  });

  /// 曲目实体。
  final Track track;

  /// 曲目关联的本地资源包。
  final TrackResourceBundle resources;
}
