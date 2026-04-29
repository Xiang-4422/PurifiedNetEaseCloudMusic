import 'dart:io';
import 'dart:typed_data';

import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:just_audio/just_audio.dart';

/// 封装 `just_audio` 细节，避免 audio_service handler 继续直接处理文件源和缓存流。
class PlaybackEngineAdapter {
  /// 创建播放引擎适配器。
  PlaybackEngineAdapter({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  /// 底层播放器事件流。
  Stream<PlaybackEvent> get playbackEventStream => _player.playbackEventStream;

  /// 当前播放器处理状态。
  ProcessingState get processingState => _player.processingState;

  /// 当前是否启用随机播放。
  bool get shuffleModeEnabled => _player.shuffleModeEnabled;

  /// 当前是否正在播放。
  bool get playing => _player.playing;

  /// 当前播放进度。
  Duration get position => _player.position;

  /// 当前缓冲进度。
  Duration get bufferedPosition => _player.bufferedPosition;

  /// 当前播放速度。
  double get speed => _player.speed;

  /// 当前是否已经设置音源。
  bool get hasAudioSource => _player.audioSource != null;

  /// 设置底层播放器音源。
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

  /// 开始播放。
  Future<void> play() => _player.play();

  /// 暂停播放。
  Future<void> pause() => _player.pause();

  /// 跳转到指定播放进度。
  Future<void> seek(Duration position) => _player.seek(position);

  /// 释放底层播放器。
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
    // `.uc!` 不是标准媒体文件，播放器只能接收解密后的字节流。
    final fileBytes = Uint8List.fromList(
      File(uri).readAsBytesSync().map((byte) => byte ^ 0xa3).toList(),
    );

    // ignore: experimental_member_use
    return StreamAudioResponse(
      sourceLength: fileBytes.length,
      contentLength: (end ?? fileBytes.length) - (start ?? 0),
      offset: start ?? 0,
      stream: Stream.fromIterable([fileBytes.sublist(start ?? 0, end)]),
      contentType: fileType,
    );
  }
}
