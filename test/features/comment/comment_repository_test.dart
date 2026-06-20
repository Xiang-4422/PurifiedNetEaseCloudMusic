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
  });
}

CommentRepository _buildRepository(
  _FakeNeteaseCommentRemoteDataSource remoteDataSource,
) {
  return CommentRepository(
    remoteDataSource: remoteDataSource,
    cacheStore: CommentCacheStore(
      cacheDataSource: _InMemoryAppCacheDataSource(),
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
