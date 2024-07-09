
part of '../common_controller.dart';

abstract class CommonRepository {
  Future<void> followUser(
    String uid,
    String followId,
  );
}
