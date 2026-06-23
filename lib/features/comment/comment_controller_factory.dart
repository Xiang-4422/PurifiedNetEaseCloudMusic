import 'package:bujuan/core/entities/comment_data.dart';
import 'package:bujuan/features/comment/comment_item_controller.dart';
import 'package:bujuan/features/comment/comment_list_controller.dart';
import 'package:bujuan/features/comment/comment_repository.dart';
import 'package:bujuan/features/comment/floor_comment_controller.dart';
import 'package:bujuan/features/comment/reply_sheet_controller.dart';

/// Creates page-local comment controllers with comment repository injected.
class CommentControllerFactory {
  /// Creates a factory for comment controllers.
  const CommentControllerFactory({required CommentRepository repository}) : _repository = repository;

  final CommentRepository _repository;

  /// Creates a controller for a resource comment list.
  CommentListController createList({
    required String id,
    required String type,
    required int sortType,
    int pageSize = 10,
  }) {
    return CommentListController(
      id: id,
      type: type,
      sortType: sortType,
      repository: _repository,
      pageSize: pageSize,
    );
  }

  /// Creates a controller for floor replies under one comment.
  FloorCommentController createFloor({
    required String id,
    required String type,
    required String parentCommentId,
    int pageSize = 20,
  }) {
    return FloorCommentController(
      id: id,
      type: type,
      parentCommentId: parentCommentId,
      repository: _repository,
      pageSize: pageSize,
    );
  }

  /// Creates a controller for one comment item.
  CommentItemController createItem({
    required CommentData comment,
    required bool isReply,
    required FloorCommentController floorController,
  }) {
    return CommentItemController(
      comment: comment,
      isReply: isReply,
      floorController: floorController,
    );
  }

  /// Creates a controller for the reply input sheet.
  ReplySheetController createReplySheet({
    required FloorCommentController floorController,
  }) {
    return ReplySheetController(floorController: floorController);
  }
}
