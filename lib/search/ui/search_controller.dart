import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_example/authentication/ui/auth_provider.dart';

part '../data/search_repository.dart';

part '../data/search_repository_impl.dart';

class SearchUsersController {
  final searchRepository = _SearchRepositoryImpl(AuthProvider());
}
