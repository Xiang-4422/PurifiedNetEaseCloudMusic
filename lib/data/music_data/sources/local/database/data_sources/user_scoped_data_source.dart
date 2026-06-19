import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/radio_data.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/core/entities/user_profile_data.dart';

/// 用户资料本地数据源。
abstract class UserProfileDataSource {
  /// 读取用户资料。
  Future<UserProfileData?> loadProfile(String userId);

  /// 保存用户资料。
  Future<void> saveProfile(UserProfileData profile);
}

/// 用户曲目列表本地数据源。
abstract class UserTrackListDataSource {
  /// 读取用户曲目 id 列表。
  Future<List<String>> loadTrackIds(
    String userId,
    UserTrackListKind kind,
  );

  /// 替换用户曲目列表。
  Future<void> replaceTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds,
  );

  /// 追加用户曲目列表。
  Future<void> appendTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds, {
    required int startOrder,
  });

  /// 插入或更新单个用户曲目引用。
  Future<void> upsertTrackRef(
    String userId,
    UserTrackListKind kind,
    String trackId, {
    int? sortOrder,
  });

  /// 删除单个用户曲目引用。
  Future<void> deleteTrackRef(
    String userId,
    UserTrackListKind kind,
    String trackId,
  );

  /// 获取下一个曲目排序值。
  Future<int> nextTrackSortOrder(
    String userId,
    UserTrackListKind kind,
  );
}

/// 用户歌单列表本地数据源。
abstract class UserPlaylistListDataSource {
  /// 读取用户歌单摘要列表。
  Future<List<PlaylistSummaryData>> loadPlaylistItems(
    String userId,
    UserPlaylistListKind kind, {
    String? keyword,
  });

  /// 搜索用户歌单摘要。
  Future<List<PlaylistSummaryData>> searchPlaylistItems(
    String userId,
    String keyword,
  );

  /// 替换用户歌单摘要列表。
  Future<void> replacePlaylistItems(
    String userId,
    UserPlaylistListKind kind,
    List<PlaylistSummaryData> items,
  );

  /// 追加用户歌单摘要列表。
  Future<void> appendPlaylistItems(
    String userId,
    UserPlaylistListKind kind,
    List<PlaylistSummaryData> items, {
    required int startOrder,
  });
}

/// 用户歌单订阅状态本地数据源。
abstract class PlaylistSubscriptionDataSource {
  /// 读取歌单订阅状态。
  Future<bool?> loadPlaylistSubscriptionState(
    String userId,
    String playlistId,
  );

  /// 保存歌单订阅状态。
  Future<void> savePlaylistSubscriptionState(
    String userId,
    String playlistId,
    bool isSubscribed,
  );
}

/// 用户电台本地数据源。
abstract class UserRadioDataSource {
  /// 读取用户订阅电台列表。
  Future<List<RadioSummaryData>> loadSubscribedRadios(String userId);

  /// 替换用户订阅电台列表。
  Future<void> replaceSubscribedRadios(
    String userId,
    List<RadioSummaryData> items,
  );

  /// 追加用户订阅电台列表。
  Future<void> appendSubscribedRadios(
    String userId,
    List<RadioSummaryData> items, {
    required int startOrder,
  });

  /// 读取电台节目列表。
  Future<List<RadioProgramData>> loadPrograms(
    String userId,
    String radioId, {
    required bool asc,
  });

  /// 替换电台节目列表。
  Future<void> replacePrograms(
    String userId,
    String radioId, {
    required bool asc,
    required List<RadioProgramData> items,
  });

  /// 追加电台节目列表。
  Future<void> appendPrograms(
    String userId,
    String radioId, {
    required bool asc,
    required List<RadioProgramData> items,
    required int startOrder,
  });
}

/// 用户同步标记本地数据源。
abstract class UserSyncMarkerDataSource {
  /// 读取同步标记时间。
  Future<DateTime?> loadSyncMarker(
    String userId,
    String markerKey,
  );

  /// 标记同步时间为当前时间。
  Future<void> markSyncMarkerUpdated(
    String userId,
    String markerKey,
  );

  /// 清理同步标记。
  Future<void> clearSyncMarker(
    String userId,
    String markerKey,
  );
}

/// 用户作用域本地数据源聚合接口，仅用于数据库门面和兼容装配。
abstract class UserScopedDataSource implements UserProfileDataSource, UserTrackListDataSource, UserPlaylistListDataSource, PlaylistSubscriptionDataSource, UserRadioDataSource, UserSyncMarkerDataSource {}
