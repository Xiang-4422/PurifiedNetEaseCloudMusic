import 'package:bujuan/core/database/drift_database.dart' as db;
import 'package:bujuan/domain/entities/user_profile_data.dart';
import 'package:drift/drift.dart' as drift;

class UserDao {
  UserDao({required db.BujuanDriftDatabase database}) : _database = database;

  final db.BujuanDriftDatabase _database;

  Future<UserProfileData?> loadProfile(String userId) async {
    final row = await (_database.select(_database.userProfiles)
          ..where((tbl) => tbl.userId.equals(userId)))
        .getSingleOrNull();
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

  Future<DateTime?> loadSyncMarker(String userId, String markerKey) async {
    final row = await (_database.select(_database.userSyncMarkers)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) & tbl.markerKey.equals(markerKey),
          ))
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(row.updatedAtMs);
  }

  Future<void> markSyncMarkerUpdated(String userId, String markerKey) {
    return _database.into(_database.userSyncMarkers).insertOnConflictUpdate(
          db.UserSyncMarkersCompanion(
            userId: drift.Value(userId),
            markerKey: drift.Value(markerKey),
            updatedAtMs: drift.Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
  }

  Future<void> clearSyncMarker(String userId, String markerKey) {
    return (_database.delete(_database.userSyncMarkers)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) & tbl.markerKey.equals(markerKey),
          ))
        .go();
  }
}
