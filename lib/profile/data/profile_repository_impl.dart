part of '../ui/profile_controller.dart';

class _ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> changeProfileInfo(
      String uid, String bio, String username) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'username': username,
        'bio': bio,
      });
      var docs = await _firestore
          .collection('posts')
          .where("uid", isEqualTo: uid)
          .get();
      for (var doc in docs.docs) {
        await doc.reference.update({'username': username});
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Future<model.User> getUserInfo(String uid) async {
    return model.User.fromJson(
        (await _firestore.collection('users').doc(uid).get()).data() ?? {});
  }

  @override
  Future<int> getPostInfo(String uid) async {
    return (await _firestore
            .collection('posts')
            .where('uid', isEqualTo: uid)
            .get())
        .docs
        .length;
  }

  @override
  Future<List<Post>> getUserPosts(String uid) async {
    var posts =
        await _firestore.collection('posts').where('uid', isEqualTo: uid).get();
    return posts.docs.map((snapshot) => Post.fromJson(snapshot)).toList();
  }
}
