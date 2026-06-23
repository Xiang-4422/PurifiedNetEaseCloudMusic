import 'package:bujuan/core/entities/user_profile_data.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart' as db;
import 'package:drift/drift.dart' as drift;

/// 用户资料 DAO。
class UserProfileDao {
  /// 创建用户资料 DAO。
  UserProfileDao({required db.BujuanDriftDatabase database}) : _database = database;

  final db.BujuanDriftDatabase _database;

  /// 读取用户资料。
  Future<UserProfileData?> loadProfile(String userId) async {
    final row = await (_database.select(_database.userProfiles)..where((tbl) => tbl.userId.equals(userId))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return UserProfileData(
      userId: row.userId,
      nickname: row.nickname,
      signature: row.signature,
      follows: row.follows,
      followeds: row.followeds,
      playlistCount: row.playlistCount,
      avatarUrl: row.avatarUrl,
    );
  }

  /// 保存用户资料。
  Future<void> saveProfile(UserProfileData profile) {
    return _database.into(_database.userProfiles).insertOnConflictUpdate(
          db.UserProfilesCompanion(
            userId: drift.Value(profile.userId),
            nickname: drift.Value(profile.nickname),
            signature: drift.Value(profile.signature),
            follows: drift.Value(profile.follows),
            followeds: drift.Value(profile.followeds),
            playlistCount: drift.Value(profile.playlistCount),
            avatarUrl: drift.Value(profile.avatarUrl),
            updatedAtMs: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }
}
