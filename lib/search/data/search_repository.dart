part of '../ui/search_controller.dart';

abstract class SearchRepository {
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>?> getUsers(
      String currentName);
}
