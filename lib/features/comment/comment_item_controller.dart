import 'package:bujuan/domain/entities/comment_data.dart';
import 'package:bujuan/features/comment/floor_comment_controller.dart';
import 'package:flutter/foundation.dart';

/// 评论项状态控制器，避免回复展开、点赞和楼层分页状态继续散在 widget 内。
class CommentItemController extends ChangeNotifier {
  /// 创建评论项控制器。
  CommentItemController({
    required CommentData comment,
    required this.isReply,
    required FloorCommentController floorController,
  })  : _comment = comment,
        _replyCount = comment.replyCount,
        _unExpandedReplyCount = comment.replyCount,
        _floorController = floorController;

  /// 当前评论是否是楼层回复。
  final bool isReply;
  final FloorCommentController _floorController;

  CommentData _comment;
  final int _replyCount;
  int _unExpandedReplyCount;
  bool _isReplyVisible = false;

  /// 当前评论数据。
  CommentData get comment => _comment;

  /// 当前评论的回复总数。
  int get replyCount => _replyCount;

  /// 尚未展开展示的回复数量。
  int get unExpandedReplyCount => _unExpandedReplyCount;

  /// 回复列表是否处于展开状态。
  bool get isReplyVisible => _isReplyVisible;

  /// 切换当前评论的点赞状态。
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

  /// 收起当前评论的楼层回复。
  void fold() {
    _isReplyVisible = false;
    _unExpandedReplyCount = _replyCount;
    notifyListeners();
  }

  /// 展开当前评论的楼层回复，并按需加载更多回复。
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

  /// 在展开和收起之间切换楼层回复可见性。
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
