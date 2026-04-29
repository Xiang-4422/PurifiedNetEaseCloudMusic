import 'package:bujuan/domain/entities/track.dart';

import 'package:bujuan/domain/entities/local_resource_entry.dart';

/// 本地资源索引数据源。
abstract class LocalResourceIndexDataSource {
  /// 获取指定歌曲的指定类型资源。
  Future<LocalResourceEntry?> getResource(
    String trackId,
    LocalResourceKind kind,
  );

  /// 获取指定歌曲的全部本地资源。
  Future<List<LocalResourceEntry>> getTrackResources(String trackId);

  /// 批量获取歌曲资源。
  Future<Map<String, List<LocalResourceEntry>>> getTrackResourcesByIds(
    Iterable<String> trackIds,
  );

  /// 列出本地音频资源。
  Future<List<LocalResourceEntry>> listAudioResources({
    Set<TrackResourceOrigin>? origins,
  });

  /// 保存本地资源。
  Future<void> saveResource(LocalResourceEntry entry);

  /// 更新资源最近访问时间。
  Future<void> touchResource(
    String trackId,
    LocalResourceKind kind, {
    required DateTime accessedAt,
  });

  /// 删除指定资源。
  Future<void> removeResource(String trackId, LocalResourceKind kind);

  /// 删除指定歌曲的全部资源。
  Future<void> removeTrackResources(String trackId);

  /// 删除指定来源的全部资源。
  Future<void> removeResourcesByOrigin(TrackResourceOrigin origin);
}
