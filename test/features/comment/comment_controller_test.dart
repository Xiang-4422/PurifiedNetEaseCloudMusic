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

class _FakeCommentRepository implements CommentRepository {
  _FakeCommentRepository({
    this.comments = const [],
    this.floorComments = const [],
  });

  List<CommentData> comments;
  List<CommentData> floorComments;
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
