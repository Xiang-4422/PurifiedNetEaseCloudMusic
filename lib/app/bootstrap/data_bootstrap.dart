import 'dart:async';
import 'dart:developer' as developer;

import 'package:bujuan/app/bootstrap/data_source_bootstrap.dart';
import 'package:bujuan/app/bootstrap/repository_bootstrap.dart';
import 'package:bujuan/app/bootstrap/storage_bootstrap.dart';
import 'package:bujuan/data/app_storage/app_preferences.dart';
import 'package:bujuan/data/music_data/sources/local/database/app_database.dart';
import 'package:get/get.dart';
import 'package:netease_music_api/netease_music_api.dart';

/// Initializes local storage, data sources, repositories and long-running recovery.
Future<void> initializeDataInfrastructure({
  required NeteaseMusicApi neteaseApi,
}) async {
  final storage = await initializeStorageInfrastructure();
  final appDatabase = storage.appDatabase;
  final appPreferences = storage.appPreferences;
  final dataSources = initializeDataSourceInfrastructure(
    appDatabase: appDatabase,
    neteaseApi: neteaseApi,
  );
  final repositories = initializeRepositoryInfrastructure(
    appPreferences: appPreferences,
    dataSources: dataSources,
  );

  _registerInfrastructure(
    appPreferences: appPreferences,
    appDatabase: appDatabase,
    dataSources: dataSources,
  );
  registerRepositoryInfrastructure(repositories);

  unawaited(
    repositories.downloadRepository.recoverInterruptedTasks().then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        developer.log(
          'download.recovery.failed',
          name: 'Download',
          error: error,
          stackTrace: stackTrace,
        );
      },
    ),
  );
}

void _registerInfrastructure({
  required AppPreferences appPreferences,
  required AppDatabase appDatabase,
  required AppDataSourceBootstrapResult dataSources,
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
}
