part of '../ui/profile_controller.dart';

class _ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> changeBio(String uid, String bio) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'bio': bio,
      });
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
