import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String postId;
  final String username;
  final DateTime datePublished;
  final String postUrl;
  final String profileImage;
  final List likes;

  const Post(
      {required this.description,
      required this.uid,
      required this.postId,
      required this.username,
      required this.datePublished,
      required this.postUrl,
      required this.profileImage,
      required this.likes});

  static Map<String, dynamic> toJson(Map<String,dynamic> json) => {
        'username': json['username'],
        'uid': json['uid'],
        'description': json['description'],
        'postId': json['postId'],
        'datePublished': json['datePublished'],
        'postUrl': json['postUrl'],
        'profileImage': json['profileImage'],
        'likes': json['likes'],
      };

  static Post fromJson(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    final Timestamp timestamp = snapshot['datePublished'];
    return Post(
      username: snapshot["username"],
      uid: snapshot["uid"],
      description: snapshot["description"],
      postId: snapshot["postId"],
      datePublished:  timestamp.toDate(),//DateTime.fromMicrosecondsSinceEpoch(snapshot["datePublished"]),//snapshot["datePublished"],
      postUrl: snapshot["postUrl"],
      profileImage: snapshot["profileImage"],
      likes: snapshot["likes"],
    );
  }
}
