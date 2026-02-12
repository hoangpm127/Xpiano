import 'comment_models.dart';

abstract class CommentsRepository {
  Future<List<CommentUI>> fetchComments(String feedId);
  Future<CommentUI> postComment(String feedId, String text);
}
