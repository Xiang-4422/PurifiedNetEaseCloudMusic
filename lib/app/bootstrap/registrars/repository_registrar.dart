import 'package:bujuan/data/local/app_cache_data_source.dart';
import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/user_scoped_data_source.dart';
import 'package:bujuan/data/netease/api/netease_music_api.dart';
import 'package:bujuan/data/netease/remote/netease_album_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_artist_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_auth_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_cloud_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_comment_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_explore_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_playlist_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_radio_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_search_remote_data_source.dart';
import 'package:bujuan/data/netease/remote/netease_user_remote_data_source.dart';
import 'package:bujuan/features/auth/auth_state_store.dart';
import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/auth/auth_repository.dart';
import 'package:bujuan/features/cloud/cloud_repository.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:bujuan/features/download/download_repository.dart';
import 'package:bujuan/features/explore/explore_cache_store.dart';
import 'package:bujuan/features/explore/explore_repository.dart';
import 'package:bujuan/features/library/library_repository.dart';
import 'package:bujuan/features/library/local_resource_index_repository.dart';
import 'package:bujuan/features/local_media/local_media_repository.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/search/search_cache_store.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/features/settings/settings_repository.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:get/get.dart';

/// Repository 注册器，统一装配业务仓库实例。
class RepositoryRegistrar {
  /// 禁止实例化 repository 注册器。
  const RepositoryRegistrar._();

  /// 注册所有仓库，并保持仓库依赖由构造函数显式传入。
  static void register({
    required LibraryRepository libraryRepository,
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

    Get.put<LibraryRepository>(libraryRepository, permanent: true);
    Get.put<AuthRepository>(
      AuthRepository(
        stateStore: const AuthStateStore(),
        remoteDataSource: authRemoteDataSource,
      ),
      permanent: true,
    );
    Get.put<SettingsRepository>(const SettingsRepository(), permanent: true);
    Get.put<UserRepository>(
      UserRepository(
        libraryRepository: libraryRepository,
        remoteDataSource: userRemoteDataSource,
        userScopedDataSource: userScopedDataSource,
      ),
      permanent: true,
    );
    Get.put<PlaylistRepository>(
      PlaylistRepository(
        appCacheDataSource: appCacheDataSource,
        libraryRepository: libraryRepository,
        localLibraryDataSource: localLibraryDataSource,
        remoteDataSource: playlistRemoteDataSource,
        userScopedDataSource: userScopedDataSource,
      ),
      permanent: true,
    );
    Get.put<AlbumRepository>(
      AlbumRepository(
        libraryRepository: libraryRepository,
        remoteDataSource: albumRemoteDataSource,
      ),
      permanent: true,
    );
    Get.put<ArtistRepository>(
      ArtistRepository(
        libraryRepository: libraryRepository,
        remoteDataSource: artistRemoteDataSource,
      ),
      permanent: true,
    );
    Get.put<CloudRepository>(
      CloudRepository(
        libraryRepository: libraryRepository,
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
        libraryRepository: libraryRepository,
        remoteDataSource: searchRemoteDataSource,
        cacheStore: searchCacheStore,
        userScopedDataSource: userScopedDataSource,
      ),
      permanent: true,
    );
    Get.put<LocalMediaRepository>(
      LocalMediaRepository(
        libraryRepository: libraryRepository,
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
}
