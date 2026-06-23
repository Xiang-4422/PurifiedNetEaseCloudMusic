import 'package:bujuan/core/state/operation_result.dart';
import 'package:bujuan/data/music_data/music_remote_data_sources.dart';
import 'package:bujuan/core/entities/comment_data.dart';
import 'package:bujuan/features/comment/comment_cache_store.dart';

/// 评论仓库，封装评论列表、楼层评论、发送评论和点赞操作。
class CommentRepository {
  /// 创建评论仓库。
  CommentRepository({
    required CommentRemoteDataSource remoteDataSource,
    required CommentCacheStore cacheStore,
    Duration cacheTtl = const Duration(minutes: 10),
  })  : _remoteDataSource = remoteDataSource,
        _cacheStore = cacheStore,
        _cacheTtl = cacheTtl;

  final CommentRemoteDataSource _remoteDataSource;
  final CommentCacheStore _cacheStore;
  final Duration _cacheTtl;

  /// 分页获取评论列表。
  Future<CommentPage> fetchComments(
    String id,
    String type, {
    int pageNo = 1,
    int pageSize = 20,
    bool showInner = false,
    int? sortType,
    String? cursor,
    bool forceRefresh = false,
  }) async {
    final cacheKey = CommentListCacheKey(
      id: id,
      type: type,
      pageNo: pageNo,
      pageSize: pageSize,
      showInner: showInner,
      sortType: sortType ?? 99,
      cursor: cursor ?? '0',
    );
    final freshCachedPage = forceRefresh ? null : await _loadFreshCommentPage(cacheKey);
    if (freshCachedPage != null) {
      return freshCachedPage;
    }
    try {
      final page = await _remoteDataSource.fetchComments(
        id,
        type,
        pageNo: cacheKey.pageNo,
        pageSize: cacheKey.pageSize,
        showInner: cacheKey.showInner,
        sortType: cacheKey.sortType,
        cursor: cacheKey.cursor,
      );
      await _saveCommentsSafely(
        cacheKey,
        items: page.items,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
      );
      return CommentPage(
        items: page.items,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
      );
    } catch (_) {
      final cachedPage = await _loadCommentPage(cacheKey);
      if (cachedPage != null) {
        return cachedPage;
      }
      rethrow;
    }
  }

  Future<CommentPage?> _loadFreshCommentPage(CommentListCacheKey cacheKey) async {
    if (!await _areCommentsFresh(cacheKey)) {
      return null;
    }
    return _loadCommentPage(cacheKey);
  }

  Future<CommentPage?> _loadCommentPage(CommentListCacheKey cacheKey) async {
    final ({bool hasMore, List<CommentData> items, String? nextCursor})? cachedPage;
    try {
      cachedPage = await _cacheStore.loadComments(cacheKey);
    } catch (_) {
      return null;
    }
    if (cachedPage == null) {
      return null;
    }
    return CommentPage(
      items: cachedPage.items,
      hasMore: cachedPage.hasMore,
      nextCursor: cachedPage.nextCursor,
    );
  }

  /// 分页获取楼层评论。
  Future<FloorCommentPage> fetchFloorComments(
    String id,
    String type,
    String parentCommentId, {
    int time = -1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = FloorCommentCacheKey(
      id: id,
      type: type,
      parentCommentId: parentCommentId,
      time: time,
      limit: limit,
    );
    final freshCachedPage = forceRefresh ? null : await _loadFreshFloorCommentPage(cacheKey);
    if (freshCachedPage != null) {
      return freshCachedPage;
    }
    try {
      final page = await _remoteDataSource.fetchFloorComments(
        id,
        type,
        parentCommentId,
        time: cacheKey.time,
        limit: cacheKey.limit,
      );
      await _saveFloorCommentsSafely(
        cacheKey,
        items: page.items,
        hasMore: page.hasMore,
        nextTime: page.nextTime,
      );
      return FloorCommentPage(
        items: page.items,
        hasMore: page.hasMore,
        nextTime: page.nextTime,
      );
    } catch (_) {
      final cachedPage = await _loadFloorCommentPage(cacheKey);
      if (cachedPage != null) {
        return cachedPage;
      }
      rethrow;
    }
  }

  Future<FloorCommentPage?> _loadFreshFloorCommentPage(
    FloorCommentCacheKey cacheKey,
  ) async {
    if (!await _areFloorCommentsFresh(cacheKey)) {
      return null;
    }
    return _loadFloorCommentPage(cacheKey);
  }

  Future<FloorCommentPage?> _loadFloorCommentPage(
    FloorCommentCacheKey cacheKey,
  ) async {
    final ({bool hasMore, List<CommentData> items, int nextTime})? cachedPage;
    try {
      cachedPage = await _cacheStore.loadFloorComments(cacheKey);
    } catch (_) {
      return null;
    }
    if (cachedPage == null) {
      return null;
    }
    return FloorCommentPage(
      items: cachedPage.items,
      hasMore: cachedPage.hasMore,
      nextTime: cachedPage.nextTime,
    );
  }

  Future<bool> _areCommentsFresh(CommentListCacheKey cacheKey) async {
    try {
      return await _cacheStore.isCommentsFresh(cacheKey, ttl: _cacheTtl);
    } catch (_) {
      return false;
    }
  }

  Future<bool> _areFloorCommentsFresh(FloorCommentCacheKey cacheKey) async {
    try {
      return await _cacheStore.isFloorCommentsFresh(cacheKey, ttl: _cacheTtl);
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveCommentsSafely(
    CommentListCacheKey cacheKey, {
    required List<CommentData> items,
    required bool hasMore,
    required String? nextCursor,
  }) async {
    try {
      await _cacheStore.saveComments(
        cacheKey,
        items: items,
        hasMore: hasMore,
        nextCursor: nextCursor,
      );
    } catch (_) {}
  }

  Future<void> _saveFloorCommentsSafely(
    FloorCommentCacheKey cacheKey, {
    required List<CommentData> items,
    required bool hasMore,
    required int nextTime,
  }) async {
    try {
      await _cacheStore.saveFloorComments(
        cacheKey,
        items: items,
        hasMore: hasMore,
        nextTime: nextTime,
      );
    } catch (_) {}
  }

  /// 发送、回复或删除评论。
  Future<OperationResult> sendComment(
    String id,
    String type,
    String operation, {
    required String content,
    String? commentId,
  }) async {
    final result = await _remoteDataSource.sendComment(
      id,
      type,
      operation,
      content: content,
      commentId: commentId,
    );
    return OperationResult(
      success: result.success,
      message: result.message,
    );
  }

  /// 切换评论点赞状态。
  Future<OperationResult> toggleCommentLike(
    String id,
    String type,
    String commentId,
    bool like,
  ) async {
    final result = await _remoteDataSource.toggleCommentLike(
      id,
      type,
      commentId,
      like,
    );
    return OperationResult(
      success: result.success,
      message: result.message,
    );
  }
}

/// 评论分页数据。
class CommentPage {
  /// 创建评论分页数据。
  const CommentPage({
    required this.items,
    required this.hasMore,
    required this.nextCursor,
  });

  /// 评论列表。
  final List<CommentData> items;

  /// 是否还有下一页。
  final bool hasMore;

  /// 下一页游标。
  final String? nextCursor;
}

/// 楼层评论分页数据。
class FloorCommentPage {
  /// 创建楼层评论分页数据。
  const FloorCommentPage({
    required this.items,
    required this.hasMore,
    required this.nextTime,
  });

  /// 评论列表。
  final List<CommentData> items;

  /// 是否还有下一页。
  final bool hasMore;

  /// 下一页时间游标。
  final int nextTime;
}
