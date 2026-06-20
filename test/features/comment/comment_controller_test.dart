import 'dart:async';

import 'package:bujuan/core/entities/comment_data.dart';
import 'package:bujuan/features/comment/comment_list_controller.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:bujuan/features/comment/floor_comment_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommentListController', () {
    test('keeps visible comments when refresh fails', () async {
      final repository = _FakeCommentRepository(
        comments: [_comment('cached')],
      );
      final controller = CommentListController(
        id: 'netease:1',
        type: 'song',
        sortType: 99,
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      repository.fetchCommentsError = StateError('offline');

      final refreshed = await controller.refresh();

      expect(refreshed, isFalse);
      expect(controller.state.value.items.map((item) => item.commentId), ['cached']);
      expect(controller.state.value.refreshing, isFalse);
      expect(controller.state.value.error, isA<StateError>());
    });

    test('uses initial error when no comments are visible', () async {
      final repository = _FakeCommentRepository()..fetchCommentsError = StateError('offline');
      final controller = CommentListController(
        id: 'netease:1',
        type: 'song',
        sortType: 99,
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(controller.state.value.items, isEmpty);
      expect(controller.state.value.hasInitialError, isTrue);
      expect(controller.state.value.error, isA<StateError>());
    });

    test('ignores stale load more result after refresh completes', () async {
      final loadMore = Completer<CommentPage>();
      final refresh = Completer<CommentPage>();
      var firstPageLoaded = false;
      final repository = _FakeCommentRepository(
        fetchCommentsWithArgs: ({
          required id,
          required type,
          required pageNo,
          required pageSize,
          required sortType,
          required cursor,
          required forceRefresh,
        }) {
          if (pageNo == 1 && !firstPageLoaded) {
            firstPageLoaded = true;
            return Future.value(
              CommentPage(
                items: [_comment('old-comment')],
                hasMore: true,
                nextCursor: 'old-cursor',
              ),
            );
          }
          if (pageNo == 1) {
            return refresh.future;
          }
          return loadMore.future;
        },
      );
      final controller = CommentListController(
        id: 'netease:1',
        type: 'song',
        sortType: 99,
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      expect(controller.state.value.items.map((item) => item.commentId), ['old-comment']);

      final loadMoreFuture = controller.loadMore();
      await _flushAsync();
      expect(controller.state.value.loadingMore, isTrue);

      final refreshFuture = controller.refresh();
      await _flushAsync();
      refresh.complete(
        CommentPage(
          items: [_comment('fresh-comment')],
          hasMore: true,
          nextCursor: 'fresh-cursor',
        ),
      );
      await refreshFuture;

      expect(controller.state.value.items.map((item) => item.commentId), ['fresh-comment']);

      loadMore.complete(
        CommentPage(
          items: [_comment('stale-comment')],
          hasMore: false,
          nextCursor: 'stale-cursor',
        ),
      );
      await loadMoreFuture;

      expect(controller.state.value.items.map((item) => item.commentId), ['fresh-comment']);
      expect(controller.state.value.loadingMore, isFalse);
      expect(controller.state.value.refreshing, isFalse);
    });

    test('ignores refresh completion after dispose', () async {
      final refresh = Completer<CommentPage>();
      final repository = _FakeCommentRepository(
        fetchCommentsWithArgs: ({
          required id,
          required type,
          required pageNo,
          required pageSize,
          required sortType,
          required cursor,
          required forceRefresh,
        }) {
          return refresh.future;
        },
      );
      final controller = CommentListController(
        id: 'netease:1',
        type: 'song',
        sortType: 99,
        repository: repository,
      );

      final refreshFuture = controller.refresh();
      await _flushAsync();

      controller.dispose();
      refresh.complete(
        CommentPage(
          items: [_comment('late-comment')],
          hasMore: false,
          nextCursor: 'late-cursor',
        ),
      );

      await expectLater(refreshFuture, completes);
    });

    test('ignores load more completion after dispose', () async {
      final loadMore = Completer<CommentPage>();
      final repository = _FakeCommentRepository(
        fetchCommentsWithArgs: ({
          required id,
          required type,
          required pageNo,
          required pageSize,
          required sortType,
          required cursor,
          required forceRefresh,
        }) {
          if (pageNo == 1) {
            return Future.value(
              CommentPage(
                items: [_comment('cached-comment')],
                hasMore: true,
                nextCursor: 'cached-cursor',
              ),
            );
          }
          return loadMore.future;
        },
      );
      final controller = CommentListController(
        id: 'netease:1',
        type: 'song',
        sortType: 99,
        repository: repository,
      );

      await controller.loadInitial();
      final loadMoreFuture = controller.loadMore();
      await _flushAsync();

      controller.dispose();
      loadMore.complete(
        CommentPage(
          items: [_comment('late-comment')],
          hasMore: false,
          nextCursor: 'late-cursor',
        ),
      );

      await expectLater(loadMoreFuture, completes);
    });
  });

  group('FloorCommentController', () {
    test('keeps visible replies when refresh fails', () async {
      final repository = _FakeCommentRepository(
        floorComments: [_comment('reply')],
      );
      final controller = FloorCommentController(
        id: 'netease:1',
        type: 'song',
        parentCommentId: 'parent',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      repository.fetchFloorCommentsError = StateError('offline');

      final refreshed = await controller.refresh();

      expect(refreshed, isFalse);
      expect(controller.state.value.items.map((item) => item.commentId), ['reply']);
      expect(controller.state.value.refreshing, isFalse);
      expect(controller.state.value.error, isA<StateError>());
    });

    test('uses initial error when no replies are visible', () async {
      final repository = _FakeCommentRepository()..fetchFloorCommentsError = StateError('offline');
      final controller = FloorCommentController(
        id: 'netease:1',
        type: 'song',
        parentCommentId: 'parent',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      expect(controller.state.value.items, isEmpty);
      expect(controller.state.value.hasInitialError, isTrue);
      expect(controller.state.value.error, isA<StateError>());
    });

    test('ignores stale load more result after refresh completes', () async {
      final loadMore = Completer<FloorCommentPage>();
      final refresh = Completer<FloorCommentPage>();
      var firstPageLoaded = false;
      final repository = _FakeCommentRepository(
        fetchFloorCommentsWithArgs: ({
          required id,
          required type,
          required parentCommentId,
          required time,
          required limit,
          required forceRefresh,
        }) {
          if (time == -1 && !firstPageLoaded) {
            firstPageLoaded = true;
            return Future.value(
              FloorCommentPage(
                items: [_comment('old-reply')],
                hasMore: true,
                nextTime: 100,
              ),
            );
          }
          if (time == -1) {
            return refresh.future;
          }
          return loadMore.future;
        },
      );
      final controller = FloorCommentController(
        id: 'netease:1',
        type: 'song',
        parentCommentId: 'parent',
        repository: repository,
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      expect(controller.state.value.items.map((item) => item.commentId), ['old-reply']);

      final loadMoreFuture = controller.loadMore();
      await _flushAsync();
      expect(controller.state.value.loadingMore, isTrue);

      final refreshFuture = controller.refresh();
      await _flushAsync();
      refresh.complete(
        FloorCommentPage(
          items: [_comment('fresh-reply')],
          hasMore: true,
          nextTime: 200,
        ),
      );
      await refreshFuture;

      expect(controller.state.value.items.map((item) => item.commentId), ['fresh-reply']);

      loadMore.complete(
        FloorCommentPage(
          items: [_comment('stale-reply')],
          hasMore: false,
          nextTime: 300,
        ),
      );
      await loadMoreFuture;

      expect(controller.state.value.items.map((item) => item.commentId), ['fresh-reply']);
      expect(controller.state.value.loadingMore, isFalse);
      expect(controller.state.value.refreshing, isFalse);
    });

    test('ignores refresh completion after dispose', () async {
      final refresh = Completer<FloorCommentPage>();
      final repository = _FakeCommentRepository(
        fetchFloorCommentsWithArgs: ({
          required id,
          required type,
          required parentCommentId,
          required time,
          required limit,
          required forceRefresh,
        }) {
          return refresh.future;
        },
      );
      final controller = FloorCommentController(
        id: 'netease:1',
        type: 'song',
        parentCommentId: 'parent',
        repository: repository,
      );

      final refreshFuture = controller.refresh();
      await _flushAsync();

      controller.dispose();
      refresh.complete(
        FloorCommentPage(
          items: [_comment('late-reply')],
          hasMore: false,
          nextTime: 1,
        ),
      );

      await expectLater(refreshFuture, completes);
    });

    test('ignores load more completion after dispose', () async {
      final loadMore = Completer<FloorCommentPage>();
      final repository = _FakeCommentRepository(
        fetchFloorCommentsWithArgs: ({
          required id,
          required type,
          required parentCommentId,
          required time,
          required limit,
          required forceRefresh,
        }) {
          if (time == -1) {
            return Future.value(
              FloorCommentPage(
                items: [_comment('cached-reply')],
                hasMore: true,
                nextTime: 100,
              ),
            );
          }
          return loadMore.future;
        },
      );
      final controller = FloorCommentController(
        id: 'netease:1',
        type: 'song',
        parentCommentId: 'parent',
        repository: repository,
      );

      await controller.loadInitial();
      final loadMoreFuture = controller.loadMore();
      await _flushAsync();

      controller.dispose();
      loadMore.complete(
        FloorCommentPage(
          items: [_comment('late-reply')],
          hasMore: false,
          nextTime: 200,
        ),
      );

      await expectLater(loadMoreFuture, completes);
    });
  });
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

Future<void> _flushAsync() async {
  for (var i = 0; i < 4; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _FakeCommentRepository implements CommentRepository {
  _FakeCommentRepository({
    this.comments = const [],
    this.floorComments = const [],
    this.fetchCommentsWithArgs,
    this.fetchFloorCommentsWithArgs,
  });

  List<CommentData> comments;
  List<CommentData> floorComments;
  final Future<CommentPage> Function({
    required String id,
    required String type,
    required int pageNo,
    required int pageSize,
    required int? sortType,
    required String? cursor,
    required bool forceRefresh,
  })? fetchCommentsWithArgs;
  final Future<FloorCommentPage> Function({
    required String id,
    required String type,
    required String parentCommentId,
    required int time,
    required int limit,
    required bool forceRefresh,
  })? fetchFloorCommentsWithArgs;
  Object? fetchCommentsError;
  Object? fetchFloorCommentsError;

  @override
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
    final fetchWithArgs = fetchCommentsWithArgs;
    if (fetchWithArgs != null) {
      return fetchWithArgs(
        id: id,
        type: type,
        pageNo: pageNo,
        pageSize: pageSize,
        sortType: sortType,
        cursor: cursor,
        forceRefresh: forceRefresh,
      );
    }
    final error = fetchCommentsError;
    if (error != null) {
      throw error;
    }
    return CommentPage(
      items: comments,
      hasMore: false,
      nextCursor: 'next',
    );
  }

  @override
  Future<FloorCommentPage> fetchFloorComments(
    String id,
    String type,
    String parentCommentId, {
    int time = -1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final fetchWithArgs = fetchFloorCommentsWithArgs;
    if (fetchWithArgs != null) {
      return fetchWithArgs(
        id: id,
        type: type,
        parentCommentId: parentCommentId,
        time: time,
        limit: limit,
        forceRefresh: forceRefresh,
      );
    }
    final error = fetchFloorCommentsError;
    if (error != null) {
      throw error;
    }
    return FloorCommentPage(
      items: floorComments,
      hasMore: false,
      nextTime: 1,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
