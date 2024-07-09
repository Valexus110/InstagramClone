import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/post.dart';
import '../../models/user.dart' as model;

part '../data/profile_repository.dart';

part '../data/profile_repository_impl.dart';

class ProfileController {
  final _profileRepository = _ProfileRepositoryImpl();

  Future<model.User> getUserInfo(String uid) async {
    return await _profileRepository.getUserInfo(uid);
  }

  Future<int> getPostInfo(String uid) async {
    return await _profileRepository.getPostInfo(uid);
  }

  Future<List<Post>> getUserPosts(String uid) async {
    return await _profileRepository.getUserPosts(uid);
  }

  Future<void> changeBio(
    String uid,
    String bio,
  ) async {
    return await _profileRepository.changeBio(uid, bio);
  }
}
