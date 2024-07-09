part of '../ui/posts_controller.dart';

abstract class PostsRepository {
  Future<String> uploadPost(String description,
      Uint8List file,
      String uid,
      String username,
      String profileImage,);

  Future<void> likePost(String postId, String uid, List likes);

  Future<void> deletePost(String postId);

  Future<void> addBookmark(String postId, String uid, bool saved);

  Future<Map<String, dynamic>?>? getIsPostSaved(String postId);

  Future<void> getSavedPosts();

  Stream<List<Post>> getListOfPosts(String uid);
}
