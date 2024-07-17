part of '../ui/profile_controller.dart';

abstract class ProfileRepository {
  Future<model.User> getUserInfo(String uid);

  Future<int> getPostInfo(String uid);

  Future<List<Post>> getUserPosts(String uid);

  Future<void> changeProfileInfo(
    String uid,
    String bio,
    String username,
    String photoUrl,
  );
}
