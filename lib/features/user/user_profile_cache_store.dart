import 'dart:convert';

import 'package:bujuan/core/storage/cache_box.dart';

import 'user_profile_data.dart';

class UserProfileCacheStore {
  const UserProfileCacheStore();

  Future<UserProfileData?> loadProfile(String userId) async {
    final cachedProfile = CacheBox.instance.get(_profileCacheKey(userId));
    if (cachedProfile is! Map) {
      return null;
    }
    return UserProfileData.fromJson(
      Map<String, dynamic>.from(
        cachedProfile.map((key, value) => MapEntry('$key', value)),
      ),
    );
  }

  Future<void> saveProfile(UserProfileData profile) async {
    await CacheBox.instance.put(
      _profileCacheKey(profile.userId),
      jsonDecode(jsonEncode(profile.toJson())),
    );
  }

  Future<void> clearProfile(String userId) {
    return CacheBox.instance.delete(_profileCacheKey(userId));
  }

  Future<void> clearAllProfiles() async {
    final keys = CacheBox.instance.keys
        .where((key) => '$key'.startsWith(_profileKeyPrefix))
        .toList();
    for (final key in keys) {
      await CacheBox.instance.delete(key);
    }
  }

  String _profileCacheKey(String userId) => 'USER_PROFILE_$userId';

  static const String _profileKeyPrefix = 'USER_PROFILE_';
}
