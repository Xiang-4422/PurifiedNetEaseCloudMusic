import 'dart:convert';

import 'package:bujuan/data/local/app_cache_data_source.dart';
import 'package:bujuan/domain/entities/user_profile_data.dart';

/// UserProfileCacheStore。
class UserProfileCacheStore {
  /// 创建 UserProfileCacheStore。
  const UserProfileCacheStore({
    required AppCacheDataSource cacheDataSource,
  }) : _cacheDataSource = cacheDataSource;

  final AppCacheDataSource _cacheDataSource;

  /// loadProfile。
  Future<UserProfileData?> loadProfile(String userId) async {
    final payloadJson =
        await _cacheDataSource.loadPayloadJson(_profileCacheKey(userId));
    if (payloadJson == null) {
      return null;
    }
    final cachedProfile = jsonDecode(payloadJson);
    if (cachedProfile is! Map) {
      return null;
    }
    return UserProfileData.fromJson(
      Map<String, dynamic>.from(
        cachedProfile.map((key, value) => MapEntry('$key', value)),
      ),
    );
  }

  /// saveProfile。
  Future<void> saveProfile(UserProfileData profile) async {
    await _cacheDataSource.save(
      cacheKey: _profileCacheKey(profile.userId),
      payloadJson: jsonEncode(profile.toJson()),
    );
  }

  /// clearProfile。
  Future<void> clearProfile(String userId) {
    return _cacheDataSource.delete(_profileCacheKey(userId));
  }

  /// clearAllProfiles。
  Future<void> clearAllProfiles() {
    return _cacheDataSource.deleteByPrefix(_profileKeyPrefix);
  }

  String _profileCacheKey(String userId) => 'USER_PROFILE_$userId';

  static const String _profileKeyPrefix = 'USER_PROFILE_';
}
