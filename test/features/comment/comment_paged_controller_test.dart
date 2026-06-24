import 'dart:async';

import 'package:bujuan/core/entities/comment_data.dart';
import 'package:bujuan/features/comment/comment_paged_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommentPagedController', () {
    test('keeps visible items when refresh fails', () async {
      var failNextLoad = false;
      final controller = CommentPagedController<int>(
        firstCursor: 0,
        loadPage: ({required cursor, required forceRefresh}) async {
          if (failNextLoad) {
            throw StateError('offline');
          }
          return CommentPagedPage<int>(
            items: [_comment('visible')],
            hasMore: false,
            nextCursor: 1,
          );
        },
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      failNextLoad = true;

      final refreshed = await controller.refresh();

      expect(refreshed, isFalse);
      expect(controller.state.value.items.map((item) => item.commentId), ['visible']);
      expect(controller.state.value.refreshing, isFalse);
      expect(controller.state.value.error, isA<StateError>());
    });

    test('ignores stale load more result after refresh completes', () async {
      final loadMore = Completer<CommentPagedPage<int>>();
      final refresh = Completer<CommentPagedPage<int>>();
      var firstPageLoaded = false;
      final controller = CommentPagedController<int>(
        firstCursor: 0,
        loadPage: ({required cursor, required forceRefresh}) {
          if (cursor == 0 && !firstPageLoaded) {
            firstPageLoaded = true;
            return Future.value(
              CommentPagedPage<int>(
                items: [_comment('old')],
                hasMore: true,
                nextCursor: 1,
              ),
            );
          }
          if (cursor == 0) {
            return refresh.future;
          }
          return loadMore.future;
        },
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();

      final loadMoreFuture = controller.loadMore();
      await _flushAsync();
      final refreshFuture = controller.refresh();
      await _flushAsync();
      refresh.complete(
        CommentPagedPage<int>(
          items: [_comment('fresh')],
          hasMore: false,
          nextCursor: 2,
        ),
      );
      await refreshFuture;

      loadMore.complete(
        CommentPagedPage<int>(
          items: [_comment('stale')],
          hasMore: false,
          nextCursor: 3,
        ),
      );
      await loadMoreFuture;

      expect(controller.state.value.items.map((item) => item.commentId), ['fresh']);
    });

    test('can skip repeated initial load until forced', () async {
      var loadCount = 0;
      final controller = CommentPagedController<int>(
        firstCursor: 0,
        skipRepeatedInitialLoad: true,
        loadPage: ({required cursor, required forceRefresh}) async {
          loadCount += 1;
          return CommentPagedPage<int>(
            items: [_comment('load-$loadCount')],
            hasMore: false,
            nextCursor: loadCount,
          );
        },
      );
      addTearDown(controller.dispose);

      await controller.loadInitial();
      await controller.loadInitial();

      expect(loadCount, 1);
      expect(controller.state.value.items.map((item) => item.commentId), ['load-1']);

      await controller.loadInitial(force: true);

      expect(loadCount, 2);
      expect(controller.state.value.items.map((item) => item.commentId), ['load-2']);
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
