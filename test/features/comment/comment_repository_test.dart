import 'package:bujuan/core/entities/comment_data.dart';
import 'package:bujuan/data/music_data/sources/local/database/data_sources/app_cache_data_source.dart';
import 'package:bujuan/data/music_data/sources/netease/remote/netease_comment_remote_data_source.dart';
import 'package:bujuan/features/comment/comment_cache_store.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommentRepository', () {
    test('reuses fresh cached comments without remote request', () async {
      final remoteDataSource = _FakeNeteaseCommentRemoteDataSource(
        comments: [_comment('1')],
      );
      final repository = _buildRepository(remoteDataSource);

      final first = await repository.fetchComments('netease:101', 'song');
      remoteDataSource.comments = [_comment('2')];
      final second = await repository.fetchComments('netease:101', 'song');

      expect(first.items.map((item) => item.commentId), ['1']);
      expect(second.items.map((item) => item.commentId), ['1']);
      expect(remoteDataSource.fetchCommentsCallCount, 1);
    });

    test('normalizes comment cache key and remote parameters', () async {
      final remoteDataSource = _FakeNeteaseCommentRemoteDataSource(
        comments: [_comment('1')],
      );
      final repository = _buildRepository(remoteDataSource);

      final first = await repository.fetchComments(
        ' netease:101 ',
        ' song ',
        cursor: ' ',
      );
      remoteDataSource.comments = [_comment('2')];
      final second = await repository.fetchComments('netease:101', 'song');

      expect(first.items.map((item) => item.commentId), ['1']);
      expect(second.items.map((item) => item.commentId), ['1']);
      expect(remoteDataSource.fetchCommentsCallCount, 1);
      expect(
        remoteDataSource.commentRequests.single,
        (
          id: 'netease:101',
          type: 'song',
          pageNo: 1,
          pageSize: 20,
          showInner: false,
          sortType: 99,
          cursor: '0',
        ),
      );
    });

    test('force refresh bypasses fresh cached comments and updates cache', () async {
      final remoteDataSource = _FakeNeteaseCommentRemoteDataSource(
        comments: [_comment('1')],
      );
      final repository = _buildRepository(remoteDataSource);

      await repository.fetchComments('netease:101', 'song');
      remoteDataSource.comments = [_comment('2')];
      final refreshed = await repository.fetchComments(
        'netease:101',
        'song',
        forceRefresh: true,
      );
      final cached = await repository.fetchComments('netease:101', 'song');

      expect(refreshed.items.map((item) => item.commentId), ['2']);
      expect(cached.items.map((item) => item.commentId), ['2']);
      expect(remoteDataSource.fetchCommentsCallCount, 2);
    });

    test('falls back to cached comments when remote refresh fails', () async {
      final remoteDataSource = _FakeNeteaseCommentRemoteDataSource(
        comments: [_comment('1')],
      );
      final repository = _buildRepository(remoteDataSource);
      await repository.fetchComments('netease:101', 'song');
      remoteDataSource.fetchCommentsError = Exception('offline');

      final fallback = await repository.fetchComments(
        'netease:101',
        'song',
        forceRefresh: true,
      );

      expect(fallback.items.map((item) => item.commentId), ['1']);
      expect(remoteDataSource.fetchCommentsCallCount, 2);
    });

    test('fetches remote comments when freshness check fails', () async {
      final remoteDataSource = _FakeNeteaseCommentRemoteDataSource(
        comments: [_comment('remote')],
      );
      final repository = _buildRepository(
        remoteDataSource,
        cacheDataSource: _FailingAppCacheDataSource(failIsFresh: true),
      );

      final page = await repository.fetchComments('netease:101', 'song');

      expect(page.items.map((item) => item.commentId), ['remote']);
      expect(remoteDataSource.fetchCommentsCallCount, 1);
    });

    test('fetches remote comments when fresh cached comments fail to load', () async {
      final remoteDataSource = _FakeNeteaseCommentRemoteDataSource(
        comments: [_comment('remote')],
      );
      final repository = _buildRepository(
        remoteDataSource,
        cacheDataSource: _FailingAppCacheDataSource(
          failLoadPayloadJson: true,
          freshResult: true,
        ),
      );

      final page = await repository.fetchComments('netease:101', 'song');

      expect(page.items.map((item) => item.commentId), ['remote']);
      expect(remoteDataSource.fetchCommentsCallCount, 1);
    });

    test('returns remote comments when cache save fails', () async {
      final remoteDataSource = _FakeNeteaseCommentRemoteDataSource(
        comments: [_comment('remote')],
      );
      final repository = _buildRepository(
        remoteDataSource,
        cacheDataSource: _FailingAppCacheDataSource(failSave: true),
      );

      final page = await repository.fetchComments('netease:101', 'song');

      expect(page.items.map((item) => item.commentId), ['remote']);
      expect(remoteDataSource.fetchCommentsCallCount, 1);
    });

    test('falls back to cached floor comments when remote refresh fails', () async {
      final remoteDataSource = _FakeNeteaseCommentRemoteDataSource(
        floorComments: [_comment('floor-1')],
        floorNextTime: 123,
      );
      final repository = _buildRepository(remoteDataSource);
      await repository.fetchFloorComments('netease:101', 'song', 'parent-1');
      remoteDataSource.fetchFloorCommentsError = Exception('offline');

      final fallback = await repository.fetchFloorComments(
        'netease:101',
        'song',
        'parent-1',
        forceRefresh: true,
      );

      expect(fallback.items.map((item) => item.commentId), ['floor-1']);
      expect(fallback.nextTime, 123);
      expect(remoteDataSource.fetchFloorCommentsCallCount, 2);
    });

    test('normalizes floor comment cache key and remote parameters', () async {
      final remoteDataSource = _FakeNeteaseCommentRemoteDataSource(
        floorComments: [_comment('floor-1')],
        floorNextTime: 123,
      );
      final repository = _buildRepository(remoteDataSource);

      final first = await repository.fetchFloorComments(
        ' netease:101 ',
        ' song ',
        ' parent-1 ',
      );
      remoteDataSource.floorComments = [_comment('floor-2')];
      final second = await repository.fetchFloorComments(
        'netease:101',
        'song',
        'parent-1',
      );

      expect(first.items.map((item) => item.commentId), ['floor-1']);
      expect(second.items.map((item) => item.commentId), ['floor-1']);
      expect(remoteDataSource.fetchFloorCommentsCallCount, 1);
      expect(
        remoteDataSource.floorCommentRequests.single,
        (
          id: 'netease:101',
          type: 'song',
          parentCommentId: 'parent-1',
          time: -1,
          limit: 20,
        ),
      );
    });

    test('returns remote floor comments when cache save fails', () async {
      final remoteDataSource = _FakeNeteaseCommentRemoteDataSource(
        floorComments: [_comment('floor-remote')],
        floorNextTime: 456,
      );
      final repository = _buildRepository(
        remoteDataSource,
        cacheDataSource: _FailingAppCacheDataSource(failSave: true),
      );

      final page = await repository.fetchFloorComments(
        'netease:101',
        'song',
        'parent-1',
      );

      expect(page.items.map((item) => item.commentId), ['floor-remote']);
      expect(page.nextTime, 456);
      expect(remoteDataSource.fetchFloorCommentsCallCount, 1);
    });
  });
}

