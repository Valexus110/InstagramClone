import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String uid;
  final String chatterUid;
  final String profilePic;
  final String chatterName;
  final String? lastMessage;
  final DateTime? lastMessageDate;

  const Chat(
      {required this.uid,
      required this.chatterUid,
      required this.profilePic,
      required this.chatterName,
      this.lastMessage,
      this.lastMessageDate});

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'chatterUid': chatterUid,
        'profilePic': profilePic,
        'chatterName': chatterName,
        'lastMessage': lastMessage,
        'lastMessageDate': lastMessageDate
      };

  static Chat fromJson(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    final Timestamp? timestamp = snapshot['lastMessageDate'];
    return Chat(
      uid: snapshot["uid"],
      chatterUid: snapshot['chatterUid'],
      profilePic: snapshot["profilePic"],
      chatterName: snapshot["chatterName"],
      lastMessage: snapshot['lastMessage'],
      lastMessageDate: timestamp?.toDate(),
    );
  }
}
