part of '../ui/recommendation_controller.dart';

class _RecommendationRepositoryImpl implements RecommendationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>> getFollowed(String currUid) async {
    var userSnap = await _firestore.collection(users).doc(currUid).get();
    return userSnap.data() ?? {};
  }

  @override
  Future<List<model.User>> getUserInfo(
      bool? isFollowers, String currUid, List following, List followers) async {
    var user = await _firestore.collection(users).get();
    var userInfo = <model.User>[];
    for (var e in user.docs) {
      Map<String, dynamic>? userData;
      if (isFollowers == null) {
        if (!followers.contains(e.id) &&
            !following.contains(e.id) &&
            e.id != currUid) {
          userData = e.data();
        }
      } else if (isFollowers == true) {
        if (followers.contains(e.id)) {
          userData = e.data();
        }
      } else if (isFollowers == false) {
        if (following.contains(e.id)) {
          userData = e.data();
        }
      }
      if(userData != null )userInfo.add(model.User.fromJson(userData));
    }
    return userInfo;
  }
}
