import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_example/comments/ui/comment_controller.dart';
import 'package:instagram_example/models/user.dart' as model;
import 'package:instagram_example/authentication/ui/auth_provider.dart';
import 'package:instagram_example/comments/ui/comments_screen.dart';
import 'package:instagram_example/posts/ui/posts_controller.dart';
import 'package:instagram_example/utils/colors.dart';
import 'package:instagram_example/utils/global_variables.dart';
import 'package:instagram_example/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/post.dart';
import '../../profile/ui/profile_screen.dart';
import 'like_animation.dart';

class PostCard extends StatefulWidget {
  final Post snap;
  final bool savedScreen;

  const PostCard({Key? key, required this.snap, this.savedScreen = false})
      : super(key: key);

  @override
  PostCardState createState() => PostCardState();
}

class PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLen = 0;
  bool saved = false;
  final postsController = PostsController();
  final _commentController = CommentController();
  late final AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of(context, listen: false);
    getComments();
    getSaved();
  }

  void getSaved() async {
    try {
      var snap = await postsController.getIsPostSaved(widget.snap.postId);
      if (snap != null) {
        saved = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void getComments() async {
    try {
      var length =
          await _commentController.getCommentsCount(widget.snap.postId);
      setState(() {
        commentLen = length;
      });
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, e.toString());
    }
  }

  Future<void> addBookmark(String postId, String uid) async {
    String message = "";
    await postsController.addBookmark(postId, uid, saved);
    if (saved) {
      message = "Removed from Favourite Posts";
    } else {
      message = "Added to Favourite Posts";
    }
    if (!mounted) return;
    showSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<AuthProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color:
                width > webScreenSize ? secondaryColor : mobileBackgroundColor,
          ),
          color: mobileBackgroundColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: //(FirebaseAuth.instance.currentUser!.uid != widget.snap['uid']) ?
            Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
                  .copyWith(right: 0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfileScreen(uid: widget.snap.uid))),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(
                        widget.snap.profileImage,
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.snap.username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
                    if (authProvider.getUserId() == widget.snap.uid)
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                      child: ListView(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shrinkWrap: true,
                                          children: [
                                            'Delete Post',
                                          ]
                                              .map((e) => GestureDetector(
                                                    onTap: () async {
                                                      await postsController
                                                          .deletePost(widget
                                                              .snap.postId);
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        vertical: 12,
                                                        horizontal: 16,
                                                      ),
                                                      child: Text(e),
                                                    ),
                                                  ))
                                              .toList()),
                                    ));
                          },
                          icon: const Icon(Icons.more_vert))
                  ],
                ),
              ),
            ),
            GestureDetector(
              onDoubleTap: () async {
                await postsController.likePost(
                  widget.snap.postId,
                  user.uid,
                  widget.snap.likes,
                );
                setState(() {
                  isLikeAnimating = true;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    child: Image.network(
                      widget.snap.postUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isLikeAnimating ? 1 : 0,
                    child: LikeAnimation(
                      isAnimating: isLikeAnimating,
                      duration: const Duration(
                        milliseconds: 400,
                      ),
                      onEnd: () {
                        setState(() {
                          isLikeAnimating = false;
                        });
                      },
                      child: const Icon(Icons.favorite,
                          color: Colors.white, size: 100),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                LikeAnimation(
                  isAnimating: widget.snap.likes.contains(user.uid),
                  smallLike: true,
                  onEnd: () {},
                  child: IconButton(
                    onPressed: () async {
                      await postsController.likePost(
                        widget.snap.postId,
                        user.uid,
                        widget.snap.likes,
                      );
                    },
                    icon: widget.snap.likes.contains(user.uid)
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : const Icon(Icons.favorite_border),
                  ),
                ),
                IconButton(
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CommentsScreen(
                                  postId: widget.snap.postId,
                                ))),
                    icon: const Icon(
                      Icons.comment_outlined,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.send,
                    )),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: LikeAnimation(
                      isAnimating: saved,
                      smallLike: true,
                      onEnd: () {},
                      child: IconButton(
                        onPressed: () async {
                          await addBookmark(widget.snap.postId, user.uid);
                          if (!mounted) return;
                          setState(() {
                            saved = !saved;
                          });
                        },
                        icon: saved || widget.savedScreen
                            ? const Icon(
                                Icons.bookmark,
                                color: Colors.white70,
                              )
                            : const Icon(Icons.bookmark_border),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontWeight: FontWeight.w800),
                    child: Text(
                      '${widget.snap.likes.length} likes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 8,
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: primaryColor,
                        ),
                        children: [
                          TextSpan(
                            text: widget.snap.username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' ${widget.snap.description}',
                          )
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: TextButton(
                        child: Text("View all $commentLen comments",
                            style: const TextStyle(
                              fontSize: 16,
                              color: secondaryColor,
                            )),
                        onPressed: () => Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => CommentsScreen(
                                      postId: widget.snap.postId,
                                    )))
                            .then((value) => getComments()),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      DateFormat.yMMMd().format(widget.snap.datePublished),
                      style: const TextStyle(
                        fontSize: 16,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
        //  : Container(),
        );
  }
}
