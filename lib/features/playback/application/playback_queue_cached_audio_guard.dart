import 'dart:io';

import 'package:bujuan/core/entities/playback_media_type.dart';
import 'package:bujuan/core/entities/source_type.dart';
import 'package:bujuan/core/util/local_file_path_normalizer.dart';

/// 校验播放队列里的缓存音频标记是否仍对应真实可用的本地文件。
bool hasUsableCachedAudio({
  required bool isCached,
  required SourceType sourceType,
  required MediaType mediaType,
  required String? playbackUrl,
}) {
  if (!isCached || sourceType == SourceType.local) {
    return false;
  }
  if (mediaType != MediaType.local && mediaType != MediaType.neteaseCache) {
    return false;
  }
  final localPath = LocalFilePathNormalizer.normalize(playbackUrl);
  return localPath.isNotEmpty && File(localPath).existsSync();
}
