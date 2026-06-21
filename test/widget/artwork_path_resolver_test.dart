import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/ui/widgets/common/image/artwork_path_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArtworkPathResolver', () {
    test('keeps explicit page artwork before local fallback item artwork', () {
      final artwork = ArtworkPathResolver.resolveExplicitArtwork(
        'https://example.com/playlist.jpg',
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

      expect(artwork, 'https://example.com/playlist.jpg');
    });

    test('falls back to item artwork when explicit page artwork is missing', () {
      final artwork = ArtworkPathResolver.resolveExplicitArtwork(
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

      expect(artwork, '/local/song.jpg');
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
  });
}
