import 'dart:developer' as developer;

import 'package:bujuan/app/bootstrap/data_source_bootstrap.dart';
import 'package:bujuan/data/app_storage/app_preferences.dart';
import 'package:bujuan/data/app_storage/local_image_cache_repository.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_artwork_cache_repository.dart';
import 'package:bujuan/data/music_data/sources/local/resources/local_resource_index_repository.dart';
import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/auth/auth_state_store.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/features/settings/settings_repository.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// 应用启动阶段创建并注册的 repository 集合。
class AppRepositoryBootstrapResult {
  /// 创建 repository 启动结果。
  const AppRepositoryBootstrapResult({
    required this.localResourceIndexRepository,
    required this.localArtworkCacheRepository,
    required this.localImageCacheRepository,
    required this.musicDataRepository,
    required this.authRepository,
    required this.settingsRepository,
    required this.userRepository,
    required this.playlistRepository,
    required this.albumRepository,
    required this.artistRepository,
    required this.cloudRepository,
    required this.radioRepository,
    required this.searchRepository,
    required this.localMediaRepository,
    required this.downloadRepository,
    required this.playbackRepository,
    required this.commentRepository,
  });

  /// 本地资源索引 repository。
  final LocalResourceIndexRepository localResourceIndexRepository;

  /// 本地封面缓存 repository。
  final LocalArtworkCacheRepository localArtworkCacheRepository;

  /// 本地图片展示缓存 repository。
  final LocalImageCacheRepository localImageCacheRepository;

  /// 音乐数据聚合 repository。
  final MusicDataRepository musicDataRepository;

  /// 登录 repository。
  final AuthRepository authRepository;

  /// 设置 repository。
  final SettingsRepository settingsRepository;

  /// 用户资料库 repository。
  final UserRepository userRepository;

  /// 歌单 repository。
  final PlaylistRepository playlistRepository;

  /// 专辑 repository。
  final AlbumRepository albumRepository;

  /// 歌手 repository。
  final ArtistRepository artistRepository;

  /// 云盘 repository。
  final CloudRepository cloudRepository;

  /// 电台 repository。
  final RadioRepository radioRepository;

  /// 搜索 repository。
  final SearchRepository searchRepository;

  /// 本地媒体 repository。
  final LocalMediaRepository localMediaRepository;

  /// 下载 repository。
  final DownloadRepository downloadRepository;

  /// 播放 repository。
  final PlaybackRepository playbackRepository;

  /// 评论 repository。
  final CommentRepository commentRepository;
}

