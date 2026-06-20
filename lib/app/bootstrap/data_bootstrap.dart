import 'dart:async';

import 'package:bujuan/app/bootstrap/data_source_bootstrap.dart';
import 'package:bujuan/app/bootstrap/storage_bootstrap.dart';
import 'package:bujuan/data/app_storage/app_preferences.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/database/app_database.dart';
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
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/features/settings/settings_repository.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:netease_music_api/netease_music_api.dart';

/// Initializes local storage, data sources, repositories and long-running recovery.
Future<void> initializeDataInfrastructure({
  required NeteaseMusicApi neteaseApi,
}) async {
  final storage = await initializeStorageInfrastructure();
  final appDatabase = storage.appDatabase;
  final appPreferences = storage.appPreferences;
  final dataSources = initializeDataSourceInfrastructure(appDatabase: appDatabase);
  final localResourceIndexRepository = LocalResourceIndexRepository(
    dataSource: dataSources.localResourceIndexDataSource,
    localLibraryDataSource: dataSources.localLibraryDataSource,
  );
  final sharedDio = Dio();
  final localArtworkCacheRepository = LocalArtworkCacheRepository(
    dio: sharedDio,
    resourceIndexRepository: localResourceIndexRepository,
  );
  final musicDataRepository = MusicDataRepository(
    localDataSource: dataSources.localLibraryDataSource,
    localMusicSource: dataSources.localMusicSource,
    neteaseSource: NeteaseMusicSource(api: neteaseApi),
    resourceIndexRepository: localResourceIndexRepository,
    artworkCacheRepository: localArtworkCacheRepository,
  );
  final downloadRepository = DownloadRepository(
    musicDataRepository: musicDataRepository,
    taskDataSource: dataSources.downloadTaskDataSource,
    resourceIndexRepository: localResourceIndexRepository,
    dio: sharedDio,
  );
  final playbackRepository = PlaybackRepository(
    musicDataRepository: musicDataRepository,
    playbackRestoreDataSource: dataSources.playbackRestoreDataSource,
  );

  _registerInfrastructure(
    appPreferences: appPreferences,
    appDatabase: appDatabase,
    dataSources: dataSources,
    localResourceIndexRepository: localResourceIndexRepository,
    localArtworkCacheRepository: localArtworkCacheRepository,
  );
  _registerRepositories(
    appPreferences: appPreferences,
    musicDataRepository: musicDataRepository,
    dataSources: dataSources,
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
  required AppDataSourceBootstrapResult dataSources,
  required LocalResourceIndexRepository localResourceIndexRepository,
  required LocalArtworkCacheRepository localArtworkCacheRepository,
}) {
  Get.put<AppPreferences>(appPreferences, permanent: true);
  Get.put<AppDatabase>(appDatabase, permanent: true);
  Get.put(dataSources.localLibraryDataSource, permanent: true);
  Get.put<PlaybackRestoreDataSource>(
    dataSources.playbackRestoreDataSource,
    permanent: true,
  );
  Get.put<LocalResourceIndexDataSource>(
    dataSources.localResourceIndexDataSource,
    permanent: true,
  );
  Get.put(dataSources.downloadTaskDataSource, permanent: true);
  Get.put(dataSources.appCacheDataSource, permanent: true);
  Get.put(dataSources.userProfileDataSource, permanent: true);
  Get.put(dataSources.userTrackListDataSource, permanent: true);
  Get.put<UserPlaylistListDataSource>(
    dataSources.userPlaylistListDataSource,
    permanent: true,
  );
  Get.put<PlaylistSubscriptionDataSource>(
    dataSources.playlistSubscriptionDataSource,
    permanent: true,
  );
  Get.put(dataSources.userRadioDataSource, permanent: true);
  Get.put(dataSources.userSyncMarkerDataSource, permanent: true);
  Get.put(dataSources.localMusicSource, permanent: true);
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
  required AppDataSourceBootstrapResult dataSources,
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
      userProfileDataSource: dataSources.userProfileDataSource,
      userTrackListDataSource: dataSources.userTrackListDataSource,
      userPlaylistListDataSource: dataSources.userPlaylistListDataSource,
      userSyncMarkerDataSource: dataSources.userSyncMarkerDataSource,
    ),
    permanent: true,
  );
  Get.put<PlaylistRepository>(
    PlaylistRepository(
      appCacheDataSource: dataSources.appCacheDataSource,
      musicDataRepository: musicDataRepository,
      localLibraryDataSource: dataSources.localLibraryDataSource,
      remoteDataSource: playlistRemoteDataSource,
      playlistSubscriptionDataSource: dataSources.playlistSubscriptionDataSource,
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
      userTrackListDataSource: dataSources.userTrackListDataSource,
      remoteDataSource: cloudRemoteDataSource,
    ),
    permanent: true,
  );
  Get.put<RadioRepository>(
    RadioRepository(
      userRadioDataSource: dataSources.userRadioDataSource,
      remoteDataSource: radioRemoteDataSource,
    ),
    permanent: true,
  );
  Get.put<SearchRepository>(
    SearchRepository(
      musicDataRepository: musicDataRepository,
      remoteDataSource: searchRemoteDataSource,
      cacheStore: dataSources.searchCacheStore,
      userPlaylistListDataSource: dataSources.userPlaylistListDataSource,
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
      cacheStore: dataSources.exploreCacheStore,
    ),
    permanent: true,
  );
}
