import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String uid;
  final String commentId;
  final String profilePic;
  final String name;
  final String text;
  final DateTime datePublished;

  const Comment({
    required this.uid,
    required this.commentId,
    required this.profilePic,
    required this.name,
    required this.text,
    required this.datePublished,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'commentId': commentId,
        'profilePic': profilePic,
        'name': name,
        'text': text,
        'datePublished': datePublished,
      };

  static Comment fromJson(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    final Timestamp timestamp = snapshot['datePublished'];
    return Comment(
      uid: snapshot["uid"],
      commentId: snapshot['commentId'],
      profilePic: snapshot["profilePic"],
      name: snapshot["name"],
      text: snapshot["text"],
      datePublished: timestamp.toDate(),
    );
  }
}
