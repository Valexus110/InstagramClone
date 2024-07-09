part of '../ui/auth_provider.dart';

class _AuthRepositoryImpl implements AuthRepository {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final storageRepository = StorageController();

  @override
  Future<model.User> getUserDetails() async {
    auth.User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();
    return model.User.fromJson(snap.data() as Map<String, dynamic>);
  }

  @override
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
      if (kDebugMode) {
        print(err.toString());
      }
    }
    return res;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<String> signupUser(
      {required String email,
      required String password,
      required String username,
      required String bio,
      required Uint8List? file}) async {
    String res = "Please fill all fields";
    file == null ? res = "$res and add photo" : res = res;
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        if (file == null) {
          res = "You need to add the photo to complete registration";
        } else {
          auth.UserCredential userCredential = await _auth
              .createUserWithEmailAndPassword(email: email, password: password);

          String photoUrl = await storageRepository.uploadImageToStorage(
              'profilePics', file, false);
          model.User currentUser = model.User(
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
              .set(currentUser.toJson());
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

  @override
  String getUser() {
    return _auth.currentUser!.uid;
  }
}
