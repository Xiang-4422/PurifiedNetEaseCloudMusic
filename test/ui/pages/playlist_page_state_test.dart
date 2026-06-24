import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playlist_entity.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/features/playlist/playlist_detail_data.dart';
import 'package:bujuan/ui/pages/playlist/playlist_page_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('playlist presentation shows full page loading only without metadata', () {
    const presentation = PlaylistPagePresentation(
      loadState: PlaylistPageLoadState.loadingInitial,
      fetchKind: PlaylistFetchKind.none,
      hasPlaylistMetadata: false,
      songCount: 0,
    );

    expect(presentation.showInitialLoading, isTrue);
    expect(presentation.showEmptyError, isFalse);
    expect(presentation.isShowingPlaylistSkeleton, isFalse);
  });

  test('playlist presentation keeps metadata visible when first page is loading', () {
    const presentation = PlaylistPagePresentation(
      loadState: PlaylistPageLoadState.showingMetadataOnly,
      fetchKind: PlaylistFetchKind.loadingFirstPage,
      hasPlaylistMetadata: true,
      songCount: 0,
    );

    expect(presentation.showInitialLoading, isFalse);
    expect(presentation.isShowingPlaylistSkeleton, isTrue);
    expect(presentation.isShowingStatusFooter, isFalse);
  });

  test('playlist presentation exposes retry footer when partial data fails', () {
    const presentation = PlaylistPagePresentation(
      loadState: PlaylistPageLoadState.loadFailedWithPartial,
      fetchKind: PlaylistFetchKind.none,
      hasPlaylistMetadata: true,
      songCount: 12,
    );

    expect(presentation.isShowingStatusFooter, isTrue);
    expect(presentation.completionMessage, '剩余歌曲加载失败，下拉可重试');
    expect(presentation.canPlayLoadedPlaylist, isTrue);
  });

  test('playlist presentation blocks playback while fetch is running', () {
    const presentation = PlaylistPagePresentation(
      loadState: PlaylistPageLoadState.showingFull,
      fetchKind: PlaylistFetchKind.loadingRemaining,
      hasPlaylistMetadata: true,
      songCount: 12,
    );

    expect(presentation.canPlayLoadedPlaylist, isFalse);
    expect(presentation.isShowingStatusFooter, isTrue);
    expect(presentation.completionMessage, '正在加载剩余歌曲...');
  });

  test('playlist metadata is present when title cover or track count exists', () {
    expect(
      PlaylistPagePresentation.hasMetadata(
        playlistName: '每日推荐',
        coverUrl: null,
        trackCount: null,
      ),
      isTrue,
    );
    expect(
      PlaylistPagePresentation.hasMetadata(
        playlistName: '  ',
        coverUrl: 'https://example.com/cover.jpg',
        trackCount: null,
      ),
      isTrue,
    );
    expect(
      PlaylistPagePresentation.hasMetadata(
        playlistName: '  ',
        coverUrl: null,
        trackCount: 0,
      ),
      isTrue,
    );
    expect(
      PlaylistPagePresentation.hasMetadata(
        playlistName: '  ',
        coverUrl: '',
        trackCount: null,
      ),
      isFalse,
    );
  });

  test('playlist state model starts with route metadata visible', () {
    final state = PlaylistPageStateModel.initial(
      playlistName: '路线歌单',
      coverUrl: null,
      trackCount: null,
    );

    expect(state.loadState, PlaylistPageLoadState.showingMetadataOnly);
    expect(state.presentation.showInitialLoading, isFalse);
    expect(state.presentation.isShowingPlaylistSkeleton, isFalse);
  });

  test('playlist state model applies local metadata without losing existing cover', () {
    final state = PlaylistPageStateModel.initial(
      playlistName: '',
      coverUrl: 'https://cover.test/route.jpg',
      trackCount: null,
    ).copyWith(loadState: PlaylistPageLoadState.loadingInitial);

    final next = state.applyLocalPlaylist(
      const PlaylistEntity(
        id: 'netease:1',
        sourceType: SourceType.netease,
        sourceId: '1',
        title: '本地歌单',
        trackCount: 12,
      ),
    );

    expect(next.playlistName, '本地歌单');
    expect(next.coverUrl, 'https://cover.test/route.jpg');
    expect(next.trackCount, 12);
    expect(next.loadState, PlaylistPageLoadState.showingMetadataOnly);
  });

  test('playlist state model applies detail and derives presentation', () {
    final state = PlaylistPageStateModel.initial(
      playlistName: '旧歌单',
      coverUrl: null,
      trackCount: null,
    );

    final next = state.applyDetail(
      const PlaylistDetailData(
        songs: [PlaybackQueueItem.empty()],
        isSubscribed: true,
        isMyPlayList: true,
        source: PlaylistDetailSource.remote,
        expectedTrackCount: 1,
        playlistName: '远端歌单',
        coverUrl: 'https://cover.test/remote.jpg',
      ),
      nextState: PlaylistPageLoadState.showingFull,
    );

    expect(next.playlistName, '远端歌单');
    expect(next.coverUrl, 'https://cover.test/remote.jpg');
    expect(next.trackCount, 1);
    expect(next.isSubscribed, isTrue);
    expect(next.isMyPlaylist, isTrue);
    expect(next.presentation.canPlayLoadedPlaylist, isTrue);
  });

  test('playlist state model keeps visible songs playable after remaining load fails', () {
    final state = PlaylistPageStateModel.initial(
      playlistName: '歌单',
      coverUrl: null,
      trackCount: 10,
    ).copyWith(
      songs: const [PlaybackQueueItem.empty()],
      loadState: PlaylistPageLoadState.showingPartial,
      fetchKind: PlaylistFetchKind.loadingRemaining,
    );

    final failed = state.failRemainingLoad().endFetch();

    expect(failed.loadState, PlaylistPageLoadState.loadFailedWithPartial);
    expect(failed.fetchKind, PlaylistFetchKind.none);
    expect(failed.presentation.canPlayLoadedPlaylist, isTrue);
    expect(failed.presentation.completionMessage, '剩余歌曲加载失败，下拉可重试');
  });

  test('playlist state model marks empty primary failure without metadata as full error', () {
    final state = PlaylistPageStateModel.initial(
      playlistName: ' ',
      coverUrl: null,
      trackCount: null,
    ).beginFirstPageLoad(showLoadingState: true);

    final failed = state.failPrimaryLoad().endFetch();

    expect(failed.loadState, PlaylistPageLoadState.loadFailedEmpty);
    expect(failed.presentation.showEmptyError, isTrue);
  });
}
