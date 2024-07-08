part of '../ui/feed_controller.dart';

abstract class FeedRepository {
  Stream<QuerySnapshot<Map<String, dynamic>>> getPosts();
}
