import 'dart:math';

import 'package:bujuan/core/entities/music_resource_id.dart';

/// 规划网易云歌曲详情批量请求。
List<List<String>> planNeteaseSongDetailBatches({
  required List<String> ids,
  int offset = 0,
  int limit = -1,
  int batchSize = 1000,
}) {
  if (batchSize <= 0) {
    return const [];
  }

  final normalizedIds = normalizeNeteaseSongIds(ids);
  final startOffset = max(0, offset);
  if (startOffset >= normalizedIds.length) {
    return const [];
  }

  final targetIds = normalizedIds.sublist(startOffset);
  final fetchCount = limit < 0 || targetIds.length < limit ? targetIds.length : limit;
  final resolvedIds = targetIds.take(fetchCount).toList();
  return [
    for (var start = 0; start < resolvedIds.length; start += batchSize)
      resolvedIds.sublist(
        start,
        min(start + batchSize, resolvedIds.length),
      ),
  ];
}

/// 规范化网易云原始歌曲 id。
String normalizeNeteaseSongId(String id) {
  final sourceSongId = MusicResourceId.toNeteaseSourceId(id).trim();
  if (sourceSongId.isEmpty || MusicResourceId.hasKnownPrefix(sourceSongId)) {
    return '';
  }
  return sourceSongId;
}

/// 规范化网易云原始歌曲 id 列表，过滤空白值并保留顺序。
List<String> normalizeNeteaseSongIds(Iterable<String> ids) {
  return ids.map(normalizeNeteaseSongId).where((id) => id.isNotEmpty).toList();
}
