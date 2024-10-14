part of '../ui/profile_controller.dart';

class _ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> changeProfileInfo(String currentUid, String currentBio,
      String currentUsername, String currentPhotoUrl) async {
    try {
      await _firestore.collection(users).doc(currentUid).update({
        username: currentUsername,
        bio: currentBio,
        photoUrl: currentPhotoUrl,
      });
      var docs = await _firestore
          .collection(posts)
          .where(uid, isEqualTo: currentUid)
          .get();
      for (var doc in docs.docs) {
        await doc.reference
            .update({username: currentUsername, profileImage: currentPhotoUrl});
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Future<model.User> getUserInfo(String currentUid) async {
    return model.User.fromJson(
        (await _firestore.collection(users).doc(currentUid).get()).data() ??
            {});
  }

  @override
  Future<int> getPostInfo(String currentUid) async {
    return (await _firestore
            .collection(posts)
            .where(uid, isEqualTo: currentUid)
            .get())
        .docs
        .length;
  }

  @override
  Future<List<Post>> getUserPosts(String currentUid) async {
    var postsList = await _firestore
        .collection(posts)
        .where(uid, isEqualTo: currentUid)
        .get();
    return postsList.docs.map((snapshot) => Post.fromJson(snapshot)).toList();
  }
}
