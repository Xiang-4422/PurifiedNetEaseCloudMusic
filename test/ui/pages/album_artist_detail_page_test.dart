import 'dart:io';
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:bujuan/app/routing/router.gr.dart';
import 'package:bujuan/core/entities/album_entity.dart';
import 'package:bujuan/core/entities/artist_entity.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/data/app_storage/local_image_cache_repository.dart';
import 'package:bujuan/features/album/album_page_controller_factory.dart';
import 'package:bujuan/features/album/album_repository.dart';
import 'package:bujuan/features/artist/artist_page_controller_factory.dart';
import 'package:bujuan/features/artist/artist_repository.dart';
import 'package:bujuan/features/playback/player_controller.dart';
import 'package:bujuan/features/user/user_library_controller.dart';
import 'package:bujuan/ui/pages/album/album_page_view.dart';
import 'package:bujuan/ui/pages/artist/artist_page_view.dart';
import 'package:bujuan/ui/services/local_image_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late Directory imageCacheDirectory;

  setUp(() {
    Get.testMode = true;
    imageCacheDirectory = Directory.systemTemp.createTempSync('album_artist_image_cache_test_');
    LocalImageCacheService.configure(
      repository: LocalImageCacheRepository(
        cacheDirectoryProvider: () async => imageCacheDirectory,
        downloader: (imageUrl, savePath, options) async {
          await File(savePath).writeAsBytes(const <int>[]);
        },
      ),
    );
    Get.put<UserLibraryController>(_FakeUserLibraryController());
    Get.put<PlayerController>(_FakePlayerController());
  });

  tearDown(() {
    Get.reset();
    if (imageCacheDirectory.existsSync()) {
      imageCacheDirectory.deleteSync(recursive: true);
    }
  });

  testWidgets('AlbumPageView keeps cached detail when background refresh fails', (tester) async {
    Get.put<AlbumRepository>(
      _FakeAlbumRepository(
        localDetail: AlbumDetailData(
          album: _album('album-1', title: 'Cached Album'),
          albumSongs: [_song('song-1', title: 'Cached Album Song')],
        ),
        fetchError: StateError('offline'),
      ),
    );
    _putAlbumPageControllerFactory();

    await tester.pumpWidget(
      _routedPage(
        const AlbumPageView(),
        routeName: AlbumRouteView.name,
        path: 'albumDetails',
        queryParams: const {'albumId': 'album-1'},
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Cached Album'), findsWidgets);
    expect(find.text('Cached Album Song'), findsOneWidget);
    expect(find.text('专辑加载失败'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AlbumPageView ignores stale background refresh after newer refresh', (tester) async {
    final repository = _FakeAlbumRepository(
      localDetail: AlbumDetailData(
        album: _album('album-1', title: 'Cached Album'),
        albumSongs: [_song('song-1', title: 'Cached Album Song')],
      ),
      controlledFetches: true,
    );
    Get.put<AlbumRepository>(repository);
    _putAlbumPageControllerFactory();

    await tester.pumpWidget(
      _routedPage(
        const AlbumPageView(),
        routeName: AlbumRouteView.name,
        path: 'albumDetails',
        queryParams: const {'albumId': 'album-1'},
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(repository.fetchCallCount, 1);

    final refresh = tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show();
    await _pumpUntil(tester, () => repository.fetchCallCount == 2);
    expect(repository.fetchCallCount, 2);

    repository.completeFetch(
      1,
      AlbumDetailData(
        album: _album('album-1', title: 'Fresh Album'),
        albumSongs: [_song('song-2', title: 'Fresh Album Song')],
      ),
    );
    await refresh;
    await tester.pump();

    expect(find.textContaining('Fresh Album'), findsWidgets);
    expect(find.text('Fresh Album Song'), findsOneWidget);

    repository.completeFetch(
      0,
      AlbumDetailData(
        album: _album('album-1', title: 'Stale Album'),
        albumSongs: [_song('song-stale', title: 'Stale Album Song')],
      ),
    );
    await tester.pump();

    expect(find.textContaining('Fresh Album'), findsWidgets);
    expect(find.text('Fresh Album Song'), findsOneWidget);
    expect(find.textContaining('Stale Album'), findsNothing);
    expect(find.text('Stale Album Song'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AlbumPageView shows retry state when first remote load fails', (tester) async {
    Get.put<AlbumRepository>(
      _FakeAlbumRepository(fetchError: StateError('offline')),
    );
    _putAlbumPageControllerFactory();

    await tester.pumpWidget(
      _routedPage(
        const AlbumPageView(),
        routeName: AlbumRouteView.name,
        path: 'albumDetails',
        queryParams: const {'albumId': 'album-1'},
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('专辑加载失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ArtistPageView keeps cached detail when background refresh fails', (tester) async {
    Get.put<ArtistRepository>(
      _FakeArtistRepository(
        localDetail: ArtistDetailData(
          artist: _artist('artist-1', name: 'Cached Artist'),
          topSongs: [_song('song-1', title: 'Cached Artist Song')],
          hotAlbums: [_album('album-1', title: 'Cached Artist Album')],
        ),
        fetchError: StateError('offline'),
      ),
    );
    _putArtistPageControllerFactory();

    await tester.pumpWidget(
      _routedPage(
        const ArtistPageView(),
        routeName: ArtistRouteView.name,
        path: 'artists',
        queryParams: const {'artistId': 'artist-1'},
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Cached Artist'), findsWidgets);
    expect(find.text('Cached Artist Album'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pump();
    expect(find.text('Cached Artist Song'), findsOneWidget);
    expect(find.text('歌手加载失败'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ArtistPageView ignores stale background refresh after newer refresh', (tester) async {
    final repository = _FakeArtistRepository(
      localDetail: ArtistDetailData(
        artist: _artist('artist-1', name: 'Cached Artist'),
        topSongs: [_song('song-1', title: 'Cached Artist Song')],
        hotAlbums: [_album('album-1', title: 'Cached Artist Album')],
      ),
      controlledFetches: true,
    );
    Get.put<ArtistRepository>(repository);
    _putArtistPageControllerFactory();

    await tester.pumpWidget(
      _routedPage(
        const ArtistPageView(),
        routeName: ArtistRouteView.name,
        path: 'artists',
        queryParams: const {'artistId': 'artist-1'},
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(repository.fetchCallCount, 1);

    final refresh = tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show();
    await _pumpUntil(tester, () => repository.fetchCallCount == 2);
    expect(repository.fetchCallCount, 2);

    repository.completeFetch(
      1,
      ArtistDetailData(
        artist: _artist('artist-1', name: 'Fresh Artist'),
        topSongs: [_song('song-2', title: 'Fresh Artist Song')],
        hotAlbums: [_album('album-2', title: 'Fresh Artist Album')],
      ),
    );
    await refresh;
    await tester.pump();

    expect(find.textContaining('Fresh Artist'), findsWidgets);
    expect(find.text('Fresh Artist Album'), findsOneWidget);

    repository.completeFetch(
      0,
      ArtistDetailData(
        artist: _artist('artist-1', name: 'Stale Artist'),
        topSongs: [_song('song-stale', title: 'Stale Artist Song')],
        hotAlbums: [_album('album-stale', title: 'Stale Artist Album')],
      ),
    );
    await tester.pump();

    expect(find.textContaining('Fresh Artist'), findsWidgets);
    expect(find.text('Fresh Artist Album'), findsOneWidget);
    expect(find.textContaining('Stale Artist'), findsNothing);
    expect(find.text('Stale Artist Album'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ArtistPageView shows retry state when first remote load fails', (tester) async {
    Get.put<ArtistRepository>(
      _FakeArtistRepository(fetchError: StateError('offline')),
    );
    _putArtistPageControllerFactory();

    await tester.pumpWidget(
      _routedPage(
        const ArtistPageView(),
        routeName: ArtistRouteView.name,
        path: 'artists',
        queryParams: const {'artistId': 'artist-1'},
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('歌手加载失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _putAlbumPageControllerFactory() {
  Get.put<AlbumPageControllerFactory>(
    AlbumPageControllerFactory(
      repository: Get.find<AlbumRepository>(),
      likedSongIds: () => Get.find<UserLibraryController>().likedSongIds.toList(),
    ),
  );
}

void _putArtistPageControllerFactory() {
  Get.put<ArtistPageControllerFactory>(
    ArtistPageControllerFactory(
      repository: Get.find<ArtistRepository>(),
      likedSongIds: () => Get.find<UserLibraryController>().likedSongIds.toList(),
    ),
  );
}

Widget _routedPage(
  Widget child, {
  required String routeName,
  required String path,
  required Map<String, dynamic> queryParams,
}) {
  final routeData = RouteData(
    route: RouteMatch(
      name: routeName,
      segments: [path],
      path: path,
      stringMatch: path,
      key: ValueKey(routeName),
      queryParams: Parameters(queryParams),
    ),
    router: RootRouter(),
    pendingChildren: const [],
  );
  return GetMaterialApp(
    theme: ThemeData.light(),
    home: Scaffold(
      body: RouteDataScope(
        routeData: routeData,
        child: child,
      ),
    ),
  );
}

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition,
) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    if (condition()) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 50));
  }
  fail('Condition was not met before pump timeout.');
}

AlbumEntity _album(String id, {required String title}) {
  return AlbumEntity(
    id: 'netease:$id',
    sourceType: SourceType.netease,
    sourceId: id,
    title: title,
    artworkUrl: 'https://example.test/$id.jpg',
    artistNames: const ['Artist'],
  );
}

ArtistEntity _artist(String id, {required String name}) {
  return ArtistEntity(
    id: 'netease:$id',
    sourceType: SourceType.netease,
    sourceId: id,
    name: name,
    artworkUrl: 'https://example.test/$id.jpg',
  );
}

PlaybackQueueItem _song(String id, {required String title}) {
  return PlaybackQueueItem(
    id: 'netease:$id',
    sourceId: id,
    title: title,
    albumTitle: 'Album',
    artistNames: const ['Artist'],
    artistIds: const ['artist-1'],
    duration: const Duration(minutes: 3),
    artworkUrl: null,
    localArtworkPath: null,
    mediaType: MediaType.playlist,
    playbackUrl: null,
    lyricKey: null,
    isLiked: false,
    isCached: false,
  );
}

class _FakeAlbumRepository implements AlbumRepository {
  _FakeAlbumRepository({
    this.localDetail,
    this.fetchError,
    this.controlledFetches = false,
  });

  final AlbumDetailData? localDetail;
  final Object? fetchError;
  final bool controlledFetches;
  final List<Completer<AlbumDetailData>> _fetches = [];

  int get fetchCallCount => _fetches.length;

  void completeFetch(int index, AlbumDetailData detail) {
    _fetches[index].complete(detail);
  }

  @override
  Future<AlbumDetailData?> loadLocalAlbumDetail({
    required String albumId,
    required List<int> likedSongIds,
  }) async {
    return localDetail;
  }

  @override
  Future<AlbumDetailData> fetchAlbumDetail({
    required String albumId,
    required List<int> likedSongIds,
  }) async {
    final error = fetchError;
    if (error != null) {
      throw error;
    }
    if (controlledFetches) {
      final completer = Completer<AlbumDetailData>();
      _fetches.add(completer);
      return completer.future;
    }
    throw StateError('remote detail not configured');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeArtistRepository implements ArtistRepository {
  _FakeArtistRepository({
    this.localDetail,
    this.fetchError,
    this.controlledFetches = false,
  });

  final ArtistDetailData? localDetail;
  final Object? fetchError;
  final bool controlledFetches;
  final List<Completer<ArtistDetailData>> _fetches = [];

  int get fetchCallCount => _fetches.length;

  void completeFetch(int index, ArtistDetailData detail) {
    _fetches[index].complete(detail);
  }

  @override
  Future<ArtistDetailData?> loadLocalArtistDetail({
    required String artistId,
    required List<int> likedSongIds,
  }) async {
    return localDetail;
  }

  @override
  Future<ArtistDetailData> fetchArtistDetail({
    required String artistId,
    required List<int> likedSongIds,
  }) async {
    final error = fetchError;
    if (error != null) {
      throw error;
    }
    if (controlledFetches) {
      final completer = Completer<ArtistDetailData>();
      _fetches.add(completer);
      return completer.future;
    }
    throw StateError('remote detail not configured');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserLibraryController extends GetxController implements UserLibraryController {
  @override
  final RxList<int> likedSongIds = <int>[].obs;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlayerController extends GetxController implements PlayerController {
  @override
  Future<void> playPlaylist(
    List<PlaybackQueueItem> playList,
    int index, {
    String playListName = '无名歌单',
    String playListNameHeader = '',
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
