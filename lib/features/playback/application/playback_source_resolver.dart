import 'dart:io';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/playback_queue_item.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/features/playback/application/playback_resolved_source.dart';
import 'package:bujuan/features/playback/playback_repository.dart';

/// 将播放队列项解析成 just_audio 可消费的真实音源。
class PlaybackSourceResolver {
  /// 创建播放源解析器。
  PlaybackSourceResolver({required PlaybackRepository repository}) : _repository = repository;

  final PlaybackRepository _repository;

  /// 将播放队列项解析为底层播放器可消费的音源。
  Future<PlaybackResolvedSource> resolve(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
  }) async {
    if (item.mediaType == MediaType.local) {
      final source = _resolveLocalFileSource(item);
      if (!source.isEmpty || item.sourceType == SourceType.local) {
        return source;
      }
      return resolveRemote(item, preferHighQuality: preferHighQuality);
    }

    if (item.mediaType == MediaType.neteaseCache) {
      final source = _resolveNeteaseCacheSource(item.playbackUrl ?? '');
      if (!source.isEmpty || item.sourceType == SourceType.local) {
        return source;
      }
      return resolveRemote(item, preferHighQuality: preferHighQuality);
    }

    return resolveRemote(item, preferHighQuality: preferHighQuality);
  }

  /// 忽略本地缓存标记，直接解析远程播放地址。
  Future<PlaybackResolvedSource> resolveRemote(
    PlaybackQueueItem item, {
    required bool preferHighQuality,
    bool forceRefresh = false,
  }) async {
    final url = await _repository.fetchPlaybackUrl(
          item.id,
          preferHighQuality: preferHighQuality,
          forceRefresh: forceRefresh,
        ) ??
        '';
    if (url.isEmpty) {
      return const PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.empty,
      );
    }

    final localPath = _localPathCandidate(url);
    if (File(localPath).existsSync()) {
      return PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.filePath,
        url: localPath,
        markAsCached: true,
      );
    }
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.url,
      url: url,
    );
  }

  bool _isEncryptedNeteaseCache(String url) {
    return url.endsWith('.uc!');
  }

  PlaybackResolvedSource _resolveLocalFileSource(PlaybackQueueItem item) {
    final localPath = _localPathCandidate(item.playbackUrl ?? '');
    if (localPath.isEmpty || !File(localPath).existsSync()) {
      return const PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.empty,
      );
    }
    return PlaybackResolvedSource(
      kind: PlaybackResolvedSourceKind.filePath,
      url: localPath,
      markAsCached: item.sourceType != SourceType.local,
    );
  }

  PlaybackResolvedSource _resolveNeteaseCacheSource(String url) {
    final localPath = _localPathCandidate(url);
    if (localPath.isEmpty || !File(localPath).existsSync()) {
      return const PlaybackResolvedSource(
        kind: PlaybackResolvedSourceKind.empty,
      );
    }
    final isEncryptedCache = _isEncryptedNeteaseCache(localPath);
    return PlaybackResolvedSource(
      kind: isEncryptedCache ? PlaybackResolvedSourceKind.neteaseCacheStream : PlaybackResolvedSourceKind.filePath,
      url: localPath,
      fileType: isEncryptedCache ? localPath.replaceAll('.uc!', '').split('.').last : '',
      markAsCached: true,
    );
  }

  String _localPathCandidate(String url) {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      return '';
    }
    final uri = Uri.tryParse(trimmedUrl);
    final scheme = uri?.scheme.toLowerCase();
    if (uri != null && scheme == 'file') {
      final host = uri.host.toLowerCase();
      if (!Platform.isWindows && host.isNotEmpty && host != 'localhost') {
        return '';
      }
      return Uri(
        scheme: 'file',
        host: Platform.isWindows && host.isNotEmpty && host != 'localhost' ? uri.host : null,
        path: uri.path,
      ).toFilePath(windows: Platform.isWindows);
    }
    if (scheme == 'http' || scheme == 'https') {
      return '';
    }
    return trimmedUrl.split('?').first;
  }
}
