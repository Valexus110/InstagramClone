import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_example/chat/widgets/chat_message.dart';
import 'package:instagram_example/models/chat.dart';
import 'package:instagram_example/models/message.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../utils/const_variables.dart';

part '../data/chat_repository.dart';

part '../data/chat_repository_impl.dart';

class ChatProvider extends ChangeNotifier {
  final _chatRepository = _ChatRepositoryImpl();
  List<Chat> chats = [];
  String? _chatId;
  late Chat _userData;
  List<ChatMessage> _messages = [];

  String? get chatId => _chatId;

  Chat get userData => _userData;

  List<ChatMessage> get messages => _messages;

  Future<String> createNewChat(
      {required String messageContent,
      required String currentUid,
      required String chatterUid,
      required String currentPhotoUrl,
      required String chatterPhotoUrl,
      required String currentName,
      required String chatterName}) async {
    return await _chatRepository.createNewChat(
        messageContent: messageContent,
        currentUid: currentUid,
        chatterUid: chatterUid,
        currentPhotoUrl: currentPhotoUrl,
        chatterPhotoUrl: chatterPhotoUrl,
        currentName: currentName,
        chatterName: chatterName);
  }

  Future<List<Chat>> getChats({
    required String currentUid,
  }) async {
    return await _chatRepository.getChats(currentUid: currentUid);
  }

  Future<List<Message>> getMessages(
      {required String currentUid, required String chatterUid}) async {
    return await _chatRepository.getMessages(
        currentUid: currentUid, chatterUid: chatterUid);
  }

  set chatId(String? value) {
    _chatId = value;
    notifyListeners();
  }

  set userData(Chat value) {
    _userData = value;
    notifyListeners();
  }

  set messages(List<ChatMessage> value) {
    _messages = value;
    notifyListeners();
  }

  removeFromMessages({
    required String currentUid,
    required String chatterUid,
    required String messageId,
    required bool lastMessage,
    required String? messageText,
    required DateTime? messageDate,
  }) async {
    return await _chatRepository.removeMessage(
        currentUid: currentUid,
        chatterUid: chatterUid,
        messageId: messageId,
        lastMessage: lastMessage,
        messageText: messageText,
        messageDate: messageDate);
  }

  updateMessage({
    required String currentUid,
    required String chatterUid,
    required bool lastMessage,
    required String messageUid,
    required String messageText,
  }) async {
    return await _chatRepository.updateMessage(
      currentUid: currentUid,
      chatterUid: chatterUid,
      messageId: messageUid,
      lastMessage: lastMessage,
      messageText: messageText,
    );
  }
}
