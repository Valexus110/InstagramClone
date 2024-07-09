import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:instagram_example/models/user.dart' as model;
import 'package:instagram_example/storage/storage_controller.dart';

part '../data/auth_repository.dart';

part '../data/auth_repository_impl.dart';

class AuthProvider extends ChangeNotifier {
  model.User? _user;

  model.User get getUser => _user!;
  final _authRepository = _AuthRepositoryImpl();

  String getUserId() {
   return _authRepository.getUser();
  }

  Future<void> refreshUser() async {
    model.User user = await _authRepository.getUserDetails();
    _user = user;
    notifyListeners();
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    return await _authRepository.loginUser(email: email, password: password);
  }

  Future<String> signupUser(
      {required String email,
      required String password,
      required String username,
      required String bio,
      required Uint8List? file}) async {
    return await _authRepository.signupUser(
        email: email,
        password: password,
        username: username,
        bio: bio,
        file: file);
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
