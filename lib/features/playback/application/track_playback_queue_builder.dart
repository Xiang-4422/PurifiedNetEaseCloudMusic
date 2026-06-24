import 'package:bujuan/core/entities/playback_queue_item.dart';
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
  }) async {
    if (tracks.isEmpty) {
      return const [];
    }
    final tracksWithResources = await _musicDataRepository.getTracksWithResources(
      tracks.map((track) => track.id),
    );
    final resourcesByTrackId = {
      for (final item in tracksWithResources) item.track.id: item.resources,
    };
    return PlaybackQueueItemMapper.fromTrackWithResourcesList(
      [
        for (final track in tracks)
          TrackWithResources(
            track: track,
            resources: resourcesByTrackId[track.id] ?? const TrackResourceBundle(),
          ),
      ],
      likedSongIds: likedSongIds,
    );
  }
}
