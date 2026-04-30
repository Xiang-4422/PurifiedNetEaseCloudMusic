import 'package:audio_service/audio_service.dart';
import 'package:bujuan/domain/entities/playback_media_type.dart';
import 'package:bujuan/domain/entities/playback_mode.dart';
import 'package:bujuan/domain/entities/playback_repeat_mode.dart';
import 'package:bujuan/domain/entities/playback_restore_state.dart';
import 'package:bujuan/domain/entities/track.dart';
import 'package:bujuan/domain/entities/track_lyrics.dart';
import 'package:bujuan/domain/entities/track_with_resources.dart';
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

MediaItem _mediaItem({
  required MediaType type,
  required String url,
}) {
  return MediaItem(
    id: 'netease:1',
    title: 'Track',
    extras: {
      'type': type.name,
      'url': url,
    },
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
