part of 'storage_controller.dart';

abstract class StorageRepository {
  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost,
      [String postId = ""]);

  Future<void> deleteImageFromStorage(String childName, String doc);
}
