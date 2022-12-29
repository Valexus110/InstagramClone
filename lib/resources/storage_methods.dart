import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImagetoStorage(
      String childName, Uint8List file, bool isPost,
      [String postId = ""]) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);

    if (isPost) {
      ref = ref.child(postId);
    }
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> deleteImageFromStorage(String childName, String doc) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    print(doc);
    ref.child(doc).delete();
  }
}
