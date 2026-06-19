import 'package:bujuan/core/entities/user_profile_data.dart';

import '../dao/user_dao.dart';
import 'user_scoped_data_source.dart';

/// Drift 实现的用户资料数据源。
class DriftUserProfileDataSource implements UserProfileDataSource {
  /// 创建 Drift 用户资料数据源。
  const DriftUserProfileDataSource({required UserDao userDao}) : _userDao = userDao;

  final UserDao _userDao;

  @override
  Future<UserProfileData?> loadProfile(String userId) {
    return _userDao.loadProfile(userId);
  }

  @override
  Future<void> saveProfile(UserProfileData profile) {
    return _userDao.saveProfile(profile);
  }
}
