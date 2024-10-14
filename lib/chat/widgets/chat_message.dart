import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';

class ChatMessage extends StatelessWidget {
  final bool isSender;
  final bool isSent;
  final bool isSeen;
  final String text;
  final DateTime? prevDate;
  final DateTime currDate;

  const ChatMessage(
      {required this.isSender,
      required this.isSent,
      required this.isSeen,
      required this.text,
      required this.prevDate,
      required this.currDate,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 8,
        ),
        dateLabel(),
        const SizedBox(
          height: 8,
        ),
        BubbleSpecialThree(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 2),
          sent: isSender && isSent,
          seen: isSender && isSeen,
          text: text,
          color: const Color(0xFF1B97F3),
          isSender: isSender,
          textStyle: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget dateLabel() {
    if (prevDate?.day != currDate.day || prevDate?.month != currDate.month) {
      var formattedDate = DateFormat.MMMMd(locale.localeName).format(currDate);
      return Column(children: [
        const SizedBox(
          height: 8,
        ),
        Text(formattedDate),
        const SizedBox(
          height: 8,
        ),
      ]);
    }
    return Container();
  }
}
