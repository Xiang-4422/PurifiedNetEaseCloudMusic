import 'package:bujuan/domain/entities/playlist_summary_data.dart';
import 'package:bujuan/domain/entities/radio_data.dart';
import 'package:bujuan/domain/entities/user_library_kinds.dart';
import 'package:bujuan/domain/entities/user_profile_data.dart';

abstract class UserScopedDataSource {
  Future<UserProfileData?> loadProfile(String userId);

  Future<void> saveProfile(UserProfileData profile);

  Future<List<String>> loadTrackIds(
    String userId,
    UserTrackListKind kind,
  );

  Future<void> replaceTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds,
  );

  Future<void> appendTrackList(
    String userId,
    UserTrackListKind kind,
    List<String> trackIds, {
    required int startOrder,
  });

  Future<void> upsertTrackRef(
    String userId,
    UserTrackListKind kind,
    String trackId, {
    int? sortOrder,
  });

  Future<void> deleteTrackRef(
    String userId,
    UserTrackListKind kind,
    String trackId,
  );

  Future<int> nextTrackSortOrder(
    String userId,
    UserTrackListKind kind,
  );

  Future<List<PlaylistSummaryData>> loadPlaylistItems(
    String userId,
    UserPlaylistListKind kind, {
    String? keyword,
  });

  Future<List<PlaylistSummaryData>> searchPlaylistItems(
    String userId,
    String keyword,
  );

  Future<void> replacePlaylistItems(
    String userId,
    UserPlaylistListKind kind,
    List<PlaylistSummaryData> items,
  );

  Future<void> appendPlaylistItems(
    String userId,
    UserPlaylistListKind kind,
    List<PlaylistSummaryData> items, {
    required int startOrder,
  });

  Future<bool?> loadPlaylistSubscriptionState(
    String userId,
    String playlistId,
  );

  Future<void> savePlaylistSubscriptionState(
    String userId,
    String playlistId,
    bool isSubscribed,
  );

  Future<List<RadioSummaryData>> loadSubscribedRadios(String userId);

  Future<void> replaceSubscribedRadios(
    String userId,
    List<RadioSummaryData> items,
  );

  Future<void> appendSubscribedRadios(
    String userId,
    List<RadioSummaryData> items, {
    required int startOrder,
  });

  Future<List<RadioProgramData>> loadPrograms(
    String userId,
    String radioId, {
    required bool asc,
  });

  Future<void> replacePrograms(
    String userId,
    String radioId, {
    required bool asc,
    required List<RadioProgramData> items,
  });

  Future<void> appendPrograms(
    String userId,
    String radioId, {
    required bool asc,
    required List<RadioProgramData> items,
    required int startOrder,
  });

  Future<DateTime?> loadSyncMarker(
    String userId,
    String markerKey,
  );

  Future<void> markSyncMarkerUpdated(
    String userId,
    String markerKey,
  );

  Future<void> clearSyncMarker(
    String userId,
    String markerKey,
  );
}
