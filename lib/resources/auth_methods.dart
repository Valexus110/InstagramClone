import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_example/models/user.dart' as model;
import 'package:instagram_example/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromSnap(snap);
  }

  Future<String> signupUser(
      {required String email,
      required String password,
      required String username,
      required String bio,
      required Uint8List? file}) async {
    String res = "Please fill all fields";
    file == null ? res = res + " and add photo" : res = res;
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        if (file == null) {
          res = "You need to add the photo to complete registration";
        } else {
          UserCredential userCredential = await _auth
              .createUserWithEmailAndPassword(email: email, password: password);

          String photoUrl = await StorageMethods()
              .uploadImagetoStorage('profilePics', file, false);

          model.User user = model.User(
            username: username,
            uid: userCredential.user!.uid,
            email: email,
            bio: bio,
            followers: [],
            following: [],
            photoUrl: photoUrl,
          );

          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(user.toJson());
          res = "Success";
        }
      }
    } on FirebaseException catch (err) {
      if (err.code == 'invalid-email') {
        res = "The email is badly formatted.";
      } else if (err.code == 'weak-password') {
        res = "Your password should be at least 6 characters.";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = "Please fill all fields";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "Success";
      }
    } catch (err) {
      res = "Invalid email or password";
      print(err.toString());
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
