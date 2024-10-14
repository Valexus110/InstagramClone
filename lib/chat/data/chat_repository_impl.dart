part of '../ui/chat_provider.dart';

class _ChatRepositoryImpl implements ChatRepository {
  final _firestore = FirebaseFirestore.instance;

  Future<Message?> _addNewMessage({
    required String chatterUid,
    required String content,
  }) async {
    var message = Message(
        messageUid: const Uuid().v1(),
        chatterUid: chatterUid,
        content: content,
        isSeen: false,
        isSent: true,
        messageDate: DateTime.now());
    return message;
  }

  @override
  Future<String> createNewChat({
    required String messageContent,
    required String currentUid,
    required String chatterUid,
    required String currentPhotoUrl,
    required String chatterPhotoUrl,
    required String currentName,
    required String chatterName,
  }) async {
    String message = locale.unknownError;
    var chatIsExist = false;
    await _firestore
        .collection(users)
        .doc(currentUid)
        .collection(chats)
        .doc(chatterUid)
        .get()
        .then((doc) {
      chatIsExist = doc.exists;
    });
    List<InternetAddress>? connection;
    try {
      connection = await InternetAddress.lookup('example.com');
    } on SocketException catch (_) {
      connection = null;
    }
    try {
      if (messageContent.isNotEmpty && connection!.isNotEmpty) {
        Message? newMessage = await _addNewMessage(
            chatterUid: chatterUid, content: messageContent);
        if (newMessage != null) {
          var firstMessageJson = Message(
            messageUid: newMessage.messageUid,
            chatterUid: currentUid,
            content: newMessage.content,
            isSeen: newMessage.isSeen,
            isSent: newMessage.isSent,
            messageDate: newMessage.messageDate,
          ).toJson();
          var secondMessageJson = Message(
            messageUid: newMessage.messageUid,
            chatterUid: currentUid,
            content: newMessage.content,
            isSeen: false,
            isSent: false,
            messageDate: newMessage.messageDate,
          ).toJson();
          if (!chatIsExist) {
            var firstChatJson = Chat(
              uid: currentUid,
              chatterUid: chatterUid,
              profilePic: chatterPhotoUrl,
              chatterName: chatterName,
              lastMessage: newMessage.content,
              lastMessageDate: newMessage.messageDate,
            ).toJson();
            var secondChatJson = Chat(
              uid: chatterUid,
              chatterUid: currentUid,
              profilePic: currentPhotoUrl,
              chatterName: currentName,
              lastMessage: newMessage.content,
              lastMessageDate: newMessage.messageDate,
            ).toJson();
            await _firestore
                .collection(users)
                .doc(currentUid)
                .collection(chats)
                .doc(chatterUid)
                .set(firstChatJson);
            await _firestore
                .collection(users)
                .doc(chatterUid)
                .collection(chats)
                .doc(currentUid)
                .set(secondChatJson);
          } else {
            await _firestore
                .collection(users)
                .doc(currentUid)
                .collection(chats)
                .doc(chatterUid)
                .update({
              'lastMessage': newMessage.content,
              'lastMessageDate': newMessage.messageDate,
            });
            await _firestore
                .collection(users)
                .doc(chatterUid)
                .collection(chats)
                .doc(currentUid)
                .update({
              'lastMessage': newMessage.content,
              'lastMessageDate': newMessage.messageDate,
            });
          }
          await _firestore
              .collection(users)
              .doc(currentUid)
              .collection(chats)
              .doc(chatterUid)
              .collection(messages)
              .doc(newMessage.messageUid)
              .set(firstMessageJson);
          await _firestore
              .collection(users)
              .doc(chatterUid)
              .collection(chats)
              .doc(currentUid)
              .collection(messages)
              .doc(newMessage.messageUid)
              .set(secondMessageJson);
          return 'Ok';
        }
        message = locale.anErrorOccurred;
      } else if (messageContent.isEmpty && connection!.isNotEmpty) {
        message = locale.emptyText;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return message;
  }

  @override
  Future<List<Chat>> getChats({
    required String currentUid,
  }) async {
    var allChats = await _firestore
        .collection(users)
        .doc(currentUid)
        .collection(chats)
        .get();
    var currentChats = <Chat>[];
    for (var chat in allChats.docs) {
      currentChats.add(Chat.fromJson(chat));
    }
    return currentChats;
  }

  @override
  Future<List<Message>> getMessages(
      {required String currentUid, required String chatterUid}) async {
    var allMessages = <Message>[];
    var collection = await _firestore
        .collection(users)
        .doc(currentUid)
        .collection(chats)
        .doc(chatterUid)
        .collection(messages)
        .get();
    for (var message in collection.docs) {
      allMessages.add(Message.fromJson(message));
    }
    return allMessages;
  }

  @override
  Future<void> removeMessage(
      {required String currentUid,
      required String chatterUid,
      required bool lastMessage,
      required String? messageText,
      required DateTime? messageDate,
      required String messageId}) async {
    await _firestore
        .collection(users)
        .doc(currentUid)
        .collection(chats)
        .doc(chatterUid)
        .collection(messages)
        .doc(messageId)
        .delete();
    await _firestore
        .collection(users)
        .doc(chatterUid)
        .collection(chats)
        .doc(currentUid)
        .collection(messages)
        .doc(messageId)
        .delete();
    if (lastMessage && messageText != null) {
      await _firestore
          .collection(users)
          .doc(currentUid)
          .collection(chats)
          .doc(chatterUid)
          .update({
        'lastMessage': messageText,
        'lastMessageDate': messageDate,
      });
      await _firestore
          .collection(users)
          .doc(chatterUid)
          .collection(chats)
          .doc(currentUid)
          .update({
        'lastMessage': messageText,
        'lastMessageDate': messageDate,
      });
    } else if (messageText == null) {
      await _firestore
          .collection(users)
          .doc(currentUid)
          .collection(chats)
          .doc(chatterUid)
          .delete();
      await _firestore
          .collection(users)
          .doc(chatterUid)
          .collection(chats)
          .doc(currentUid)
          .delete();
    }
  }

  @override
  Future<void> updateMessage({
    required String currentUid,
    required String chatterUid,
    required bool lastMessage,
    required String messageId,
    required String messageText,
  }) async {
    await _firestore
        .collection(users)
        .doc(currentUid)
        .collection(chats)
        .doc(chatterUid)
        .collection(messages)
        .doc(messageId)
        .update({'content': messageText});
    await _firestore
        .collection(users)
        .doc(chatterUid)
        .collection(chats)
        .doc(currentUid)
        .collection(messages)
        .doc(messageId)
        .update({'content': messageText});
    if (lastMessage) {
      await _firestore
          .collection(users)
          .doc(currentUid)
          .collection(chats)
          .doc(chatterUid)
          .update({
        'lastMessage': messageText,
      });
      await _firestore
          .collection(users)
          .doc(chatterUid)
          .collection(chats)
          .doc(currentUid)
          .update({
        'lastMessage': messageText,
      });
    }
  }
}
