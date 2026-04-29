import 'package:bujuan/domain/entities/comment_data.dart';
import 'package:bujuan/features/comment/floor_comment_controller.dart';
import 'package:flutter/foundation.dart';

/// 评论项状态控制器，避免回复展开、点赞和楼层分页状态继续散在 widget 内。
class CommentItemController extends ChangeNotifier {
  CommentItemController({
    required CommentData comment,
    required this.isReply,
    required FloorCommentController floorController,
  })  : _comment = comment,
        _replyCount = comment.replyCount,
        _unExpandedReplyCount = comment.replyCount,
        _floorController = floorController;

  final bool isReply;
  final FloorCommentController _floorController;

  CommentData _comment;
  final int _replyCount;
  int _unExpandedReplyCount;
  bool _isReplyVisible = false;

  CommentData get comment => _comment;

  int get replyCount => _replyCount;

  int get unExpandedReplyCount => _unExpandedReplyCount;

  bool get isReplyVisible => _isReplyVisible;

  Future<void> toggleLike() async {
    final liked = !_comment.liked;
    final success = await _floorController.toggleLike(
      _comment,
      liked: liked,
    );
    if (!success) {
      return;
    }
    _comment = _comment.copyWith(
      liked: liked,
      likedCount: liked ? _comment.likedCount + 1 : _comment.likedCount - 1,
    );
    notifyListeners();
  }

  void fold() {
    _isReplyVisible = false;
    _unExpandedReplyCount = _replyCount;
    notifyListeners();
  }

  Future<void> expand() async {
    if (!_isReplyVisible && _floorController.state.value.items.isNotEmpty) {
      _isReplyVisible = true;
      _syncUnExpandedReplyCount();
      notifyListeners();
      return;
    }
    if (_floorController.state.value.items.isEmpty) {
      await _floorController.loadInitial();
    } else if (_floorController.state.value.hasMore) {
      await _floorController.loadMore();
    }
    _isReplyVisible = true;
    _syncUnExpandedReplyCount();
    notifyListeners();
  }

  Future<void> toggleReplyVisibility() async {
    if (isReply) {
      return;
    }
    if (_isReplyVisible) {
      fold();
      return;
    }
    await expand();
  }

  void _syncUnExpandedReplyCount() {
    _unExpandedReplyCount =
        _replyCount - _floorController.state.value.items.length;
  }
}
