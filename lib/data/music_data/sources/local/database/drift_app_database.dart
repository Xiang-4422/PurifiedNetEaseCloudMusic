import 'package:bujuan/data/music_data/sources/local/database/app_database.dart';
import 'package:bujuan/data/music_data/sources/local/database/schema/app_database_schema.dart';
import 'package:bujuan/data/music_data/sources/local/database/schema/database_collection_schema.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_database.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/cache_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/download_task_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/playlist_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/radio_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/resource_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/track_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/dao/user_dao.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_app_cache_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_download_task_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_local_library_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_local_resource_index_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_playlist_subscription_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_playback_history_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_playback_restore_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_user_playlist_list_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_user_profile_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_user_radio_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_user_scoped_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_user_sync_marker_data_source.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/drift_user_track_list_data_source.dart';

/// Drift 实现的应用数据库门面。
class DriftAppDatabase implements AppDatabase {
  /// 创建 Drift 应用数据库。
  DriftAppDatabase({required this.databaseName});

  /// 数据库文件名。
  final String databaseName;
  late final BujuanDriftDatabase _database;
  late final LocalLibraryDataSource _localLibraryDataSource;
  late final PlaybackRestoreDataSource _playbackRestoreDataSource;
  late final PlaybackHistoryDataSource _playbackHistoryDataSource;
  late final LocalResourceIndexDataSource _localResourceIndexDataSource;
  late final DownloadTaskDataSource _downloadTaskDataSource;
  late final AppCacheDataSource _appCacheDataSource;
  late final UserProfileDataSource _userProfileDataSource;
  late final UserTrackListDataSource _userTrackListDataSource;
  late final UserPlaylistListDataSource _userPlaylistListDataSource;
  late final PlaylistSubscriptionDataSource _playlistSubscriptionDataSource;
  late final UserRadioDataSource _userRadioDataSource;
  late final UserSyncMarkerDataSource _userSyncMarkerDataSource;
  late final UserScopedDataSource _userScopedDataSource;

  @override
  Future<void> init() async {
    _database = BujuanDriftDatabase(databaseName: databaseName);
    final playlistDao = PlaylistDao(database: _database);
    _localLibraryDataSource = DriftLocalLibraryDataSource(
      trackDao: TrackDao(database: _database),
      playlistDao: playlistDao,
    );
    _playbackRestoreDataSource = DriftPlaybackRestoreDataSource(database: _database);
    _playbackHistoryDataSource = DriftPlaybackHistoryDataSource(database: _database);
    _localResourceIndexDataSource = DriftLocalResourceIndexDataSource(
      dao: ResourceDao(database: _database),
    );
    _downloadTaskDataSource = DriftDownloadTaskDataSource(
      dao: DownloadTaskDao(database: _database),
    );
    _appCacheDataSource = DriftAppCacheDataSource(
      dao: CacheDao(database: _database),
    );
    final userDao = UserDao(database: _database);
    _userProfileDataSource = DriftUserProfileDataSource(userDao: userDao);
    _userTrackListDataSource = DriftUserTrackListDataSource(userDao: userDao);
    _userPlaylistListDataSource = DriftUserPlaylistListDataSource(
      dao: playlistDao,
    );
    _playlistSubscriptionDataSource = DriftPlaylistSubscriptionDataSource(
      userDao: userDao,
    );
    _userRadioDataSource = DriftUserRadioDataSource(
      dao: RadioDao(database: _database),
    );
    _userSyncMarkerDataSource = DriftUserSyncMarkerDataSource(userDao: userDao);
    _userScopedDataSource = DriftUserScopedDataSource(
      userProfileDataSource: _userProfileDataSource,
      userTrackListDataSource: _userTrackListDataSource,
      userPlaylistListDataSource: _userPlaylistListDataSource,
      playlistSubscriptionDataSource: _playlistSubscriptionDataSource,
      userRadioDataSource: _userRadioDataSource,
      userSyncMarkerDataSource: _userSyncMarkerDataSource,
    );
  }

  @override
  int get schemaVersion => AppDatabaseSchema.schemaVersion;

  @override
  List<DatabaseCollectionSchema> get collections => AppDatabaseSchema.collections;

  @override
  LocalLibraryDataSource get localLibraryDataSource => _localLibraryDataSource;

  @override
  PlaybackRestoreDataSource get playbackRestoreDataSource => _playbackRestoreDataSource;

  @override
  PlaybackHistoryDataSource get playbackHistoryDataSource => _playbackHistoryDataSource;

  @override
  LocalResourceIndexDataSource get localResourceIndexDataSource => _localResourceIndexDataSource;

  @override
  DownloadTaskDataSource get downloadTaskDataSource => _downloadTaskDataSource;

  @override
  AppCacheDataSource get appCacheDataSource => _appCacheDataSource;

  @override
  UserScopedDataSource get userScopedDataSource => _userScopedDataSource;

  @override
  UserProfileDataSource get userProfileDataSource => _userProfileDataSource;

  @override
  UserTrackListDataSource get userTrackListDataSource => _userTrackListDataSource;

  @override
  UserPlaylistListDataSource get userPlaylistListDataSource => _userPlaylistListDataSource;

  @override
  PlaylistSubscriptionDataSource get playlistSubscriptionDataSource => _playlistSubscriptionDataSource;

  @override
  UserRadioDataSource get userRadioDataSource => _userRadioDataSource;

  @override
  UserSyncMarkerDataSource get userSyncMarkerDataSource => _userSyncMarkerDataSource;
}
