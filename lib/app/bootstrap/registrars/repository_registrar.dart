import 'package:bujuan/data/local/local_library_data_source.dart';
import 'package:bujuan/data/local/user_scoped_data_source.dart';
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
import 'package:bujuan/features/playlist/playlist_cache_store.dart';
import 'package:bujuan/features/playlist/playlist_repository.dart';
import 'package:bujuan/features/radio/radio_repository.dart';
import 'package:bujuan/features/search/search_cache_store.dart';
import 'package:bujuan/features/search/search_repository.dart';
import 'package:bujuan/features/user/user_repository.dart';
import 'package:get/get.dart';

class RepositoryRegistrar {
  const RepositoryRegistrar._();

  static void register({
    required LibraryRepository libraryRepository,
    required UserScopedDataSource userScopedDataSource,
    required PlaylistCacheStore playlistCacheStore,
    required LocalLibraryDataSource localLibraryDataSource,
    required SearchCacheStore searchCacheStore,
    required ExploreCacheStore exploreCacheStore,
    required LocalResourceIndexRepository localResourceIndexRepository,
    required DownloadRepository downloadRepository,
    required PlaybackRepository playbackRepository,
  }) {
    Get.put<LibraryRepository>(libraryRepository, permanent: true);
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.put<UserRepository>(
      UserRepository(
        libraryRepository: libraryRepository,
        userScopedDataSource: userScopedDataSource,
      ),
      permanent: true,
    );
    Get.put<PlaylistRepository>(
      PlaylistRepository(
        cacheStore: playlistCacheStore,
        libraryRepository: libraryRepository,
        localLibraryDataSource: localLibraryDataSource,
        userScopedDataSource: userScopedDataSource,
      ),
      permanent: true,
    );
    Get.put<AlbumRepository>(
      AlbumRepository(libraryRepository: libraryRepository),
      permanent: true,
    );
    Get.put<ArtistRepository>(
      ArtistRepository(libraryRepository: libraryRepository),
      permanent: true,
    );
    Get.put<CloudRepository>(
      CloudRepository(
        libraryRepository: libraryRepository,
        userScopedDataSource: userScopedDataSource,
      ),
      permanent: true,
    );
    Get.put<RadioRepository>(
      RadioRepository(userScopedDataSource: userScopedDataSource),
      permanent: true,
    );
    Get.put<SearchRepository>(
      SearchRepository(
        libraryRepository: libraryRepository,
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
    Get.put<CommentRepository>(CommentRepository(), permanent: true);
    Get.put<ExploreRepository>(
      ExploreRepository(cacheStore: exploreCacheStore),
      permanent: true,
    );
  }
}
