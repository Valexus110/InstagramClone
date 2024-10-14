import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_example/authentication/ui/auth_provider.dart';

import '../../models/user.dart';
import '../../utils/const_variables.dart';

part '../data/search_repository.dart';

part '../data/search_repository_impl.dart';

class SearchUsersController {
  final _searchRepository = _SearchRepositoryImpl(AuthProvider());

  Future<List<User>?> getUsers(String currentName) async {
    return await _searchRepository.getUsers(currentName);
  }
}
