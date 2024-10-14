part of '../ui/search_controller.dart';

class _SearchRepositoryImpl implements SearchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthProvider authProvider;

  _SearchRepositoryImpl(this.authProvider);

  @override
  Future<List<User>?> getUsers(String currentName) async {
    List<User> actualUsers = [];
    if (currentName.isEmpty) return null;
    var usersList = await _firestore.collection(users).get();
    for (var user in usersList.docs) {
      if (user.id == authProvider.getUserId()) continue;
      if (user
          .data()[username]
          .toString()
          .toLowerCase()
          .contains(currentName.toLowerCase())) {
        actualUsers.add(User.fromJson(user.data()));
      }
    }
    return actualUsers;
  }
}
