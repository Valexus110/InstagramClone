
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

part 'data/common_repository.dart';

part 'data/common_repository_impl.dart';

class CommonController {
 final _commonRepository = _CommonRepositoryImpl();

 Future<void> followUser(String uid, String followId) async {
   return await _commonRepository.followUser(uid, followId);
 }
}