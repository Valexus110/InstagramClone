import 'package:flutter/material.dart';
import 'package:instagram_example/comments/ui/comment_controller.dart';
import 'package:instagram_example/models/comment.dart';
import 'package:instagram_example/utils/colors.dart';
import 'package:instagram_example/comments/widgets/comment_card.dart';
import 'package:instagram_example/models/user.dart';
import 'package:instagram_example/authentication/ui/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../utils/utils.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  CommentsScreenState createState() => CommentsScreenState();
}

class CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentTextController = TextEditingController();
  final CommentController _commentController = CommentController();

  @override
  void dispose() {
    super.dispose();
    _commentTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<AuthProvider>(context).getUser!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(locale.comments),
        centerTitle: false,
      ),
      body: StreamBuilder(
          stream: _commentController.getListOfComments(widget.postId),
          builder: (context, AsyncSnapshot<List<Comment>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => CommentCard(
                      snap: snapshot.data![index],
                    ));
          }),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8),
                  child: TextField(
                    minLines: 2,
                    maxLines: 5,
                    controller: _commentTextController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(fontSize: 14),
                      hintText:locale.commentsAs(user.username),// 'Comment as ${user.username}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  var message = await _commentController.postComment(
                      widget.postId,
                      _commentTextController.text,
                      user.uid,
                      user.username,
                      user.photoUrl);
                  if (!context.mounted) return;
                  if (message != 'Ok') showSnackBar(context, message);
                  setState(() {
                    _commentTextController.text = "";
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Text(
                    locale.post,
                    style: const TextStyle(
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
