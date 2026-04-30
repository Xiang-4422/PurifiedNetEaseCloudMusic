import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_queue_item.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/domain/entities/playback_restore_state.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:bujuan/features/playback/playback_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlaybackSourceResolver', () {
    test('treats normal cached audio path as file source', () async {
      final resolver = PlaybackSourceResolver(
        repository: _FakePlaybackRepository(),
      );

      final source = await resolver.resolve(
        _mediaItem(
          type: MediaType.neteaseCache,
          url: '/cache/audio/song.mp3',
        ),
        preferHighQuality: false,
      );

      expect(source.kind, PlaybackResolvedSourceKind.filePath);
      expect(source.url, '/cache/audio/song.mp3');
    });

    test('keeps uc cache path on decrypted stream source', () async {
      final resolver = PlaybackSourceResolver(
        repository: _FakePlaybackRepository(),
      );

      final source = await resolver.resolve(
        _mediaItem(
          type: MediaType.neteaseCache,
          url: '/cache/audio/song.mp3.uc!',
        ),
        preferHighQuality: false,
      );

      expect(source.kind, PlaybackResolvedSourceKind.neteaseCacheStream);
      expect(source.fileType, 'mp3');
    });
  });
}

PlaybackQueueItem _mediaItem({
  required MediaType type,
  required String url,
}) {
  return PlaybackQueueItem(
    id: 'netease:1',
    sourceId: 'netease:1',
    title: 'Track',
    albumTitle: null,
    artistNames: const [],
    artistIds: const [],
    duration: null,
    artworkUrl: null,
    localArtworkPath: null,
    mediaType: type,
    playbackUrl: url,
    lyricKey: null,
    isLiked: false,
    isCached: false,
  );
}

class _FakePlaybackRepository implements PlaybackRepository {
  @override
  Future<String?> fetchPlaybackUrl(
    String trackId, {
    required bool preferHighQuality,
  }) async {
    return 'https://example.com/song.mp3';
  }

  @override
  Future<PlaybackRestoreState> getRestoreState() async {
    return const PlaybackRestoreState();
  }

  @override
  Future<Track?> getTrack(String trackId) async {
    return null;
  }

  @override
  Future<TrackWithResources?> getTrackWithResources(String trackId) async {
    return null;
  }

  @override
  Future<TrackLyrics?> fetchSongLyrics(String trackId) async {
    return null;
  }

  @override
  Future<void> saveSongLyrics(String trackId, TrackLyrics lyrics) async {}

  @override
  Future<void> updateRestoreState({
    PlaybackMode? playbackMode,
    PlaybackRepeatMode? repeatMode,
    List<String>? queue,
    String? currentSongId,
    String? playlistName,
    String? playlistHeader,
    Duration? position,
  }) async {}
}
