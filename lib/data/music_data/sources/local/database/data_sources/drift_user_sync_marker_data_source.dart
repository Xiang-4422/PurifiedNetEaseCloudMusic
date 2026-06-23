import '../dao/user_sync_marker_dao.dart';
import 'user_scoped_data_source.dart';

/// Drift 实现的用户同步标记数据源。
class DriftUserSyncMarkerDataSource implements UserSyncMarkerDataSource {
  /// 创建 Drift 用户同步标记数据源。
  const DriftUserSyncMarkerDataSource({required UserSyncMarkerDao dao}) : _dao = dao;

  final UserSyncMarkerDao _dao;

  @override
  Future<DateTime?> loadSyncMarker(String userId, String markerKey) {
    return _dao.loadSyncMarker(userId, markerKey);
  }

  @override
  Future<void> markSyncMarkerUpdated(String userId, String markerKey) {
    return _dao.markSyncMarkerUpdated(userId, markerKey);
  }

  @override
  Future<void> clearSyncMarker(String userId, String markerKey) {
    return _dao.clearSyncMarker(userId, markerKey);
  }
}
