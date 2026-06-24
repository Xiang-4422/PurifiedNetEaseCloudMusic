import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArtworkPathResolver', () {
    test('keeps explicit page artwork before local fallback item artwork', () {
      final artwork = ArtworkPathResolver.resolveExplicitArtwork(
        'https://example.com/playlist.jpg?param=200y200&token=keep',
        fallbackItems: const [
          PlaybackQueueItem(
            id: '1',
            sourceId: '1',
            title: 'Song',
            albumTitle: null,
            artistNames: [],
            artistIds: [],
            duration: null,
            artworkUrl: null,
            localArtworkPath: '/local/song.jpg',
            mediaType: MediaType.playlist,
            playbackUrl: null,
            lyricKey: null,
            isLiked: false,
            isCached: false,
          ),
        ],
      );

      expect(artwork, 'https://example.com/playlist.jpg?token=keep');
    });

    test('falls back to item artwork when explicit page artwork is missing', () {
      final fileUri = Uri(
        scheme: 'file',
        host: 'localhost',
        path: '/local/song.jpg',
        queryParameters: {'token': 'cached'},
      ).toString();
      final artwork = ArtworkPathResolver.resolveExplicitArtwork(
        null,
        fallbackItems: [
          PlaybackQueueItem(
            id: '1',
            sourceId: '1',
            title: 'Song',
            albumTitle: null,
            artistNames: [],
            artistIds: [],
            duration: null,
            artworkUrl: null,
            localArtworkPath: fileUri,
            mediaType: MediaType.playlist,
            playbackUrl: null,
            lyricKey: null,
            isLiked: false,
            isCached: false,
          ),
        ],
      );

      expect(artwork, '/local/song.jpg');
    });

    test('uses remote fallback artwork when page artwork is missing', () {
      final artwork = ArtworkPathResolver.resolvePreferredArtwork(
        null,
        fallbackItems: const [
          PlaybackQueueItem(
            id: '1',
            sourceId: '1',
            title: 'Song',
            albumTitle: null,
            artistNames: [],
            artistIds: [],
            duration: null,
            artworkUrl: 'https://example.com/song.jpg?param=200y200&token=keep',
            localArtworkPath: null,
            mediaType: MediaType.playlist,
            playbackUrl: null,
            lyricKey: null,
            isLiked: false,
            isCached: false,
          ),
        ],
      );

      expect(artwork, 'https://example.com/song.jpg?token=keep');
    });

    test('ignores non-http fallback artwork when page artwork is missing', () {
      final artwork = ArtworkPathResolver.resolvePreferredArtwork(
        null,
        fallbackItems: const [
          PlaybackQueueItem(
            id: '1',
            sourceId: '1',
            title: 'Song',
            albumTitle: null,
            artistNames: [],
            artistIds: [],
            duration: null,
            artworkUrl: 'ftp://example.com/song.jpg',
            localArtworkPath: null,
            mediaType: MediaType.playlist,
            playbackUrl: null,
            lyricKey: null,
            isLiked: false,
            isCached: false,
          ),
        ],
      );

      expect(artwork, isNull);
    });

    test('does not prefer unsafe uri artwork as local fallback', () {
      final unsafeUri = Uri(
        scheme: 'file',
        host: 'media-server',
        path: '/local/song.jpg',
      ).toString();
      final artwork = ArtworkPathResolver.resolvePreferredArtwork(
        'https://example.com/playlist.jpg',
        fallbackItems: [
          PlaybackQueueItem(
            id: '1',
            sourceId: '1',
            title: 'Song',
            albumTitle: null,
            artistNames: const [],
            artistIds: const [],
            duration: null,
            artworkUrl: 'ftp://example.com/song.jpg',
            localArtworkPath: unsafeUri,
            mediaType: MediaType.playlist,
            playbackUrl: null,
            lyricKey: null,
            isLiked: false,
            isCached: false,
          ),
        ],
      );

      expect(artwork, 'https://example.com/playlist.jpg');
    });

    test('prefers local playback artwork over remote artwork url', () {
      final artwork = ArtworkPathResolver.resolvePlaybackArtwork(
        artworkUrl: 'https://example.com/song.jpg',
        localArtworkPath: '/local/song.jpg',
      );

      expect(artwork, '/local/song.jpg');
    });

    test('falls back to remote playback artwork when local path is unsafe', () {
      final unsafeUri = Uri(
        scheme: 'file',
        host: 'media-server',
        path: '/local/song.jpg',
      ).toString();

      final artwork = ArtworkPathResolver.resolvePlaybackArtwork(
        artworkUrl: 'https://example.com/song.jpg',
        localArtworkPath: unsafeUri,
      );

      expect(artwork, 'https://example.com/song.jpg');
    });

    test('uses placeholder when playback artwork only has unsafe uri', () {
      expect(
        ArtworkPathResolver.resolvePlaybackArtwork(
          artworkUrl: null,
          localArtworkPath: 'ftp://example.com/song.jpg',
        ),
        isNull,
      );
    });

    test('normalizes local display file uri before image rendering', () {
      final fileUri = Uri(
        scheme: 'file',
        host: 'localhost',
        path: '/local/song.jpg',
        queryParameters: {'token': 'cached'},
      ).toString();

      expect(
        ArtworkPathResolver.resolveDisplayPath(fileUri),
        '/local/song.jpg',
      );
    });

    test('normalizes remote display artwork before image cache lookup', () {
      expect(
        ArtworkPathResolver.resolveDisplayPath(
          'https://example.com/song.jpg?param=200y200&token=keep',
        ),
        'https://example.com/song.jpg?token=keep',
      );
    });

    test('uses placeholder for unsafe display artwork uri', () {
      expect(
        ArtworkPathResolver.resolveDisplayPath('ftp://example.com/song.jpg'),
        isEmpty,
      );
    });
  });
}
