part of '../common_controller.dart';

class _CommonRepositoryImpl implements CommonRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<void> followUser(String currentUid, String currentFollowId) async {
    try {
      //get current user following list
      DocumentSnapshot userSnap =
          await _firestore.collection(users).doc(currentUid).get();
      List followingList = (userSnap.data()! as dynamic)[following];

      //get following user followers list
      DocumentSnapshot followSnap =
          await _firestore.collection(users).doc(currentFollowId).get();
      List followersList = (followSnap.data()! as dynamic)[followers];

      //remove if ids already in database
      if (followingList.contains(currentFollowId) ||
          followersList.contains(currentUid)) {
        await _firestore.collection(users).doc(currentFollowId).update({
          followers: FieldValue.arrayRemove([currentUid])
        });
        await _firestore.collection(users).doc(currentUid).update({
          following: FieldValue.arrayRemove([currentFollowId])
        });
      } else {
        //add new follower to following user
        await _firestore.collection(users).doc(currentFollowId).update({
          followers: FieldValue.arrayUnion([currentUid])
        });

        //add new following to current user
        await _firestore.collection(users).doc(currentUid).update({
          following: FieldValue.arrayUnion([currentFollowId])
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
