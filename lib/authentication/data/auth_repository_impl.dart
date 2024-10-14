part of '../ui/auth_provider.dart';

class _AuthRepositoryImpl implements AuthRepository {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final storageRepository = StorageController();

  @override
  Future<model.User> getUserDetails() async {
    auth.User currentUser = _auth.currentUser!;
    DocumentSnapshot snap =
        await _firestore.collection(users).doc(currentUser.uid).get();
    return model.User.fromJson(snap.data() as Map<String, dynamic>);
  }

  @override
  Future<String> loginUser(
      {required String email, required String password}) async {
    String res = locale.fillAllFields;

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = success;
      }
    } catch (err) {
      res = locale.invalidField;
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
    String res = locale.fillAllFields;
    file == null ? res = "$res ${locale.andAddPhoto}" : res = res;
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        if (file == null) {
          res = locale.addPhoto;
        } else {
          auth.UserCredential userCredential = await _auth
              .createUserWithEmailAndPassword(email: email, password: password);

          String photoUrl = await storageRepository.uploadImageToStorage(
              profilePics, file, false);
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
              .collection(users)
              .doc(userCredential.user!.uid)
              .set(currentUser.toJson());
          res = success;
        }
      }
    } on FirebaseException catch (err) {
      if (err.code == invalidEmail) {
        res = locale.badFormatEmail;
      } else if (err.code == weakPassword) {
        res = locale.weakPassword;
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
