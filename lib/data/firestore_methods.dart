import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_example/models/post.dart';
import 'package:uuid/uuid.dart';

import '../storage/storage_controller.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final storageRepository = StorageController().storageRepository;

  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profileImage,
  ) async {
    String res = "some error occurred";
    try {
      String postId = const Uuid().v1();
      String photoUrl = await storageRepository.uploadImageToStorage(
          "posts", file, true, postId);
      Post post = Post(
          description: description,
          uid: uid,
          postId: postId,
          username: username,
          datePublished: DateTime.now(),
          postUrl: photoUrl,
          profileImage: profileImage,
          likes: []);
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection("posts").doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection("posts").doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<String> postComment(BuildContext context, String postId, String text,
      String uid, String name, String profilePic) async {
    String message = 'Unknown error';
    List<InternetAddress>? connection;
    try {
      connection = await InternetAddress.lookup('example.com');
    } on SocketException catch (_) {
      connection = null;
    }
    try {
      if (text.isNotEmpty && connection!.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        message = 'Ok';
      } else if (text.isEmpty && connection!.isNotEmpty) {
        message = 'Text is empty';
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return message;
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      storageRepository.deleteImageFromStorage("posts", postId);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> changeBio(
    String uid,
    String bio,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'bio': bio,
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> followUser(
    String uid,
    String followId,
  ) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> addBookmark(String postId, String uid, bool saved) async {
    if (saved) {
      await FirebaseFirestore.instance
          .collection('savedPosts')
          .doc(uid)
          .collection('posts')
          .doc(postId)
          .delete();
    } else {
      var doc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();
      var data = doc.data();
      await FirebaseFirestore.instance
          .collection('savedPosts')
          .doc(uid)
          .collection('posts')
          .doc(postId)
          .set({
        'description': data!['description'],
        'uid': data['uid'],
        'postId': data['postId'],
        'username': data['username'],
        'datePublished': data['datePublished'],
        'postUrl': data['postUrl'],
        'profileImage': data['profileImage'],
        'likes': data['likes'],
      });
    }
  }
}