CommentRepository _buildRepository(
  _FakeNeteaseCommentRemoteDataSource remoteDataSource, {
  AppCacheDataSource? cacheDataSource,
}) {
  return CommentRepository(
    remoteDataSource: remoteDataSource,
    cacheStore: CommentCacheStore(
      cacheDataSource: cacheDataSource ?? _InMemoryAppCacheDataSource(),
    ),
  );
}

CommentData _comment(String id) {
  return CommentData(
    commentId: id,
    user: CommentUserData(
      nickname: 'User $id',
      avatarUrl: 'https://avatar.test/$id.jpg',
    ),
    content: 'Comment $id',
    time: 1000,
    replyCount: 1,
    likedCount: 2,
    liked: false,
  );
}

class _FakeNeteaseCommentRemoteDataSource implements NeteaseCommentRemoteDataSource {
  _FakeNeteaseCommentRemoteDataSource({
    this.comments = const [],
    this.floorComments = const [],
    this.floorNextTime = -1,
  });

  List<CommentData> comments;
  List<CommentData> floorComments;
  int floorNextTime;
  Object? fetchCommentsError;
  Object? fetchFloorCommentsError;
  int fetchCommentsCallCount = 0;
  int fetchFloorCommentsCallCount = 0;
  final commentRequests = <({String id, String type, int pageNo, int pageSize, bool showInner, int sortType, String cursor})>[];
  final floorCommentRequests = <({String id, String type, String parentCommentId, int time, int limit})>[];

