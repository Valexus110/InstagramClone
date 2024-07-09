part of '../ui/search_controller.dart';

abstract class SearchRepository {
  Future<List<User>?> getUsers(
      String currentName);
}
