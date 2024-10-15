import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
import '../../main.dart';
import '../../models/post.dart';
import '../../profile/ui/profile_screen.dart';
import 'like_animation.dart';

class PostCard extends StatefulWidget {
  final Post snap;
  final bool savedScreen;

  const PostCard({super.key, required this.snap, this.savedScreen = false});

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
  Uint8List? imageByteList;

  @override
  void initState() {
    super.initState();
    authProvider = Provider.of(context, listen: false);
    _setPostImage();
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
      message = locale.removedFromFavourite;
    } else {
      message = locale.addedToFavourite;
    }
    if (!mounted) return;
    showSnackBar(context, message);
  }

  Future<ByteData?> getPostImage(http.Client client) async {
    final response = await client.get(Uri.parse(widget.snap.postUrl));
    var originalUnit8List = response.bodyBytes;

    ui.Image originalUiImage = await decodeImageFromList(originalUnit8List);
    ByteData? originalByteData = await originalUiImage.toByteData();
    print('original image ByteData size is ${originalByteData?.lengthInBytes}');

    var codec = await ui.instantiateImageCodec(originalUnit8List,
        targetHeight: 250, targetWidth: 250);
    var frameInfo = await codec.getNextFrame();
    ui.Image targetUiImage = frameInfo.image;

    ByteData? targetByteData =
        await targetUiImage.toByteData(format: ui.ImageByteFormat.png);
    print('target image ByteData size is ${targetByteData?.lengthInBytes}');
    return targetByteData;
  }

  _setPostImage() async {
    ByteData? imageByteData = await getPostImage(http.Client());
    if (!mounted) return;
    setState(() {
      imageByteList = imageByteData?.buffer.asUint8List();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<AuthProvider>(context).getUser!;
    final width = MediaQuery.of(context).size.width;
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                width > webScreenSize ? secondaryColor : borderBackgroundColor,
          ),
          color: borderBackgroundColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: //(FirebaseAuth.instance.currentUser!.uid != widget.snap['uid']) ?
            Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8).copyWith(right: 0),
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
                              fontSize: 16,
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
                                            locale.deletePost,
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
            const SizedBox(
              height: 8,
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
              child: imageByteList != null
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.memory(imageByteList!),
                        // SizedBox(
                        //   // height: MediaQuery.of(context).size.height * 0.35,
                        //   width: double.infinity,
                        //   child: Image.memory(imageByteList!),
                        //   // child: Image.memory(
                        //   //   widget.snap.postUrl,
                        //   // ),
                        // ),
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
                    )
                  : const Placeholder(
                      fallbackWidth: 200,
                      fallbackHeight: 200,
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
                      '${widget.snap.likes.length} ${locale.likes}',
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
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' ${widget.snap.description}',
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width,
                        maxHeight: 36),
                    child: GestureDetector(
                      onTap: () {},
                      child: TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(locale.viewComments(commentLen),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white60,
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
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Text(
                      DateFormat.yMMMd().format(widget.snap.datePublished),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
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
