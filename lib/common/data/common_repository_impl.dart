part of '../common_controller.dart';

class _CommonRepositoryImpl implements CommonRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<void> followUser(String uid, String followId) async {
    try {
      //get current user following list
      DocumentSnapshot userSnap =
          await _firestore.collection('users').doc(uid).get();
      List following = (userSnap.data()! as dynamic)['following'];

      //get following user followers list
      DocumentSnapshot followSnap =
          await _firestore.collection('users').doc(followId).get();
      List followers = (followSnap.data()! as dynamic)['followers'];

      //remove if ids already in database
      if (following.contains(followId) || followers.contains(uid)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        //add new follower to following user
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        //add new following to current user
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
