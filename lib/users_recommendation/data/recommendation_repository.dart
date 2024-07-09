
part of '../ui/recommendation_controller.dart';

abstract class RecommendationRepository {
  Future<Map<String,dynamic>?> getFollowed(String currUid);

  Future<List<model.User>> getUserInfo(bool? isFollowers,String currUid,List following, List followers);
}