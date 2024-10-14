import 'package:flutter/material.dart';
import 'package:instagram_example/models/message.dart';
import 'package:provider/provider.dart';

import '../../authentication/ui/auth_provider.dart';
import '../../main.dart';
import '../../models/chat.dart';
import '../../models/user.dart';
import '../../utils/utils.dart';
import '../widgets/chat_message.dart';
import 'chat_provider.dart';

class SingleChatScreen extends StatefulWidget {
  const SingleChatScreen({super.key});

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  final _textController = TextEditingController();
  bool isMessageBeingSent = false;
  bool isMessagesLoaded = false;
  var allMessages = <ChatMessage>[];
  var messagesFromDb = <Message>[];
  var dateTime = DateTime.now();
  DateTime? prevDate;
  late User user;
  late Chat chatterInfo;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> getAllMessages({bool isUpdating = false}) async {
    prevDate = null;
    allMessages = context.watch<ChatProvider>().messages;
    if (allMessages.isEmpty || isUpdating) {
      if (context.watch<ChatProvider>().chatId == null) return false;
      var currentUid = context.watch<AuthProvider>().getUser!.uid;
      messagesFromDb = await context.watch<ChatProvider>().getMessages(
          currentUid: currentUid,
          chatterUid: context.watch<ChatProvider>().chatId!);
      messagesFromDb
          .sort((prev, curr) => prev.messageDate.compareTo(curr.messageDate));
      messagesFromDb = messagesFromDb;
      var chatMessages = <ChatMessage>[];
      if (!mounted) return false;
      for (Message message in messagesFromDb) {
        chatMessages.add(ChatMessage(
          isSender: message.chatterUid == currentUid,
          isSent: message.isSent,
          isSeen: message.isSeen,
          text: message.content,
          prevDate: prevDate,
          currDate: message.messageDate,
        ));
        prevDate = message.messageDate;
      }
      allMessages = chatMessages.reversed.toList();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    chatterInfo = context.watch<ChatProvider>().userData;
    user = context.watch<AuthProvider>().getUser!;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool pop, Object? result) => {
              context.read<ChatProvider>().chatId = null,
            },
        child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(chatterInfo.profilePic),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                          child: Text(
                        chatterInfo.chatterName.toString(),
                        style: const TextStyle(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  ),
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: Consumer<ChatProvider>(
                          builder: (context, provider, child) {
                        return Stack(
                          children: [
                            FutureBuilder(
                                future: getAllMessages(),
                                builder: (context, snapshot) {
                                  isMessagesLoaded = snapshot.hasData;
                                  if (snapshot.hasData) {
                                    return Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 8.0, top: 8.0),
                                        child: ListView.builder(
                                            itemBuilder: (context, index) {
                                              var isSender =
                                                  allMessages[index].isSender;
                                              return GestureDetector(
                                                onLongPress: () => {
                                                  if (isSender)
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                Colors
                                                                    .blueAccent,
                                                            title: Text(
                                                                locale
                                                                    .chooseAction,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            18)),
                                                            actions: [
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return AlertDialog(
                                                                            title: customTextField(
                                                                                TextEditingController(text: allMessages[index].text),
                                                                                locale.edit,
                                                                                locale.writeAMessage,
                                                                                messagesFromDb[index],
                                                                                index));
                                                                      });
                                                                },
                                                                style: ButtonStyle(
                                                                    backgroundColor:
                                                                        WidgetStateProperty.all(Colors
                                                                            .black),
                                                                    foregroundColor:
                                                                        WidgetStateProperty.all(
                                                                            Colors.white)),
                                                                child: Text(
                                                                  locale.edit,
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return AlertDialog(
                                                                          backgroundColor:
                                                                              Colors.blueAccent,
                                                                          title:
                                                                              Text(
                                                                            locale.deleteMessage,
                                                                            style:
                                                                                const TextStyle(fontSize: 18),
                                                                          ),
                                                                          actions: [
                                                                            ElevatedButton(
                                                                              onPressed: () {
                                                                                var isIndexZero = index == 0;
                                                                                provider.removeFromMessages(
                                                                                  currentUid: user.uid,
                                                                                  chatterUid: chatterInfo.chatterUid,
                                                                                  messageId: messagesFromDb[index].messageUid,
                                                                                  lastMessage: isIndexZero,
                                                                                  messageText: messagesFromDb.length == 1
                                                                                      ? null
                                                                                      : isIndexZero
                                                                                          ? messagesFromDb[1].content
                                                                                          : messagesFromDb[index - 1].content,
                                                                                  messageDate: messagesFromDb.length == 1
                                                                                      ? null
                                                                                      : isIndexZero
                                                                                          ? messagesFromDb[1].messageDate
                                                                                          : messagesFromDb[index - 1].messageDate,
                                                                                );
                                                                                setState(() {
                                                                                  allMessages.removeAt(index);
                                                                                  messagesFromDb.removeAt(index);
                                                                                });
                                                                                Navigator.of(context)
                                                                                  ..pop()
                                                                                  ..pop();
                                                                              },
                                                                              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.black), foregroundColor: WidgetStateProperty.all(Colors.white)),
                                                                              child: Text(
                                                                                locale.yes,
                                                                              ),
                                                                            ),
                                                                            ElevatedButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(context)
                                                                                    ..pop()
                                                                                    ..pop();
                                                                                },
                                                                                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.black), foregroundColor: WidgetStateProperty.all(Colors.white)),
                                                                                child: Text(locale.no)),
                                                                          ],
                                                                        );
                                                                      });
                                                                },
                                                                style: ButtonStyle(
                                                                    backgroundColor:
                                                                        WidgetStateProperty.all(Colors
                                                                            .black),
                                                                    foregroundColor:
                                                                        WidgetStateProperty.all(
                                                                            Colors.white)),
                                                                child: Text(
                                                                  locale.delete,
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        }),
                                                },
                                                child: allMessages[index],
                                              );
                                            },
                                            itemCount: allMessages.length,
                                            padding: const EdgeInsets.only(
                                                bottom: 48),
                                            reverse: true,
                                            shrinkWrap: true),
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                }),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Card(
                                margin: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                elevation: 3,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        minLines: 1,
                                        maxLines: 3,
                                        controller: _textController,
                                        decoration: InputDecoration(
                                          fillColor: Colors.white12,
                                          filled: true,
                                          hintStyle: const TextStyle(
                                              fontSize: 16, height: 1.4),
                                          hintText: "Сообщение",
                                          border: InputBorder.none,
                                          suffixIcon: IconButton(
                                              onPressed: () async {
                                                if (!isMessagesLoaded) return;
                                                setState(() {
                                                  isMessageBeingSent = true;
                                                });
                                                var message = await provider
                                                    .createNewChat(
                                                        messageContent:
                                                            _textController
                                                                .text,
                                                        currentUid: user.uid,
                                                        chatterUid: chatterInfo
                                                            .chatterUid,
                                                        currentPhotoUrl:
                                                            user.photoUrl,
                                                        chatterPhotoUrl:
                                                            chatterInfo
                                                                .profilePic,
                                                        currentName:
                                                            user.username,
                                                        chatterName: chatterInfo
                                                            .chatterName);
                                                if (!context.mounted) return;
                                                if (message != 'Ok') {
                                                  showSnackBar(
                                                      context, message);
                                                }
                                                setState(() {
                                                  isMessageBeingSent = false;
                                                  _textController.text = "";
                                                });
                                                _textController.clear();
                                              },
                                              icon: isMessageBeingSent
                                                  ? const Padding(
                                                      padding:
                                                          EdgeInsets.all(4.0),
                                                      child:
                                                          CircularProgressIndicator(),
                                                    )
                                                  : const Icon(
                                                      Icons.send,
                                                    )),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ))));
  }

  Widget customTextField(TextEditingController controller, String label,
      String hint, Message message, int index) {
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context),
        borderRadius: const BorderRadius.all(Radius.circular(16.0)));
    return TextField(
      onSubmitted: (text) async {
        await context.read<ChatProvider>().updateMessage(
              currentUid: user.uid,
              chatterUid: chatterInfo.chatterUid,
              messageUid: message.messageUid,
              lastMessage: index == 0,
              messageText: text,
            );
        if (!mounted) return;
        setState(() {
          allMessages[index] = ChatMessage(
              isSender: allMessages[index].isSender,
              isSent: allMessages[index].isSent,
              isSeen: allMessages[index].isSeen,
              text: text,
              prevDate: allMessages[index].prevDate,
              currDate: allMessages[index].currDate);
        });
        Navigator.of(context)
          ..pop()
          ..pop();
      },
      decoration: InputDecoration(
        filled: true,
        label: Text(label),
        hintText: hint,
        border: inputBorder,
        fillColor: Colors.white12,
        contentPadding: const EdgeInsets.all(10.0),
      ),
      autofocus: true,
      controller: controller,
    );
  }
}
