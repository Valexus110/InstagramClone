part of '../ui/search_controller.dart';

class _SearchRepositoryImpl implements SearchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProvider authProvider;

  _SearchRepositoryImpl(this.authProvider);

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getUsers(
      String currentName) async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> actualUsers = [];
    if (currentName.isEmpty) return null;
    var users = await _firestore.collection('users').get();
    for (var user in users.docs) {
      if (user.id == authProvider.getUserId()) continue;
      if (user
          .data()['username']
          .toString()
          .toLowerCase()
          .contains(currentName.toLowerCase())) {
        actualUsers.add(user);
      }
    }
    return actualUsers;
  }
}
