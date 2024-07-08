

import 'package:cloud_firestore/cloud_firestore.dart';

part '../data/feed_repository.dart';

part '../data/feed_repository_impl.dart';

class FeedController {
  final feedRepository = _FeedRepositoryImpl();
}
