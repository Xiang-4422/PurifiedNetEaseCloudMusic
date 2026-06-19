import '../dao/user_dao.dart';
import 'user_scoped_data_source.dart';

/// Drift 实现的用户同步标记数据源。
class DriftUserSyncMarkerDataSource implements UserSyncMarkerDataSource {
  /// 创建 Drift 用户同步标记数据源。
  const DriftUserSyncMarkerDataSource({required UserDao userDao}) : _userDao = userDao;

  final UserDao _userDao;

  @override
  Future<DateTime?> loadSyncMarker(String userId, String markerKey) {
    return _userDao.loadSyncMarker(userId, markerKey);
  }

  @override
  Future<void> markSyncMarkerUpdated(String userId, String markerKey) {
    return _userDao.markSyncMarkerUpdated(userId, markerKey);
  }

  @override
  Future<void> clearSyncMarker(String userId, String markerKey) {
    return _userDao.clearSyncMarker(userId, markerKey);
  }
}
