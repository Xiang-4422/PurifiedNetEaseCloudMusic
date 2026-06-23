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
}
