part of 'storage_controller.dart';

class _StorageRepositoryImpl extends StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> deleteImageFromStorage(String childName, String doc) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    if (kDebugMode) {
      print(doc);
    }
    ref.child(doc).delete();
  }

  @override
  Future<String> uploadImageToStorage(
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
}
