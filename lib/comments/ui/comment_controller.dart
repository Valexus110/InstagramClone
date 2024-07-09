import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../models/comment.dart';

part '../data/comment_repository.dart';

part '../data/comment_repository_impl.dart';

class CommentController {
  final _commentRepository = _CommentRepositoryImpl();

  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    return await _commentRepository.postComment(
        postId, text, uid, name, profilePic);
  }

  Stream<List<Comment>> getListOfComments(String postId) {
    return _commentRepository.getListOfComments(postId);
  }

  Future<int> getCommentsCount(String postId) async {
    return _commentRepository.getCommentsCount(postId);
  }
}
