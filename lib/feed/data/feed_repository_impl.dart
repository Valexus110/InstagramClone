part of '../ui/feed_controller.dart';

class _FeedRepositoryImpl implements FeedRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<Post>> getPosts() {
    var postsList = _firestore
        .collection(posts)
        .orderBy(datePublished, descending: true)
        .snapshots();

    return postsList.map(
            (snapshot) => snapshot.docs.map((doc) => Post.fromJson(doc)).toList());
  }
}
