part of '../ui/auth_provider.dart';

abstract class AuthRepository {
  Future<model.User> getUserDetails();

  Future<String> signupUser(
      {required String email,
      required String password,
      required String username,
      required String bio,
      required Uint8List? file});

  Future<String> loginUser({required String email, required String password});

  getUser();

  Future<void> signOut();
}
