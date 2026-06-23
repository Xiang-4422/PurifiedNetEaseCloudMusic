import 'package:bujuan/core/entities/user_library_kinds.dart';

import '../dao/user_track_list_dao.dart';
import 'user_scoped_data_source.dart';

/// Drift 实现的用户曲目列表数据源。
class DriftUserTrackListDataSource implements UserTrackListDataSource {
  /// 创建 Drift 用户曲目列表数据源。
  const DriftUserTrackListDataSource({required UserTrackListDao dao}) : _dao = dao;

  final UserTrackListDao _dao;

  @override
  Future<List<String>> loadTrackIds(String userId, UserTrackListKind kind) {
    return _dao.loadTrackIds(userId, kind);
  }

  @override
  Future<void> replaceTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds,
  ) {
    return _dao.replaceTrackList(userId, kind, trackIds);
  }

  @override
  Future<void> appendTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds, {
    required int startOrder,
  }) {
    return _dao.appendTrackList(
      userId,
      kind,
      trackIds,
      startOrder: startOrder,
    );
  }

  @override
  Future<void> upsertTrackRef(
    String userId,
    UserTrackListKind kind,
    String trackId, {
    int? sortOrder,
  }) {
    return _dao.upsertTrackRef(
      userId,
      kind,
      trackId,
      sortOrder: sortOrder,
    );
  }

  @override
  Future<void> deleteTrackRef(
    String userId,
    UserTrackListKind kind,
    String trackId,
  ) {
    return _dao.deleteTrackRef(userId, kind, trackId);
  }

  @override
  Future<int> nextTrackSortOrder(String userId, UserTrackListKind kind) {
    return _dao.nextTrackSortOrder(userId, kind);
  }
}
