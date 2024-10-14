part of '../ui/chat_provider.dart';

abstract class ChatRepository {
  Future<String> createNewChat({
    required String messageContent,
    required String currentUid,
    required String chatterUid,
    required String currentPhotoUrl,
    required String chatterPhotoUrl,
    required String currentName,
    required String chatterName,
  });

  Future<void> updateMessage({
    required String currentUid,
    required String chatterUid,
    required bool lastMessage,
    required String messageId,
    required String messageText,
  });

  Future<List<Chat>> getChats({
    required String currentUid,
  });

  Future<List<Message>> getMessages({
    required String currentUid,
    required String chatterUid,
  });

  Future<void> removeMessage({
    required String currentUid,
    required String chatterUid,
    required bool lastMessage,
    required String messageId,
    required String? messageText,
    required DateTime? messageDate,
  });
}
