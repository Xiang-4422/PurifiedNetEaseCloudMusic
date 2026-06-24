import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/track.dart';
import 'package:bujuan/core/entities/track_resource_bundle.dart';
import 'package:bujuan/core/entities/track_with_resources.dart';
import 'package:bujuan/data/music_data/music_data_repository.dart';
import 'package:bujuan/features/playback/application/playback_queue_item_mapper.dart';

/// 从曲目实体构建播放队列项，并补齐本地资源状态。
class TrackPlaybackQueueBuilder {
  /// 创建曲目播放队列构建器。
  const TrackPlaybackQueueBuilder(this._musicDataRepository);

  final MusicDataRepository _musicDataRepository;

  /// 构建播放队列项。
  Future<List<PlaybackQueueItem>> build(
    List<Track> tracks, {
    required List<int> likedSongIds,
    MediaType? mediaType,
  }) async {
    final candidates = [
      for (final track in tracks)
        if (_normalizedTrackId(track.id).isNotEmpty) track,
    ];
    if (candidates.isEmpty) {
      return const [];
    }
    final resourceTrackIds = _uniqueTrackIds(
      candidates.map((track) => track.id),
    );
    final tracksWithResources = await _musicDataRepository.getTracksWithResources(
      resourceTrackIds,
    );
    final resourcesByTrackId = {
      for (final item in tracksWithResources) _normalizedTrackId(item.track.id): item.resources,
    };
    return buildFromTrackResources(
      [
        for (final track in candidates)
          TrackWithResources(
            track: track,
            resources: resourcesByTrackId[_normalizedTrackId(track.id)] ?? const TrackResourceBundle(),
          ),
      ],
      likedSongIds: likedSongIds,
      mediaType: mediaType,
    );
  }

  /// 按曲目 id 读取本地曲目和资源后构建播放队列项。
  Future<List<PlaybackQueueItem>> buildFromTrackIds(
    Iterable<String> trackIds, {
    required List<int> likedSongIds,
    MediaType? mediaType,
  }) async {
    final candidateTrackIds = _uniqueTrackIds(trackIds);
    if (candidateTrackIds.isEmpty) {
      return const [];
    }
    final tracksWithResources = await _musicDataRepository.getTracksWithResources(
      candidateTrackIds,
    );
    return buildFromTrackResources(
      tracksWithResources,
      likedSongIds: likedSongIds,
      mediaType: mediaType,
    );
  }

  /// 用已经携带本地资源的曲目构建播放队列项。
  List<PlaybackQueueItem> buildFromTrackResources(
    List<TrackWithResources> tracks, {
    required List<int> likedSongIds,
    MediaType? mediaType,
  }) {
    return PlaybackQueueItemMapper.fromTrackWithResourcesList(
      tracks,
      likedSongIds: likedSongIds,
      mediaType: mediaType,
    );
  }

  List<String> _uniqueTrackIds(Iterable<String> trackIds) {
    final seen = <String>{};
    final result = <String>[];
    for (final trackId in trackIds) {
      final normalizedTrackId = _normalizedTrackId(trackId);
      if (normalizedTrackId.isEmpty || !seen.add(normalizedTrackId)) {
        continue;
      }
      result.add(normalizedTrackId);
    }
    return result;
  }

  String _normalizedTrackId(String trackId) {
    return trackId.trim();
  }
}
