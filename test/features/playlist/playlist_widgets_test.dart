import 'dart:ui' show SemanticsAction;

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_summary_data.dart';
import 'package:bujuan/data/app_storage/local_image_cache_repository.dart';
import 'package:bujuan/ui/services/local_image_cache_service.dart';
import 'package:bujuan/ui/widgets/playlist/playlist_widgets.dart';
import 'package:bujuan/ui/widgets/common/music/music_list_tile.dart';
import 'package:bujuan/ui/widgets/common/layout/section_header.dart';
import 'package:bujuan/ui/widgets/common/image/simple_extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    LocalImageCacheService.configure(
      repository: LocalImageCacheRepository(),
    );
  });

  group('playlist widgets', () {
    testWidgets('Header grows from padding instead of forcing fixed height', (tester) async {
      const headerKey = Key('header');
      await tester.pumpWidget(
        _wrap(
          const Header(
            '一个非常非常长的标题用来验证窄屏下不会溢出',
            key: headerKey,
            padding: 32,
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(headerKey)).height, greaterThan(50));
    });

    testWidgets('UniversalListTile expands with text scale and constrains trailing', (tester) async {
      const tileKey = Key('tile');
      await tester.pumpWidget(
        _wrap(
          UniversalListTile(
            key: tileKey,
            titleString: '很长很长的歌曲标题用来验证文本不会撑爆布局',
            subTitleString: '很长很长的副标题 / 艺人 / 专辑',
            trailing: Container(width: 220, height: 32, color: Colors.red),
          ),
          textScale: 2,
          width: 320,
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(tileKey)).height, greaterThan(52));
    });

    testWidgets('SongItem shows index and still triggers playback callback', (tester) async {
      var playCallCount = 0;
      await tester.pumpWidget(
        _wrap(
          SongItem(
            playlist: [_song()],
            index: 0,
            playListName: 'list',
            showIndex: true,
            showPic: false,
            onPlay: (
              playlist,
              index, {
              String playListName = '',
              String playListNameHeader = '',
            }) async {
              playCallCount++;
            },
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      await tester.tap(find.text('Track'));
      await tester.pump();
      expect(playCallCount, 1);
    });

    test('UniversalListTile semantic label uses title and subtitle', () {
      expect(
        universalListTileSemanticLabel(
          title: ' Track ',
          subtitle: ' Artist ',
        ),
        'Track，Artist',
      );
      expect(
        universalListTileSemanticLabel(
          title: ' ',
          subtitle: ' ',
        ),
        '未命名内容',
      );
    });

    testWidgets('SongItem exposes a stable playback semantic label', (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _wrap(
            SongItem(
              playlist: [_song()],
              index: 0,
              playListName: 'list',
              showPic: false,
              onPlay: (
                playlist,
                index, {
                String playListName = '',
                String playListNameHeader = '',
              }) async {},
            ),
          ),
        );

        expect(find.bySemanticsLabel('Track，Artist'), findsOneWidget);
        final node = tester.getSemantics(find.bySemanticsLabel('Track，Artist'));
        final data = node.getSemanticsData();
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.hasAction(SemanticsAction.tap), isTrue);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('SongItem prefers local artwork path for thumbnails', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SongItem(
            playlist: [
              _song(
                artworkUrl: 'https://example.com/remote.jpg',
                localArtworkPath: '/cache/local.jpg',
              ),
            ],
            index: 0,
            playListName: 'list',
            onPlay: (
              playlist,
              index, {
              String playListName = '',
              String playListNameHeader = '',
            }) async {},
          ),
        ),
      );

      final image = tester.widget<SimpleExtendedImage>(
        find.byType(SimpleExtendedImage),
      );
      expect(image.url, '/cache/local.jpg');
    });

    testWidgets('PlayListWidget keeps artwork square and honors height override', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 360,
            child: PlayListWidget(
              playLists: const [
                PlaylistSummaryData(id: '1', title: 'Playlist'),
              ],
              albumCountInWidget: 2,
              albumMargin: 10,
              heightForWidth: (_) => 320,
            ),
          ),
        ),
      );

      final image = tester.widget<SimpleExtendedImage>(
        find.byType(SimpleExtendedImage).first,
      );
      expect(image.width, image.height);
      expect(tester.getSize(find.byType(CustomScrollView)).height, 320);
    });
  });
}

Widget _wrap(
  Widget child, {
  double textScale = 1,
  double width = 420,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, 800),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

PlaybackQueueItem _song({
  String? artworkUrl,
  String? localArtworkPath,
}) {
  return PlaybackQueueItem(
    id: '1',
    sourceId: '1',
    title: 'Track',
    albumTitle: null,
    artistNames: ['Artist'],
    artistIds: [],
    duration: null,
    artworkUrl: artworkUrl,
    localArtworkPath: localArtworkPath,
    mediaType: MediaType.playlist,
    playbackUrl: null,
    lyricKey: null,
    isLiked: false,
    isCached: false,
  );
}