/// 创建应用核心 repository 和 feature repository。
AppRepositoryBootstrapResult initializeRepositoryInfrastructure({
  required AppPreferences appPreferences,
  required AppDataSourceBootstrapResult dataSources,
}) {
  final localResourceIndexRepository = LocalResourceIndexRepository(
    dataSource: dataSources.localResourceIndexDataSource,
    localLibraryDataSource: dataSources.localLibraryDataSource,
  );
  final sharedDio = Dio();
  final localImageCacheRepository = LocalImageCacheRepository(dio: sharedDio);
  final localArtworkCacheRepository = LocalArtworkCacheRepository(
    dio: sharedDio,
    resourceIndexRepository: localResourceIndexRepository,
  );
  final musicDataRepository = MusicDataRepository(
    localDataSource: dataSources.localLibraryDataSource,
    localMusicSource: dataSources.localMusicSource,
    neteaseSource: dataSources.neteaseMusicSource,
    resourceIndexRepository: localResourceIndexRepository,
    artworkCacheRepository: localArtworkCacheRepository,
  );
  final downloadRepository = DownloadRepository(
    musicDataRepository: musicDataRepository,
    taskDataSource: dataSources.downloadTaskDataSource,
    resourceIndexRepository: localResourceIndexRepository,
    dio: sharedDio,
    onBackgroundError: _reportDownloadBackgroundError,
  );
  final playbackRepository = PlaybackRepository(
    musicDataRepository: musicDataRepository,
    playbackRestoreDataSource: dataSources.playbackRestoreDataSource,
    playbackHistoryDataSource: dataSources.playbackHistoryDataSource,
  );

  return AppRepositoryBootstrapResult(
    localResourceIndexRepository: localResourceIndexRepository,
    localArtworkCacheRepository: localArtworkCacheRepository,
    localImageCacheRepository: localImageCacheRepository,
    musicDataRepository: musicDataRepository,
    authRepository: AuthRepository(
      stateStore: const AuthStateStore(),
      remoteDataSource: dataSources.authRemoteDataSource,
    ),
    settingsRepository: SettingsRepository(preferences: appPreferences),
    userRepository: UserRepository(
      musicDataRepository: musicDataRepository,
      remoteDataSource: dataSources.userRemoteDataSource,
      userProfileDataSource: dataSources.userProfileDataSource,
      userTrackListDataSource: dataSources.userTrackListDataSource,
      userPlaylistListDataSource: dataSources.userPlaylistListDataSource,
      userSyncMarkerDataSource: dataSources.userSyncMarkerDataSource,
    ),
    playlistRepository: PlaylistRepository(
      appCacheDataSource: dataSources.appCacheDataSource,
      musicDataRepository: musicDataRepository,
      localLibraryDataSource: dataSources.localLibraryDataSource,
      remoteDataSource: dataSources.playlistRemoteDataSource,
      playlistSubscriptionDataSource: dataSources.playlistSubscriptionDataSource,
    ),
    albumRepository: AlbumRepository(
      musicDataRepository: musicDataRepository,
      remoteDataSource: dataSources.albumRemoteDataSource,
    ),
    artistRepository: ArtistRepository(
      musicDataRepository: musicDataRepository,
      remoteDataSource: dataSources.artistRemoteDataSource,
    ),
    cloudRepository: CloudRepository(
      musicDataRepository: musicDataRepository,
      userTrackListDataSource: dataSources.userTrackListDataSource,
      remoteDataSource: dataSources.cloudRemoteDataSource,
    ),
    radioRepository: RadioRepository(
      userRadioDataSource: dataSources.userRadioDataSource,
      remoteDataSource: dataSources.radioRemoteDataSource,
    ),
    searchRepository: SearchRepository(
      musicDataRepository: musicDataRepository,
      remoteDataSource: dataSources.searchRemoteDataSource,
      cacheStore: dataSources.searchCacheStore,
      userPlaylistListDataSource: dataSources.userPlaylistListDataSource,
    ),
    localMediaRepository: LocalMediaRepository(
      musicDataRepository: musicDataRepository,
      resourceIndexRepository: localResourceIndexRepository,
    ),
    downloadRepository: downloadRepository,
    playbackRepository: playbackRepository,
    commentRepository: CommentRepository(
      remoteDataSource: dataSources.commentRemoteDataSource,
      cacheStore: dataSources.commentCacheStore,
    ),
  );
}

void _reportDownloadBackgroundError(
  String trackId,
  Object error,
  StackTrace stackTrace,
) {
  developer.log(
    'download.background.failed trackId=$trackId',
    name: 'Download',
    error: error,
    stackTrace: stackTrace,
  );
}

/// 注册 repository，使后续 playback 和 feature bootstrap 只从容器读取。
void registerRepositoryInfrastructure(AppRepositoryBootstrapResult repositories) {
  Get.put<LocalResourceIndexRepository>(
    repositories.localResourceIndexRepository,
    permanent: true,
  );
  Get.put<LocalArtworkCacheRepository>(
    repositories.localArtworkCacheRepository,
    permanent: true,
  );
  Get.put<LocalImageCacheRepository>(
    repositories.localImageCacheRepository,
    permanent: true,
  );
  Get.put<MusicDataRepository>(repositories.musicDataRepository, permanent: true);
  Get.put<AuthRepository>(repositories.authRepository, permanent: true);
  Get.put<SettingsRepository>(repositories.settingsRepository, permanent: true);
  Get.put<UserRepository>(repositories.userRepository, permanent: true);
  Get.put<PlaylistRepository>(repositories.playlistRepository, permanent: true);
  Get.put<AlbumRepository>(repositories.albumRepository, permanent: true);
  Get.put<ArtistRepository>(repositories.artistRepository, permanent: true);
  Get.put<CloudRepository>(repositories.cloudRepository, permanent: true);
  Get.put<RadioRepository>(repositories.radioRepository, permanent: true);
  Get.put<SearchRepository>(repositories.searchRepository, permanent: true);
  Get.put<LocalMediaRepository>(repositories.localMediaRepository, permanent: true);
  Get.put<DownloadRepository>(repositories.downloadRepository, permanent: true);
  Get.put<PlaybackRepository>(repositories.playbackRepository, permanent: true);
  Get.put<CommentRepository>(repositories.commentRepository, permanent: true);
}
