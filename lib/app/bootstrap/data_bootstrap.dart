import 'dart:async';

import 'package:bujuan/data/app_storage/app_preferences.dart';
import 'package:bujuan/data/app_storage/cache_box.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/database/app_database.dart';
import 'package:bujuan/data/music_data/sources/local/database/drift_app_database.dart';
import 'package:bujuan/data/music_data/sources/local/database/local_database_config.dart';
import 'package:bujuan/data/music_data/sources/local/local_music_source.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_artwork_cache_repository.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:bujuan/data/music_data/sources/netease/netease_music_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_album_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_artist_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_auth_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_cloud_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_comment_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_explore_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_playlist_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_radio_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_search_remote_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_user_remote_data_source.dart';
import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/auth/auth_state_store.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/explore/explore_cache_store.dart';
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/search/search_cache_store.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/features/settings/settings_repository.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:netease_music_api/netease_music_api.dart';

/// Initializes local storage, data sources, repositories and long-running recovery.
Future<void> initializeDataInfrastructure() async {
  final appDatabase = DriftAppDatabase(databaseName: LocalDatabaseConfig.databaseName);
  await appDatabase.init();

  await Hive.initFlutter('BuJuan');
  final cacheBox = await Hive.openBox('cache');
  CacheBox.init(cacheBox);
  const appPreferences = AppPreferences();

  final localLibraryDataSource = appDatabase.localLibraryDataSource;
  final localResourceIndexDataSource = appDatabase.localResourceIndexDataSource;
  final userScopedDataSource = appDatabase.userScopedDataSource;
  final downloadTaskDataSource = appDatabase.downloadTaskDataSource;
  final playbackRestoreDataSource = appDatabase.playbackRestoreDataSource;
  final appCacheDataSource = appDatabase.appCacheDataSource;
  final searchCacheStore = SearchCacheStore(
    cacheDataSource: appCacheDataSource,
  );
  final exploreCacheStore = ExploreCacheStore(
    cacheDataSource: appCacheDataSource,
  );
  final neteaseApi = NeteaseMusicApi();
  final localMusicSource = LocalMusicSource(localDataSource: localLibraryDataSource);
  final localResourceIndexRepository = LocalResourceIndexRepository(
    dataSource: localResourceIndexDataSource,
    localLibraryDataSource: localLibraryDataSource,
  );
  final sharedDio = Dio();
  final localArtworkCacheRepository = LocalArtworkCacheRepository(
    dio: sharedDio,
    resourceIndexRepository: localResourceIndexRepository,
  );
  final musicDataRepository = MusicDataRepository(
    localDataSource: localLibraryDataSource,
    localMusicSource: localMusicSource,
    neteaseSource: NeteaseMusicSource(api: neteaseApi),
    resourceIndexRepository: localResourceIndexRepository,
    artworkCacheRepository: localArtworkCacheRepository,
  );
  final downloadRepository = DownloadRepository(
    musicDataRepository: musicDataRepository,
    taskDataSource: downloadTaskDataSource,
    resourceIndexRepository: localResourceIndexRepository,
    dio: sharedDio,
  );
  final playbackRepository = PlaybackRepository(
    musicDataRepository: musicDataRepository,
    playbackRestoreDataSource: playbackRestoreDataSource,
  );

  _registerInfrastructure(
    appPreferences: appPreferences,
    appDatabase: appDatabase,
    localLibraryDataSource: localLibraryDataSource,
    playbackRestoreDataSource: playbackRestoreDataSource,
    localResourceIndexDataSource: localResourceIndexDataSource,
    downloadTaskDataSource: downloadTaskDataSource,
    appCacheDataSource: appCacheDataSource,
    userScopedDataSource: userScopedDataSource,
    localMusicSource: localMusicSource,
    localResourceIndexRepository: localResourceIndexRepository,
    localArtworkCacheRepository: localArtworkCacheRepository,
  );
  _registerRepositories(
    appPreferences: appPreferences,
    musicDataRepository: musicDataRepository,
    userScopedDataSource: userScopedDataSource,
    appCacheDataSource: appCacheDataSource,
    localLibraryDataSource: localLibraryDataSource,
    searchCacheStore: searchCacheStore,
    exploreCacheStore: exploreCacheStore,
    localResourceIndexRepository: localResourceIndexRepository,
    downloadRepository: downloadRepository,
    playbackRepository: playbackRepository,
    neteaseApi: neteaseApi,
  );

  unawaited(downloadRepository.recoverInterruptedTasks());
}

