import 'dart:io';
import 'dart:typed_data';

import 'package:bujuan/features/playback/application/playback_source_resolver.dart';
import 'package:just_audio/just_audio.dart';

/// 封装 `just_audio` 细节，避免 audio_service handler 继续直接处理文件源和缓存流。
class PlaybackEngineAdapter {
  /// 创建 PlaybackEngineAdapter。
  PlaybackEngineAdapter({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  /// playbackEventStream。
  Stream<PlaybackEvent> get playbackEventStream => _player.playbackEventStream;

  /// processingState。
  ProcessingState get processingState => _player.processingState;

  /// shuffleModeEnabled。
  bool get shuffleModeEnabled => _player.shuffleModeEnabled;

  /// playing。
  bool get playing => _player.playing;

  /// position。
  Duration get position => _player.position;

  /// bufferedPosition。
  Duration get bufferedPosition => _player.bufferedPosition;

  /// speed。
  double get speed => _player.speed;

  /// hasAudioSource。
  bool get hasAudioSource => _player.audioSource != null;

  /// setSource。
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

  /// play。
  Future<void> play() => _player.play();

  /// pause。
  Future<void> pause() => _player.pause();

  /// seek。
  Future<void> seek(Duration position) => _player.seek(position);

  /// dispose。
  Future<void> dispose() => _player.dispose();
}

// ignore: experimental_member_use
/// NeteaseCacheStreamSource。
class NeteaseCacheStreamSource extends StreamAudioSource {
  /// 创建 NeteaseCacheStreamSource。
  NeteaseCacheStreamSource(this.uri, this.fileType);

  /// uri。
  final String uri;

  /// fileType。
  final String fileType;

  @override
  // ignore: experimental_member_use
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
