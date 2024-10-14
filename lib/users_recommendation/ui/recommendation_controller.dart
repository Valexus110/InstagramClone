import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_example/models/user.dart' as model;

import '../../utils/const_variables.dart';

part '../data/recommendation_repository.dart';

part '../data/recommendation_repository_impl.dart';

class RecommendationController {
  final _recommendationRepository = _RecommendationRepositoryImpl();

  Future<Map<String, dynamic>> getFollowed(String currUid) async {
    return await _recommendationRepository.getFollowed(currUid);
  }

  Future<List<model.User>> getUserInfo(
      bool? isFollowers, String currUid, List following, List followers) async {
    return await _recommendationRepository.getUserInfo(
        isFollowers, currUid, following, followers);
  }
}
