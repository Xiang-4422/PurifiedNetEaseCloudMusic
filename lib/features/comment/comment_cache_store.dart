import 'dart:convert';

import 'package:bujuan/core/entities/comment_data.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/app_cache_data_source.dart';

/// 评论短期缓存存储。
class CommentCacheStore {
  /// 创建评论缓存存储。
  const CommentCacheStore({
    required AppCacheDataSource cacheDataSource,
  }) : _cacheDataSource = cacheDataSource;

  final AppCacheDataSource _cacheDataSource;

  /// 读取评论列表缓存。
  Future<({List<CommentData> items, bool hasMore, String? nextCursor})?> loadComments(
    CommentListCacheKey key,
  ) async {
    final payloadJson = await _cacheDataSource.loadPayloadJson(_commentListKey(key));
    if (payloadJson == null) {
      return null;
    }
    final cached = _decodeMap(payloadJson);
    if (cached == null) {
      return null;
    }
    return (
      items: _commentItems(cached['items']),
      hasMore: cached['hasMore'] == true,
      nextCursor: cached['nextCursor']?.toString(),
    );
  }

  /// 保存评论列表缓存。
  Future<void> saveComments(
    CommentListCacheKey key, {
    required List<CommentData> items,
    required bool hasMore,
    required String? nextCursor,
  }) {
    return _cacheDataSource.save(
      cacheKey: _commentListKey(key),
      payloadJson: jsonEncode({
        'items': items.map((item) => item.toJson()).toList(),
        'hasMore': hasMore,
        'nextCursor': nextCursor,
      }),
    );
  }

  /// 判断评论列表缓存是否新鲜。
  Future<bool> isCommentsFresh(
    CommentListCacheKey key, {
    required Duration ttl,
  }) {
    return _cacheDataSource.isFresh(
      _commentListKey(key),
      ttl: ttl,
    );
  }

  /// 读取楼层评论缓存。
  Future<({List<CommentData> items, bool hasMore, int nextTime})?> loadFloorComments(
    FloorCommentCacheKey key,
  ) async {
    final payloadJson = await _cacheDataSource.loadPayloadJson(_floorCommentKey(key));
    if (payloadJson == null) {
      return null;
    }
    final cached = _decodeMap(payloadJson);
    if (cached == null) {
      return null;
    }
    return (
      items: _commentItems(cached['items']),
      hasMore: cached['hasMore'] == true,
      nextTime: _intValue(cached['nextTime'], fallback: -1),
    );
  }

  /// 保存楼层评论缓存。
  Future<void> saveFloorComments(
    FloorCommentCacheKey key, {
    required List<CommentData> items,
    required bool hasMore,
    required int nextTime,
  }) {
    return _cacheDataSource.save(
      cacheKey: _floorCommentKey(key),
      payloadJson: jsonEncode({
        'items': items.map((item) => item.toJson()).toList(),
        'hasMore': hasMore,
        'nextTime': nextTime,
      }),
    );
  }

  /// 判断楼层评论缓存是否新鲜。
  Future<bool> isFloorCommentsFresh(
    FloorCommentCacheKey key, {
    required Duration ttl,
  }) {
    return _cacheDataSource.isFresh(
      _floorCommentKey(key),
      ttl: ttl,
    );
  }

  String _commentListKey(CommentListCacheKey key) {
    return [
      appCacheCommentListPrefix,
      key.id,
      key.type,
      key.pageNo,
      key.pageSize,
      key.showInner ? 1 : 0,
      key.sortType,
      key.cursor,
    ].map((item) => Uri.encodeComponent('$item')).join(':');
  }

  String _floorCommentKey(FloorCommentCacheKey key) {
    return [
      appCacheFloorCommentPrefix,
      key.id,
      key.type,
      key.parentCommentId,
      key.time,
      key.limit,
    ].map((item) => Uri.encodeComponent('$item')).join(':');
  }

  Map<String, dynamic>? _decodeMap(String payloadJson) {
    try {
      final decoded = jsonDecode(payloadJson);
      if (decoded is! Map) {
        return null;
      }
      return Map<String, dynamic>.from(
        decoded.map((key, value) => MapEntry('$key', value)),
      );
    } catch (_) {
      return null;
    }
  }

  List<CommentData> _commentItems(dynamic value) {
    final comments = <CommentData>[];
    for (final item in value as List? ?? const []) {
      if (item is! Map) {
        continue;
      }
      try {
        comments.add(
          CommentData.fromJson(
            Map<String, dynamic>.from(
              item.map((key, value) => MapEntry('$key', value)),
            ),
          ),
        );
      } catch (_) {
        continue;
      }
    }
    return comments;
  }

  int _intValue(dynamic value, {required int fallback}) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

/// 评论列表缓存键。
class CommentListCacheKey {
  /// 创建评论列表缓存键。
  const CommentListCacheKey({
    required this.id,
    required this.type,
    required this.pageNo,
    required this.pageSize,
    required this.showInner,
    required this.sortType,
    required this.cursor,
  });

  /// 资源 id。
  final String id;

  /// 资源类型。
  final String type;

  /// 页码。
  final int pageNo;

  /// 每页数量。
  final int pageSize;

  /// 是否显示内部评论。
  final bool showInner;

  /// 排序类型。
  final int sortType;

  /// 分页游标。
  final String cursor;
}

/// 楼层评论缓存键。
class FloorCommentCacheKey {
  /// 创建楼层评论缓存键。
  const FloorCommentCacheKey({
    required this.id,
    required this.type,
    required this.parentCommentId,
    required this.time,
    required this.limit,
  });

  /// 资源 id。
  final String id;

  /// 资源类型。
  final String type;

  /// 父评论 id。
  final String parentCommentId;

  /// 时间游标。
  final int time;

  /// 每页数量。
  final int limit;
}
