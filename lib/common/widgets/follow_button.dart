import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final Function()? func;
  final bool isButtonLoading;
  final String text;
  final int divider;
  final bool isFollow;

  const FollowButton(
      {super.key,
      this.func,
      this.isButtonLoading = false,
      required this.text,
      required this.divider,
      required this.isFollow});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
        padding: const EdgeInsets.only(top: 2),
        child: TextButton(
          onPressed: isButtonLoading ? null : func,
          child: Container(
            decoration: BoxDecoration(
              color: isFollow ? Colors.blue : Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            width: width / divider,
            height: 40,
            child: isButtonLoading
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
