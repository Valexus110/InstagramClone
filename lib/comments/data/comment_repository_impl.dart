part of '../ui/comment_controller.dart';

class _CommentRepositoryImpl implements CommentRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    String message = 'Unknown error';
    List<InternetAddress>? connection;
    try {
      connection = await InternetAddress.lookup('example.com');
    } on SocketException catch (_) {
      connection = null;
    }
    try {
      if (text.isNotEmpty && connection!.isNotEmpty) {
        String commentId = const Uuid().v1();
        var json = Comment(
                uid: uid,
                commentId: commentId,
                profilePic: profilePic,
                name: name,
                text: text,
                datePublished: DateTime.now())
            .toJson();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set(json);
        // 'profilePic': profilePic,
        // 'name': name,
        // 'uid': uid,
        // 'text': text,
        // 'commentId': commentId,
        // 'datePublished': DateTime.now(),
        message = 'Ok';
      } else if (text.isEmpty && connection!.isNotEmpty) {
        message = 'Text is empty';
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return message;
  }

  @override
  Future<int> getCommentsCount(String postId) async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();
    return snap.docs.length;
  }

  @override
  Stream<List<Comment>> getListOfComments(String postId) {
    var comments = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('datePublished', descending: false)
        .snapshots();

    return comments.map(
            (snapshot) => snapshot.docs.map((doc) => Comment.fromJson(doc)).toList());
  }
}
