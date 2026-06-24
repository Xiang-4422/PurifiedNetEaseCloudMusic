import 'package:bujuan/data/music_data/sources/netease/remote/netease_comment_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/netease_music_api.dart';

void main() {
  group('NeteaseCommentRemoteDataSource', () {
    test('normalizes resource id before fetching comments', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseCommentRemoteDataSource(api: api);

      await dataSource.fetchComments(
        ' netease:101 ',
        ' song ',
        pageNo: 2,
        pageSize: 30,
        showInner: true,
        sortType: 3,
        cursor: '999',
      );

      expect(
        api.commentListRequests.single,
        (
          id: '101',
          type: 'song',
          pageNo: 2,
          pageSize: 30,
          showInner: true,
          sortType: 3,
          cursor: '999',
        ),
      );
    });

    test('normalizes floor comment ids before fetching replies', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseCommentRemoteDataSource(api: api);

      await dataSource.fetchFloorComments(
        ' netease:101 ',
        ' song ',
        ' parent-1 ',
        time: 123,
        limit: 10,
      );

      expect(
        api.floorCommentRequests.single,
        (
          id: '101',
          type: 'song',
          parentCommentId: 'parent-1',
          time: 123,
          limit: 10,
        ),
      );
    });

    test('normalizes comment operation ids before sending comment command', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseCommentRemoteDataSource(api: api);

      await dataSource.sendComment(
        ' netease:101 ',
        ' song ',
        ' reply ',
        content: '  keep user text  ',
        commentId: ' comment-1 ',
      );

      expect(
        api.commentRequests.single,
        (
          id: '101',
          type: 'song',
          operation: 'reply',
          commentId: 'comment-1',
          content: '  keep user text  ',
        ),
      );
    });

    test('normalizes like ids and derives thread id from normalized type', () async {
      final api = _FakeNeteaseMusicApi();
      final dataSource = NeteaseCommentRemoteDataSource(api: api);

      await dataSource.toggleCommentLike(
        ' netease:101 ',
        ' song ',
        ' comment-1 ',
        true,
      );

      expect(
        api.likeCommentRequests.single,
        (
          id: '101',
          type: 'song',
          commentId: 'comment-1',
          like: true,
          threadId: 'R_SO_4_101',
        ),
      );
    });
  });
}

class _FakeNeteaseMusicApi implements NeteaseMusicApi {
  final commentListRequests = <({
    String id,
    String type,
    int pageNo,
    int pageSize,
    bool showInner,
    int? sortType,
    String? cursor,
  })>[];
  final floorCommentRequests = <({
    String id,
    String type,
    String parentCommentId,
    int time,
    int limit,
  })>[];
  final commentRequests = <({
    String id,
    String type,
    String operation,
    String? commentId,
    String? content,
  })>[];
  final likeCommentRequests = <({
    String id,
    String type,
    String commentId,
    bool like,
    String? threadId,
  })>[];

  @override
  Future<CommentList2Wrap> commentList2(
    String id,
    String type, {
    int pageNo = 1,
    int pageSize = 20,
    bool showInner = true,
    int? sortType,
    String? cursor,
  }) async {
    commentListRequests.add(
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
    return _commentListWrap();
  }

  @override
  Future<FloorCommentDetailWrap> floorComments(
    String id,
    String type,
    String parentCommentId, {
    int time = -1,
    int limit = 20,
  }) async {
    floorCommentRequests.add(
      (
        id: id,
        type: type,
        parentCommentId: parentCommentId,
        time: time,
        limit: limit,
      ),
    );
    return _floorCommentDetailWrap();
  }

  @override
  Future<CommentWrap> comment(
    String id,
    String type,
    String op, {
    String? commentId,
    String? threadId,
    String? content,
  }) async {
    commentRequests.add(
      (
        id: id,
        type: type,
        operation: op,
        commentId: commentId,
        content: content,
      ),
    );
    return CommentWrap()
      ..code = 200
      ..message = 'ok';
  }

  @override
  Future<CommentWrap> likeComment(
    String id,
    String commentId,
    String type,
    bool like, {
    String? threadId,
  }) async {
    likeCommentRequests.add(
      (
        id: id,
        type: type,
        commentId: commentId,
        like: like,
        threadId: threadId,
      ),
    );
    return CommentWrap()
      ..code = 200
      ..message = 'ok';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

CommentList2Wrap _commentListWrap() {
  return CommentList2Wrap()
    ..code = 200
    ..data = (CommentList2Data()
      ..comments = const []
      ..hasMore = false
      ..cursor = null);
}

FloorCommentDetailWrap _floorCommentDetailWrap() {
  return FloorCommentDetailWrap()
    ..code = 200
    ..data = (FloorCommentDetail()
      ..comments = const []
      ..hasMore = false
      ..time = -1);
}
