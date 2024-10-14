

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/post.dart';
import '../../utils/const_variables.dart';

part '../data/feed_repository.dart';

part '../data/feed_repository_impl.dart';

class FeedController {
  final _feedRepository = _FeedRepositoryImpl();

  Stream<List<Post>> getPosts() {
    return _feedRepository.getPosts();
  }

}
