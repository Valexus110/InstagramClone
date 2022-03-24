import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final Function()? func;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final String text;
  final int divider;

  const FollowButton(
      {Key? key,
      this.func,
      required this.backgroundColor,
      required this.borderColor,
      required this.textColor,
      required this.text,
      required this.divider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
        padding: const EdgeInsets.only(top: 2),
        child: TextButton(
          onPressed: func,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            width: width / divider,
            height: 27,
          ),
        ));
  }
}
