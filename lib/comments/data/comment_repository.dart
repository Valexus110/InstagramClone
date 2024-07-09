part of '../ui/comment_controller.dart';

abstract class CommentRepository {
  Future<String> postComment(String postId, String text,
      String uid, String name, String profilePic);

  Stream<List<Comment>> getListOfComments(String postId);

  Future<int> getCommentsCount(String postId);
}