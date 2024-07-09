import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

part 'storage_repository.dart';

part 'storage_repository_impl.dart';

class StorageController {
  final _storageRepository = _StorageRepositoryImpl();

  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost,
      [String postId = ""]) async {
    return await _storageRepository.uploadImageToStorage(
        childName, file, isPost);
  }

  Future<void> deleteImageFromStorage(String childName, String doc) async {
    return await _storageRepository.deleteImageFromStorage(childName, doc);
  }
}
