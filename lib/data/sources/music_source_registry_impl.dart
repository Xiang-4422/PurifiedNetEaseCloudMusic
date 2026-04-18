import 'package:bujuan/data/sources/netease/netease_music_source.dart';
import 'package:bujuan/domain/sources/music_source.dart';
import 'package:bujuan/domain/sources/music_source_registry.dart';

class MusicSourceRegistryImpl implements MusicSourceRegistry {
  MusicSourceRegistryImpl({List<MusicSource>? sources})
      : _sources = sources ?? [NeteaseMusicSource()];

  final List<MusicSource> _sources;

  @override
  MusicSource? getBySourceKey(String sourceKey) {
    for (final source in _sources) {
      if (source.sourceKey == sourceKey) {
        return source;
      }
    }
    return null;
  }

  @override
  MusicSource? getByTrackId(String trackId) {
    final sourceKey = _extractSourceKey(trackId);
    if (sourceKey == null) {
      return null;
    }
    return getBySourceKey(sourceKey);
  }

  @override
  MusicSource? getByPlaylistId(String playlistId) {
    final sourceKey = _extractSourceKey(playlistId);
    if (sourceKey == null) {
      return null;
    }
    return getBySourceKey(sourceKey);
  }

  @override
  List<MusicSource> getAll() {
    return List.unmodifiable(_sources);
  }

  String? _extractSourceKey(String value) {
    final separatorIndex = value.indexOf(':');
    if (separatorIndex <= 0) {
      // 现有播放队列和缓存里仍然大量保存纯数字网易云 ID，这里先兜底，
      // 避免领域层切换时把历史状态恢复链路一并打断。
      return 'netease';
    }
    return value.substring(0, separatorIndex);
  }
}
