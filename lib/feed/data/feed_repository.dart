part of '../ui/feed_controller.dart';

abstract class FeedRepository {
  Stream<List<Post>> getPosts();
}
