
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_example/main.dart';
import 'package:instagram_example/models/post.dart';
import 'package:instagram_example/utils/const_variables.dart';
import 'package:uuid/uuid.dart';

import '../../storage/storage_controller.dart';

part '../data/posts_repository.dart';

part '../data/posts_repository_impl.dart';

class PostsController {
  final _postsRepository = _PostsRepositoryImpl();

  Stream<List<Post>> getListOfPosts(String userId) {
    return _postsRepository.getListOfPosts(userId);
  }

  Future<Map<String, dynamic>?>? getIsPostSaved(String postId) async {
     return await _postsRepository.getIsPostSaved(postId);
  }

  Future<void> getSavedPosts() async {
    return await _postsRepository.getSavedPosts();
  }

  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profileImage) async {
    return await _postsRepository.uploadPost(
        description, file, uid, username, profileImage);
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    return await _postsRepository.likePost(postId, uid, likes);
  }

  Future<void> deletePost(String postId) async {
    return await _postsRepository.deletePost(postId);
  }

  Future<void> addBookmark(String postId, String uid, bool saved) async {
    return await _postsRepository.addBookmark(postId, uid, saved);
  }
}
