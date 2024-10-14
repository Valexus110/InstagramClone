import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageUid;
  final String chatterUid;
  final String content;
  final bool isSeen;
  final bool isSent;
  final DateTime messageDate;

  const Message({
    required this.messageUid,
    required this.chatterUid,
    required this.content,
    required this.isSeen,
    required this.isSent,
    required this.messageDate,
  });

  Map<String, dynamic> toJson() => {
        'messageUid': messageUid,
        'chatterUid': chatterUid,
        'content': content,
        'isSeen': isSeen,
        'isSent': isSent,
        'messageDate': messageDate,
      };

  static Message fromJson(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    final Timestamp timestamp = snapshot['messageDate'];
    return Message(
      messageUid: snapshot["messageUid"],
      chatterUid: snapshot['chatterUid'],
      content: snapshot['content'],
      isSent: snapshot['isSent'],
      isSeen: snapshot['isSeen'],
      messageDate: timestamp.toDate(),
    );
  }
}
