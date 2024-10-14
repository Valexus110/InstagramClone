part of '../ui/comment_controller.dart';

class _CommentRepositoryImpl implements CommentRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<String> postComment(String currentPostId, String text,
      String currentUid, String currentName, String currentProfilePic) async {
    String message = locale.unknownError;
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
                uid: currentUid,
                commentId: commentId,
                profilePic: currentProfilePic,
                name: currentName,
                text: text,
                datePublished: DateTime.now())
            .toJson();
        await _firestore
            .collection(posts)
            .doc(currentPostId)
            .collection(comments)
            .doc(commentId)
            .set(json);
        message = 'Ok';
      } else if (text.isEmpty && connection!.isNotEmpty) {
        message = locale.emptyText;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return message;
  }

  @override
  Future<int> getCommentsCount(String currentPostId) async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection(posts)
        .doc(currentPostId)
        .collection(comments)
        .get();
    return snap.docs.length;
  }

  @override
  Stream<List<Comment>> getListOfComments(String currentPostId) {
    var commentsList = FirebaseFirestore.instance
        .collection(posts)
        .doc(currentPostId)
        .collection(comments)
        .orderBy(datePublished, descending: false)
        .snapshots();

    return commentsList.map((snapshot) =>
        snapshot.docs.map((doc) => Comment.fromJson(doc)).toList());
  }
}
