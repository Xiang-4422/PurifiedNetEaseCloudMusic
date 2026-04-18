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
      return null;
    }
    return value.substring(0, separatorIndex);
  }
}
