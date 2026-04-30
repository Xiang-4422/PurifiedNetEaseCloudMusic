import 'dart:io';
import 'dart:typed_data';

import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:just_audio/just_audio.dart';

/// 播放引擎端口，供 audio_service handler 串行委托底层播放器操作。
abstract class PlaybackEnginePort {
  /// 底层播放器事件流。
  Stream<PlaybackEvent> get playbackEventStream;

  /// 当前播放器处理状态。
  ProcessingState get processingState;

  /// 当前是否启用随机播放。
  bool get shuffleModeEnabled;

  /// 当前是否正在播放。
  bool get playing;

  /// 当前播放进度。
  Duration get position;

  /// 当前缓冲进度。
  Duration get bufferedPosition;

  /// 当前播放速度。
  double get speed;

  /// 当前是否已经设置音源。
  bool get hasAudioSource;

  /// 设置底层播放器音源。
  Future<void> setSource(PlaybackResolvedSource source);

  /// 开始播放。
  Future<void> play();

  /// 暂停播放。
  Future<void> pause();

  /// 跳转到指定播放进度。
  Future<void> seek(Duration position);

  /// 释放底层播放器。
  Future<void> dispose();
}

/// 封装 `just_audio` 细节，避免 audio_service handler 继续直接处理文件源和缓存流。
class PlaybackEngineAdapter implements PlaybackEnginePort {
  /// 创建播放引擎适配器。
  PlaybackEngineAdapter({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  @override
  Stream<PlaybackEvent> get playbackEventStream => _player.playbackEventStream;

  @override
  ProcessingState get processingState => _player.processingState;

  @override
  bool get shuffleModeEnabled => _player.shuffleModeEnabled;

  @override
  bool get playing => _player.playing;

  @override
  Duration get position => _player.position;

  @override
  Duration get bufferedPosition => _player.bufferedPosition;

  @override
  double get speed => _player.speed;

  @override
  bool get hasAudioSource => _player.audioSource != null;

  @override
  Future<void> setSource(PlaybackResolvedSource source) {
    switch (source.kind) {
      case PlaybackResolvedSourceKind.filePath:
        return _player.setFilePath(source.url);
      case PlaybackResolvedSourceKind.neteaseCacheStream:
        return _player.setAudioSource(
          NeteaseCacheStreamSource(source.url, source.fileType),
        );
      case PlaybackResolvedSourceKind.url:
        return _player.setUrl(source.url);
      case PlaybackResolvedSourceKind.empty:
        return Future.value();
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() => _player.dispose();
}

// ignore: experimental_member_use
/// 网易云 `.uc!` 缓存文件解密后的音频流来源。
class NeteaseCacheStreamSource extends StreamAudioSource {
  /// 创建网易云缓存流音源。
  NeteaseCacheStreamSource(this.uri, this.fileType);

  /// 本地缓存文件路径。
  final String uri;

  /// 解密后提供给播放器的内容类型。
  final String fileType;

  @override
  // ignore: experimental_member_use
  /// 读取并解密缓存文件字节流。
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final file = File(uri);
    final sourceLength = await file.length();
    final offset = _clampRangeValue(start ?? 0, 0, sourceLength);
    final resolvedEnd =
        _clampRangeValue(end ?? sourceLength, offset, sourceLength);

    // ignore: experimental_member_use
    return StreamAudioResponse(
      sourceLength: sourceLength,
      contentLength: resolvedEnd - offset,
      offset: offset,
      stream: file.openRead(offset, resolvedEnd).map(_decryptChunk),
      contentType: _contentTypeForFileType(fileType),
    );
  }

  Uint8List _decryptChunk(List<int> chunk) {
    final decrypted = Uint8List(chunk.length);
    for (var index = 0; index < chunk.length; index++) {
      decrypted[index] = chunk[index] ^ 0xa3;
    }
    return decrypted;
  }

  int _clampRangeValue(int value, int min, int max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  String _contentTypeForFileType(String type) {
    switch (type.toLowerCase()) {
      case 'mp3':
        return 'audio/mpeg';
      case 'flac':
        return 'audio/flac';
      case 'm4a':
        return 'audio/mp4';
      case 'aac':
        return 'audio/aac';
      case 'wav':
        return 'audio/wav';
      case 'ogg':
        return 'audio/ogg';
      default:
        return type.contains('/') ? type : 'application/octet-stream';
    }
  }
}
