import 'package:flutter/material.dart';
import 'package:instagram_example/chat/ui/chat_provider.dart';
import 'package:instagram_example/chat/ui/single_chat_screen.dart';
import 'package:instagram_example/main.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../authentication/ui/auth_provider.dart';
import '../../models/chat.dart';
import '../../utils/utils.dart';

class ChatScreen extends StatefulWidget {
  final String? profileImage;

  const ChatScreen({super.key, this.profileImage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Widget> _chats = <Widget>[];
  List<Chat> _dbChats = <Chat>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var chatId = context.watch<ChatProvider>().chatId == null;
    return Scaffold(
        appBar: chatId
            ? AppBar(
                title: Text(locale.chats),
              )
            : null,
        body: chatId
            ? FutureBuilder(
                future: _getAllChats(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            key: Key("$index"),
                            onTap: () => setState(() {
                                  context.read<ChatProvider>().chatId =
                                      _dbChats[index].chatterUid;
                                  context.read<ChatProvider>().userData =
                                      _dbChats[index];
                                }),
                            child: _chats[index]);
                      },
                      itemCount: _chats.length,
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              )
            : const SingleChatScreen());
  }

  Future<bool> _getAllChats() async {
    var currentUid = context.watch<AuthProvider>().getUser!.uid;
    _chats = [];
    _dbChats =
        await context.watch<ChatProvider>().getChats(currentUid: currentUid);
    for (Chat chat in _dbChats) {
      if (chat.lastMessage != null && chat.lastMessageDate != null) {
        _chats.add(chatField(chat));
      }
    }
    return true;
  }

  Widget chatField(Chat chat) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              chat.profilePic,
            ),
          ),
          Expanded(
            child: ListTile(
              title: Text(
                chat.chatterName,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle:
                  Text(chat.lastMessage!, overflow: TextOverflow.ellipsis),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                DateFormat(datePattern(DateTime.now(), chat.lastMessageDate!))
                    .format(chat.lastMessageDate!),
              ))
        ],
      ),
    );
  }
}
