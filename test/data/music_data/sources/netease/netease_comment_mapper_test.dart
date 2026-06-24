import 'package:bujuan/data/music_data/sources/netease/mappers/netease_comment_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netease_music_api/netease_music_api.dart';

void main() {
  group('NeteaseCommentMapper', () {
    test('normalizes comment ids and skips blank comment items', () {
      final comments = NeteaseCommentMapper.fromItemList([
        _commentItem(' 1001 '),
        _commentItem(' '),
        _commentItem('1002'),
      ]);

      expect(comments.map((comment) => comment.commentId), ['1001', '1002']);
    });
  });
}

CommentItem _commentItem(String commentId) {
  return CommentItem()
    ..commentId = commentId
    ..user = (NeteaseUserInfo()
      ..userId = 'user-$commentId'
      ..nickname = 'User $commentId'
      ..avatarUrl = 'https://avatar.test/$commentId.jpg')
    ..content = 'Comment $commentId'
    ..time = 1000
    ..replyCount = 1
    ..likedCount = 2
    ..liked = false;
}
