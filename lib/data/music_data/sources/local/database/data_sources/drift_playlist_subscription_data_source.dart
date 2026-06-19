import '../dao/user_dao.dart';
import 'user_scoped_data_source.dart';

/// Drift 实现的歌单订阅状态数据源。
class DriftPlaylistSubscriptionDataSource implements PlaylistSubscriptionDataSource {
  /// 创建 Drift 歌单订阅状态数据源。
  const DriftPlaylistSubscriptionDataSource({required UserDao userDao}) : _userDao = userDao;

  final UserDao _userDao;

  @override
  Future<bool?> loadPlaylistSubscriptionState(
    String userId,
    String playlistId,
  ) {
    return _userDao.loadPlaylistSubscriptionState(userId, playlistId);
  }

  @override
  Future<void> savePlaylistSubscriptionState(
    String userId,
    String playlistId,
    bool isSubscribed,
  ) {
    return _userDao.savePlaylistSubscriptionState(
      userId,
      playlistId,
      isSubscribed,
    );
  }
}
