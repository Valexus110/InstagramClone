import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

part 'storage_repository.dart';

part 'storage_repository_impl.dart';

class StorageController {
  final storageRepository = _StorageRepositoryImpl();
}
