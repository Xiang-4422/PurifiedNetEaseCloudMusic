/// 返回稳定的喜欢歌曲 id 快照。
List<int> normalizeLikedSongIds(Iterable<int> likedSongIds) {
  return likedSongIds.toSet().toList()..sort();
}

/// 返回保留原始顺序的喜欢歌曲 id 列表。
List<int> uniqueLikedSongIds(Iterable<int> likedSongIds) {
  final seen = <int>{};
  final result = <int>[];
  for (final songId in likedSongIds) {
    if (seen.add(songId)) {
      result.add(songId);
    }
  }
  return result;
}

/// 返回可用于异步上下文比较的喜欢歌曲 id 签名。
String likedSongIdsSignature(Iterable<int> likedSongIds) {
  return normalizeLikedSongIds(likedSongIds).join(',');
}