void _registerInfrastructure({
  required AppPreferences appPreferences,
  required AppDatabase appDatabase,
  required LocalLibraryDataSource localLibraryDataSource,
  required PlaybackRestoreDataSource playbackRestoreDataSource,
  required LocalResourceIndexDataSource localResourceIndexDataSource,
  required DownloadTaskDataSource downloadTaskDataSource,
  required AppCacheDataSource appCacheDataSource,
  required UserScopedDataSource userScopedDataSource,
  required LocalMusicSource localMusicSource,
  required LocalResourceIndexRepository localResourceIndexRepository,
  required LocalArtworkCacheRepository localArtworkCacheRepository,
}) {
  Get.put<AppPreferences>(appPreferences, permanent: true);
  Get.put<AppDatabase>(appDatabase, permanent: true);
  Get.put<LocalLibraryDataSource>(localLibraryDataSource, permanent: true);
  Get.put<PlaybackRestoreDataSource>(
    playbackRestoreDataSource,
    permanent: true,
  );
  Get.put<LocalResourceIndexDataSource>(
    localResourceIndexDataSource,
    permanent: true,
  );
  Get.put<DownloadTaskDataSource>(downloadTaskDataSource, permanent: true);
  Get.put<AppCacheDataSource>(appCacheDataSource, permanent: true);
  Get.put<UserScopedDataSource>(userScopedDataSource, permanent: true);
  Get.put<LocalMusicSource>(localMusicSource, permanent: true);
  Get.put<LocalResourceIndexRepository>(
    localResourceIndexRepository,
    permanent: true,
  );
  Get.put<LocalArtworkCacheRepository>(
    localArtworkCacheRepository,
    permanent: true,
  );
}

void _registerRepositories({
  required AppPreferences appPreferences,
  required MusicDataRepository musicDataRepository,
  required UserScopedDataSource userScopedDataSource,
  required AppCacheDataSource appCacheDataSource,
  required LocalLibraryDataSource localLibraryDataSource,
  required SearchCacheStore searchCacheStore,
  required ExploreCacheStore exploreCacheStore,
  required LocalResourceIndexRepository localResourceIndexRepository,
  required DownloadRepository downloadRepository,
  required PlaybackRepository playbackRepository,
  required NeteaseMusicApi neteaseApi,
}) {
  final authRemoteDataSource = NeteaseAuthRemoteDataSource(api: neteaseApi);
  final userRemoteDataSource = NeteaseUserRemoteDataSource(api: neteaseApi);
  final playlistRemoteDataSource = NeteasePlaylistRemoteDataSource(api: neteaseApi);
  final albumRemoteDataSource = NeteaseAlbumRemoteDataSource(api: neteaseApi);
  final artistRemoteDataSource = NeteaseArtistRemoteDataSource(api: neteaseApi);
  final cloudRemoteDataSource = NeteaseCloudRemoteDataSource(api: neteaseApi);
  final radioRemoteDataSource = NeteaseRadioRemoteDataSource(api: neteaseApi);
  final searchRemoteDataSource = NeteaseSearchRemoteDataSource(api: neteaseApi);
  final commentRemoteDataSource = NeteaseCommentRemoteDataSource(api: neteaseApi);
  final exploreRemoteDataSource = NeteaseExploreRemoteDataSource(api: neteaseApi);

  Get.put<MusicDataRepository>(musicDataRepository, permanent: true);
  Get.put<AuthRepository>(
    AuthRepository(
      stateStore: const AuthStateStore(),
      remoteDataSource: authRemoteDataSource,
    ),
    permanent: true,
  );
  Get.put<SettingsRepository>(
    SettingsRepository(preferences: appPreferences),
    permanent: true,
  );
  Get.put<UserRepository>(
    UserRepository(
      musicDataRepository: musicDataRepository,
      remoteDataSource: userRemoteDataSource,
      userScopedDataSource: userScopedDataSource,
    ),
    permanent: true,
  );
  Get.put<PlaylistRepository>(
    PlaylistRepository(
      appCacheDataSource: appCacheDataSource,
      musicDataRepository: musicDataRepository,
      localLibraryDataSource: localLibraryDataSource,
      remoteDataSource: playlistRemoteDataSource,
      userScopedDataSource: userScopedDataSource,
    ),
    permanent: true,
  );
  Get.put<AlbumRepository>(
    AlbumRepository(
      musicDataRepository: musicDataRepository,
      remoteDataSource: albumRemoteDataSource,
    ),
    permanent: true,
  );
  Get.put<ArtistRepository>(
    ArtistRepository(
      musicDataRepository: musicDataRepository,
      remoteDataSource: artistRemoteDataSource,
    ),
    permanent: true,
  );
  Get.put<CloudRepository>(
    CloudRepository(
      musicDataRepository: musicDataRepository,
      userScopedDataSource: userScopedDataSource,
      remoteDataSource: cloudRemoteDataSource,
    ),
    permanent: true,
  );
  Get.put<RadioRepository>(
    RadioRepository(
      userScopedDataSource: userScopedDataSource,
      remoteDataSource: radioRemoteDataSource,
    ),
    permanent: true,
  );
  Get.put<SearchRepository>(
    SearchRepository(
      musicDataRepository: musicDataRepository,
      remoteDataSource: searchRemoteDataSource,
      cacheStore: searchCacheStore,
      userScopedDataSource: userScopedDataSource,
    ),
    permanent: true,
  );
  Get.put<LocalMediaRepository>(
    LocalMediaRepository(
      musicDataRepository: musicDataRepository,
      resourceIndexRepository: localResourceIndexRepository,
    ),
    permanent: true,
  );
  Get.put<DownloadRepository>(downloadRepository, permanent: true);
  Get.put<PlaybackRepository>(playbackRepository, permanent: true);
  Get.put<CommentRepository>(
    CommentRepository(remoteDataSource: commentRemoteDataSource),
    permanent: true,
  );
  Get.put<ExploreRepository>(
    ExploreRepository(
      remoteDataSource: exploreRemoteDataSource,
      cacheStore: exploreCacheStore,
    ),
    permanent: true,
  );
}
