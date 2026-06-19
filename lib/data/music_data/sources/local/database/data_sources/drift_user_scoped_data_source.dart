import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/core/entities/radio_data.dart';
import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/core/entities/user_profile_data.dart';

import 'user_scoped_data_source.dart';

/// Drift 用户作用域数据源聚合器。
class DriftUserScopedDataSource implements UserScopedDataSource {
  /// 创建 Drift 用户作用域数据源聚合器。
  const DriftUserScopedDataSource({
    required UserProfileDataSource userProfileDataSource,
    required UserTrackListDataSource userTrackListDataSource,
    required UserPlaylistListDataSource userPlaylistListDataSource,
    required PlaylistSubscriptionDataSource playlistSubscriptionDataSource,
    required UserRadioDataSource userRadioDataSource,
    required UserSyncMarkerDataSource userSyncMarkerDataSource,
  })  : _userProfileDataSource = userProfileDataSource,
        _userTrackListDataSource = userTrackListDataSource,
        _userPlaylistListDataSource = userPlaylistListDataSource,
        _playlistSubscriptionDataSource = playlistSubscriptionDataSource,
        _userRadioDataSource = userRadioDataSource,
        _userSyncMarkerDataSource = userSyncMarkerDataSource;

  final UserProfileDataSource _userProfileDataSource;
  final UserTrackListDataSource _userTrackListDataSource;
  final UserPlaylistListDataSource _userPlaylistListDataSource;
  final PlaylistSubscriptionDataSource _playlistSubscriptionDataSource;
  final UserRadioDataSource _userRadioDataSource;
  final UserSyncMarkerDataSource _userSyncMarkerDataSource;

  @override
  Future<UserProfileData?> loadProfile(String userId) {
    return _userProfileDataSource.loadProfile(userId);
  }

  @override
  Future<void> saveProfile(UserProfileData profile) {
    return _userProfileDataSource.saveProfile(profile);
  }

  @override
  Future<List<String>> loadTrackIds(String userId, UserTrackListKind kind) {
    return _userTrackListDataSource.loadTrackIds(userId, kind);
  }

  @override
  Future<void> replaceTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds,
  ) {
    return _userTrackListDataSource.replaceTrackList(userId, kind, trackIds);
  }

  @override
  Future<void> appendTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds, {
    required int startOrder,
  }) {
    return _userTrackListDataSource.appendTrackList(
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
    return _userTrackListDataSource.upsertTrackRef(
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
    return _userTrackListDataSource.deleteTrackRef(userId, kind, trackId);
  }

  @override
  Future<int> nextTrackSortOrder(String userId, UserTrackListKind kind) {
    return _userTrackListDataSource.nextTrackSortOrder(userId, kind);
  }

  @override
  Future<List<PlaylistSummaryData>> loadPlaylistItems(
    String userId,
    UserPlaylistListKind kind, {
    String? keyword,
  }) {
    return _userPlaylistListDataSource.loadPlaylistItems(
      userId,
      kind,
      keyword: keyword,
    );
  }

  @override
  Future<List<PlaylistSummaryData>> searchPlaylistItems(
    String userId,
    String keyword,
  ) {
    return _userPlaylistListDataSource.searchPlaylistItems(userId, keyword);
  }

  @override
  Future<void> replacePlaylistItems(
    String userId,
    UserPlaylistListKind kind,
    List<PlaylistSummaryData> items,
  ) {
    return _userPlaylistListDataSource.replacePlaylistItems(
      userId,
      kind,
      items,
    );
  }

  @override
  Future<void> appendPlaylistItems(
    String userId,
    UserPlaylistListKind kind,
    List<PlaylistSummaryData> items, {
    required int startOrder,
  }) {
    return _userPlaylistListDataSource.appendPlaylistItems(
      userId,
      kind,
      items,
      startOrder: startOrder,
    );
  }

  @override
  Future<bool?> loadPlaylistSubscriptionState(
    String userId,
    String playlistId,
  ) {
    return _playlistSubscriptionDataSource.loadPlaylistSubscriptionState(
      userId,
      playlistId,
    );
  }

  @override
  Future<void> savePlaylistSubscriptionState(
    String userId,
    String playlistId,
    bool isSubscribed,
  ) {
    return _playlistSubscriptionDataSource.savePlaylistSubscriptionState(
      userId,
      playlistId,
      isSubscribed,
    );
  }

  @override
  Future<List<RadioSummaryData>> loadSubscribedRadios(String userId) {
    return _userRadioDataSource.loadSubscribedRadios(userId);
  }

  @override
  Future<void> replaceSubscribedRadios(
    String userId,
    List<RadioSummaryData> items,
  ) {
    return _userRadioDataSource.replaceSubscribedRadios(userId, items);
  }

  @override
  Future<void> appendSubscribedRadios(
    String userId,
    List<RadioSummaryData> items, {
    required int startOrder,
  }) {
    return _userRadioDataSource.appendSubscribedRadios(
      userId,
      items,
      startOrder: startOrder,
    );
  }

  @override
  Future<List<RadioProgramData>> loadPrograms(
    String userId,
    String radioId, {
    required bool asc,
  }) {
    return _userRadioDataSource.loadPrograms(
      userId,
      radioId,
      asc: asc,
    );
  }

  @override
  Future<void> replacePrograms(
    String userId,
    String radioId, {
    required bool asc,
    required List<RadioProgramData> items,
  }) {
    return _userRadioDataSource.replacePrograms(
      userId,
      radioId,
      asc: asc,
      items: items,
    );
  }

  @override
  Future<void> appendPrograms(
    String userId,
    String radioId, {
    required bool asc,
    required List<RadioProgramData> items,
    required int startOrder,
  }) {
    return _userRadioDataSource.appendPrograms(
      userId,
      radioId,
      asc: asc,
      items: items,
      startOrder: startOrder,
    );
  }

  @override
  Future<DateTime?> loadSyncMarker(String userId, String markerKey) {
    return _userSyncMarkerDataSource.loadSyncMarker(userId, markerKey);
  }

  @override
  Future<void> markSyncMarkerUpdated(String userId, String markerKey) {
    return _userSyncMarkerDataSource.markSyncMarkerUpdated(userId, markerKey);
  }

  @override
  Future<void> clearSyncMarker(String userId, String markerKey) {
    return _userSyncMarkerDataSource.clearSyncMarker(userId, markerKey);
  }
}