  @override
  Future<({bool hasMore, List<CommentData> items, String? nextCursor})> fetchComments(
    String id,
    String type, {
    required int pageNo,
    required int pageSize,
    required bool showInner,
    required int sortType,
    required String cursor,
  }) async {
    fetchCommentsCallCount++;
    commentRequests.add(
      (
        id: id,
        type: type,
        pageNo: pageNo,
        pageSize: pageSize,
        showInner: showInner,
        sortType: sortType,
        cursor: cursor,
      ),
    );
    final error = fetchCommentsError;
    if (error != null) {
      throw error;
    }
    return (
      items: comments,
      hasMore: false,
      nextCursor: 'next-$pageNo',
    );
  }

  @override
  Future<({bool hasMore, List<CommentData> items, int nextTime})> fetchFloorComments(
    String id,
    String type,
    String parentCommentId, {
    required int time,
    required int limit,
  }) async {
    fetchFloorCommentsCallCount++;
    floorCommentRequests.add(
      (
        id: id,
        type: type,
        parentCommentId: parentCommentId,
        time: time,
        limit: limit,
      ),
    );
    final error = fetchFloorCommentsError;
    if (error != null) {
      throw error;
    }
    return (
      items: floorComments,
      hasMore: false,
      nextTime: floorNextTime,
    );
  }

  @override
  Future<({String? message, bool success})> sendComment(
    String id,
    String type,
    String operation, {
    required String content,
    String? commentId,
  }) async {
    return (success: true, message: null);
  }

  @override
  Future<({String? message, bool success})> toggleCommentLike(
    String id,
    String type,
    String commentId,
    bool like,
  ) async {
    return (success: true, message: null);
  }
}

class _InMemoryAppCacheDataSource implements AppCacheDataSource {
  final Map<String, AppCacheRecord> _records = {};

  @override
  Future<AppCacheRecord?> load(String cacheKey) async {
    return _records[cacheKey];
  }

  @override
  Future<String?> loadPayloadJson(String cacheKey) async {
    return _records[cacheKey]?.payloadJson;
  }

  @override
  Future<void> save({
    required String cacheKey,
    required String payloadJson,
  }) async {
    _records[cacheKey] = AppCacheRecord(
      cacheKey: cacheKey,
      payloadJson: payloadJson,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> isFresh(String cacheKey, {required Duration ttl}) async {
    return _records[cacheKey]?.isFresh(ttl) ?? false;
  }

  @override
  Future<void> delete(String cacheKey) async {
    _records.remove(cacheKey);
  }

  @override
  Future<void> deleteByPrefix(String cacheKeyPrefix) async {
    _records.removeWhere((key, _) => key.startsWith(cacheKeyPrefix));
  }
}

class _FailingAppCacheDataSource extends _InMemoryAppCacheDataSource {
  _FailingAppCacheDataSource({
    this.failLoadPayloadJson = false,
    this.failSave = false,
    this.failIsFresh = false,
    this.freshResult,
  });

  final bool failLoadPayloadJson;
  final bool failSave;
  final bool failIsFresh;
  final bool? freshResult;

  @override
  Future<String?> loadPayloadJson(String cacheKey) {
    if (failLoadPayloadJson) {
      throw StateError('cache load failed');
    }
    return super.loadPayloadJson(cacheKey);
  }

  @override
  Future<void> save({
    required String cacheKey,
    required String payloadJson,
  }) {
    if (failSave) {
      throw StateError('cache save failed');
    }
    return super.save(cacheKey: cacheKey, payloadJson: payloadJson);
  }

  @override
  Future<bool> isFresh(String cacheKey, {required Duration ttl}) {
    if (failIsFresh) {
      throw StateError('cache freshness failed');
    }
    final result = freshResult;
    if (result != null) {
      return Future<bool>.value(result);
    }
    return super.isFresh(cacheKey, ttl: ttl);
  }
}
