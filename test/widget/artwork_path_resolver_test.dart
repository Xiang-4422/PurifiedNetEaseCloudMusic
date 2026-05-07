import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
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
  });
}
