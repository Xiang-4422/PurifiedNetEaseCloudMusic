import 'package:bujuan/core/entities/user_library_kinds.dart';
import 'package:bujuan/core/entities/user_profile_data.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/user_playlist_subscription_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/user_profile_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/user_sync_marker_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/user_track_list_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_playlist_subscription_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_user_profile_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_user_sync_marker_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_user_track_list_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Drift user capability data sources', () {
    late BujuanDriftDatabase database;
    late DriftUserProfileDataSource profileDataSource;
    late DriftUserTrackListDataSource trackListDataSource;
    late DriftPlaylistSubscriptionDataSource subscriptionDataSource;
    late DriftUserSyncMarkerDataSource syncMarkerDataSource;

    setUp(() {
      database = BujuanDriftDatabase.connect(NativeDatabase.memory());
      profileDataSource = DriftUserProfileDataSource(
        dao: UserProfileDao(database: database),
      );
      trackListDataSource = DriftUserTrackListDataSource(
        dao: UserTrackListDao(database: database),
      );
      subscriptionDataSource = DriftPlaylistSubscriptionDataSource(
        dao: UserPlaylistSubscriptionDao(database: database),
      );
      syncMarkerDataSource = DriftUserSyncMarkerDataSource(
        dao: UserSyncMarkerDao(database: database),
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('stores profiles by user id', () async {
      await profileDataSource.saveProfile(_profile('user-a', nickname: 'Alice'));
      await profileDataSource.saveProfile(_profile('user-b', nickname: 'Bob'));

      final userA = await profileDataSource.loadProfile('user-a');
      final userB = await profileDataSource.loadProfile('user-b');

      expect(userA?.nickname, 'Alice');
      expect(userB?.nickname, 'Bob');
    });

    test('stores track lists by user id and list kind', () async {
      await trackListDataSource.replaceTrackList(
        'user-a',
        UserTrackListKind.liked,
        const ['1', '2'],
      );
      await trackListDataSource.replaceTrackList(
        'user-a',
        UserTrackListKind.cloud,
        const ['cloud-1'],
      );
      await trackListDataSource.replaceTrackList(
        'user-b',
        UserTrackListKind.liked,
        const ['3'],
      );
      await trackListDataSource.appendTrackList(
        'user-a',
        UserTrackListKind.liked,
        const ['4'],
        startOrder: 2,
      );

      final userALiked = await trackListDataSource.loadTrackIds(
        'user-a',
        UserTrackListKind.liked,
      );
      final userACloud = await trackListDataSource.loadTrackIds(
        'user-a',
        UserTrackListKind.cloud,
      );
      final userBLiked = await trackListDataSource.loadTrackIds(
        'user-b',
        UserTrackListKind.liked,
      );

      expect(userALiked, ['1', '2', '4']);
      expect(userACloud, ['cloud-1']);
      expect(userBLiked, ['3']);
    });

    test('stores playlist subscription state by user id', () async {
      await subscriptionDataSource.savePlaylistSubscriptionState(
        'user-a',
        'playlist',
        true,
      );
      await subscriptionDataSource.savePlaylistSubscriptionState(
        'user-b',
        'playlist',
        false,
      );

      final userAState = await subscriptionDataSource.loadPlaylistSubscriptionState(
        'user-a',
        'playlist',
      );
      final userBState = await subscriptionDataSource.loadPlaylistSubscriptionState(
        'user-b',
        'playlist',
      );

      expect(userAState, isTrue);
      expect(userBState, isFalse);
    });

    test('stores sync markers by user id and marker key', () async {
      await syncMarkerDataSource.markSyncMarkerUpdated('user-a', 'liked');
      await syncMarkerDataSource.markSyncMarkerUpdated('user-b', 'liked');
      await syncMarkerDataSource.markSyncMarkerUpdated('user-a', 'cloud');
      await syncMarkerDataSource.clearSyncMarker('user-b', 'liked');

      final userALiked = await syncMarkerDataSource.loadSyncMarker(
        'user-a',
        'liked',
      );
      final userACloud = await syncMarkerDataSource.loadSyncMarker(
        'user-a',
        'cloud',
      );
      final userBLiked = await syncMarkerDataSource.loadSyncMarker(
        'user-b',
        'liked',
      );

      expect(userALiked, isNotNull);
      expect(userACloud, isNotNull);
      expect(userBLiked, isNull);
    });
  });
}

UserProfileData _profile(String userId, {required String nickname}) {
  return UserProfileData(
    userId: userId,
    nickname: nickname,
    signature: '',
    follows: 0,
    followeds: 0,
    playlistCount: 0,
    avatarUrl: '',
  );
}
