import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final Function()? func;
  final bool isExit;
  final String text;
  final int divider;
  final bool isFollow;

  const FollowButton(
      {Key? key,
      this.func,
      this.isExit = false,
      required this.text,
      required this.divider,
      required this.isFollow})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
        padding: const EdgeInsets.only(top: 2),
        child: TextButton(
          onPressed: isExit ? null : func,
          child: Container(
            decoration: BoxDecoration(
              color: isFollow ? Colors.blue : Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            width: width / divider,
            height: 40,
            child: isExit
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: Center(
                        child: CircularProgressIndicator(
                      strokeWidth: 3,
                    )))
                : Text(
                    text,
                    style: TextStyle(
                      color: isFollow ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ));
  }
}
